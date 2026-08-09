-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = "MONITOR1",
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

hl.monitor({
    output    = MONITOR1,
    mode      = "2560x1440@165",
    position  = "0x0",
    scale     = "1",
})

hl.monitor({
    output    = MONITOR2,
    mode      = "2560x1440@145",
    position  = "0x1440",
    scale     = "1",
})
