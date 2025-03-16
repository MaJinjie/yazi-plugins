---@since 25.2.26
---------------------------------- Sync --------------------------------
local S = {}

--- Check if the file under the cursor is part of the previous selection.
S.hovered_is_selected = ya.sync(function()
  local c = cx.active.current
  local file = c.files[c.cursor + 1]
  return file and file:is_selected() or false
end)

--- Get the current mode.
S.get_mode = ya.sync(function()
  local mode = cx.active.mode
  return {
    is_select = mode.is_select,
    is_unset = mode.is_unset,
    is_visual = mode.is_visual,
  }
end)

---------------------------------- Module --------------------------------

local M = {}

---@param job {args:{[1]: "select"|"unset"|"escape"}}
function M:entry(job)
  local action = job.args[1] or "select"
  local mode = S.get_mode()

  if action == "escape" then
    if mode.is_visual then
      ya.mgr_emit("visual_mode", { unset = not S.hovered_is_selected() })
      ya.mgr_emit("escape", { visual = true })
    else
      ya.mgr_emit("escape", {})
    end
  else
    local is_eq = mode["is_" .. action]
    if is_eq then
      ya.mgr_emit("escape", { visual = true })
    else
      ya.mgr_emit("visual_mode", { unset = action == "unset" })
    end
  end
end

return M
