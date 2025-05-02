---@since 25.2.26

---------------------------------- Sync --------------------------------
local S = {}

S.state = ya.sync(function()
	return cx.active.current.cwd
end)

---------------------------------- Config --------------------------------
local SCRIPT_CONTENT = [=[
#!/usr/bin/zsh

export TEMP
export -UT RG_ARGS rg_args 

TEMP=$(mktemp -u)
trap 'rm -rf $TEMP' EXIT

rg_args=( "--column" "--line-number" "--no-heading" "--color=always" "--smart-case" ${(Q)${(z)1}} )

TRANSFORMER='
  local left right
  local rg_pat fzf_pat
  local -UT RG_ARGS rg_args

  if [[ $FZF_QUERY =~ ^(.*)\ --\ (.*)$ ]]; then
    left=$match[1]
    right=$match[2]
  else
    left=$FZF_QUERY
  fi

  if [[ $left =~ ([^[:space:]]+)(.*) ]]; then
    rg_pat=$match[1]
    fzf_pat=$match[2]
  fi

  if [[ -n $right ]]; then
    rg_args+=( ${(z)right} )
  fi

  if ! [[ -r $TEMP && "$rg_pat $RG_ARGS" == $(<$TEMP) ]]; then
    echo "$rg_pat $RG_ARGS" > $TEMP
    printf "reload:sleep 0.1; command rg %q %s || true" "$rg_pat" "$rg_args"
  fi
  echo "+search:$fzf_pat"
'

:|fzf \
  --disabled \
  --delimiter ':' \
  --multi \
  --ansi \
  --style=full \
  --height=100% \
  --expect=enter,alt-enter \
  --with-nth '{1..3} {4..}' \
  --accept-nth '{1..3}' \
  --preview='bat --color=always --number --highlight-line {2} -- {1}' \
  --preview-window='up,35%,+{2}/2' \
  --bind='focus:transform-preview-label:((FZF_POS)) && echo \ {1}\ ' \
  --bind="change:transform:$TRANSFORMER" \
  ${(Q)${(z)2}}
]=]
local EXIT_MESSAGE = {
	-- [0] = "Normal exit",
	-- [1] = "No match",
	[2] = "Error",
	[126] = "Permission denied error from become action",
	[127] = "Invalid shell command for become action",
	[128] = "Interrupted with CTRL-C or ESC",
}
local key_actions = {
	["enter"] = function(...)
		local cmd = "$EDITOR"
		for i = 1, select("#", ...) do
			local file = select(i, ...)
			cmd = cmd .. " " .. ya.quote(file)
		end
		ya.mgr_emit("shell", { cmd, orphan = true, block = true })
	end,
	["alt-enter"] = function(target)
		ya.mgr_emit(target:find("[/\\]$") and "cd" or "reveal", { target })
	end,
}

---------------------------------- Util --------------------------------
local H = {}

function H.input()
	return ya.input({
		title = "Rg Args:",
		position = { "center", w = 50 },
	})
end

function H.fail(s, ...)
	ya.notify({ title = "Grep Files", content = string.format(s, ...), timeout = 5, level = "error" })
end
---------------------------------- Module --------------------------------
local M = {}

function M:entry(job)
	local args = job.args or {}

	local interactive_args = ""
	if args.interactive then
		local value, event = H.input()
		if event ~= 1 then
			return
		end
		interactive_args = value
	end

	local _permit = ya.hide()
	local cwd = tostring(S.state())

	local child, err = Command("zsh")
		:cwd(cwd)
		:args({ "-c", SCRIPT_CONTENT, "-" })
		:arg((args["extra-rg-args"] or "") .. " " .. interactive_args)
		:arg(args["extra-fzf-args"] or "")
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return H.fail("Failed to start `zsh`, error: %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return H.fail("Cannot read output, error: %s", err)
	elseif not output.status.success and EXIT_MESSAGE[output.status.code] then
		return H.fail("`fzf` exited with error code %s, %s", output.status.code, EXIT_MESSAGE[output.status.code])
	end

	local files = {}
	for file in output.stdout:gmatch("[^\r\n]+") do
		table.insert(files, file:match("^(.-):%d") or file)
	end

	local key = files[1]
	if key and key_actions[key] and #files > 1 then
		table.insert(files, "+" .. output.stdout:match(":(%d+):"))
		key_actions[key](table.unpack(files, 2))
	end
end

return M
