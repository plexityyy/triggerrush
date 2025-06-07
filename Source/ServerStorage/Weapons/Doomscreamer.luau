local weapon = {}

weapon.ammoType = "rockets"
weapon.slotPriority = 7
weapon.weaponIcon = "rbxassetid://94172747511330"

local idleAnim : Animation = Instance.new("Animation")
local fireAnim : Animation = Instance.new("Animation")

idleAnim.AnimationId = "rbxassetid://101600719475607"
fireAnim.AnimationId = "rbxassetid://83648695047932"

local InventoryManager = require(game.ServerStorage.Assets.Modules.InventoryManager)
local ProjectileManager = require(game.ServerStorage.Assets.Modules.ProjectileManager)

local Debris : Debris = game:GetService("Debris")

local data : table<Player, table<any>> = {}
function weapon:equip(ply : Player)
	data[ply] = {
		anims = {
			idle = ply.Character.Humanoid.Animator:LoadAnimation(idleAnim),
			fire = ply.Character.Humanoid.Animator:LoadAnimation(fireAnim)
		},
		timeToTick = tick(),
	}
	
	local screamer : BasePart = script.Launcher:Clone()
	screamer.Parent = ply.Character
	
	local m : Motor6D = Instance.new("Motor6D")
	m.Parent = ply.Character["Right Arm"]
	m.Part0 = ply.Character["Right Arm"]
	m.Part1 = screamer
	m.C1 = CFrame.new(Vector3.new(0.4, -0.5, -0.1)) * CFrame.Angles(math.rad(90),0,0)
	
	data[ply].anims.idle:Play()
	
	game.ReplicatedStorage.Remotes.SummonViewmodel:FireClient(ply,"Doomscreamer")
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
	if ply.Character["Right Arm"]:FindFirstChild("Motor6D") then
		ply.Character["Right Arm"].Motor6D:Destroy()
	end
	ply.Character.Launcher:Destroy()
	
	for _,v in pairs(data[ply].anims) do
		v:Stop()
	end
	
	data[ply] = nil
end

function weapon:attack(ply : Player)
	if (tick() - data[ply].timeToTick) < 0.75 then return end
	if InventoryManager:getPlayerAmmo(ply).rockets <= 0 then return end
	
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
			game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireClient(v,ply.Character.PrimaryPart.Position,"rbxassetid://6027998739",function(sound : Sound)
				sound.PlaybackSpeed = math.random(900,1100)/1000
			end)
		end
	end
	
	--
	local spawnPos : CFrame = ply.Character.PrimaryPart.CFrame*CFrame.new(Vector3.new(0,0,-5))
	local rocket = ProjectileManager:createProjectile("Rocket",ply,spawnPos.Position,game.ReplicatedStorage.Remotes.GetMousePos:InvokeClient(ply))
end

return weapon