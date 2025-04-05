pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- trace test
-- by akd

-- TODO: Consider implementing your own trace() function.
-- TODO: Is it even worth it though? It's not like we can get the correct file names or line numbers anyway.

local function one()
	local function two()
		local function three()
			printh("trace():")
			printh(trace())
		end
		three()
	end
	two()
end
one()

-- This try() function wraps a callback in a coroutine such that, if it errors, it prints the trace instead of crashing.
local function try(callback, ...)
	local co = cocreate(callback)
	local ok, err = coresume(co, callback, ...)
	if err then
		printh("trace():")
		printh(trace())
	end
	return ok, err
end

local function a()
	local function b()
		local function c()
			local ok, err = try(function()
				-- This will cause an error:
				assert(false, "Custom error message")
			end)
			printh("ok: " .. tostr(ok))
			printh("err: " .. err)
		end
		c()
	end
	b()
end
a()
