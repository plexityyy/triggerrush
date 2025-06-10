local explosionRadius : number = 15
local minExplosionRadius : number = 5
local maxDamage : number = 100
local maxForce : number = 30

local DamageManager = require(game.ServerStorage.Assets.Modules.DamageManager)

local grenade = {}
grenade.__index = grenade

function grenade:new(owner : Player,startingPos : Vector3, direction : Vector3)
	local newGrenade = {}
	setmetatable(newGrenade,grenade)
	
	newGrenade.Owner = owner
	newGrenade.Direction = direction
	newGrenade.Speed = 160
	newGrenade.Gravity = Vector3.new(0,-workspace.Gravity,0)
	newGrenade.HitAnything = false
	newGrenade.Object = script.GrenadeBall:Clone()
	newGrenade.Object.Parent = workspace.Projectiles
	newGrenade.Object.Position = startingPos
	newGrenade.Blacklist = {owner.Character} -- stuff that the grenade should ignore
	
	newGrenade.Object.Touched:Connect(function() end) -- to ensure that :GetTouchingParts() can be used
	newGrenade.Velocity = newGrenade.Direction * newGrenade.Speed
	newGrenade.TickTilKaboom = nil
	newGrenade.AlreadyDoingTick = false
	
	newGrenade.Object.PointLight.Color = owner:GetAttribute("CharacterColour")
	
	return newGrenade
end

function grenade:getObject() : BasePart
	return self.Object
end

function grenade:doExplosion(pos : Vector3)
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
		if not ply.Character:FindFirstChild("HumanoidRootPart") then continue end
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
			DamageManager:damagePlayerWithAttacker(self.Owner,ply,damage,"Kaboominator",false)
			continue
		end
		if dist > explosionRadius then continue end
		
		local damage : number = math.max(0, maxDamage * ((explosionRadius/dist)/explosionRadius))
		if damage <= 0 then continue end
		if ply == self.Owner then damage /= 2 end
		
		ply.Character.PrimaryPart.Velocity = direction*force
		DamageManager:damagePlayerWithAttacker(self.Owner,ply,damage,"Kaboominator",false)
	end
end

function grenade:Touched(hit : BasePart)
	-- check to see if the part is part of a player
	local targetPly : Player? = game.Players:GetPlayerFromCharacter(hit.Parent) or game.Players:GetPlayerFromCharacter(hit.Parent.Parent)
	if targetPly then
		for _,v in pairs(self.Blacklist) do
			if v == targetPly.Character then
				return
			end
		end
		
		self:doExplosion(self:getObject().Position)
		self.Object:Destroy()
		self.Object = nil
		return
	end
	if hit.CanCollide then
		for _,v in pairs(self.Blacklist) do
			if v:IsAncestorOf(hit) then
				return
			end
		end
		
		-- turn ball into a phys object
		self.Object.CanCollide = true
		self.Object.Anchored = false
		self.Object.beep:Play()
		
		self.TickTilKaboom = tick()
		self.HitAnything = true
	end
end

function grenade:update(dt : number)
	if not self.HitAnything then
		self.Velocity += self.Gravity * dt
		self.Object.CFrame += self.Velocity * dt
		
		local touchingParts : table<BasePart?> = self.Object:GetTouchingParts()
		if (#touchingParts > 0) then
			self:Touched(touchingParts[1])
		end
		return
	end
	
	if self.AlreadyDoingTick then return end
	if (tick() - self.TickTilKaboom >= 1) then
		self:doExplosion(self:getObject().Position)
		self.AlreadyDoingTick = true
		
		self.Object:Destroy()
		self.Object = nil
	end
end

return grenade