local InventoryManager = require(game.ServerStorage.Assets.Modules.InventoryManager)

return function(event : RemoteEvent, player : Player, weaponToSwitchTo : string)
	if not player:GetAttribute("Playing") then return end
	if not InventoryManager:doesPlayerHaveWeapon(player,weaponToSwitchTo) then return end
	if InventoryManager:getPlayerCurrentWeapon(player) == weaponToSwitchTo then return end
	
	-- unequip old weapon
	InventoryManager:getWeapons()[InventoryManager:getPlayerCurrentWeapon(player)]:unequip(player)
	
	-- equip new weapon
	InventoryManager:getInventory(player).currentWeapon = weaponToSwitchTo
	InventoryManager:getWeapons()[weaponToSwitchTo]:equip(player)
	
	InventoryManager:updatePlayerInventory(player)
end