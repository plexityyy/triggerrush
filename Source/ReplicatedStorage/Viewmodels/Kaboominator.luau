local humanoid : Humanoid = script.Parent:FindFirstChild("Humanoid") or script.Parent:WaitForChild("Humanoid")
local animator : Animator = humanoid:FindFirstChildWhichIsA("Animator")

local playable : table<string, AnimationTrack> = {
	["Equip"] = animator:LoadAnimation(script.Parent:WaitForChild("Equip")),
	["Idle"] = animator:LoadAnimation(script.Parent:WaitForChild("Idle")),
	["Fire"] = animator:LoadAnimation(script.Parent:WaitForChild("Fire"))
}

playable.Fire:GetMarkerReachedSignal("start"):Connect(function()
	workspace.ViewmodelSounds.fire.PlaybackSpeed = math.random(900,1100)/1000
	workspace.ViewmodelSounds.fire:Play()
end)

playable.Equip:GetMarkerReachedSignal("start"):Connect(function()
	workspace.ViewmodelSounds.equip:Play()
end)

return playable