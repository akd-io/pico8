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
map_width = 16
map_height = 16

function log(text)
  printh(text, "log.txt")
end

-- This function wraps a value within a range, uverflowing and underflowing as needed.
function wrap_within_range(i, min_val, max_val)
  local range_size = max_val - min_val + 1
  return (i - min_val) % range_size + min_val
end

-- This function takes two booles and returns a directional value.
function bool_delta(boola, boolb)
  local delta = 0
  if boola then delta -= 1 end
  if boolb then delta += 1 end
  return delta
end

function generate_map()
  local a_map = { {} }
  for x = 1, map_width do
    for y = 1, map_width do
      local random_sprite = rnd({
        c_sprite_sand, c_sprite_sand, c_sprite_sand, c_sprite_sand, c_sprite_sand, c_sprite_sand,
        c_sprite_sand, c_sprite_sand, c_sprite_sand_spots_1, c_sprite_sand_spots_2,
        c_sprite_sand_spots_3, c_sprite_sand_plants_1, c_sprite_sand_plants_2
      })
      if a_map[x] == nil then
        a_map[x] = {}
      end
      a_map[x][y] = random_sprite
    end
  end
  return a_map
end

function _init()
  scene = c_scene_menu
end

current_map = {}
function new_game()
  scene = c_scene_game
  current_map = generate_map()
end

selected_menu_option = 1
menu_options = { "new game", "options", "quit" }
function update_menu_scene()
  local dy = bool_delta(btnp(⬆️), btnp(⬇️))
  selected_menu_option = wrap_within_range(selected_menu_option + dy, 1, #menu_options)

  if btnp(❎) then
    if selected_menu_option == 1 then
      new_game()
    elseif selected_menu_option == 2 then
      log("Options")
    elseif selected_menu_option == 3 then
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
function update_game_scene()
  local controller_dx = bool_delta(btn(⬅️), btn(➡️))
  local controller_dy = bool_delta(btn(⬆️), btn(⬇️))

  -- If the player is trying to move diagonally, then ignore the input.
  if controller_dx ~= 0 and controller_dy ~= 0 then
    controller_dx = 0
    conroller_dy = 0
  end

  local snake_dx = snake[1].x - snake[2].x
  local snake_dy = snake[1].y - snake[2].y

  -- If the player is trying to move in the opposite direction of the current direction,
  -- then ignore the input.
  if controller_dx == -snake_dx then
    controller_dx = 0
  end
  if controller_dy == -snake_dy then
    controller_dy = 0
  end

  local dx = controller_dx == 0 and controller_dy == 0 and snake_dx or controller_dx
  local dy = controller_dx == 0 and controller_dy == 0 and snake_dy or controller_dy

  -- Move the snake's body.
  for i = #snake, 2, -1 do
    snake[i].x = snake[i - 1].x
    snake[i].y = snake[i - 1].y
  end
  -- Move the snake's head.
  snake[1].x = wrap_within_range(snake[1].x + dx, 0, map_width - 1)
  snake[1].y = wrap_within_range(snake[1].y + dy, 0, map_height - 1)
end

function _update()
  if scene == c_scene_menu then
    update_menu_scene()
  elseif scene == c_scene_game then
    update_game_scene(current_map)
  end
end

function render_menu_scene()
  print("snake", 40, 20, 14)
  for i = 1, #menu_options do
    local y = 20 + i * 8
    local option = menu_options[i]
    local color = i == selected_menu_option and c_color_pink or c_color_light_gray
    print(option, 40, y, color)
    if i == selected_menu_option then
      x1 = 32
      x2 = 32 + (3 + #option) * 4
      xDelta = ceil(2 * cos(time()) + 0.5)
      print(">", x1 + xDelta, y, color)
      print("<", x2 - xDelta, y, color)
    end
  end
end

function render_game_scene()
  render_map(current_map)
  render_snake(snake)
end

function _draw()
  cls()
  if scene == c_scene_menu then
    render_menu_scene()
  elseif scene == c_scene_game then
    render_game_scene(current_map)
  end
end

function render_map(sprite_map)
  for x = 1, map_width do
    for y = 1, map_height do
      spr(sprite_map[x][y], (x - 1) * 8, (y - 1) * 8)
    end
  end
end

function render_snake(snake)
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
