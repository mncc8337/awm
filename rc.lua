local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- error handling
-- check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message = message
    }
end)

awful.spawn.with_shell(". ~/.autostart")

-- set up theme
-- local colorscheme = require("theme.colorscheme.dynamic")
-- colorscheme.tint("#dd716f", 0.4)
-- colorscheme.tint("#cac7ff", 0.9)
-- colorscheme.tint("#d1edff", 0.9)
local colorscheme = require("theme.colorscheme.gruvbox")

local theme = require("theme")
theme.set_colorscheme(colorscheme)
theme.build()
theme.save_json_config()

-- run this after changing theme
-- theme.build_gtk_theme()

theme.wallpaper = theme.wallpaper_path .. "IMG_0795.JPG"
theme.wallpaper_crop = {
    top = 0,
    left = 0,
    bottom = 0,
    right = 0,
}

beautiful.init(theme)

-- global vars
MODKEY = "Mod4"
ALTKEY = "Mod1"
TERMINAL = "tym"
FILEMAN = "nemo"
APPLAUNCHER = "rofi -show drun"
PROMPTRUNNER = "rofi -show run"
SETUPDISPLAY = "" -- "arandr"

-- declare signal services
-- require("signal.touchpad")
require("signal.battery")
require("signal.backlight")
require("signal.playerctl")
require("signal.screenshot")
require("signal.pulseaudio")

-- some ideapad specific features
require("signal.ideapad")
awesome.connect_signal("ideapad::current_profile", function(prof)
    naughty.notification {
        message = "current power profile is <b>" .. prof .. "</b>"
    }
end)

awesome.connect_signal("battery::alarm", function()
    naughty.notification {
        title = "system",
        message = "battery level is below healthy limit, please recharge",
        urgency = "critical",
        timeout = 0,
    }
end)

require("config")
require("ui")

-- TODO: move these to ui/
require("lockscreen").init()

awesome.set_idle_timeout("display-off", 300, function()
    awesome.dpms_off()
end)

awesome.set_idle_timeout("lock", 900, function()
    awesome.lock()
end)

require("ui.widget.popup")
-- require("ui.widget.controlpanel")

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:activate { context = "mouse_enter", raise = false }
-- end)

-- Inhibit idle while presenting / watching a long video. Combines with
-- protocol-level inhibitors (mpv, browsers); see awesome.idle_inhibited
-- for the OR'd state.
-- awful.keyboard.append_global_keybindings({ awful.key {
--     modifiers = { modkey, "Shift" }, key = "i",
--     on_press = function() awesome.idle_inhibit = not awesome.idle_inhibit end,
--     description = "toggle idle inhibit", group = "awesome",
-- } })

-- store/restore geometry of floating clients
client.connect_signal("property::floating", function(c)
    -- this signal is fired before the actual geometry change
    if not c.floating then
        -- save last floating geometry
        c.stored_floating_geometry = {
            x = c.x,
            y = c.y,
            width = c.width,
            height = c.height,
        }
    elseif c.stored_floating_geometry and not c.maximized and not c.fullscreen then
        c.x = c.stored_floating_geometry.x
        c.y = c.stored_floating_geometry.y
        c.width = c.stored_floating_geometry.width
        c.height = c.stored_floating_geometry.height
    end
end)

-- maximized/fullscreen clients fixes
-- idk if the default config has these issue
-- because doing manual positioning is pita

local function geometry_fix(c, type)
    local wibar = awful.screen.focused().wibar

    -- c.fullscreen and c.maximized should be mutual exclusive
    if c.fullscreen and c.maximized then
        if wibar.visible then
            -- if wibar is visible then fullscreen will have higher priority than maximize
            -- and the client should revert to maximize state after un-fullscreening
            c.maximized = false

            if type == "fullscreen" then
                -- save state
                c.previously_maximized = true
            end
        else
            -- if wibar is not visible then fullscreen is the same as maximize
            -- so if only one is activated previously
            -- then activating either of them after that should deactivate both
            c.fullscreen = false
            c.maximized = false
        end
        return
    end

    -- now we are just dealing with either fullscreened or maximized, not both

    if c.maximized or c.fullscreen then
        -- hide titlebar
        awful.titlebar.hide(c)
        c.titlebar_hidden = true
        -- also hide border width. this also fix the client wrong size for some reason??
        c.border_width = 0
    elseif not c.maximized and not c.fullscreen then
        if c.previously_maximized then
            -- restore previous state
            c.maximized = true
            c.previously_maximized = false
        elseif c.titlebar_hidden then
            -- undo all the thing above
            awful.titlebar.show(c)
            c.titlebar_hidden = false
            c.border_width = beautiful.border_width
        end
    end
end
client.connect_signal("property::maximized", function(c) geometry_fix(c, "maximize") end)
client.connect_signal("property::fullscreen", function(c) geometry_fix(c, "fullscreen") end)

client.connect_signal("request::manage", function(c)
    -- -- fix weird position of already maximized/fullscreened clients when spawn
    -- -- just found out that my weird global placement rules causes this (see config/rules.lua)
    -- if c.maximized then
    --     c.maximized = false
    --     c.maximized = true
    -- end
    -- if c.fullscreen then
    --     c.fullscreen = false
    --     -- remind that its border exists
    --     c.border_width = beautiful.border_width
    --     c.fullscreen = true
    -- end
    -- ^ does not happended anymore, just keep it here incase it happended again

    -- save geometry of existed floating clients
    if c.floating then
        local previous_maximized = c.maximized
        local previous_fullscreen = c.fullscreen

        -- turn off maximize/fullscreen to get the real geometry
        if c.maximized then c.maximized = false end
        if c.fullscreen then c.fullscreen = false end

        -- toggle floating to trigger the property::floating signal
        c.floating = false
        c.floating = true

        c.maximized = previous_maximized
        c.fullscreen = previous_fullscreen
    end
end)
