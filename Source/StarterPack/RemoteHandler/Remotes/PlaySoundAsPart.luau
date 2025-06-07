--[[[

	This is was made thanks to Roblox's "alright" Audio engine.
	for whatever reason, putting a global Sound object in a
	player character's limb causes it to sound extremely
	wobbly (at least on the player's screen). thus, this was
	created as a work-around.
	
	this will probably be removed once this problem has been
	fixed, though i somehow doubt it.

]]

return function(event : RemoteEvent, pos : Vector3, id : string, func)
	local sound : Sound = Instance.new("Sound")
	sound.SoundId = id
	
	local part : Part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1,1,1)
	part.Transparency = 1
	part.Position = pos
	part.Parent = workspace.CurrentCamera
	
	sound.Parent = part
	if func then func(sound) end
	
	sound.Ended:Connect(function() part:Destroy() end)
	sound:Play()
end