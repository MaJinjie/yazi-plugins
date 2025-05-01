---@since 25.2.26
---------------------------------- Sync --------------------------------
local S = {}

S.get_pref = ya.sync(function()
	local pref = cx.active.pref
	return {
		show_hidden = pref.show_hidden,
	}
end)

S.find_directory = ya.sync(function(_, fallback)
	local c = cx.active.current
	local h = cx.active.current.hovered

	local function find_range(s, e)
		for i = s, e do
			local file = c.files[i]
			if file.cha.is_dir then
				return file
			end
		end
	end
	local function exec()
		if h and h.cha.is_dir then
			return h
		end
		return find_range(c.cursor + 1, #c.files) or find_range(1, c.cursor)
	end

	local ret = exec() or (fallback and h) or nil
	return ret and { url = ret.url, is_dir = ret.cha.is_dir }
end)

---------------------------------- Util --------------------------------
local H = {}

function H.input(value)
	return ya.input({
		title = "Better Filter:",
		position = { "center", w = 30 },
		realtime = true,
		debounce = 0.1,
		value = value,
	})
end

---@param value string
function H.parse_input(value)
	return value:gsub("%s*/$", ""):gsub("%.", "\\."):gsub("%s+", ".*")
end

-- 将|cur_pref | cx.current.pref|还原为|old_pref|
function H.set_pref(old_pref, cur_pref)
	cur_pref = cur_pref or S.get_pref()

	local function neq(field)
		return old_pref[field] ~= cur_pref[field]
	end

	if neq("show_hidden") then
		ya.mgr_emit("hidden", { toggle = true })
	end
end

function H.escape(filter)
	ya.mgr_emit("escape", { filter = filter, find = true })
end

---------------------------------- Module --------------------------------
local M = {}

function M:entry()
	local pref = S.get_pref()
	local input = H.input()
	local last_event
	--- @cast input -string

	while true do
		local value, event = input:recv()
		last_event = event

		if event == 0 or event == 2 then
			H.escape(true)
			break
		end
		--- @cast value -?
		--- @diagnostic disable-next-line: redefined-local
		local pref = S.get_pref()
		local query = H.parse_input(value)

		H.set_pref({
			show_hidden = value:match("^%.") ~= nil,
		}, pref)
		ya.mgr_emit("filter_do", { query, smart = true })
		ya.mgr_emit("find_do", { query, smart = true })

		if event == 1 then
			H.escape(false)
			break
		end

		if value:match("/$") then
			local obj = S.find_directory()
			if obj then
				H.escape(true)
				ya.mgr_emit("cd", { obj.url })
				input = H.input()
			else
				input = H.input(value:gsub("%s*/", ""))
				ya.notify({ title = "better-filter", level = "warn", content = "Not Found Directory!", timeout = 1 })
			end
		end
	end

	if last_event ~= 1 then
		-- restore pref
		H.set_pref(pref)
	end
end

return M
