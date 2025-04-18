--[[pod_format="raw",created="2025-04-14 14:04:50",modified="2025-04-14 14:25:06",revision=2]]
include("/lib/describe.lua")
include("/lib/utils.lua")
include("/lib/react.lua")
renderRoot, useState, createContext, useContext, useMemo = __initReact()
include("/hooks/usePrevious.lua")
include("/hooks/useMouse.lua")
MouseProvider, useMouse = __initMouseProvider()
include("/hooks/useClickableArea.lua")
include("/projects/deqoi/deqoi.lua")
include("/lib/mkdirr.lua")
include("/hooks/useDir.lua")

local width = 480 / 2
local height = 270 / 2

-- TODO: Remove when ready for fullscreen.
window(width, height)

function _init()

end

function _update()

end

local cachePodDirPath = "/ram/explore-cache"
local cachePodFilePath = cachePodDirPath .. "/allCartPaths.pod"

local categoryPaths = {
  "bbs://new",
  "bbs://featured",
  "bbs://wip"
}
local function useCartPaths()
  local cache = useState(function()
    if (fstat(cachePodFilePath)) then
      local cache = fetch(cachePodFilePath)
      -- TODO: Check against cache schema. Refresh if invalid.
      -- TODO: Refresh if stale.
      return cache
    end
    return nil
  end)

  if cache then
    -- TODO: At some point we should implement refresh functionality,
    -- TODO: and this early return will become problematic, because
    -- TODO: not returning here will cause hooks call count to change.
    assert(type(cache) == "table", "cache should be a table, got " .. type(cache))
    -- TODO: Check against cache schema. Refresh if invalid.
    return cache
  end

  local categoryDirs = useDirs(categoryPaths)
  --printh("useCartPaths: Count categoryDirs: " .. #categoryDirs)
  --printh("useCartPaths: categoryDirs: " .. describe(categoryDirs))

  local categoryDirsLoaded = useMemo(function()
    printh("useCartPaths: categoryDirs changed!")
    return objectEvery(categoryDirs, function(categoryDir)
      return categoryDir.loading == false
    end)
  end, { categoryDirs })

  local categoryPagePaths = useMemo(function()
    printh("useCartPaths: categoryDirsLoaded changed!")
    printh("useCartPaths: categoryDirsLoaded = " .. tostr(categoryDirsLoaded))
    local categoryPagePaths = {}
    for categoryPath in all(categoryPaths) do
      categoryPagePaths[categoryPath] = {}
    end

    if not categoryDirsLoaded then
      return categoryPagePaths
    end

    for categoryPath in all(categoryPaths) do
      local categoryDir = categoryDirs[categoryPath]
      for categoryPageName in all(categoryDir.result) do
        local pagePath = categoryPath .. "/" .. categoryPageName
        add(categoryPagePaths[categoryPath], pagePath)
      end
    end
    return categoryPagePaths
  end, { categoryDirsLoaded })

  local categoryPageDirs = {}
  local categoryPageDirsDep = {}
  for categoryPath in all(categoryPaths) do
    local pagePaths = categoryPagePaths[categoryPath]
    categoryPageDirs[categoryPath] = useDirs(pagePaths)
    add(categoryPageDirsDep, categoryPageDirs[categoryPath])
  end

  local pageDirsLoaded = useMemo(function()
    printh("useCartPaths: categoryPageDirs changed!")
    printh("useCartPaths: categoryPageDirs = " .. tostr(categoryPageDirs))
    if not categoryDirsLoaded then return false end
    return objectEvery(categoryPaths, function(categoryPath)
      local pageDirs = categoryPageDirs[categoryPath]
      return objectEvery(pageDirs, function(pageDir)
        return pageDir.loading == false
      end)
    end)
  end, categoryPageDirsDep) -- TODO: `categoryPageDirsDep` is not wrapped on purpose. But is this a safe deps array in edge cases too? That is, is it impossible to for its length to change.

  local allCartPaths = useMemo(function()
    printh("useCartPaths: pageDirsLoaded changed!")
    printh("useCartPaths: pageDirsLoaded = " .. tostr(pageDirsLoaded))
    local allCartPaths = {}
    for categoryPath in all(categoryPaths) do
      allCartPaths[categoryPath] = {}
    end

    if not pageDirsLoaded then
      return allCartPaths
    end

    for categoryPath in all(categoryPaths) do
      local pagePaths = categoryPagePaths[categoryPath]
      for pagePath in all(pagePaths) do
        local pageDir = categoryPageDirs[categoryPath][pagePath]
        for cartFile in all(pageDir.result) do
          local cartPath = pagePath .. "/" .. cartFile
          add(allCartPaths[categoryPath], cartPath)
        end
      end
    end

    printh("allCartPaths:")
    printh(describe(allCartPaths))

    mkdirr(cachePodDirPath)
    store(cachePodFilePath, allCartPaths)

    return allCartPaths
  end, { pageDirsLoaded })

  return allCartPaths
end

local memLabelCache = {}
-- TODO: Remove labels from cache when off screen and not to be displayed in a prev/next press or two.
function useLabels(cartIDs, cachePath)
  return useMemo(function()
    local labels = {}
    -- TODO: Refactor to use useQueries.
    for cartID in all(cartIDs) do
      if not memLabelCache[cartID] then
        local labelQoiString = fetch(cachePath .. "/" .. cartID .. "/label.qoi")
        -- TODO: labelQoiString will be nil until cart caching code is finished copying carts to the cache directory.
        -- TODO: What do we do about this? Implement fake await using polling?
        memLabelCache[cartID] = qoiDecode(labelQoiString)
      end
      labels[cartID] = memLabelCache[cartID]
    end
    return labels
  end, cartIDs)
end

---Wrap is a component that simply takes a function and arguments and runs the function on render.
---This is useful for calling builtin functions like clip() at a specific point in the render tree,
---as it's not possible to specify a function like clip as a component in the render tree,
---as its return value is not a valid react element.
function Wrap(func, ...)
  func(...)
  -- Do not return func's return value, as it is not a valid react element.
end

local frame = 0
function App()
  local cachePath = "/appdata/explore/cartCache"
  mkdirr(cachePath)

  local state = useState({
    categoryIndex = 1,
    selectedCartIndex = 1,
  })

  local categoryIndexDiff = tonum(btnp(3)) - tonum(btnp(2))
  if categoryIndexDiff != 0 then
    state.categoryIndex = ((state.categoryIndex + categoryIndexDiff - 1) % #categoryPaths) + 1
  end

  local function getOffsetIndex(currentIndex, offset, length)
    return ((currentIndex + offset - 1) % length) + 1
  end

  local allCartPaths = useCartPaths()
  --printh("allCartPaths:")
  --printh(describe(allCartPaths))

  local selectedCategoryPath = categoryPaths[state.categoryIndex]
  local categoryCartPaths = allCartPaths[selectedCategoryPath]
  --printh("categoryCartsPaths:")
  --printh(describe(categoryCartsPaths))

  local selectedCartIndexDiff = tonum(btnp(1)) - tonum(btnp(0))
  if selectedCartIndexDiff != 0 then
    state.selectedCartIndex = getOffsetIndex(state.selectedCartIndex, selectedCartIndexDiff, #categoryCartPaths)
  end

  local selectedCartPath = categoryCartPaths[state.selectedCartIndex]

  local drawnCartPaths = {
    categoryCartPaths[getOffsetIndex(state.selectedCartIndex, -3, #categoryCartPaths)],
    categoryCartPaths[getOffsetIndex(state.selectedCartIndex, -2, #categoryCartPaths)],
    categoryCartPaths[getOffsetIndex(state.selectedCartIndex, -1, #categoryCartPaths)],
    categoryCartPaths[state.selectedCartIndex],
    categoryCartPaths[getOffsetIndex(state.selectedCartIndex, 1, #categoryCartPaths)],
    categoryCartPaths[getOffsetIndex(state.selectedCartIndex, 2, #categoryCartPaths)],
    categoryCartPaths[getOffsetIndex(state.selectedCartIndex, 3, #categoryCartPaths)],
  }
  --local labels = useLabels(drawnCartPaths, cachePath)

  cls() -- TODO: Probably don't need this later, when rendering on every part of the screen anyway.
  return {
    { Wrap, clip,  0,                                                0, width * 1 / 10,  height },
    --{ Wrap, spr,     labels[1], },
    { Wrap, clip,  width * 1 / 10,                                   0, width * 3 / 10,  height },
    --{ Wrap, spr,     labels[2] },
    { Wrap, clip,  width * 3 / 10,                                   0, width * 7 / 10,  height },
    --{ Wrap, spr,     labels[3] },
    { Wrap, clip,  width * 7 / 10,                                   0, width * 9 / 10,  height },
    --{ Wrap, spr,     labels[4] },
    { Wrap, clip,  width * 9 / 10,                                   0, width * 10 / 10, height },
    --{ Wrap, spr,     labels[5] },
    { Wrap, clip,  0,                                                0, width,           height },

    { Wrap, print, "frame: " .. frame,                               0, 0,               12 },
    { Wrap, print, "fps: " .. stat(7),                               12 },
    { Wrap, print, "selectedCartIndex: " .. state.selectedCartIndex, 12 },
    { Wrap, print, "selectedCartPath: " .. tostr(selectedCartPath),  12 },

    arrayMap(drawnCartPaths, function(cartPath, i)
      return { Wrap, print, cartPath, 12 }
    end)
  }
end

function _draw()
  frame += 1
  renderRoot(App)
end
