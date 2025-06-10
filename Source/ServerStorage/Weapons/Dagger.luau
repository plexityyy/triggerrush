local weapon = {}

weapon.ammoType = nil
weapon.slotPriority = 1
weapon.weaponIcon = "rbxassetid://2992801749"

local DamageManager = require(game.ServerStorage.Assets.Modules.DamageManager)
local InventoryManager = require(game.ServerStorage.Assets.Modules.InventoryManager)

local idleAnim : Animation = Instance.new("Animation")
local attack1Anim : Animation = Instance.new("Animation")
local attack2Anim : Animation = Instance.new("Animation")

idleAnim.AnimationId = "rbxassetid://16053870251"
attack1Anim.AnimationId = "rbxassetid://16053875720"
attack2Anim.AnimationId = "rbxassetid://16053878517"

--[[

	For some reason, when players equip and unequip weapons,
	the FPS steadily decreases, only returning to normal when
	they die or return to the menu.

	As a workaround, the server creates as many copies of the
	weapon model as there are player slots, and assigns a copy
	to each player character when they need the weapon.

	It's not ideal, but this is the only way to prevent third-person
	player animations and models from being removed.

]]
local modelCopies : table<unknown> = {}

for i = 1,game.Players.MaxPlayers do
	modelCopies[i] = {
		model = script.DaggerHandle:Clone(),
		taken = false
	}
end

local data : table<Player, table<unknown>> = {}
function weapon:equip(ply : Player)
	local chosenModel : MeshPart? = nil
	for i = 1,#modelCopies do
		if modelCopies[i].taken then continue end
		chosenModel = modelCopies[i].model
		modelCopies[i].taken = true
		break
	end
	
	if chosenModel then
		chosenModel.Parent = ply.Character
		
		local motor : Motor6D = Instance.new("Motor6D")
		motor.Parent = chosenModel
		motor.Part0 = chosenModel
		motor.Part1 = ply.Character["Right Arm"]
		motor.C0 = CFrame.new(Vector3.new(-0.954, -0.443, -0.947)) * CFrame.Angles(0,math.rad(180),math.rad(-90))
	end
	
	data[ply] = {
		anims = {
			idle = ply.Character.Humanoid.Animator:LoadAnimation(idleAnim),
			attack1 = ply.Character.Humanoid.Animator:LoadAnimation(attack1Anim),
			attack2 = ply.Character.Humanoid.Animator:LoadAnimation(attack2Anim)
		},
		timeToTick = tick()-0.4,
		whichAtk = 2
	}
	
	data[ply].anims.idle.Priority = Enum.AnimationPriority.Action
	data[ply].anims.attack1.Priority = Enum.AnimationPriority.Action2
	data[ply].anims.attack2.Priority = Enum.AnimationPriority.Action3
	
	data[ply].anims.idle:Play()
	
	game.ReplicatedStorage.Remotes.SummonViewmodel:FireClient(ply,"Dagger")
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
	if ply.Character:FindFirstChild("DaggerHandle") then
		local model = ply.Character.DaggerHandle
		
		if model:FindFirstChild("Motor6D") then
			model.Motor6D:Destroy()
		end
		
		for i = 1,#modelCopies do
			if not modelCopies[i].taken then continue end
			modelCopies[i].model = model
			modelCopies[i].taken = false
		end
		
		model.Parent = nil
	end
	
	for _,v in pairs(data[ply].anims) do
		v:Stop()
	end
	
	data[ply] = nil
end

function weapon:attack(ply : Player)
	if (tick() - data[ply].timeToTick) < 1 then return end
	data[ply].timeToTick = tick()
	
	data[ply].whichAtk += 1
	if data[ply].whichAtk > 2 then data[ply].whichAtk = 1 end
	
	data[ply].anims["attack" .. tostring(data[ply].whichAtk)]:Play()
	game.ReplicatedStorage.Remotes.PlayViewmodelAnimation:FireClient(ply,"Attack" .. tostring(data[ply].whichAtk))
	
	task.wait(0.1)
	
	for i = 1,4 do
		if InventoryManager:getPlayerCurrentWeapon(ply) ~= "Dagger" then break end
		
		local origin : Vector3 = ply.Character.Head.Position
		local mousePos : Vector3 = game.ReplicatedStorage.Remotes.GetMousePos:InvokeClient(ply)
		
		local direction : Vector3 = (mousePos - origin).Unit*7
		
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
				DamageManager:damagePlayerWithAttacker(ply,victimPly,45,"Dagger")
				game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireAllClients(victimPly.Character.PrimaryPart.Position,"rbxassetid://18512270266")
				break
			end
		end
		
		task.wait(0.02)
	end
end

return weapon