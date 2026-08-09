-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Workspaces 1..NUM_WPM pinned to MONITOR1, NUM_WPM+1..NUM_WPM*2 pinned to MONITOR2.
-- This makes m~N ("Nth workspace on focused monitor") work correctly for relative switching.
for i = 1, NUM_WPM do
    hl.workspace_rule({ workspace = tostring(i), monitor = MONITOR1, persistent = true })
end
for i = 1, NUM_WPM do
    hl.workspace_rule({ workspace = tostring(NUM_WPM + i), monitor = MONITOR2, persistent = true })
end
