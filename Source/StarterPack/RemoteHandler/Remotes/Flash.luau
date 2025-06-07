local Debris : Debris = game:GetService("Debris")
local TweenService : TweenService = game:GetService("TweenService")

local ply : Player = game.Players.LocalPlayer
local plyGui : PlayerGui = ply:WaitForChild("PlayerGui")
local Gui : ScreenGui = plyGui:WaitForChild("InGameGui")

return function(event : RemoteEvent, colour : Color3)
	local flashFrame = Gui.FlashGui:Clone()
	flashFrame.BackgroundColor3 = colour
	flashFrame.Parent = Gui
	flashFrame.Visible = true
	TweenService:Create(flashFrame,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{BackgroundTransparency=1}):Play()
	Debris:AddItem(flashFrame,0.5)
end