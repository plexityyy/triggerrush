local TweenService : TweenService = game:GetService("TweenService")
local Debris : Debris = game:GetService("Debris")

return function(event : RemoteEvent, pos : Vector3, amount : number, criticalHit : boolean)
	local damagePart : BasePart = game.ReplicatedStorage.Assets.DamagePart:Clone()
	if criticalHit then
		game.Players.LocalPlayer.PlayerGui.Sounds.criticalHitDealt:Play()
		damagePart.BillboardGui.criticalLabel.Visible = true
		damagePart.BillboardGui.TextLabel.Size = UDim2.new(1,0,0.5,0)
		damagePart.BillboardGui.TextLabel.Position = UDim2.new(0,0,0.5,0)
	end
	damagePart.BillboardGui.TextLabel.Text = string.format("-%s",tostring(math.floor(amount)))
	damagePart.Position = pos
	damagePart.Parent = workspace.CurrentCamera
	
	Debris:AddItem(damagePart,3)
	TweenService:Create(damagePart,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position=pos+Vector3.new(0,2,0)}):Play()
	task.wait(1.5)
	TweenService:Create(damagePart.BillboardGui.TextLabel,TweenInfo.new(1.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency=1,TextStrokeTransparency=1}):Play()
	TweenService:Create(damagePart.BillboardGui.criticalLabel,TweenInfo.new(1.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency=1,TextStrokeTransparency=1}):Play()
end