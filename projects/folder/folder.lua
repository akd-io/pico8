-- Sprites
local extensionToSpriteMap = {
  ["/"] = 1,
  [".txt"] = 2,
  [".p8l"] = 2, -- Log file from printh(text, fileName) https://www.lexaloffle.com/dl/docs/pico-8_manual.html#PRINTH
  [".p8"] = 3, -- Cartridge, text format https://www.lexaloffle.com/dl/docs/pico-8_manual.html#_Loading_and_Saving
  [".p8.png"] = 3, -- Cartridge, image format https://www.lexaloffle.com/dl/docs/pico-8_manual.html#_Loading_and_Saving
  [".p8.rom"] = 3, -- Cartridge, raw 32k binary format https://www.lexaloffle.com/dl/docs/pico-8_manual.html#_Loading_and_Saving
  [".lua"] = 6, -- Included Lua code https://www.lexaloffle.com/dl/docs/pico-8_manual.html#_INCLUDE
  [".png"] = 4, -- Sprite sheet and label https://www.lexaloffle.com/dl/docs/pico-8_manual.html#Sprite_Sheet_
  [".wav"] = 5, -- SFX and music https://www.lexaloffle.com/dl/docs/pico-8_manual.html#SFX_and_Music_
  [".map.png"] = 4, -- Exported map https://www.lexaloffle.com/dl/docs/pico-8_manual.html#MAP_and_CODE
  [".lua.png"] = 4, -- Exported code https://www.lexaloffle.com/dl/docs/pico-8_manual.html#MAP_and_CODE
  [".html"] = 6, -- Exported web app html https://www.lexaloffle.com/dl/docs/pico-8_manual.html#Web_Applications_
  [".js"] = 6, -- Exported web app js https://www.lexaloffle.com/dl/docs/pico-8_manual.html#Web_Applications_
  [".bin"] = 3, -- Exported binary app https://www.lexaloffle.com/dl/docs/pico-8_manual.html#Binary_Applications_
  [".gif"] = 7 -- Exported video https://www.lexaloffle.com/dl/docs/pico-8_manual.html#Recording_GIFs
  -- TODO:
  -- .md -- Markdown
  -- .zip -- Zip file
  -- .xcf -- Gimp file
  -- .sh/.bat/.make
}

local function sortedFileArray(dir)
  local files = {}
  local folders = {}
  for element in all(dir) do
    if endsWidth(element, "/") then
      add(folders, element)
    else
      add(files, element)
    end
  end
  return { unpack(sortedArray(folders)), unpack(sortedArray(files)) }
end

local LsContext = createContext(sortedFileArray(ls()))

local function getExtension(fileName)
  if endsWidth(fileName, "/") then
    return "/"
  end
  local tokens = split(fileName, ".")
  return "." .. tokens[#tokens]
end

local function File(fileName, x, y)
  local fileNameX = x + 6
  local iconWidth = 6
  local fileNameTextWidth = print(fileName, 0, 256) - 1
  local clickableArea = useClickableArea(
    x,
    y,
    x + fileNameTextWidth + iconWidth,
    y + 6
  )

  if clickableArea.leftClicked then
    printh(fileName .. " clicked")
  end

  if clickableArea.isHovering then
    rectfill(
      x - 1,
      y - 1,
      x + fileNameTextWidth + iconWidth,
      y + 5,
      13
    )
  end

  if clickableArea.leftDown then
    rectfill(
      x - 1,
      y - 1,
      x + fileNameTextWidth + iconWidth,
      y + 5,
      12
    )
  end
  spr(extensionToSpriteMap[getExtension(fileName)], x, y)
  print(fileName, fileNameX, y, 6)
end

local function FileList(fileNames, x, y)
  assert(type(x) == "number")
  return {
    arrayMap(
      fileNames, function(fileName, i)
        return { fileName, File, fileName, x + 6, y + (i - 1) * 7 }
      end
    )
  }
end

local function MouseSelection()
  local mouse = useMouse()

  if mouse.leftSelection then
    color(3)
    rectfill(unpack(mouse.leftSelection))
    color(11)
    rect(unpack(mouse.leftSelection))
  end
  if mouse.rightSelection then
    color(13)
    rectfill(unpack(mouse.rightSelection))
    color(14)
    rect(unpack(mouse.rightSelection))
  end
end

local function ListView()
  local cwd, setCwd = useState(nil)
  local fileNames = useContext(LsContext)

  return {
    { FileList, fileNames, 10, 10 }
  }
end

local function Mouse(x, y)
  spr(8, x, y)
end

local function App()
  local lsValue = sortedFileArray(ls())
  local mouse = useMouse()
  cls(1)
  return {
    { MouseSelection },
    {
      LsContext.Provider, lsValue, {
        { ListView }
      }
    },
    { Mouse, mouse.x - 1, mouse.y - 1 }
  }
end

local function Providers()
  return {
    {
      MouseProvider, {
        { App }
      }
    }
  }
end

local function _update60() end
local function _draw()
  renderRoot(Providers)
end