local ply : Player = game.Players.LocalPlayer
local plyGui : PlayerGui = ply:WaitForChild("PlayerGui")
local coreGui : ScreenGui = plyGui:WaitForChild("CoreGui")

return function(event : RemoteEvent, message : string)
	coreGui.Sounds.MessageSound:Play()
	
	if (#coreGui.ChatBoxLabel.MessagesFrame:GetChildren()) > 6 then
		for _,v in pairs(coreGui.ChatBoxLabel.MessagesFrame:GetChildren()) do
			if v:IsA("UIListLayout") then continue end -- we dont wanna accidentally destroy this thing
			v:Destroy()
			break
		end
	end
	
	local msgLabel = script.MessageLabel:Clone()
	msgLabel.Text = message
	msgLabel.Parent = coreGui.ChatBoxLabel.MessagesFrame
	msgLabel.DecayScript.Enabled = true
end