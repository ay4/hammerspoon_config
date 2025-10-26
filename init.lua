function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon: Config Loaded")


hs.execute("hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x700000039,\"HIDKeyboardModifierMappingDst\":0x70000006D}]}'")

hyper = hs.hotkey.modal.new({}, nil)

hyper.pressed = function()
  hyper:enter()
end

hyper.released = function()
  hyper:exit()
end

hs.hotkey.bind({}, 'F18', hyper.pressed, hyper.released)

local useful_chars="abcdefghijklmnopqrstuvwxyz0123456789"

for i=1, #useful_chars do
   local c = useful_chars:sub(i,i)
    hyper:bind({}, c, function()
        hs.eventtap.event.newKeyEvent({"shift", "ctrl", "alt"}, c, true):post()
        hs.eventtap.event.newKeyEvent({"shift", "ctrl", "alt"}, c, false):post()
    end)
end

-- F5 -> Apple Calendar
hs.hotkey.bind({}, "f5", function()
    hs.application.launchOrFocus("Calendar")
end)

-- F6 -> Telegram
hs.hotkey.bind({}, "f6", function()
    hs.application.launchOrFocus("Telegram")
end)

-- F7 -> Telegram Lite
hs.hotkey.bind({}, "f7", function()
    hs.application.launchOrFocus("Telegram Lite")
end)

-- F8 -> Amazing marvin
hs.hotkey.bind({}, "f8", function()
    hs.application.launchOrFocus("Amazing marvin")
end)

-- F9 -> Mail
hs.hotkey.bind({}, "f9", function()
    hs.application.launchOrFocus("Mail")
end)

-- F4 -> Cmd+Q (Quit frontmost app)
hs.hotkey.bind({}, "f4", function()
    -- Send Command+Q to the currently focused app
    hs.eventtap.keyStroke({"cmd"}, "q")
end)

    local mailBundleID = "com.apple.mail"
local ax = require("hs.axuielement")

-- We'll watch for both Backspace (aka "delete") and Forward Delete.
local deleteKeys = {
    [hs.keycodes.map.delete]        = true, -- keycode 51 (Backspace key)
    [hs.keycodes.map.forwarddelete] = true, -- keycode 117 (Fn+Delete / Forward Delete)
}

-- Returns true if the currently focused UI element in Mail is something editable
-- (compose text area, To:/Subject:, search field, etc.).
-- If you're in one of those, we should NOT hijack Delete.
local function mailEditingText()
    local frontApp = hs.application.frontmostApplication()
    if not frontApp or frontApp:bundleID() ~= mailBundleID then
        -- We only care about Mail here. If Mail isn't frontmost,
        -- we treat this as "not editing text in Mail".
        return false
    end

    local sysElem = ax.systemWideElement()
    if not sysElem then return false end

    local focusedElem = sysElem:attributeValue("AXFocusedUIElement")
    if not focusedElem then return false end

    -- Many editable things in Mail report AXEditable = true
    -- (message body when composing, search field, etc.)
    local editable = focusedElem:attributeValue("AXEditable")
    if editable == true then
        return true
    end

    -- Some fields (like To:/Cc: token fields) can be weird.
    -- Fall back to checking the element role.
    local role = focusedElem:attributeValue("AXRole")
    if role == "AXTextField"
        or role == "AXTextArea"
        or role == "AXSearchField"
        or role == "AXTokenField"
    then
        return true
    end

    return false
end

-- Event tap callback. We decide whether to swallow the key and send Archive.
local function handleMailDelete(ev)
    -- Only care about keyDown events
    if ev:getType() ~= hs.eventtap.event.types.keyDown then
        return false
    end

    -- Only care about Delete / Forward Delete
    local keyCode = ev:getKeyCode()
    if not deleteKeys[keyCode] then
        return false
    end

    -- Only act if Apple Mail is actually frontmost.
    local frontApp = hs.application.frontmostApplication()
    if not frontApp or frontApp:bundleID() ~= mailBundleID then
        -- Mail is NOT the active app (maybe Alfred is up, or you're in Safari, etc.)
        -- -> do nothing, let Delete behave normally.
        return false
    end

    -- We're in Mail. If user's cursor is in a text field (compose window,
    -- subject line, To:/Cc:, search box...), then DO NOT archive.
    if mailEditingText() then
        return false
    end

    -- Otherwise: intercept Delete and fire the Archive shortcut instead.
    -- We aim Ctrl+Cmd+A at Mail (frontApp).
    hs.eventtap.keyStroke({ "ctrl", "cmd" }, "a", 0, frontApp)

    -- Swallow the original Delete so it doesn't also "Move to Trash".
    return true
end

-- Create and start the global event tap.
local mailDeleteTap = hs.eventtap.new(
    { hs.eventtap.event.types.keyDown },
    handleMailDelete
)
mailDeleteTap:start()

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
hs.hotkey.bind({}, "f15", volume.up, nil, volume.up)


hs.hotkey.bind({"cmd","alt"} , 18, function()
    hs.keycodes.setLayout("ABC")
end)


hs.hotkey.bind({"cmd","alt"}, 19, function()
    hs.keycodes.setLayout("Russian – PC")
end)

hs.grid.setGrid('12x8')

 function moveWin(cell, window)
    window = hs.window.focusedWindow()
    hs.grid.set(window, cell, screen)
end

hs.hotkey.bind({"ctrl", "shift", "cmd"}, "w", function() hs.grid.maximizeWindow() end)
hs.hotkey.bind({"ctrl", "shift", "alt"}, "w", function() hs.grid.maximizeWindow() end)


laptop_left_half={
x = 0,
y = 0,
w = 6,
h = 8
}

laptop_right_half={
x = 6,
y = 0,
w = 6,
h = 8
}

hs.hotkey.bind({"ctrl", "shift", "alt"}, "a", function() moveWin(laptop_left_half) end)
hs.hotkey.bind({"ctrl", "shift", "alt"}, "d", function() moveWin(laptop_right_half) end)


laptop_center={
x = 2,
y = 1,
w = 9,
h = 6
}

hs.hotkey.bind({"ctrl", "shift", "alt"}, "s", function() moveWin(laptop_center) end)


laptop_messenger_top={
x = 0,
y = 0,
w = 2,
h = 4
}

laptop_messenger_bottom={
x = 0,
y = 4,
w = 2,
h = 4
}

hs.hotkey.bind({"ctrl", "shift", "alt"}, "q", function() moveWin(laptop_messenger_top) end)
hs.hotkey.bind({"ctrl", "shift", "alt"}, "z", function() moveWin(laptop_messenger_bottom) end)

desktop_messenger_top={
x = 0,
y = 0,
w = 2,
h = 4
}

desktop_messenger_bottom={
x = 0,
y = 4,
w = 2,
h = 4
}


hs.hotkey.bind({"ctrl", "shift", "cmd"}, "q", function() moveWin(desktop_messenger_top) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "z", function() moveWin(desktop_messenger_bottom) end)

desktop_top={
x = 2,
y = 0,
w = 8,
h = 1
}

desktop_bottom={
x = 2,
y = 7,
w = 8,
h = 1
}
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "1", function() moveWin(desktop_top) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "2", function() moveWin(desktop_bottom) end)



desktop_center_left={
x = 2,
y = 1,
w = 4,
h = 6
}

desktop_center_right={
x = 6,
y = 1,
w = 4,
h = 6
}

desktop_center_center={
x = 3,
y = 2,
w = 6,
h = 4
}

hs.hotkey.bind({"ctrl", "shift", "cmd"}, "a", function() moveWin(desktop_center_left) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "d", function() moveWin(desktop_center_right) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "s", function() moveWin(desktop_center_center) end)


desktop_manager_top={
x = 10,
y = 0,
w = 2,
h = 4
}

desktop_manager_bottom={
x = 10,
y = 4,
w = 2,
h = 4
}


hs.hotkey.bind({"ctrl", "shift", "cmd"}, "e", function() moveWin(desktop_manager_top) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "x", function() moveWin(desktop_manager_bottom) end)

desktop_keynote={
x = 2,
y = 0,
w = 8,
h = 8
}


hs.hotkey.bind({"ctrl", "shift", "cmd"}, "k", function() moveWin(desktop_keynote) end)

desktop_vertical={
x = 4,
y = 1,
w = 4,
h = 6
}


hs.hotkey.bind({"ctrl", "shift", "cmd"}, "v", function() moveWin(desktop_vertical) end)

hs.hotkey.bind({"cmd"}, "M", function()
  local currentapp=hs.application.frontmostApplication()
  currentapp:hide()
end)
