--[[pod_format="raw",created="2025-04-18 23:14:10",modified="2025-04-18 23:18:49",revision=13]]
function Label(labelUserdata, index, width, height)
  local xTargets = {
    0,
    width * 0.5 / 10,
    width * 1.5 / 10,
    width * 8.5 / 10,
    width * 9.5 / 10,
    width * 10 / 10
  }

  local x1 = useSpring(xTargets[index])
  local x2 = useSpring(xTargets[index + 1])

  palt(0) -- Treat all colors as opaque.
  clip(x1, 0, x2, height)
  spr(labelUserdata, 0, 0)
end
