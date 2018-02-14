
local function print(text)
	DEFAULT_CHAT_FRAME:AddMessage(text, 0.8, 1, 1)
end

function copypasta(text)
	URLCopyFrameEditBox:SetText(text)
	URLCopyFrame:Show()
end

-- scuffed code, don't read
local function assign(which_class)
	local raidsize = GetNumRaidMembers()
	if raidsize == 0 then
		print("You are not in a raid.")
		return
	end

	local groups_list = {}	-- list: group number => true
	local buffers = {}		-- array of names

	for i = 1, raidsize do
		local name, _, group, level, class, _, _, online = GetRaidRosterInfo(i)
		if online then
			groups_list[group] = true
			if level == 60 and class == which_class then
				table.insert(buffers, name)
			end
		end
	end

	local groups = {} -- array of groups

	for group in groups_list do
		table.insert(groups, group)
	end

	table.sort(groups)
	table.sort(buffers)

	local numpriests = table.getn(buffers)

	if numpriests == 0 then
		print("No matching players found.")
		return
	end

	local priestgroups = {}	-- list: name => number of groups to buff for this buffer

	local i = 1
	for _, group in groups do
		local name = buffers[i]
		priestgroups[name] = priestgroups[name] and priestgroups[name] + 1 or 1
		i = i == numpriests and 1 or i + 1
	end

	local assignments = {} -- list: name => {array of groups}

	local i = 1	-- current buffer index
	local j = 0	-- number of groups assigned to current buffer i
	for _, group in groups do
		local name = buffers[i]
		if not assignments[name] then
			assignments[name] = {}
		end

		table.insert(assignments[name], group)

		j = j + 1
		if j == priestgroups[name] then
			j = 0
			i = i + 1
		end
	end

	text = which_class .. " Buffs: "

	for _, name in buffers do
		local assigngroups = assignments[name]
		if assigngroups then
			text = text .. name .. ": "
			for _, group in assigngroups do
				text = text .. group .. " "
			end
		end
	end

	copypasta(text)
end

local function assign_something(what)
	if not what or what == "" then
		what = "Priest"
	end
	return assign(what)
end

SLASH_PBA1 = "/assign"
SlashCmdList["PBA"] = assign_something
