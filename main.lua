local fs = require('fs')
local path = require('path')

local lex = require('lex')
local parse = require('parse')
local gen = require('gen')

local filePath = path.normalize(args[2])
local outPath = path.normalize(args[3])

local function getDescendants(dir)
	local files = fs.readdirSync(dir)
	local result = {}
	for _, file in ipairs(files) do
		local filePath = path.join(dir, file)
		if fs.statSync(filePath).type == "directory" then
			for _, descendant in ipairs(getDescendants(filePath)) do
				table.insert(result, descendant)
			end
		elseif file:match('.lua$') and not file:match('.spec.lua$') then
			table.insert(result, filePath)
		end
	end
	return result
end

local classes = {}

for _,v in ipairs(getDescendants(filePath)) do
	local stat = fs.statSync(v)
	local fd = fs.openSync(v, 'r')
	local content = fs.readSync(fd, stat.size)
	fs.closeSync(fd)
	
	local lines = lex(content)
	
	for name, class in pairs(parse(lines)) do
		classes[name] = class
	end
end

local docs = gen(classes)

for _, v in ipairs(fs.readdirSync(filePath)) do
	local files = getDescendants(path.join(filePath, v))

	local out = path.join(outPath)

	for _, v in ipairs(files) do
		local fd = fs.openSync(v, 'r')
		local content = fs.readSync(fd)
		fs.closeSync(fd)
		
		local lines = lex(content)
		local classList = parse(lines)

		for name in pairs(classList) do
			local fd = fs.openSync(path.join(out, name:lower() .. '.md'), 'w')
			fs.writeSync(fd, 0, docs[name])
			fs.closeSync(fd)
		end
	end
end