return function(event : RemoteEvent, position : Vector3, times : number)
	for i = 1,times do
		local bloodPart : Part = Instance.new("Part",workspace)
		bloodPart.Size = Vector3.new(1,.25,1)
		bloodPart.BrickColor = BrickColor.new("Bright red")
		bloodPart.Position = position
		bloodPart.CollisionGroup = "Ragdolls"
		bloodPart.Velocity = Vector3.new(math.random(-30,30),math.random(1,30),math.random(-30,30))
		
		game:GetService("Debris"):AddItem(bloodPart,math.random(100,450)/1000)
	end
end