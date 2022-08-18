return function(lines)
	local classes, macros = {}, {}
	local currentclass, cursor

	for _, line in ipairs(lines) do
		if line:match("^@class") then
			currentclass = line:match("^@class ([%w]+)")
			classes[currentclass] = {
				props = {},
				methods = {},
				types = {},
				static = {},
				description = "",
			}
			cursor = classes[currentclass]
		elseif line:match("^@prop") then
			local name, type = line:match("^@prop (.+) !! (.+)")
			classes[currentclass].props[name] = {
				type = type,
				description = "",
			}
			cursor = classes[currentclass].props[name]
		elseif line:match("^@method") then
			local name = line:match("^@method (.+)")
			classes[currentclass].methods[name] = {
				description = "",
				params = {},
				returns = {},
			}
			cursor = classes[currentclass].methods[name]
		elseif line:match("^@static") then
			local name = line:match("^@static (.+)")
			classes[currentclass].static[name] = {
				description = "",
				params = {},
				returns = {},
			}
			cursor = classes[currentclass].static[name]
		elseif line:match("^@return") then
			local type, description = line:match("^@return (.+) !! (.*)")
			table.insert(cursor.returns, {
				type = type,
				description = description,
			})
		elseif line:match("^@param") then
			local name, type, description = line:match("^@param (.+) !! (.+) !! (.*)")
			table.insert(cursor.params, {
				name = name,
				type = type,
				description = description,
			})
		elseif line:match("^@type") then
			local name, type = line:match("^@type (.+) !! (.+)")
			classes[currentclass].types[name] = {
				type = type,
				description = "",
			}
			cursor = classes[currentclass].types[name]
		elseif line:match("^@extends") then
			local extends = line:match("^@extends (.+)")
			classes[currentclass].extends = extends
		elseif line:match("^@macro") then
			local name, value = line:match("^@macro (.+) !! (.+)")
			macros[name] = value
		elseif line:match("^@constructor") then
			classes[currentclass].constructor = {
				description = "",
				params = {},
				returns = {},
			}
			cursor = classes[currentclass].constructor
		else
			if cursor then
				for i, v in ipairs(macros) do
					line = line:gsub(('@%s@'):format(i), v)
				end

				cursor.description = cursor.description .. line .. "\n"
			end
		end
	end

	return classes
end
