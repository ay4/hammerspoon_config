--
-- Reload config
--

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")


-- IMPLEMENTING HYPER KEY
--
-- Remap CapsLock to F18 using internal Mac methods
--

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

--
-- Reimplementing Kawa
-- (layout switching)
--

hs.hotkey.bind({"cmd","alt"} , 18, function()
    hs.keycodes.setLayout("ABC")
end)


hs.hotkey.bind({"cmd","alt"}, 19, function()
    hs.keycodes.setLayout("Russian – PC")
end)

--
-- Implementing window switching
--

hs.grid.setGrid('12x6')

--
-- Maximizing
--
hyper:bind({}, "w", function() hs.grid.maximizeWindow() end)

--
-- Constructing window position
--

--
-- Messengers
--

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

function moveWin(cell, window)
   window = hs.window.focusedWindow()
   hs.grid.set(window, cell, screen)
end

hyper:bind({}, "1", function() moveWin(messenger_top) end)
hyper:bind({}, "2", function() moveWin(messenger_center) end)
hyper:bind({}, "3", function() moveWin(messenger_bottom) end)

--
-- Center
--

local global_center={
  x = 2,
  y = 1,
  w = 8,
  h = 4
}

hyper:bind({}, "s", function() moveWin(global_center) end)

--
-- Small halves
--

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

--
-- Thirds
--

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

--
-- Halves
--

local left_half={
  x = 0,
  y = 0,
  w = 6,
  h = 6
}

local right_half={
  x = 7,
  y = 0,
  w = 6,
  h = 6
}

hyper:bind({}, "a", function() moveWin(left_half) end)
hyper:bind({}, "s", function() moveWin(right_half) end)

--
-- Quarters
--

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

--
-- File manager
--

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
