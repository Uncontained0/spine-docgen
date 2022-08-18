local function sum(name, val, type)
	local to = type .. "-" .. name

	return ('- <code><a style="color:white" href="#%s">%s</a>%s</code>'):format(to, name, val)
end

local function sort(t)
	local indexes = {}
	for k in pairs(t) do
		table.insert(indexes, k)
	end
	table.sort(indexes, function(a, b)
		return a:lower() < b:lower()
	end)
	return indexes
end

local function count(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

local function anchor(type, name)
	return ("{#%s}"):format(type .. "-" .. name)
end

local function inherits(class, classes)
	local inherits = {}

	while true do
		local parent = classes[class.extends]

		if parent == nil then
			break
		end

		table.insert(inherits, class.extends)
		class = parent
	end

	return inherits
end

local function getparams(params)
	local paramstr = ''

	for _, param in ipairs(params) do
		paramstr = paramstr .. ('%s: %s, '):format(param.name, param.type)
	end

	paramstr = paramstr:gsub(', $', '')

	return paramstr
end

local function getreturns(returns)
	local returnstr = ''

	for _, ret in ipairs(returns) do
		returnstr = returnstr .. ('%s, '):format(ret.type)
	end

	returnstr = returnstr:gsub(', $', '')

	return returnstr
end

return function(classes)
	local docs = {}

	for classname, class in pairs(classes) do
		local _str = ""

		local function out(str)
			_str = _str .. str
		end

		local function line(str)
			_str = _str .. str .. "\n"
		end

		line(("# %s"):format(classname))
		if class.extends then
			line(("#### Extends [%s](%s)"):format(class.extends, './' .. class.extends))
		end

		line(class.description)

		local types = sort(class.types)
		local props = sort(class.props)
		local methods = sort(class.methods)
		local static = sort(class.static)

		local inherits = inherits(class, classes)

		local typeCount = #types
		for _, v in pairs(inherits) do
			typeCount = typeCount + count(classes[v].types)
		end

		local propCount = #props
		for _, v in pairs(inherits) do
			propCount = propCount + count(classes[v].props)
		end

		local methodCount = #methods
		for _, v in pairs(inherits) do
			methodCount = methodCount + count(classes[v].methods)
		end

		local staticCount = #static
		for _, v in pairs(inherits) do
			staticCount = staticCount + count(classes[v].static)
		end

		line('## Summary')

		if typeCount > 0 then
			line('### Types')

			for _, name in ipairs(types) do
				local type = class.types[name]

				line(sum(name, (": %s"):format(type.type), "type"))
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				if count(mixclass.types) > 0 then
					line(('::: details Inherited from [%s](%s)'):format(name, './' .. name))
					for _, name in ipairs(sort(mixclass.types)) do
						local type = mixclass.types[name]

						line(sum(name, type.type, "type"))
					end
					line(':::')
				end
			end
		end

		if propCount > 0 then
			line('### Properties')

			for _, name in ipairs(props) do
				local prop = class.props[name]

				line(sum(name, (': %s'):format(prop.type), "prop"))
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				if count(mixclass.props) > 0 then
					line(('::: details Inherited from [%s](%s)'):format(name, './' .. name))
					for _, name in ipairs(sort(mixclass.props)) do
						local prop = mixclass.props[name]

						line(sum(name, (': %s'):format(prop.type), "prop"))
					end
					line(':::')
				end
			end
		end

		if methodCount > 0 then
			line('### Methods')

			for _, name in ipairs(methods) do
				local method = class.methods[name]

				local params = getparams(method.params)
				local returns = getreturns(method.returns)

				line(sum(name, ('(%s): %s'):format(params, returns), "method"))
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				if count(mixclass.methods) > 0 then
					line(('::: details Inherited from [%s](%s)'):format(name, './' .. name))
					for _, name in ipairs(sort(mixclass.methods)) do
						local method = mixclass.methods[name]

						local params = getparams(method.params)
						local returns = getreturns(method.returns)

						line(sum(name, ('(%s): %s'):format(params, returns), "method"))
					end
					line(':::')
				end
			end
		end

		if staticCount > 0 then
			line('### Static Methods')

			for _, name in ipairs(static) do
				local method = class.static[name]

				local params = getparams(method.params)
				local returns = getreturns(method.returns)

				line(sum(name, ('(%s): %s'):format(params, returns), "static"))
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				if count(mixclass.static) > 0 then
					line(('::: details Inherited from [%s](%s)'):format(name, './' .. name))
					for _, name in ipairs(sort(mixclass.static)) do
						local method = mixclass.static[name]

						local params = getparams(method.params)
						local returns = getreturns(method.returns)

						line(sum(name, ('(%s): %s'):format(params, returns), "static"))
					end
					line(':::')
				end
			end
		end

		if class.constructor then
			local method = class.constructor
			line('## Constructor')

			line(class.constructor.description)

			if #method.params > 0 then
				line('#### Parameters')
				for _, param in ipairs(method.params) do
					if #param.description > 0 then
						line(('- <code>%s: %s</code> - %s'):format(param.name, param.type, param.description))
					else
						line(('- <code>%s: %s</code>'):format(param.name, param.type))
					end
				end
			end

			if #method.returns > 0 then
				line('#### Returns')
				for _, returns in ipairs(method.returns) do
					if #returns.description > 0 then
						line(('- <code>%s</code> - %s'):format(returns.type, returns.description))
					else
						line(('- <code>%s</code>'):format(returns.type))
					end
				end
			end
		end

		if typeCount > 0 then
			line('## Types')

			local typeSrc = {}
			for i, v in pairs(class.types) do
				typeSrc[i] = v
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				for i, v in pairs(mixclass.types) do
					typeSrc[i] = v
				end
			end

			local types = sort(typeSrc)

			for _, name in ipairs(types) do
				local type = typeSrc[name]

				line(('### %s: <code>%s</code> %s'):format(name, type.type, anchor('type', name)))
				line(type.description)
			end
		end

		if propCount > 0 then
			line('## Properties')

			local propSrc = {}
			for i, v in pairs(class.props) do
				propSrc[i] = v
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				for i, v in pairs(mixclass.props) do
					propSrc[i] = v
				end
			end

			local props = sort(propSrc)

			for _, name in ipairs(props) do
				local prop = propSrc[name]

				line(('### %s: <code>%s</code> %s'):format(name, prop.type, anchor('prop', name)))
				line(prop.description)
			end
		end

		if methodCount > 0 then
			line('## Methods')

			local methodSrc = {}
			for i, v in pairs(class.methods) do
				methodSrc[i] = v
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				for i, v in pairs(mixclass.methods) do
					methodSrc[i] = v
				end
			end

			local methods = sort(methodSrc)

			for _, name in ipairs(methods) do
				local method = methodSrc[name]

				line(('### %s %s'):format(name, anchor('method', name)))
				line(method.description)

				if #method.params > 0 then
					line('#### Parameters')
					for _, param in ipairs(method.params) do
						if #param.description > 0 then
							line(('- <code>%s: %s</code> - %s'):format(param.name, param.type, param.description))
						else
							line(('- <code>%s: %s</code>'):format(param.name, param.type))
						end
					end
				end

				if #method.returns > 0 then
					line('#### Returns')
					for _, returns in ipairs(method.returns) do
						if #returns.description > 0 then
							line(('- <code>%s</code> - %s'):format(returns.type, returns.description))
						else
							line(('- <code>%s</code>'):format(returns.type))
						end
					end
				end
			end
		end

		if staticCount > 0 then
			line('## Static Methods')

			local staticSrc = {}
			for i, v in pairs(class.static) do
				staticSrc[i] = v
			end

			for _, name in ipairs(inherits) do
				local mixclass = classes[name]

				for i, v in pairs(mixclass.static) do
					staticSrc[i] = v
				end
			end

			local statics = sort(staticSrc)

			for _, name in ipairs(statics) do
				local static = staticSrc[name]

				line(('### %s %s'):format(name, anchor('method', name)))
				line(static.description)

				if #static.params > 0 then
					line('#### Parameters')
					for _, param in ipairs(static.params) do
						if #param.description > 0 then
							line(('- <code>%s: %s</code> - %s'):format(param.name, param.type, param.description))
						else
							line(('- <code>%s: %s</code>'):format(param.name, param.type))
						end
					end
				end

				if #static.returns > 0 then
					line('#### Returns')
					for _, returns in ipairs(static.returns) do
						if #returns.description > 0 then
							line(('- <code>%s</code> - %s'):format(returns.type, returns.description))
						else
							line(('- <code>%s</code>'):format(returns.type))
						end
					end
				end
			end
		end

		docs[classname] = _str
	end

	return docs
end
