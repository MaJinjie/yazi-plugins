---@since 25.2.26

---------------------------------- Sync --------------------------------
local S = {}

S.state = ya.sync(function()
  return cx.active.current.cwd
end)

---------------------------------- Config --------------------------------
local script_path = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config")
  .. "/yazi/plugins/grep-files.yazi/script.zsh"
local exit_status = {
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
  ya.notify { title = "Grep Files", content = string.format(s, ...), timeout = 5, level = "error" }
end
---------------------------------- Module --------------------------------
local M = {}

function M:entry(job)
  local args = job.args or {}

  ya.dbg(self.interactive)
  if args.interactive then
    local value, event = H.input()
    if event ~= 1 then
      return
    end
    --- @cast value string
    for arg in value:gmatch("%S+") do
      args[#args + 1] = arg
    end
  end

  local _permit = ya.hide()
  local cwd = tostring(S.state())

  local child, err = Command(script_path)
    :cwd(cwd)
    :args(args)
    :stdin(Command.INHERIT)
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()

  if not child then
    return H.fail("Failed to start `%s`, error: %s", script_path, err)
  end

  local output, err = child:wait_with_output()
  if not output then
    return H.fail("Cannot read output, error: %s", err)
  elseif not output.status.success and exit_status[output.status.code] then
    return H.fail("`fzf` exited with error code %s, %s", output.status.code, exit_status[output.status.code])
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
