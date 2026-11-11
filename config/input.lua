local awful = require("awful")

-- local device_name = "FTCS0038:00 2808:0106 Touchpad"

-- store the touchpad settings locally to change it later via touchpad_toggle
local touchpad_settings = {
    tap_to_click = 1,
    natural_scrolling = 1,
    accel_speed = 0.6,
    scroll_method = "two_finger",
    accel_profile = "flat",
    tap_and_drag = 1,
    drag_lock = 1,
    tap_3fg_drag = 1,
    disable_while_typing = 1,
    click_method = "button_areas",
    send_events_mode = "enabled",
}

local function reload_settings()
    awful.input.rules = {
        {
            rule = { type = "touchpad" },
            properties = touchpad_settings,
        },
        {
            rule = { type = "pointer" },
            -- properties = { natural_scrolling = 0, accel_profile = "flat" },
        },
    }
end

-- TODO: move these to signal/touchpad.lua
local naughty = require("naughty")
local function touchpad_toggle()
    if touchpad_settings.send_events_mode == "enabled" then
        touchpad_settings.send_events_mode = "disabled"
    elseif touchpad_settings.send_events_mode == "disabled" then
        touchpad_settings.send_events_mode = "enabled"
    else return end -- "disabled_on_external_mouse"
    -- NOTE:
    -- according to somewm docs, assigning rules will reload rules across devices
    -- so this would cause a full rules reload, abeit we only change the touchpad settings
    -- this is the only way to easily toggle the touchpad in somewm though
    reload_settings()
    naughty.notification {
        message = ("touchpad is <b>%s</b>").format(touchpad_settings.send_events_mode)
    }
end

awesome.connect_signal("touchpad::toggle", touchpad_toggle)

reload_settings()
