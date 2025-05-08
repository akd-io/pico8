pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- React Context Test
-- by akd
--[[
  Prints:
    Layer1 context value: Default context value
    Layer4 context value: Default context value
    Layer2 context value: Layer1 value
    Layer3 context value: Layer1 value
    Layer4 context value: Layer3 value
    Layer4 context value: Default context value
]]
#include ../lib/react.lua

local MyContext = createContext("Default context value")

local function Layer4()
  local contextValue = useContext(MyContext)
  printh("Layer4 context value: " .. contextValue)
end

local function Layer3()
  local contextValue = useContext(MyContext)
  printh("Layer3 context value: " .. contextValue)
  return {
    {
      MyContext.Provider, "Layer3 value", {
        { Layer4 }
      }
    }
  }
end

local function Layer2()
  local contextValue = useContext(MyContext)
  printh("Layer2 context value: " .. contextValue)
  return {
    { Layer3 }
  }
end

local function Layer1()
  local contextValue = useContext(MyContext)
  printh("Layer1 context value: " .. contextValue)
  return {
    { Layer4 },
    {
      MyContext.Provider, "Layer1 value", {
        { Layer2 }
      }
    },
    { Layer4 }
  }
end

renderRoot(Layer1)
