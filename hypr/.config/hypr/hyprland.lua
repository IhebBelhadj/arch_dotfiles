-- Hyprland loads this file when it is started without a config, and it prefers
-- it over hyprland.conf. HyDE loads it too, last, as the override layer below.
-- The block keeps the two apart: hyde.lua sets `hyde` on its first line, so it
-- runs only when this file is the entry point and HyDE has not been loaded.
-- Removing it leaves a session with a cursor and nothing else.
if not hyde then
	local share = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
	local entry = share .. "/hypr/hyde.lua"
	local handle = io.open(entry, "r")
	if not handle then
		error("HyDE is not installed at " .. entry .. ". Run install.sh -r, or point Hyprland at your own config.")
	end
	handle:close()
	dofile(entry)
end

-- Your Hyprland configuration. HyDE never overwrites this file.
--
-- It loads after HyDE's own binds, so settings here take precedence. Replacing
-- a bind needs more than that: see below. HyDE's defaults live in
-- ~/.local/share/hypr/lua/ and are overwritten on every update, so edits there
-- do not survive.
--
-- Adding a keybind:
--
--     hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(hyde.sh.gamelauncher()), {
--         description = "[Utilities] game launcher",
--     })
--
-- Replacing one of HyDE's: bind the same combination again and yours takes
-- over, but copy its flags across as well. A bind counts as the same one only
-- when its flags match, and `description` is not a flag — miss one and both
-- binds stay live on that combination. Copy the whole options table from
-- ~/.local/share/hypr/lua/key_binds.lua and change only what you need:
--
--     hl.bind("F9", hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "m")), {
--         locked = true,
--         description = "[Hardware Controls|Audio] un/mute output",
--     })
--
-- Press SUPER + / to see what is actually loaded, your own binds included.
-- The full reference is KEYBINDINGS.md in the HyDE repository.
--
-- Other Lua files next to this one can be pulled in with require("name").

-- Display scale. Hyprland's "auto" picks 1.5 for this panel (a 1280x720 logical
-- desktop, drawn large). 1.25 gives a 1536x864 logical desktop -- both integers,
-- so there is no rounding. Set scale = 1 for native 1:1.
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1.25 })

-- Scroll direction. `natural_scroll` is the only knob that controls direction
-- ("Inverts scrolling direction" per the Hyprland schema):
--   false = traditional  -- fingers/wheel down scrolls the page down
--   true  = natural/mac  -- fingers down drags the content down
-- `scroll_factor` is only a speed multiplier, not a direction control; the -1
-- that `hyprctl devices` reports for an unconfigured device is its
-- "inherit the global value" sentinel, not an inversion.
--
-- The mouse wheel stays traditional; the touchpad scrolls naturally.
-- scroll_method: "2fg" (two fingers), "edge", "on_button_down" or "no_scroll".
hl.config({
	input = {
		natural_scroll = false,
		scroll_method = "2fg",
		touchpad = {
			natural_scroll = true,
			-- Speed multiplier (default 1.0); lower is slower and more precise.
			scroll_factor = 1.0,
		},
	},
})

-- Swap Caps Lock and Escape. Both directions: Caps acts as Escape and Escape
-- acts as Caps Lock. Use "caps:escape" instead to only remap Caps, leaving
-- Escape alone.
hl.config({
	input = {
		kb_options = "caps:swapescape",
	},
})

-- Maximize, and focus that carries the maximize with it.
--
-- SUPER + M maximizes the focused window: Hyprland's fullscreen *state 1*,
-- which fills the workspace but still honours gaps and the space waybar
-- reserves -- not state 2, the real edge-to-edge fullscreen. Pressing it again
-- puts the window back in its tiled slot.
--
-- SUPER + H/J/K/L moves focus, and while a window is maximized the maximized
-- slot travels with it. The extra handling is needed because Hyprland picks
-- the neighbour from window geometry: a maximized window covers the whole
-- monitor, so nothing is ever found in any direction and a plain movefocus is
-- a no-op. Dropping the maximize first restores every window's tiled box,
-- which makes the direction meaningful again. When focus does not move --
-- nothing that way -- the same window is re-maximized and nothing changes.

local MOD = hyde.config.modifiers.main
local MAXIMIZED = 1

local function set_fullscreen(win, state)
	hl.dispatch(hl.dsp.window.fullscreen_state({ internal = state, client = state, window = win }))
end

local function is_maximized(win)
	return win ~= nil and (tonumber(win.fullscreen) or 0) == MAXIMIZED
end

local function toggle_maximize()
	local win = hl.get_active_window()
	if not win then
		return
	end
	set_fullscreen(win, is_maximized(win) and 0 or MAXIMIZED)
end

local function focus(direction)
	return function()
		local win = hl.get_active_window()
		if not is_maximized(win) then
			hl.dispatch(hl.dsp.focus({ direction = direction }))
			return
		end
		set_fullscreen(win, 0)
		hl.dispatch(hl.dsp.focus({ direction = direction }))
		set_fullscreen(hl.get_active_window(), MAXIMIZED)
	end
end

-- HyDE already owns SUPER + J/K/L. Re-binding a combination only displaces the
-- original when the *flags* match too, and SUPER + K carries `locked = true`,
-- so a plain re-bind would leave both live on that key. Dropping every
-- registered variant of the combination first avoids having to mirror flags.
local function unbind(combo)
	local prefix = hyde.binds.canonicalize(combo) .. "|"
	for id, registered in pairs(hyde.binds._active) do
		if id:sub(1, #prefix) == prefix then
			hl.unbind(registered)
			hyde.binds._active[id] = nil
		end
	end
end

for _, combo in ipairs({ MOD .. " + J", MOD .. " + K", MOD .. " + L" }) do
	unbind(combo)
end

hl.bind(MOD .. " + M", toggle_maximize, { description = "[Window Management] toggle maximize" })
hl.bind(MOD .. " + H", focus("l"), { description = "[Window Management|Change focus] focus left" })
hl.bind(MOD .. " + J", focus("d"), { description = "[Window Management|Change focus] focus down" })
hl.bind(MOD .. " + K", focus("u"), { description = "[Window Management|Change focus] focus up" })
hl.bind(MOD .. " + L", focus("r"), { description = "[Window Management|Change focus] focus right" })

-- The three HyDE binds the block above displaced, given new homes. The layout
-- switch goes to ALT rather than SHIFT because SUPER + SHIFT + K is already
-- HyDE's rofi calculator.
hl.bind(MOD .. " + SHIFT + L", hl.dsp.exec_cmd(hyde.sh.session.lock()), {
	description = "[Window Management] lock session",
})
hl.bind(MOD .. " + SHIFT + J", hl.dsp.layout("togglesplit"), {
	description = "[Layout Management|Dwindle] toggle split",
})
hl.bind(MOD .. " + ALT + K", hl.dsp.exec_cmd(hyde.sh.kb.switch()), {
	locked = true,
	description = "[Utilities] toggle keyboard layout",
})

-- The active HyDE theme, as compiled into Lua by `hyde-shell theme.switch`.
-- Read here so the overrides below can defer to themes that set their own
-- values. pcall keeps a missing state file from taking the config down.
local theme_ok, theme = pcall(require, "lua_state.hypr_theme")
theme = theme_ok and type(theme) == "table" and theme or {}
local theme_decoration = theme.decoration or {}

-- No fade on unfocused windows. HyDE's default drops them to 0.75 while the
-- focused one sits at 0.90; matching inactive to whatever active is keeps
-- every window at the same opacity whether it has focus or not, including
-- under themes that pick their own active opacity.
hl.config({
	decoration = {
		inactive_opacity = theme_decoration.active_opacity or 0.90,
	},
})

-- Focus indication through border colour. HyDE derives both borders from the
-- wallpaper palette, which on a greyscale wallpaper leaves the focused window
-- barely distinguishable from the rest. This file loads after HyDE's
-- dynamic.lua, so these fixed colours win over the wallbash ones. Themes
-- listed here were designed around their own focus border and keep it.
local KEEP_THEME_BORDERS = { ["Dev Focus"] = true }

local function current_theme()
	local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
	local handle = io.open(state .. "/hyde/staterc", "r")
	if not handle then
		return nil
	end
	local name
	for line in handle:lines() do
		name = line:match('^HYDE_THEME="(.*)"$') or name
	end
	handle:close()
	return name
end

if not KEEP_THEME_BORDERS[current_theme() or ""] then
	hl.config({
		general = {
			col = {
				active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
				inactive_border = { colors = { "rgba(404040aa)" }, angle = 45 },
			},
		},
	})
end

-- Display mode switcher, Win+P style: laptop only, duplicate, extend or
-- external only. SUPER + P is HyDE's screenshot snip, so the menu lives on
-- SUPER + O, plus the laptop's own display-switch key where it has one.
-- display_mode.lua reapplies the saved choice on every config load.
require("display_mode")

hl.bind(MOD .. " + O", hl.dsp.exec_cmd("display-mode"), {
	description = "[Utilities] display mode (laptop / duplicate / extend / external)",
})
hl.bind("XF86Display", hl.dsp.exec_cmd("display-mode"), {
	description = "[Utilities] display mode (laptop / duplicate / extend / external)",
})
