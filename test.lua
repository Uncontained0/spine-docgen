local lex = require('lex')
local parse = require('parse')
local gen = require('gen')
local fs = require('fs')

local teststr = [[
--- @class World
--- This is the world class.
--- ```lua
---	local World = require(PATH.TO.WORLD)
--- hello world
--- 	hello from tabbed
--- end
--- ```
--- @prop Gravity !! number
--- This is the gravity property.
local World = {}

--- @method GetGravity
--- This method simply returns the gravity property.
---
--- @return number !! The gravity property.
function World:GetGravity()
	return self.gravity
end

	--- @method SetGravity
	--- This method sets the
	--- gravity property.
	---
	--- @param gravity !! number !! The new gravity property.
function World:SetGravity(gravity)
	self.gravity = gravity
end
]]

local lines = lex(teststr)

for _, v in ipairs(lines) do
	p(v)
end

lines = parse(lines)
lines = gen(lines)['World']