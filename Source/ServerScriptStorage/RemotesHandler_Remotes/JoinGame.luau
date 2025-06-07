return function(event : RemoteEvent, ply : Player, wantsToJoin : boolean)
	local playerColour : Color3 = ply:GetAttribute("CharacterColour")
	if wantsToJoin then
		local msg : string = "<font color=\"rgb(%d,%d,%d)\">%s</font> joined the match!"
		task.delay(0.2, function()
			game.ReplicatedStorage.Remotes.MessageEvent:FireAllClients(string.format(msg,playerColour.R*255,playerColour.G*255,playerColour.B*255,ply.DisplayName))
		end)
		
		if ply.PlayerGui:FindFirstChild("MenuGui") then
			ply.PlayerGui.MenuGui:Destroy()
		end
		
		ply:SetAttribute("Playing",true)
		ply:LoadCharacter()
		return
	end
	local msg : string = "<font color=\"rgb(%d,%d,%d)\">%s</font> left the match!"
	task.delay(0.2,function()
		game.ReplicatedStorage.Remotes.MessageEvent:FireAllClients(string.format(msg,playerColour.R*255,playerColour.G*255,playerColour.B*255,ply.DisplayName))
	end)
	
	if ply.PlayerGui:FindFirstChild("InGameGui") then
		ply.PlayerGui.InGameGui:Destroy()
	end
	if ply.Backpack:FindFirstChild("IngameUIScript") then
		ply.Backpack.IngameUIScript:Destroy()
	end

	ply:SetAttribute("Playing",false)
	ply:LoadCharacter()
end