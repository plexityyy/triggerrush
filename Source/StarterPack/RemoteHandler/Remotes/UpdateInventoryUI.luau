local ply : Player = game.Players.LocalPlayer
local plyGui : PlayerGui = ply:WaitForChild("PlayerGui")
local gui : ScreenGui = plyGui:WaitForChild("InGameGui")

return function(event : RemoteEvent, stuff : table<unknown>)
	for _,v in pairs(gui.InventoryFrame:GetChildren()) do
		if v:IsA("UIListLayout") then continue end
		v:Destroy()
	end
	
	--
	
	for i,item in pairs(stuff) do
		local frame : Frame = script.ItemFrame:Clone()
		
		if not item.equipped then
			frame.BackgroundTransparency,frame.Frame.BackgroundTransparency = 1,1
		end
		frame.Frame.ItemIcon.Image = item.icon
		frame.Frame.ItemSlot.Text = tostring(item.priority)
		frame.Name = item.name
		frame.Frame.BackgroundColor3 = ply:GetAttribute("CharacterColour")
		frame.Parent = gui.InventoryFrame
	end
end