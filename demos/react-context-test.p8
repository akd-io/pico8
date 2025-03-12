pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[
  React Context Test

  Prints:
    Rendering 18059e6c_1
    Layer1
    Layer1 context value: Default context value
    Rendering 18059e6c_1-1805996c_1
    Layer4
    Layer4 context value: Default context value
    Rendering 18059e6c_1-18059dbc_2-1
    Layer2
    Layer2 context value: Layer1 value
    Rendering 18059e6c_1-18059dbc_2-1-18059d0c_1
    Layer3
    Layer3 context value: Layer1 value
    Rendering 18059e6c_1-18059dbc_2-1-18059d0c_1-1805996c_1-1
    Layer4
    Layer4 context value: Layer3 value
    Rendering 18059e6c_1-1805996c_3
    Layer4
    Layer4 context value: Default context value
]]
#include ../lib/react.lua

local MyContext = createContext("Default context value")

local function Layer4()
  printh("Layer4")
  local contextValue = useContext(MyContext)
  printh("Layer4 context value: " .. contextValue)
end

local function Layer3()
  printh("Layer3")
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
  printh("Layer2")
  local contextValue = useContext(MyContext)
  printh("Layer2 context value: " .. contextValue)
  return {
    { Layer3 }
  }
end

local function Layer1()
  printh("Layer1")
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

local function _update60() end

renderRoot(Layer1)
