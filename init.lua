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


hs.hotkey.bind({"cmd","alt"} , 18, function()
    hs.keycodes.setLayout("ABC")
end)


hs.hotkey.bind({"cmd","alt"}, 19, function()
    hs.keycodes.setLayout("Russian – PC")
end)

    function isLaptopScreen()
    -- Get the current screen
    local currentScreen = hs.screen.mainScreen()

    -- Check the name of the screen (change "Color LCD" to the actual name of your laptop's screen)
    return currentScreen:name() == "Built-in Retina Display"
end

hs.grid.setGrid('12x8')

 function moveWin(cell, window)
    window = hs.window.focusedWindow()
    hs.grid.set(window, cell, screen)
end

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

hs.hotkey.bind({"ctrl", "shift", "alt"}, "a", function()
    if isLaptopScreen() then
        moveWin(laptop_left_half)
    else
        moveWin(desktop_center_left)
    end
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "d", function()
    if isLaptopScreen() then
        moveWin(laptop_right_half)
    else
        moveWin(desktop_center_right)
    end
end)



laptop_center={
x = 2,
y = 1,
w = 9,
h = 6
}

desktop_center_center={
x = 3,
y = 2,
w = 6,
h = 4
}

desktop_keynote={
x = 2,
y = 0,
w = 8,
h = 8
}

hs.hotkey.bind({"ctrl", "shift", "alt"}, "s", function()
    if isLaptopScreen() then
        moveWin(laptop_center)
    else
        moveWin(desktop_center_center)
    end
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "k", function()
    if not isLaptopScreen() then
        moveWin(desktop_keynote)
    end
end)



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

hs.hotkey.bind({"ctrl", "shift", "alt"}, "q", function()
    if isLaptopScreen() then
        moveWin(laptop_messenger_top)
    else
        moveWin(desktop_messenger_top)
    end
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "z", function()
    if isLaptopScreen() then
        moveWin(laptop_messenger_bottom)
    else
        moveWin(desktop_messenger_bottom)
    end
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "e", function()
    if not isLaptopScreen() then
        moveWin(desktop_manager_top)
    end
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "x", function()
    if not isLaptopScreen() then
        moveWin(desktop_manager_bottom)
    end
end)


desktop_vertical={
x = 4,
y = 1,
w = 4,
h = 6
}

hs.hotkey.bind({"ctrl", "shift", "alt"}, "v", function()
    if not isLaptopScreen() then
        moveWin(desktop_vertical)
    end
end)


-- Define window positions for the first, second, and third thirds of the laptop screen
laptop_first_third = {
    x = 0,
    y = 0,
    w = 4, -- Assuming a screen width of 12 units for simplicity
    h = 8  -- Assuming full height
}

laptop_second_third = {
    x = 4,
    y = 0,
    w = 4,
    h = 8
}

laptop_third_third = {
    x = 8,
    y = 0,
    w = 4,
    h = 8
}

-- Bind hotkeys for each third
hs.hotkey.bind({"ctrl", "shift", "alt"}, "1", function()
    if isLaptopScreen() then
        moveWin(laptop_first_third)
    else
        hs.alert.show("Not on the laptop screen!", 2)
    end
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "2", function()
    if isLaptopScreen() then
        moveWin(laptop_second_third)
    else
        hs.alert.show("Not on the laptop screen!", 2)
    end
end)

hs.hotkey.bind({"ctrl", "shift", "alt"}, "3", function()
    if isLaptopScreen() then
        moveWin(laptop_third_third)
    else
        hs.alert.show("Not on the laptop screen!", 2)
    end
end)


hs.hotkey.bind({"cmd"}, "M", function()
  local currentapp=hs.application.frontmostApplication()
  currentapp:hide()
end)
