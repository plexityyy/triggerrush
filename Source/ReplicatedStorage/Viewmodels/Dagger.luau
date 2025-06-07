local humanoid : Humanoid = script.Parent:FindFirstChild("Humanoid") or script.Parent:WaitForChild("Humanoid")
local animator : Animator = humanoid:FindFirstChildWhichIsA("Animator")

-- "stuff : table<type1, type2> = {}" should be an actual Luau feature...
local playable : table<string, AnimationTrack> = {
	["Equip"] = animator:LoadAnimation(script.Parent:WaitForChild("Equip")),
	["Idle"] = animator:LoadAnimation(script.Parent:WaitForChild("Idle")),
	["Attack1"] = animator:LoadAnimation(script.Parent:WaitForChild("Attack1")),
	["Attack2"] = animator:LoadAnimation(script.Parent:WaitForChild("Attack2")),
}

playable.Equip:GetMarkerReachedSignal("start"):Connect(function()
	workspace.ViewmodelSounds.Equip:Play()
end)

for i = 1,2 do
	playable["Attack" .. tostring(i)]:GetMarkerReachedSignal("start"):Connect(function()
		workspace.ViewmodelSounds.Slash.TimePosition = 0.25
		workspace.ViewmodelSounds.Slash:Play()
	end)
end

return playable