-- Display mode (Win+P style), applied on every config load.
--
-- `display-mode` (~/.local/bin) writes the chosen mode and the detected
-- output names to the state file below and reloads Hyprland; this module
-- turns them into monitor rules. Keeping the mode here instead of applying
-- it once through hyprctl means reloads -- theme switches, config saves --
-- do not quietly fall back to extend.
--
--   pc         laptop panel only, external disabled
--   duplicate  external mirrors the laptop panel
--   extend     no extra rules: the layout from hyprland.lua applies
--   second     external only, laptop panel disabled
--
-- The laptop panel is only ever disabled while the external output is
-- physically connected, read from DRM rather than from Hyprland, which does
-- not list outputs it has disabled. Unplugging the external screen in
-- "second" mode reloads the config, and the guard then keeps the panel on,
-- so the session can never be left without a lit screen.

local state_dir = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local STATE_FILE = state_dir .. "/hyde/display_mode"

local function read_state()
	local handle = io.open(STATE_FILE, "r")
	if not handle then
		return nil
	end
	local state = {}
	for line in handle:lines() do
		local key, value = line:match("^(%w+)=(.*)$")
		if key then
			state[key] = value
		end
	end
	handle:close()
	return state
end

local function is_connected(output)
	local pipe = io.popen("cat /sys/class/drm/card*-" .. output .. "/status 2>/dev/null")
	if not pipe then
		return false
	end
	local status = pipe:read("*a") or ""
	pipe:close()
	return status:find("^connected") ~= nil
end

local state = read_state()
if not state or not state.external or state.external == "" then
	return
end

local mode, internal, external = state.mode, state.internal, state.external

if mode == "pc" then
	hl.monitor({ output = external, disabled = true })
elseif mode == "duplicate" then
	hl.monitor({ output = external, mode = "preferred", position = "auto", scale = 1, mirror = internal })
elseif mode == "second" then
	if is_connected(external) then
		hl.monitor({ output = internal, disabled = true })
	end
	hl.on("monitor.removed", function()
		hl.exec_cmd("hyprctl reload")
	end)
end
