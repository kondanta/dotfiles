local MONITOR1  = "DP-2"
local MONITOR2  = "HDMI-A-1"
local NUM_WPM   = 10   -- must be 10 to align with Caelestia's wsaction group-of-10 logic

-- Monitor layout: DP-2 on top, HDMI-A-1 below
hl.monitor({
    output   = MONITOR1,
    mode     = "2560x1440@165",
    position = "0x0",
    scale    = 1,
})
hl.monitor({
    output   = MONITOR2,
    mode     = "2560x1440@120",
    position = "0x1440",
    scale    = 1,
})

-- Workspace pinning: 1–10 on MONITOR1, 11–20 on MONITOR2
for i = 1, NUM_WPM do
    hl.workspace_rule({ workspace = tostring(i),           monitor = MONITOR1, persistent = true })
    hl.workspace_rule({ workspace = tostring(NUM_WPM + i), monitor = MONITOR2, persistent = true })
end

-- Layout toggle (scrolling <-> dwindle)
local useScrolling = true
hl.bind("SUPER + SHIFT + Space", function()
    useScrolling = not useScrolling
    hl.config({ general = { layout = useScrolling and "scrolling" or "dwindle" } })
end)

-- Audio sink switching
hl.bind("SUPER + CTRL + I", hl.dsp.exec_cmd("/usr/local/bin/audio-switch iems"))
hl.bind("SUPER + CTRL + P", hl.dsp.exec_cmd("/usr/local/bin/audio-switch speakers"))
