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

-- Traditional (non-reversed) scrolling. Both pointer devices come up with a
-- scroll factor of -1, which inverts the direction; 1.0 restores it.
hl.config({
	input = {
		natural_scroll = false,
		scroll_factor = 1.0,
		touchpad = { natural_scroll = false, scroll_factor = 1.0 },
	},
})

hl.device({ name = "elan0718:00-04f3:30fd-touchpad", natural_scroll = false, scroll_factor = 1.0 })
hl.device({ name = "elan0718:00-04f3:30fd-mouse", natural_scroll = false, scroll_factor = 1.0 })

-- Swap Caps Lock and Escape. Both directions: Caps acts as Escape and Escape
-- acts as Caps Lock. Use "caps:escape" instead to only remap Caps, leaving
-- Escape alone.
hl.config({
	input = {
		kb_options = "caps:swapescape",
	},
})
