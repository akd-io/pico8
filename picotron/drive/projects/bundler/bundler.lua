--[[
  TODOs:
  - bundler <my-script.lua>
    - Process:
      - Takes a Lua file
      - creates a .p64 cart
      - recursively finds all includes
      - copies all dependencies to cart
    - I believe include statements just need to have leading `/` removed if files are copied into the cart such that the cart becomes the new root for their paths.
]]
