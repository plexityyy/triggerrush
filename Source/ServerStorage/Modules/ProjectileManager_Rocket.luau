local explosionRadius : number = 15
local minExplosionRadius : number = 5
local maxDamage : number = 100
local maxForce : number = 15
local speed : number = 120

local DamageManager = require(game.ServerStorage.Assets.Modules.DamageManager)

local rocket = {}
rocket.__index = rocket

function rocket:new(owner : Player,startingPos : Vector3, endPos : Vector3)
	local newRocket = {}
	setmetatable(newRocket,rocket)
	
	newRocket.Owner = owner
	newRocket.Object = script.Rocket:Clone()
	newRocket.Object.Parent = workspace.Projectiles
	newRocket.Object.CFrame = CFrame.lookAt(startingPos,endPos)
	newRocket.Object.Touched:Connect(function() end) -- to ensure that :GetTouchingParts() can be used
	
	local firePart : Part = Instance.new("Part")
	firePart.Anchored = true
	firePart.CanCollide = false
	firePart.Transparency = 1
	firePart.Size = Vector3.new(.1,.1,.1)
	firePart.Parent = newRocket.Object
	firePart.CFrame = newRocket.Object.FireAttachment.WorldCFrame
	
	local fire : Fire = Instance.new("Fire")
	fire.Color = owner:GetAttribute("CharacterColour")
	fire.Heat = 6
	fire.Size = 2
	fire.Color,fire.SecondaryColor = owner:GetAttribute("CharacterColour"),owner:GetAttribute("CharacterColour")
	fire.Parent = firePart
	
	newRocket.FireObject = firePart
	newRocket.Object.Swoosh:Play()
	newRocket.TickTillExplosion = tick()
	
	return newRocket
end

function rocket:getObject() : BasePart
	return self.Object
end

function rocket:doExplosion(pos : Vector3)
	local ex : Explosion = Instance.new("Explosion")
	ex.BlastRadius = 0
	ex.BlastPressure = 0
	ex.DestroyJointRadiusPercent = 0
	ex.Position = pos
	ex.Parent = workspace
	
	game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireAllClients(pos,"rbxassetid://8447388510")
	
	-- hurt surrounding players
	for _,ply in pairs(game.Players:GetPlayers()) do
		if not ply or not ply.Character then continue end
		if not ply:GetAttribute("Playing") then continue end
		if ply.Character:FindFirstChildWhichIsA("Humanoid").Health <= 0 then continue end
		
		local dist : number = (ply.Character.PrimaryPart.Position - pos).Magnitude
		
		local force : number
		if dist <= minExplosionRadius then
			force = maxForce
		else
			local adjMin : number = dist - minExplosionRadius
			local adjMax : number = explosionRadius - minExplosionRadius
			force = maxForce * ((adjMax - (dist-minExplosionRadius)/explosionRadius))
		end
		local direction : Vector3 = (ply.Character.PrimaryPart.Position - pos).Unit
		
		if dist <= minExplosionRadius then
			local damage : number = maxDamage
			if ply == self.Owner then damage /= 2 end
			ply.Character.PrimaryPart.Velocity = direction*force
			DamageManager:damagePlayerWithAttacker(self.Owner,ply,damage,"Doomscreamer",false)
			continue
		end
		if dist > explosionRadius then continue end
		
		local damage : number = math.max(0, maxDamage * ((explosionRadius/dist)/explosionRadius))
		if damage <= 0 then continue end
		if ply == self.Owner then damage /= 2 end
		
		ply.Character.PrimaryPart.Velocity = direction*force
		DamageManager:damagePlayerWithAttacker(self.Owner,ply,damage,"Doomscreamer",false)
	end
end

function rocket:update(dt : number)
	if not self.Object then return end
	self.Object.CFrame *= CFrame.new(0,0,-speed*dt)
	self.FireObject.CFrame = self.Object.FireAttachment.WorldCFrame
	
	local touchingParts : table<BasePart> = self.Object:GetTouchingParts()
	for i = 1,#touchingParts do
		local p : BasePart = touchingParts[i]
		if not p.CanCollide then continue end
		
		self.TickTillExplosion -= 45
		break
	end
	
	if (tick() - self.TickTillExplosion) >= 30 then -- rocket auto-detonates after 30 secs of doing nothing
		self:doExplosion(self.Object.Position)
		self.Object:Destroy()
		self.Object = nil
	end
end

return rocket