local TextService : TextService = game:GetService("TextService")
local Debris : Debris = game:GetService("Debris")

return function(event : RemoteEvent, sender : Player, msg : string)
	if #msg > 75 then return end
	if sender:FindFirstChild("CantSendMessages") then return end
	
	local bv : BoolValue = Instance.new("BoolValue")
	bv.Name = "CantSendMessages"
	bv.Parent = sender
	Debris:AddItem(bv,2)
	
	local filterResult : TextFilterResult = TextService:FilterStringAsync(msg,sender.UserId,Enum.TextFilterContext.PublicChat)
	local filteredString : string = filterResult:GetNonChatStringForBroadcastAsync()
	
	local playerColour : Color3 = sender:GetAttribute("CharacterColour")
	local result : string = "<font color=\"rgb(%d,%d,%d)\">%s</font> : %s"
	
	result = string.format(result,playerColour.R*255,playerColour.G*255,playerColour.B*255,sender.DisplayName,filteredString)
	game.ReplicatedStorage.Remotes.MessageEvent:FireAllClients(result)
end