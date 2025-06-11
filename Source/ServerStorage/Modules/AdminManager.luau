local module = {}

module.Members = { -- put user ids in here
	Superadmins = {
		game.CreatorId,
	},
	Admins = {
		-1,
		-2
	}
}

function module:isIDAdmin(id : number) : number
	for _,v in pairs(self.Members.Superadmins) do
		if v == id then
			return 2
		end
	end
	
	for _,v in pairs(self.Members.Admins) do
		if v == id then
			return 1
		end
	end
	
	return 0
end

local function split_words(str : string) : table<string>
	local words : table<string> = {}
	
	for word in string.gmatch(str, "%S+") do
		table.insert(words,word)
	end
	
	return words
end

function module:stringToCommand(runner : Player, msg : string)
	local adminType : number = self:isIDAdmin(runner.UserId)
	if adminType == 0 then return end
	
	local arguments = split_words(msg)
	if string.sub(arguments[1],1,1) ~= "!" then return end
	
	local command = string.sub(arguments[1],2,#arguments[1])
	local data = require(script.Commands:FindFirstChild(command))
	
	table.remove(arguments,1)
	if adminType == 1 then
		if data.minimumRequirement == 2 then
			return
		end
	end
	data.func(runner,unpack(arguments))
end

return module
