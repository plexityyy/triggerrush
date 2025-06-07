local weapon = {}

weapon.ammoType = "shells"
weapon.slotPriority = 4
weapon.weaponIcon = "rbxassetid://15131759883"

local DamageManager = require(game.ServerStorage.Assets.Modules.DamageManager)
local InventoryManager = require(game.ServerStorage.Assets.Modules.InventoryManager)

local Debris : Debris = game:GetService("Debris")

local gunIdleAnimation : Animation = Instance.new("Animation")
local gunFireAnimation : Animation = Instance.new("Animation")

gunIdleAnimation.AnimationId = "rbxassetid://92243292783739"
gunFireAnimation.AnimationId = "rbxassetid://77169286812122"

local data : table<Player, table<unknown>> = {}
function weapon:equip(ply : Player)
	data[ply] = {
		anims = {
			idle = ply.Character.Humanoid.Animator:LoadAnimation(gunIdleAnimation),
			fire = ply.Character.Humanoid.Animator:LoadAnimation(gunFireAnimation)
		},
		timeToTick = tick()-0.3,
	}
	
	local shotgunModel : Model = script.GunHandle:Clone()
	shotgunModel.Parent = ply.Character
	
	local sModel : Motor6D = Instance.new("Motor6D")
	sModel.Name = "ShotugnMotor"
	sModel.Parent = ply.Character["Right Arm"]
	sModel.Part0 = ply.Character["Right Arm"]
	sModel.Part1 = shotgunModel.Base
	
	data[ply].anims.idle:Play()
	
	game.ReplicatedStorage.Remotes.SummonViewmodel:FireClient(ply,"Trench Shotgun")
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
	if ply.Character["Right Arm"]:FindFirstChild("ShotugnMotor") then
		ply.Character["Right Arm"].ShotugnMotor:Destroy()
	end
	ply.Character.GunHandle:Destroy()
	
	for _,v in pairs(data[ply].anims) do
		v:Stop()
	end
	
	data[ply] = nil
end

local totalAmountOfPellets : number = 13 -- the total amount of pellets the gun will shoot
local totalDamage : number = 100 -- how much overall damage does the gun do (should all pellets hit)
local spreadIntensity : number = 1 -- how drastic the spread will be

local RNGSpread : Random = Random.new(tick())

function weapon:attack(ply : Player)
	if (tick() - data[ply].timeToTick) < 0.95 then return end
	if InventoryManager:getPlayerAmmo(ply).shells <= 0 then return end
	
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
			game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireClient(v,ply.Character.PrimaryPart.Position,"rbxassetid://15155498655",function(sound : Sound)
				sound.PlaybackSpeed = math.random(900,1100)/1000
			end)
		end
	end
	
	local flashlight : PointLight = Instance.new("PointLight")
	flashlight.Color = Color3.fromRGB(255,255,0)
	flashlight.Brightness = 3.5
	flashlight.Range = 4
	flashlight.Shadows = true
	flashlight.Parent = ply.Character.PrimaryPart
	Debris:AddItem(flashlight,0.1)
	
	--
	
	local origin : Vector3 = ply.Character.Head.Position
	local mousePos : Vector3 = game.ReplicatedStorage.Remotes.GetMousePos:InvokeClient(ply)
	
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
	
	local hitPlayers : table<Player, number> = {}
	for i = 1,totalAmountOfPellets do
		local spreadOffset : Vector3 = Vector3.new(0,0,0) -- first pellet is 100% accurate
		if i > 1 then
			spreadOffset = Vector3.new(RNGSpread:NextNumber(-spreadIntensity,spreadIntensity),RNGSpread:NextNumber(-spreadIntensity,spreadIntensity),RNGSpread:NextNumber(-spreadIntensity,spreadIntensity))
		end
		
		local direction : Vector3 = ((mousePos + spreadOffset) - origin).Unit*1200
		local result : RaycastResult? = workspace:Raycast(origin,direction,rParams)
		
		if result then
			local victimPly : Player? = game.Players:GetPlayerFromCharacter(result.Instance.Parent)
			if victimPly then
				
				if hitPlayers[victimPly] then
					hitPlayers[victimPly] += (1/totalAmountOfPellets)*totalDamage
				else
					hitPlayers[victimPly] = (1/totalAmountOfPellets)*totalDamage
				end
				
			end
		end
	end
	
	for i,v in pairs(hitPlayers) do
		DamageManager:damagePlayerWithAttacker(ply,i,v,"Trench Shotgun")
	end
end

return weapon