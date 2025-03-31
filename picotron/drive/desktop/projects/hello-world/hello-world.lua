window({
  width = 60,
  height = 10,
  resizeable = true,
  moveable = true,
  has_frame = true,
  title = tostr(pid())
})

function _update60() end

function _draw()
  cls()
  print("Hello world")
end
