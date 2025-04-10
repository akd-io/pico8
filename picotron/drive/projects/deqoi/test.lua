include("deqoi.lua")

local qoiString = fetch("/desktop/label.qoi")

printh(qoiString:sub(1, 4))

local imageData = qoiDecode(qoiString) --! Note: Result is 0-indexed!
local imageString = imageData[0] .. "," .. table.concat(imageData, ",")

store("/desktop/label.txt", imageString)
