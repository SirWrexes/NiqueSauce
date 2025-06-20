do
	---@param line string
	local function to_key_value(line)
		local eqidx = line:find("=")
		local key = line:sub(1, eqidx - 1)
		local value = line:sub(eqidx + 1)
		return key, value
	end

	---@param line string
	local function add_to_env(line)
		if line == "" then
			return
		end
		local key, value = to_key_value(line)
		if vim.env[key] ~= nil then
			return
		end
		vim.env[key] = value
	end

	local function try_inherit_fish_env()
		local out = vim.system({ "fish", "-c", "env" }, { text = true }):wait()
		if out.code == 0 then
			vim.iter(vim.gsplit(out.stdout, "\n")):each(add_to_env)
		end
	end

	pcall(try_inherit_fish_env)
end
