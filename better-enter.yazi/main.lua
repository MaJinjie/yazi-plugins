---@since 25.2.26
---@sync entry

--- @class Yazi.ctx
--- @field file? yazi.File

---------------------------------- Config --------------------------------
local list = { "enter_or_open" } --- @type string[]
local map = {} --- @type table<string, fun(self: any, ctx: Yazi.ctx):boolean>

function map:enter_or_open(ctx)
  local file = ctx.file
  if file then
    ya.mgr_emit(file.cha.is_dir and "cd" or "open", { tostring(file.url), hovered = true })
  end
  return true
end

---------------------------------- Util --------------------------------

---------------------------------- Module --------------------------------
local M = {}

function M:entry(job)
  local args = job.args or {}
  local ctx = {
    file = args[1] or cx.active.current.hovered,
  }
  for _, nm in ipairs(self.list or list) do
    local cb = map[nm]
    if cb and cb(self, ctx) then
      break
    end
  end
end

function M:setup(opts)
  opts = opts or {}

  list = opts.list or list
  for k, v in pairs(opts.map) do
    map[k] = v
  end
end

return M
