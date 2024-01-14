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
        hs.eventtap.event.newKeyEvent({"shift", "ctrl", "cmd"}, c, true):post()
        hs.eventtap.event.newKeyEvent({"shift", "ctrl", "cmd"}, c, false):post()
    end)
end

hs.hotkey.bind({"cmd","alt"} , 18, function()
    hs.keycodes.setLayout("ABC")
end)


hs.hotkey.bind({"cmd","alt"}, 19, function()
    hs.keycodes.setLayout("Russian – PC")
end)

hs.grid.setGrid('12x6')

function moveWin(cell, window)
   window = hs.window.focusedWindow()
   hs.grid.set(window, cell, screen)
end

hyper:bind({}, "w", function() hs.grid.maximizeWindow() end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "w", function() hs.grid.maximizeWindow() end)

local messenger_top={
  x = 0,
  y = 0,
  w = 2,
  h = 3
}

local messenger_bottom={
  x = 0,
  y = 3,
  w = 2,
  h = 3
}

local messenger_center={
  x = 0,
  y = 1,
  w = 2,
  h = 4
}

hyper:bind({}, "1", function() moveWin(messenger_top) end)
hyper:bind({}, "2", function() moveWin(messenger_center) end)
hyper:bind({}, "3", function() moveWin(messenger_bottom) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "1", function() moveWin(messenger_top) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "2", function() moveWin(messenger_center) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "3", function() moveWin(messenger_bottom) end)

local global_center={
  x = 2,
  y = 1,
  w = 8,
  h = 4
}

hyper:bind({}, "s", function() moveWin(global_center) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "s", function() moveWin(global_center) end)

local small_half_left={
  x = 2,
  y = 1,
  w = 4,
  h = 4
}

local small_half_right={
  x = 6,
  y = 1,
  w = 4,
  h = 4
}

hyper:bind({}, "left", function() moveWin(small_half_left) end)
hyper:bind({}, "right", function() moveWin(small_half_right) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "left", function() moveWin(small_half_left) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "right", function() moveWin(small_half_right) end)

local left_third={
  x = 0,
  y = 0,
  w = 4,
  h = 6
}

local mid_third={
  x = 4,
  y = 0,
  w = 4,
  h = 6
}

local right_third={
  x = 8,
  y = 0,
  w = 4,
  h = 6
}

hyper:bind({}, ",", function() moveWin(left_third) end)
hyper:bind({}, ".", function() moveWin(mid_third) end)
hyper:bind({}, "/", function() moveWin(right_third) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, ",", function() moveWin(left_third) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, ".", function() moveWin(mid_third) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "/", function() moveWin(right_third) end)

local left_half={
  x = 0,
  y = 0,
  w = 6,
  h = 6
}

local right_half={
  x = 6,
  y = 0,
  w = 6,
  h = 6
}

hyper:bind({}, "a", function() moveWin(left_half) end)
hyper:bind({}, "d", function() moveWin(right_half) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "a", function() moveWin(left_half) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "d", function() moveWin(right_half) end)

local topleft_quarter={
  x = 0,
  y = 0,
  w = 6,
  h = 3
}

local botleft_quarter={
  x = 0,
  y = 3,
  w = 6,
  h = 3
}

local topright_quarter={
  x = 6,
  y = 0,
  w = 6,
  h = 3
}

local botright_quarter={
  x = 6,
  y = 3,
  w = 6,
  h = 3
}

hyper:bind({}, "q", function() moveWin(topleft_quarter) end)
hyper:bind({}, "z", function() moveWin(botleft_quarter) end)
hyper:bind({}, "e", function() moveWin(topright_quarter) end)
hyper:bind({}, "x", function() moveWin(botright_quarter) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "q", function() moveWin(topleft_quarter) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "z", function() moveWin(botleft_quarter) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "e", function() moveWin(topright_quarter) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "x", function() moveWin(botright_quarter) end)

local files_top={
  x = 10,
  y = 0,
  w = 2,
  h = 3
}

local files_bottom={
  x = 10,
  y = 3,
  w = 2,
  h = 3
}

hyper:bind({}, "9", function() moveWin(files_top) end)
hyper:bind({}, "0", function() moveWin(files_bottom) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "9", function() moveWin(files_top) end)
hs.hotkey.bind({"ctrl", "shift", "cmd"}, "0", function() moveWin(files_bottom) end)

hs.hotkey.bind({"cmd"}, "M", function()
  local currentapp=hs.application.frontmostApplication()
  currentapp:hide()
end)

function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Emacs") then
           moveWin(global_center)
        end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
