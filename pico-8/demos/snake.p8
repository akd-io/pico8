pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- snake
-- by akd

-- Button characters: 🅾️❎⬅️➡️⬆️⬇️

-- COLORS
c_color_black = 0
c_color_dark_blue = 1
c_color_dark_purple = 2
c_color_dark_green = 3
c_color_brown = 4
c_color_dark_gray = 5
c_color_light_gray = 6
c_color_white = 7
c_color_red = 8
c_color_orange = 9
c_color_yellow = 10
c_color_green = 11
c_color_blue = 12
c_color_lavender = 13
c_color_pink = 14
c_color_light_peach = 15

-- SCENES
c_scene_menu = 0
c_scene_game = 1
c_scene_death_screen = 2
scene = c_scene_menu

-- SPRITES
-- Snake sprites
c_sprite_snake_head_right = 16
c_sprite_snake_head_up = 17
c_sprite_snake_head_left = 18
c_sprite_snake_head_down = 19
c_sprite_snake_body_right = 1
c_sprite_snake_body_up = 2
c_sprite_snake_body_left = 3
c_sprite_snake_body_down = 4
c_sprite_snake_body_r_u = 5
c_sprite_snake_body_u_l = 6
c_sprite_snake_body_l_d = 7
c_sprite_snake_body_d_r = 8
c_sprite_snake_body_d_l = 9
c_sprite_snake_body_r_d = 10
c_sprite_snake_body_u_r = 11
c_sprite_snake_body_l_u = 12
c_sprite_snake_tail_right = 32
c_sprite_snake_tail_up = 33
c_sprite_snake_tail_left = 34
c_sprite_snake_tail_down = 35
-- Food sprites
c_sprite_food = 25
-- Terrain sprites
c_sprite_sand = 26
c_sprite_sand_spots_1 = 27
c_sprite_sand_spots_2 = 28
c_sprite_sand_spots_3 = 29
c_sprite_sand_plants_1 = 30
c_sprite_sand_plants_2 = 31

-- MAP
mapWidth = 16
mapHeight = 16

function log(text)
  printh(text, "log.txt")
end

-- This function wraps a value within a range, uverflowing and underflowing as needed.
function wrapWithinRange(i, minVal, maxVal)
  local rangeSize = maxVal - minVal + 1
  return (i - minVal) % rangeSize + minVal
end

-- This function takes two booles and returns a directional value.
function boolDelta(boolA, boolB)
  local delta = 0
  if boolA then delta -= 1 end
  if boolB then delta += 1 end
  return delta
end

function generateMap()
  local map = { {} }
  for x = 1, mapWidth do
    for y = 1, mapWidth do
      local randomSprite = rnd({
        c_sprite_sand, c_sprite_sand, c_sprite_sand, c_sprite_sand, c_sprite_sand, c_sprite_sand,
        c_sprite_sand, c_sprite_sand, c_sprite_sand_spots_1, c_sprite_sand_spots_2,
        c_sprite_sand_spots_3, c_sprite_sand_plants_1, c_sprite_sand_plants_2
      })
      if map[x] == nil then
        map[x] = {}
      end
      map[x][y] = randomSprite
    end
  end
  return map
end

function _init()
  scene = c_scene_menu
end

currentMap = {}
function newGame()
  scene = c_scene_game
  currentMap = generateMap()
end

selectedMenuOption = 1
menuOptions = { "new game", "options", "quit" }
function update_menu_scene()
  local dy = boolDelta(btnp(⬆️), btnp(⬇️))
  selectedMenuOption = wrapWithinRange(selectedMenuOption + dy, 1, #menuOptions)

  if btnp(❎) then
    if selectedMenuOption == 1 then
      newGame()
    elseif selectedMenuOption == 2 then
      log("Options")
    elseif selectedMenuOption == 3 then
      extcmd("shutdown")
    end
  end
end

-- Snake body coordinates from head to tail.
snake = {
  { x = 8, y = 8 },
  { x = 7, y = 8 },
  { x = 6, y = 8 },
  { x = 5, y = 8 }
}
function updateGameScene()
  local controllerDx = boolDelta(btn(⬅️), btn(➡️))
  local controllerDy = boolDelta(btn(⬆️), btn(⬇️))

  -- If the player is trying to move diagonally, then ignore the input.
  if controllerDx ~= 0 and controllerDy ~= 0 then
    controllerDx = 0
    controllerDy = 0
  end

  local snakeDx = snake[1].x - snake[2].x
  local snakeDy = snake[1].y - snake[2].y

  -- If the player is trying to move in the opposite direction of the current direction,
  -- then ignore the input.
  if controllerDx == -snakeDx then
    controllerDx = 0
  end
  if controllerDy == -snakeDy then
    controllerDy = 0
  end

  local dx = controllerDx == 0 and controllerDy == 0 and snakeDx or controllerDx
  local dy = controllerDx == 0 and controllerDy == 0 and snakeDy or controllerDy

  -- Move the snake's body.
  for i = #snake, 2, -1 do
    snake[i].x = snake[i - 1].x
    snake[i].y = snake[i - 1].y
  end
  -- Move the snake's head.
  snake[1].x = wrapWithinRange(snake[1].x + dx, 0, mapWidth - 1)
  snake[1].y = wrapWithinRange(snake[1].y + dy, 0, mapHeight - 1)
end

function _update()
  if scene == c_scene_menu then
    update_menu_scene()
  elseif scene == c_scene_game then
    updateGameScene(currentMap)
  end
end

function renderMenuScene()
  print("snake", 40, 20, 14)
  for i = 1, #menuOptions do
    local y = 20 + i * 8
    local option = menuOptions[i]
    local color = i == selectedMenuOption and c_color_pink or c_color_light_gray
    print(option, 40, y, color)
    if i == selectedMenuOption then
      x1 = 32
      x2 = 32 + (3 + #option) * 4
      xDelta = ceil(2 * cos(time()) + 0.5)
      print(">", x1 + xDelta, y, color)
      print("<", x2 - xDelta, y, color)
    end
  end
end

function renderGameScene()
  renderMap(currentMap)
  renderSnake(snake)
end

function _draw()
  cls()
  if scene == c_scene_menu then
    renderMenuScene()
  elseif scene == c_scene_game then
    renderGameScene(currentMap)
  end
end

function renderMap(spriteMap)
  for x = 1, mapWidth do
    for y = 1, mapHeight do
      spr(spriteMap[x][y], (x - 1) * 8, (y - 1) * 8)
    end
  end
end

function renderSnake(snake)
  for i = 1, #snake do
    local prev = snake[i + 1]
    local curr = snake[i]
    local next = snake[i - 1]

    function dx1() return curr.x - prev.x end
    function dy1() return curr.y - prev.y end
    function dx2() return next.x - curr.x end
    function dy2() return next.y - curr.y end

    local sprite = 0
    if prev != nil and next != nil then
      -- Render body
      if dx1() == 1 and dx2() == 1 then
        sprite = c_sprite_snake_body_right
      elseif dx1() == -1 and dx2() == -1 then
        sprite = c_sprite_snake_body_left
      elseif dy1() == 1 and dy2() == 1 then
        sprite = c_sprite_snake_body_down
      elseif dy1() == -1 and dy2() == -1 then
        sprite = c_sprite_snake_body_up
        --
      elseif dx1() == 1 and dy2() == 1 then
        sprite = c_sprite_snake_body_r_d
      elseif dx1() == 1 and dy2() == -1 then
        sprite = c_sprite_snake_body_r_u
      elseif dx1() == -1 and dy2() == 1 then
        sprite = c_sprite_snake_body_l_d
      elseif dx1() == -1 and dy2() == -1 then
        sprite = c_sprite_snake_body_l_u
        --
      elseif dy1() == 1 and dx2() == 1 then
        sprite = c_sprite_snake_body_d_r
      elseif dy1() == 1 and dx2() == -1 then
        sprite = c_sprite_snake_body_d_l
      elseif dy1() == -1 and dx2() == 1 then
        sprite = c_sprite_snake_body_u_r
      elseif dy1() == -1 and dx2() == -1 then
        sprite = c_sprite_snake_body_u_l
      end
    elseif prev == nil then
      -- Render tail
      if dx2() == 1 then
        sprite = c_sprite_snake_tail_right
      elseif dx2() == -1 then
        sprite = c_sprite_snake_tail_left
      elseif dy2() == 1 then
        sprite = c_sprite_snake_tail_down
      elseif dy2() == -1 then
        sprite = c_sprite_snake_tail_up
      end
    elseif next == nil then
      -- Render head
      if dx1() == 1 then
        sprite = c_sprite_snake_head_right
      elseif dx1() == -1 then
        sprite = c_sprite_snake_head_left
      elseif dy1() == 1 then
        sprite = c_sprite_snake_head_down
      elseif dy1() == -1 then
        sprite = c_sprite_snake_head_up
      end
    end
    spr(sprite, curr.x * 8, curr.y * 8)
  end
end

__gfx__
00000000000000000b3b3b3000000000033bbbb00b3b3b300000000000000000033bbbb0033b3bb000000000000000000bb3b330000000000000000000000000
00000000bbbbbbbb0bb3b3303333333303b3bbb0bbb3b330333330000003333303b3bbbb33b3bbb0bbbbb000000bbbbb0b3b3b33000000000000000000000000
00700700bbb3bbb30bbb3b30b3b3b3b3033b3bb0bbbb3b30b3b3b3000033b3b3033b3bb33b3b3bb0bbb3bb0000bbbb3b0bb3b3b3000000000000000000000000
00077000bb3bbb3b0bbbb3303b3b3b3b03b3b3b0bb3bb3303b3bb33003bb3b3b03b3bb3bb3b3b3b03b3bbbb00bbbb3b30bbb3b3b000000000000000000000000
00077000b3b3b3b30b3b3b30b3bbb3bb033bbbb0b3b3bb30b3bb3b30033bb3bb033bb3b33b3bbbb0b3b3bbb00b3b3b3b0bbbb3b3000000000000000000000000
007007003b3b3b3b0bb3b3303bbb3bbb03b3bbb03b3b33003bb3b33003b3bbbb003b3b3bb3bbbb003b3b3bb00bb3b3b300bb3bbb000000000000000000000000
00000000333333330bbb3b30bbbbbbbb033b3bb033333000bbbb3b30033b3bbb00033333bbbbb00033b3b3b00bbb3b33000bbbbb000000000000000000000000
00000000000000000bbbb3300000000003b3b3b0000000000bbbb33003b3b3b00000000000000000033b3bb00bb3b33000000000000000000000000000000000
0bb0000000bb330000000000033bbbb0000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff
b75bbbb00b3b3b300333333303b3bb7b000000000000000000000000000000000000000000000000ffffffffffffffffffffffffff4fffffffffffffffffffff
bbbbbb3b0bbb3b303bbbb3b3033b3b5b0000000000000000000000000000000000000000000ee000fffffffffffffffffffffffffffffffffffffffff3f3ffff
bb3bbbbb0bbb3b3033333b3b03b3bbb0000000000000000000000000000000000000000000288e00ffffffffffff4fffffffffffffffff4ffff3f3ffff3fffff
b3b333330bbb3b30bbbbb3bb03b3bbb0000000000000000000000000000000000000000000288e00fffffffffffffffff4ffffffffffffffffff3fffffffffff
3b3bbbb3b5b3b330b3bbbbbb03b3bbb0000000000000000000000000000000000000000000022000fffffffffffffffffffff4ffffffffffffffffffffff3f3f
33333330b7bb3b300bbbb57b03b3b3b0000000000000000000000000000000000000000000000000fffffffffffffffffffffffffff4fffffffffffffffff3ff
000000000bbbb33000000bb00033bb00000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff
000000000b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bbbbb0bb3b330333330000003b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b3bbb30bbb3b30b3b3b300003b3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b3bbb3b0bbbb3303b3b3b3003b3b3b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03b3b3b30b3b3b30b3bbb3b0033bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003b3b3b00b3b3003bbb3b0003b3bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033333000b3000bbbbb000033b3bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000003b3b3b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1212121212121212121312121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212131212171212121212161212141200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
121212121212121312120c121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213121214121212121204121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12121212050101010d1404121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212131202121612121204121213121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121206030303030307121512121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1712121212121212121213121212121400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121213121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
