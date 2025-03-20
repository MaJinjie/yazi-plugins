---@since 25.2.26

---------------------------------- Sync --------------------------------
local S = {}

S.state = ya.sync(function()
  return cx.active.current.cwd
end)

---------------------------------- Config --------------------------------
local script_path = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config")
  .. "/yazi/plugins/find-files.yazi/fd.sh"

---------------------------------- Util --------------------------------
local H = {}

function H.input()
  return ya.input({
    title = "Fd Args:",
    position = { "center", w = 50 },
  })
end

function H.fail(s, ...)
  ya.notify { title = "Find Files", content = string.format(s, ...), timeout = 5, level = "error" }
end
---------------------------------- Module --------------------------------
local M = {}

function M:entry(job)
  local args = job.args or {}

  ya.dbg(debug)
  if args.interactive then
    local value, event = H.input()
    if event ~= 1 then
      return
    end
    table.remove(args, 1)
    --- @cast value string
    for arg in value:gmatch("%S+") do
      args[#args + 1] = arg
    end
  end

  local _permit = ya.hide()
  local cwd = tostring(S.state())

  local fd, err = Command("fd")
    :cwd(cwd)
    :args(config.default_fd_args)
    :args(args)
    :stdin(Command.INHERIT)
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()

  if not fd then
    return H.fail("Failed to start `fd`, error: %s", err)
  end

  local fzf, err = Command("fzf")
    :cwd(cwd)
    :args(config.default_fzf_args)
    :stdin(fd:take_stdout())
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()

  if not fzf then
    return H.fail("Failed to start `fzf`, error: %s", err)
  end

  local output, err = fzf:wait_with_output()
  if not output then
    return H.fail("Cannot read `fzf` output, error: %s", err)
  elseif not output.status.success and output.status.code ~= 130 then
    return H.fail("`fzf` exited with error code %s", output.status.code)
  end

  local lines = {}
  for line in output.stdout:gmatch("[^\r\n]+") do
    lines[#lines + 1] = line
  end

  if #lines >= 2 then
    if lines[1] == "enter" then
      local cmd = "$EDITOR"
      for i = 2, #lines do
        cmd = cmd .. " " .. ya.quote(lines[i])
      end
      ya.mgr_emit("shell", { cmd, orphan = true, block = true })
    elseif lines[1] == "alt-enter" then
      ya.mgr_emit(lines[2]:find("[/\\]$") and "cd" or "reveal", { lines[2] })
    end
  end
end

return M
