-- Reload config when any .lua file in this directory changes
local function reloadConfig(files)
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            hs.reload()
            return
        end
    end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")


-- ── Constants ─────────────────────────────────────────────────────────────────

-- CapsLock is remapped to Ctrl+Opt+Cmd by the Hyperkey app.
local HYPER = {"ctrl", "alt", "cmd"}

-- Screens narrower than this (logical points) are treated as the laptop screen.
-- MacBook Pro reports 1920px; external monitors are typically 2560px+.
local LAPTOP_THRESHOLD = 2000


-- ── Helpers ───────────────────────────────────────────────────────────────────

local function isLaptop()
    local win = hs.window.focusedWindow()
    local scr = (win and win:screen()) or hs.screen.primaryScreen()
    return scr:frame().w < LAPTOP_THRESHOLD
end

local function move(cell, win)
    win = win or hs.window.focusedWindow()
    if not win then return end
    hs.grid.set(win, cell, win:screen())
end


-- ── Grid cells ────────────────────────────────────────────────────────────────

hs.grid.setGrid("12x8")

local cell = {
    laptop = {
        left   = { x = 0, y = 0, w = 6, h = 8 },
        right  = { x = 6, y = 0, w = 6, h = 8 },
        center = { x = 2, y = 1, w = 9, h = 6 },
    },
    desktop = {
        left       = { x = 2,  y = 1, w = 4, h = 6 },
        right      = { x = 6,  y = 1, w = 4, h = 6 },
        center     = { x = 3,  y = 2, w = 6, h = 4 },
        wide       = { x = 2,  y = 0, w = 8, h = 8 },
        top_bar    = { x = 2,  y = 0, w = 8, h = 1 },
        bottom_bar = { x = 2,  y = 7, w = 8, h = 1 },
        mgr_top    = { x = 10, y = 0, w = 2, h = 4 },
        mgr_bottom = { x = 10, y = 4, w = 2, h = 4 },
        keynote    = { x = 2,  y = 0, w = 8, h = 8 },
        vertical   = { x = 4,  y = 1, w = 4, h = 6 },
    },
    msg = {
        top    = { x = 0, y = 0, w = 2, h = 4 },
        bottom = { x = 0, y = 4, w = 2, h = 4 },
    },
}


-- ── Window management (Hyper = CapsLock = Ctrl+Opt+Cmd) ──────────────────────

-- A/D: left-right halves on laptop; center columns on desktop
hs.hotkey.bind(HYPER, "a", function()
    move(isLaptop() and cell.laptop.left or cell.desktop.left)
end)
hs.hotkey.bind(HYPER, "d", function()
    move(isLaptop() and cell.laptop.right or cell.desktop.right)
end)

-- S: wide center on laptop; small center on desktop
hs.hotkey.bind(HYPER, "s", function()
    move(isLaptop() and cell.laptop.center or cell.desktop.center)
end)

-- W: maximize on laptop; wide center on desktop
hs.hotkey.bind(HYPER, "w", function()
    if isLaptop() then hs.grid.maximizeWindow() else move(cell.desktop.wide) end
end)

-- Q/Z: messenger column top/bottom
hs.hotkey.bind(HYPER, "q", function() move(cell.msg.top) end)
hs.hotkey.bind(HYPER, "z", function() move(cell.msg.bottom) end)

-- Desktop-only slots
hs.hotkey.bind(HYPER, "1", function() move(cell.desktop.top_bar) end)
hs.hotkey.bind(HYPER, "2", function() move(cell.desktop.bottom_bar) end)
hs.hotkey.bind(HYPER, "e", function() move(cell.desktop.mgr_top) end)
hs.hotkey.bind(HYPER, "x", function() move(cell.desktop.mgr_bottom) end)
hs.hotkey.bind(HYPER, "c", function() move(cell.desktop.mgr_bottom) end)
hs.hotkey.bind(HYPER, "k", function() move(cell.desktop.keynote) end)
hs.hotkey.bind(HYPER, "v", function() move(cell.desktop.vertical) end)

-- /: show detected screen mode and width (useful for tuning LAPTOP_THRESHOLD)
hs.hotkey.bind(HYPER, "/", function()
    local win = hs.window.focusedWindow()
    local scr = (win and win:screen()) or hs.screen.primaryScreen()
    local w   = scr:frame().w
    hs.alert.show(w < LAPTOP_THRESHOLD and ("💻 Laptop (" .. w .. "px)") or ("🖥️  Desktop (" .. w .. "px)"))
end)

-- Enter: open Warp
hs.hotkey.bind(HYPER, "return", function()
    hs.application.launchOrFocus("Warp")
end)


-- ── App launchers ─────────────────────────────────────────────────────────────

hs.hotkey.bind({}, "f5",  function() hs.application.launchOrFocus("Calendar") end)
hs.hotkey.bind({}, "f6",  function() hs.application.launchOrFocus("Telegram") end)
hs.hotkey.bind({}, "f7",  function() hs.application.launchOrFocus("Telegram Lite") end)
-- f8–f12: unassigned

-- F4: quit frontmost app
hs.hotkey.bind({}, "f4", function()
    hs.eventtap.keyStroke({"cmd"}, "q")
end)

-- Cmd+F4: quit all apps with windows (spares Hammerspoon and Finder)
hs.hotkey.bind({"cmd"}, "f4", function()
    for _, app in ipairs(hs.application.runningApplications()) do
        local name = app:name() or ""
        if name ~= "Hammerspoon" and name ~= "Finder" then
            if #(app:allWindows() or {}) > 0 then app:kill() end
        end
    end
end)

-- Cmd+M: hide instead of minimize
hs.hotkey.bind({"cmd"}, "M", function()
    hs.application.frontmostApplication():hide()
end)

-- Cmd+F6: launch and auto-position both Telegram apps into messenger slots
local function positionApp(appName, targetCell)
    hs.application.launchOrFocus(appName)
    local tries = 0
    local t
    t = hs.timer.doEvery(0.2, function()
        tries = tries + 1
        local app = hs.appfinder.appFromName(appName)
        if app then
            local win = app:mainWindow()
            if win then
                win:unminimize()
                win:raise()
                move(targetCell, win)
                t:stop()
                return
            end
        end
        if tries > 50 then t:stop() end
    end)
end

hs.hotkey.bind({"cmd"}, "f6", function()
    positionApp("Telegram",      cell.msg.top)
    positionApp("Telegram Lite", cell.msg.bottom)
end)


-- ── Input ─────────────────────────────────────────────────────────────────────

-- Horizontal scroll → switch tabs
local eventtap   = require("hs.eventtap")
local eventTypes = eventtap.event.types
local eventProps = eventtap.event.properties
local lastScrollFired = 0
local SCROLL_COOLDOWN  = 0.25
local SCROLL_MIN_DELTA = 2

local scrollTap = eventtap.new({ eventTypes.scrollWheel }, function(e)
    local dx = e:getProperty(eventProps.scrollWheelEventDeltaAxis2) or 0
    local dy = e:getProperty(eventProps.scrollWheelEventDeltaAxis1) or 0
    if math.abs(dx) <= math.abs(dy) then return false end
    if math.abs(dx) < SCROLL_MIN_DELTA then return false end
    local now = hs.timer.secondsSinceEpoch()
    if now - lastScrollFired < SCROLL_COOLDOWN then return true end
    lastScrollFired = now
    eventtap.keyStroke({"cmd", "shift"}, dx > 0 and "[" or "]", 0)
    return true
end)
scrollTap:start()

-- Volume: F13=mute, F14=down (repeating), F15=up (repeating)
local function systemKey(key)
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
end
local vol = {
    up   = function() systemKey("SOUND_UP") end,
    down = function() systemKey("SOUND_DOWN") end,
    mute = function() systemKey("MUTE") end,
}
hs.hotkey.bind({}, "f13", vol.mute)
hs.hotkey.bind({}, "f14", vol.down, nil, vol.down)
hs.hotkey.bind({}, "f15", vol.up,   nil, vol.up)

-- Layout switching: Cmd+Alt+1 = English, Cmd+Alt+2 = Russian
hs.hotkey.bind({"cmd", "alt"}, 18, function() hs.keycodes.setLayout("ABC") end)
hs.hotkey.bind({"cmd", "alt"}, 19, function() hs.keycodes.setLayout("Russian – PC") end)
