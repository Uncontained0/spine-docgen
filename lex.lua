function makeLines(str)
	local lines = {}
	for line in str:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return lines
end

function cullNonComments(lines)
	local newLines = {}
	for _, line in ipairs(lines) do
		if line:match("^%s*-%-%-") then
			table.insert(newLines, line)
		end
	end
	return newLines
end

function removeLeading(lines)
	local newLines = {}
	for _, line in ipairs(lines) do
		local newLine = line:gsub("^%s*[-]*[ ]*", "")
		table.insert(newLines, newLine)
	end
	return newLines
end

return function(text)
	local lines = makeLines(text)
	lines = cullNonComments(lines)
	lines = removeLeading(lines)

	return lines
end
