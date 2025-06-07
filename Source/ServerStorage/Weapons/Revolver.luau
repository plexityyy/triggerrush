local weapon = {}

weapon.ammoType = "bullets"
weapon.slotPriority = 3
weapon.weaponIcon = "rbxassetid://16057573220"

local idleAnim : Animation = Instance.new("Animation")
local fireAnim : Animation = Instance.new("Animation")

idleAnim.AnimationId = "rbxassetid://140578312856517"
fireAnim.AnimationId = "rbxassetid://96032428092038"

local DamageManager = require(game.ServerStorage.Assets.Modules.DamageManager)
local InventoryManager = require(game.ServerStorage.Assets.Modules.InventoryManager)

local Debris : Debris = game:GetService("Debris")

local data : table<Player, table<unknown>> = {}
function weapon:equip(ply : Player)
	data[ply] = {
		anims = {
			idle = ply.Character.Humanoid.Animator:LoadAnimation(idleAnim),
			fire = ply.Character.Humanoid.Animator:LoadAnimation(fireAnim)
		},
		timeToTick = tick(),
	}
	
	local revolver : BasePart = script.RevolverGun:Clone()
	revolver.Parent = ply.Character
	
	local m : Motor6D = Instance.new("Motor6D")
	m.Parent = ply.Character
	m.Part0 = ply.Character["Right Arm"]
	m.Part1 = revolver
	m.C1 = CFrame.new(Vector3.new(0.3, -1.35, -0.4)) * CFrame.Angles(0,math.rad(180),math.rad(180))
	
	data[ply].anims.idle:Play()
	
	game.ReplicatedStorage.Remotes.SummonViewmodel:FireClient(ply,"Revolver")
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
	if ply.Character:FindFirstChild("Motor6D") then
		ply.Character.Motor6D:Destroy()
	end
	ply.Character.RevolverGun:Destroy()
	
	for _,v in pairs(data[ply].anims) do
		v:Stop()
	end
	
	data[ply] = nil
end

function weapon:attack(ply : Player)
	if (tick() - data[ply].timeToTick) < 0.7 then return end
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
			game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireClient(v,ply.Character.PrimaryPart.Position,"rbxassetid://4580856203",function(sound : Sound)
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
			if result.Instance.Name == "Head" then
				DamageManager:damagePlayerWithAttacker(ply,victimPly,125,"Revolver",true)
				game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireAllClients(victimPly.Character.PrimaryPart.Position,"rbxassetid://7849569525")
			else
				DamageManager:damagePlayerWithAttacker(ply,victimPly,65,"Revolver")
			end
		end
	end
end

return weapon