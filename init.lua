-- Auto-reload when any .lua file in this directory changes
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then doReload = true end
    end
    if doReload then hs.reload() end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon: Config Loaded")

-- F-key app launchers
hs.hotkey.bind({}, "f5",  function() hs.application.launchOrFocus("Calendar") end)
hs.hotkey.bind({}, "f6",  function() hs.application.launchOrFocus("Telegram") end)
hs.hotkey.bind({}, "f7",  function() hs.application.launchOrFocus("Telegram Lite") end)
-- f8, f9: unassigned
hs.hotkey.bind({}, "f10", function() hs.application.launchOrFocus("Safari") end)
hs.hotkey.bind({}, "f11", function() hs.application.launchOrFocus("Sublime Text") end)
hs.hotkey.bind({}, "f12", function() hs.application.launchOrFocus("Warp") end)

-- F4: quit frontmost app; Cmd+F4: quit all normal apps
hs.hotkey.bind({}, "f4", function()
    hs.eventtap.keyStroke({"cmd"}, "q")
end)

local function quitAllNormalApps()
    for _, app in ipairs(hs.application.runningApplications()) do
        local name = app:name() or ""
        if name ~= "Hammerspoon" and name ~= "Finder" then
            if #(app:allWindows() or {}) > 0 then app:kill() end
        end
    end
end
hs.hotkey.bind({"cmd"}, "f4", quitAllNormalApps)

-- Horizontal scroll → switch tabs (Cmd+Shift+[ / Cmd+Shift+])
local eventtap       = require("hs.eventtap")
local keyStroke      = eventtap.keyStroke
local eventTypes     = eventtap.event.types
local eventProps     = eventtap.event.properties
local cooldownSeconds    = 0.25
local minHorizontalDelta = 2
local lastFired          = 0

local scrollTap = eventtap.new({ eventTypes.scrollWheel }, function(e)
    local dx = e:getProperty(eventProps.scrollWheelEventDeltaAxis2) or 0
    local dy = e:getProperty(eventProps.scrollWheelEventDeltaAxis1) or 0
    if math.abs(dx) <= math.abs(dy) then return false end
    if math.abs(dx) < minHorizontalDelta then return false end
    local now = hs.timer.secondsSinceEpoch()
    if now - lastFired < cooldownSeconds then return true end
    lastFired = now
    if dx > 0 then
        keyStroke({"cmd", "shift"}, "[", 0)
    else
        keyStroke({"cmd", "shift"}, "]", 0)
    end
    return true
end)
scrollTap:start()

-- Volume: F13=mute, F14=down, F15=up
local function sendSystemKey(key)
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
end
local volume = {
    up   = function() sendSystemKey("SOUND_UP") end,
    down = function() sendSystemKey("SOUND_DOWN") end,
    mute = function() sendSystemKey("MUTE") end,
}
hs.hotkey.bind({}, "f13", volume.mute)
hs.hotkey.bind({}, "f14", volume.down, nil, volume.down)
hs.hotkey.bind({}, "f15", volume.up,   nil, volume.up)

-- Keyboard layout switching
hs.hotkey.bind({"cmd", "alt"}, 18, function() hs.keycodes.setLayout("ABC") end)
hs.hotkey.bind({"cmd", "alt"}, 19, function() hs.keycodes.setLayout("Russian – PC") end)

-- Cmd+M: hide instead of minimize
hs.hotkey.bind({"cmd"}, "M", function()
    hs.application.frontmostApplication():hide()
end)

-- ─── Window management ───────────────────────────────────────────────────────
-- CapsLock acts as Ctrl+Option+Cmd, remapped by the Hyperkey app.
-- Screens narrower than LAPTOP_THRESHOLD points are treated as the laptop screen;
-- wider screens (external monitor) use the desktop layout.

hs.grid.setGrid('12x8')

local LAPTOP_THRESHOLD = 2000

local function isLaptop()
    local win = hs.window.focusedWindow()
    local scr = (win and win:screen()) or hs.screen.primaryScreen()
    return scr:frame().w < LAPTOP_THRESHOLD
end

local function moveWin(cell)
    local win = hs.window.focusedWindow()
    if not win then return end
    hs.grid.set(win, cell, win:screen())
end

-- Grid positions
local laptop_left_half       = { x = 0,  y = 0, w = 6, h = 8 }
local laptop_right_half      = { x = 6,  y = 0, w = 6, h = 8 }
local laptop_center          = { x = 2,  y = 1, w = 9, h = 6 }

local messenger_top          = { x = 0,  y = 0, w = 2, h = 4 }
local messenger_bottom       = { x = 0,  y = 4, w = 2, h = 4 }

local desktop_center_left    = { x = 2,  y = 1, w = 4, h = 6 }
local desktop_center_right   = { x = 6,  y = 1, w = 4, h = 6 }
local desktop_center_center  = { x = 3,  y = 2, w = 6, h = 4 }
local desktop_wide_center    = { x = 2,  y = 0, w = 8, h = 8 }
local desktop_top            = { x = 2,  y = 0, w = 8, h = 1 }
local desktop_bottom         = { x = 2,  y = 7, w = 8, h = 1 }
local desktop_manager_top    = { x = 10, y = 0, w = 2, h = 4 }
local desktop_manager_bottom = { x = 10, y = 4, w = 2, h = 4 }
local desktop_keynote        = { x = 2,  y = 0, w = 8, h = 8 }
local desktop_vertical       = { x = 4,  y = 1, w = 4, h = 6 }

-- Hyper = Ctrl+Opt+Cmd (CapsLock held, via Hyperkey app)

-- A/D: left/right halves on laptop; center-left/right columns on desktop
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "a", function()
    moveWin(isLaptop() and laptop_left_half or desktop_center_left)
end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "d", function()
    moveWin(isLaptop() and laptop_right_half or desktop_center_right)
end)

-- S: wide center on laptop; small center on desktop
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "s", function()
    moveWin(isLaptop() and laptop_center or desktop_center_center)
end)

-- W: maximize on laptop; wide center on desktop
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "w", function()
    if isLaptop() then
        hs.grid.maximizeWindow()
    else
        moveWin(desktop_wide_center)
    end
end)

-- Q/Z: messenger slots (same grid coords on both screens)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "q", function() moveWin(messenger_top) end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "z", function() moveWin(messenger_bottom) end)

-- Desktop-only positions
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "1", function() moveWin(desktop_top) end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "2", function() moveWin(desktop_bottom) end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "e", function() moveWin(desktop_manager_top) end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "x", function() moveWin(desktop_manager_bottom) end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "c", function() moveWin(desktop_manager_bottom) end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "k", function() moveWin(desktop_keynote) end)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "v", function() moveWin(desktop_vertical) end)

-- Hyper+/: show whether current screen is detected as laptop or desktop
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "/", function()
    local win = hs.window.focusedWindow()
    local scr = (win and win:screen()) or hs.screen.primaryScreen()
    local w = scr:frame().w
    if w < LAPTOP_THRESHOLD then
        hs.alert.show("💻 LAPTOP (" .. w .. "px)")
    else
        hs.alert.show("🖥️  DESKTOP (" .. w .. "px)")
    end
end)

-- CapsLock+Enter → Warp (CapsLock held = Ctrl+Opt+Cmd via Hyperkey)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "return", function()
    hs.application.launchOrFocus("Warp")
end)

-- ─── Cmd+F6: launch and auto-position both Telegram apps ─────────────────────

local function placeWindowInCell(cell, win)
    win = win or hs.window.frontmostWindow()
    if not win then return end
    hs.grid.set(win, cell, win:screen())
end

local function positionApp(appName, cell)
    hs.application.launchOrFocus(appName)
    local tries    = 0
    local pollTimer = nil
    pollTimer = hs.timer.doEvery(0.2, function()
        tries = tries + 1
        local app = hs.appfinder.appFromName(appName)
        if app then
            local win = app:mainWindow()
            if win then
                win:unminimize()
                win:raise()
                placeWindowInCell(cell, win)
                pollTimer:stop()
                pollTimer = nil
                return
            end
        end
        if tries > 50 then
            pollTimer:stop()
            pollTimer = nil
        end
    end)
end

local function arrangeMessengers()
    positionApp("Telegram",      messenger_top)
    positionApp("Telegram Lite", messenger_bottom)
end

hs.hotkey.bind({"cmd"}, "f6", arrangeMessengers)
