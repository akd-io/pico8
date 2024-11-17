function clamp(value, min, max)
  return value < min and min or value > max and max or value
end