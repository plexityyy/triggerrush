local manager = {}
local inventories = {}

local weapons : table<string, unknown> = {}
task.delay(0.05, function() -- delay so that the "recursive" error doesnt occur
	for _,wpn in pairs(game.ServerStorage.Assets.Weapons:GetChildren()) do
		weapons[wpn.Name] = require(wpn)
	end
end)

function manager:getWeapons()
	return weapons
end

function manager:getInventories() : table<any>
	return inventories
end

function manager:getInventory(ply : Player)
	return inventories[ply]
end

function manager:destroyInventory(ply : Player)
	inventories[ply] = nil
end

function manager:createInventory(ply : Player)
	inventories[ply] = {
		wpns = {
			{name="Dagger"},
			{name="Pistol"},
			{name="Trench Shotgun"},
			{name="Sten Gun"},
			{name="Revolver"},
			{name="Kaboominator"},
			{name="Doomscreamer"}
		},
		ammo = {
			bullets = 32,
			shells = 12,
			grenades = 3,
			rockets = 2
		},
		currentWeapon = "Dagger"
	}
end

function manager:addWeapon(ply : Player, weapon : string)
	if self:doesPlayerHaveWeapon(ply,weapon) then return end
	table.insert(inventories[ply].wpns,{name=weapon,ammo=require(game.ServerStorage.Assets.Weapons[weapon]).defaultAmmo})
end

function manager:getPlayerAmmo(ply : Player) : table<string, number>?
	if not inventories[ply] then return nil end
	return inventories[ply].ammo
end

local ammoLimits = {
	["bullets"] = 128,
	["shells"] = 64,
	["grenades"] = 12,
	["rockets"] = 6
}
function manager:addPlayerAmmo(ply : Player, class : string, amount : number)
	local ivn = self:getInventory(ply)
	
	ivn.ammo[class] += amount
	if ivn.ammo[class] > ammoLimits[class] then
		ivn.ammo[class] = ammoLimits[class]
	end
end

function manager:doesPlayerHaveWeapon(ply : Player, weapon : string) : boolean
	if not inventories[ply] then return false end
	
	for _,v in pairs(inventories[ply].wpns) do
		if v.name == weapon then
			return true
		end
	end
	return false
end

function manager:updatePlayerInventory(ply : Player)
	
	local stuff = {}
	for _,v in pairs(inventories[ply].wpns) do
		table.insert(stuff,{
			name = v.name,
			icon = weapons[v.name].weaponIcon,
			priority = weapons[v.name].slotPriority,
			equipped = self:getPlayerCurrentWeapon(ply) == v.name
		})
	end
	table.sort(stuff,function(a,b)
		return a.priority < b.priority
	end)
	
	game.ReplicatedStorage.Remotes.UpdateInventoryUI:FireClient(ply,stuff)
end

function manager:getPlayerCurrentWeapon(ply : Player) : string?
	if not inventories[ply] then return nil end
	return inventories[ply].currentWeapon
end

return manager