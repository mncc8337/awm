local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local cairo = require("lgi").cairo

screen.connect_signal("request::wallpaper", function(s)
    local wallpaper_width = s.geometry.width - beautiful.wibar_width
    local wallpaper_height = s.geometry.height

    beautiful.wallpaper_crop = beautiful.wallpaper_crop or {
        top = 0,
        left = 0,
        bottom = 0,
        right = 0,
    }

    local cropped = gears.surface.crop_surface {
        surface = gears.surface.load_uncached(beautiful.wallpaper),
        ratio = wallpaper_width / wallpaper_height,
        left = beautiful.wallpaper_crop.left,
        right = beautiful.wallpaper_crop.right,
        top = beautiful.wallpaper_crop.top,
        bottom = beautiful.wallpaper_crop.bottom,
    }

    -- scale down the cropped image to waste less RAM
    -- storing the full resolution
    local cropped_width, cropped_height = gears.surface.get_size(cropped)
    local final = cairo.ImageSurface(cairo.Format.ARGB32, wallpaper_width, wallpaper_height)
    local cr = cairo.Context(final)
    cr:scale(wallpaper_width / cropped_width, wallpaper_height / cropped_height)
    cr:set_source_surface(cropped, 0, 0)
    cr.operator = cairo.Operator.SOURCE
    cr:paint()
    cropped:finish()

    awful.wallpaper {
        screen = s,
        widget = {
            widget = wibox.container.margin,
            margins = {
                left = beautiful.wibar_width,
            },
            wibox.widget.imagebox(final),
        }
    }
end)
