-- getTextWidth() takes a string and prints it off-screen to calculate and
-- return the width of the text.
function getTextWidth(text)
  return print(text, 0, -100) - 1
end