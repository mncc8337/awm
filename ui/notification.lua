local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

naughty.connect_signal("request::display", function(n)
    local msg_box = wibox.widget {
        widget = wibox.container.background,
        bg = beautiful.bg[2],
        {
            widget = wibox.container.margin,
            margins = beautiful.common_padding,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget = naughty.widget.title,
                    halign = "center",
                    valign = "center",
                },
                {
                    widget = naughty.widget.message,
                    halign = "center",
                    valign = "center",
                }
            }
        }
    }

    local action_list = {
        widget = naughty.list.actions,
        base_layout = wibox.widget {
            layout = wibox.layout.flex.horizontal,
            spacing = beautiful.common_padding
        },
        widget_template = {
            widget = wibox.container.margin,
            top = beautiful.common_padding,
            {
                widget = wibox.container.background,
                bg = beautiful.bg[2],
                {
                    widget = wibox.container.margin,
                    margins = beautiful.common_padding,
                    {
                        widget = wibox.container.constraint,
                        strategy = "min",
                        width = beautiful.notification_minimum_action_width,
                        {
                            widget = wibox.widget.textbox,
                            id = "text_role",
                            halign = "center",
                            ellipsize = "none",
                            wrap = "word",
                            justify = true
                        }
                    }
                }
            }
        }
    }

    local notif = naughty.layout.box {
        notification = n,
        widget_template = wibox.widget {
            widget = wibox.container.margin,
            margins = beautiful.notification_margin,
            wibox.widget {
                layout = wibox.layout.fixed.vertical,
                wibox.widget {
                    layout = wibox.layout.align.horizontal,
                    naughty.widget.icon,
                    msg_box,
                    nil,
                },
                action_list
            }
        }
    }

    if #n.actions > 0 then
        n.timeout = 0
    end

    local function destroy_notif()
        -- if #n.actions > 0 then return end
        n:destroy()
    end

    -- why replace the built-in events?
    -- awful.title buttons will toggle if they detect mouse release event on them
    -- notifications are closed when receive mouse press event on them
    -- if you press mouse on a notification which is on top of those buttons
    -- you will unintentionally release mouse on top of the buttons, then the buttons will toggle,
    -- causing bugs like client close after click of notification, etc...
    -- by destroying notification AFTER releasing mouse, titlebar buttons will not receive the mouse release event,
    -- so they will not toggle unexpected
    notif.buttons = {
        awful.button({}, "1", nil, destroy_notif),
        awful.button({}, "3", nil, destroy_notif)
    }
end)
