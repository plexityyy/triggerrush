local weapon = {}

weapon.ammoType = "bullets"
weapon.slotPriority = 5
weapon.weaponIcon = "rbxassetid://121583451009447"

local DamageManager = require(game.ServerStorage.Assets.Modules.DamageManager)
local InventoryManager = require(game.ServerStorage.Assets.Modules.InventoryManager)

local Debris : Debris = game:GetService("Debris")

local gunIdleAnimation : Animation = Instance.new("Animation")
local gunFireAnimation : Animation = Instance.new("Animation")

gunIdleAnimation.AnimationId = "http://www.roblox.com/Asset?ID=95389685"
gunFireAnimation.AnimationId = "http://www.roblox.com/Asset?ID=95390146"

local data : table<Player, table<unknown>> = {}
function weapon:equip(ply : Player)
	data[ply] = {
		anims = {
			idle = ply.Character.Humanoid.Animator:LoadAnimation(gunIdleAnimation),
			fire = ply.Character.Humanoid.Animator:LoadAnimation(gunFireAnimation)
		},
		timeToTick = tick()+0.8,
	}
	
	local stenModel : Part = script.StenGun:Clone()
	stenModel.Parent = ply.Character
	
	local motor : Motor6D = Instance.new("Motor6D")
	motor.Name = "StenMotor"
	motor.Parent = ply.Character["Right Arm"]
	motor.Part0 = ply.Character["Right Arm"]
	motor.Part1 = stenModel
	motor.C1 = CFrame.new(0.2,-0.5,0.9) * CFrame.Angles(math.rad(90),0,0)
	
	data[ply].anims.idle:Play()
	
	game.ReplicatedStorage.Remotes.SummonViewmodel:FireClient(ply,"Sten Gun")
	game.ReplicatedStorage.Remotes.PlayViewmodelAnimation:FireClient(ply,"Equip")
	game.ReplicatedStorage.Remotes.PlayViewmodelAnimation:FireClient(ply,"Idle")
	
	local ammo = InventoryManager:getPlayerAmmo(ply)
	game.ReplicatedStorage.Remotes.UpdateAmmoUI:FireClient(ply,{
		displayAmmo = self.ammoType,
		munitions = {
			bullets = ammo.bullets,
			shells = ammo.shells,
			grenades = ammo.grenades,
			rockets = ammo.rockets
		}
	})
end

function weapon:unequip(ply : Player)
	if ply.Character["Right Arm"]:FindFirstChild("StenMotor") then
		ply.Character["Right Arm"].StenMotor:Destroy()
	end
	ply.Character.StenGun:Destroy()
	
	for _,v in pairs(data[ply].anims) do
		v:Stop()
	end
	
	data[ply] = nil
end

function weapon:attack(ply : Player)
	if (tick() - data[ply].timeToTick) < 0.1 then return end
	if InventoryManager:getPlayerAmmo(ply).bullets <= 0 then return end

	InventoryManager:getInventory(ply).ammo[self.ammoType] -= 1
	local ammo = InventoryManager:getPlayerAmmo(ply)
	game.ReplicatedStorage.Remotes.UpdateAmmoUI:FireClient(ply,{
		displayAmmo = self.ammoType,
		munitions = {
			bullets = ammo.bullets,
			shells = ammo.shells,
			grenades = ammo.grenades,
			rockets = ammo.rockets
		}
	})

	data[ply].timeToTick = tick()
	data[ply].anims.fire:Play()

	game.ReplicatedStorage.Remotes.PlayViewmodelAnimation:FireClient(ply,"Fire")

	do
		for _,v in pairs(game.Players:GetPlayers()) do
			if v == ply then
				continue
			end
			game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireClient(v,ply.Character.PrimaryPart.Position,"rbxassetid://15155508377",function(sound : Sound)
				sound.PlaybackSpeed = math.random(900,1100)/1000
			end)
		end
	end

	local flashlight : PointLight = Instance.new("PointLight")
	flashlight.Color = Color3.fromRGB(255,255,0)
	flashlight.Brightness = 1.5
	flashlight.Range = 4
	flashlight.Shadows = true
	flashlight.Parent = ply.Character.PrimaryPart
	Debris:AddItem(flashlight,0.1)

	--

	local origin : Vector3 = ply.Character.Head.Position
	local mousePos : Vector3 = game.ReplicatedStorage.Remotes.GetMousePos:InvokeClient(ply)

	local direction : Vector3 = (mousePos - origin).Unit*1200

	local rParams = RaycastParams.new()

	local whitelist : table<any> = {workspace.Map}
	for _,v in pairs(game.Players:GetPlayers()) do
		if v == ply then continue end
		for _,part in pairs(v.Character:GetChildren()) do
			if not part:IsA("BasePart") then continue end
			table.insert(whitelist,part)
		end
	end
	rParams.FilterDescendantsInstances = whitelist
	rParams.FilterType = Enum.RaycastFilterType.Include
	rParams.IgnoreWater = true

	local result : RaycastResult? = workspace:Raycast(origin,direction,rParams)
	if result then
		local victimPly : Player? = game.Players:GetPlayerFromCharacter(result.Instance.Parent)
		if victimPly then
			DamageManager:damagePlayerWithAttacker(ply,victimPly,24,"Sten Gun")
		end
	end
end

return weapon