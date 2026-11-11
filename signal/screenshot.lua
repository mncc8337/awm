-- signals
--[[
    CALL
    screenshot::full
    screenshot::area
--]]

-- dependency: maim + slop + xclip / grim + slurp + wl-clipboard
-- needs the .bin/screenshot script
-- TODO: rewrite this using awful.screenshot to remove the above deps

local awful = require("awful")

-- local save_dir = "$HOME/Pictures/"
-- local save_format = "%Y-%m-%d_%H-%M-%S.png"

awesome.connect_signal("screenshot::full", function(save)
    local cmd = "screenshot"
    if save then
        cmd = cmd .. " save"
    end
    awful.spawn.with_shell(cmd)
end)

awesome.connect_signal("screenshot::area", function(save)
    local cmd = "screenshot area"
    if save then
        cmd = cmd .. " save"
    end
    awful.spawn.with_shell(cmd)
end)
