local Items : table<string, any> = {
	["Health"] = game.ServerStorage.Assets.Pickups.Healthpack,
	["Ammo"] = game.ServerStorage.Assets.Pickups.Ammopack
}

local ItemSpawns : table<BasePart> = {}
for _,v in pairs(workspace.Map.Spawns:GetChildren()) do
	if v.Name ~= "Player" then
		local objValue : ObjectValue = Instance.new("ObjectValue")
		objValue.Name = "Item"
		objValue.Parent = v
		
		local instance : any = Items[v.Name]:Clone()
		if instance:IsA("Model") then
			instance:PivotTo(v.CFrame)
		else
			instance.CFrame = v.CFrame
		end
		instance.Parent = workspace.Pickups
		objValue.Value = instance
		
		local spawnObj : ObjectValue = Instance.new("ObjectValue")
		spawnObj.Name = "SpawnPoint"
		spawnObj.Parent = instance
		spawnObj.Value = v
		
		table.insert(ItemSpawns,v)
	end
end

game:GetService("RunService").Heartbeat:Connect(function(dt : number)
	for _,v in pairs(ItemSpawns) do
		if v.Item.Value == nil then
			if not v:GetAttribute("Tick") then
				v:SetAttribute("Tick",tick())
			else
				if (tick() - v:GetAttribute("Tick") >= 10) then
					v:SetAttribute("Tick",nil)
					
					local instance : any = Items[v.Name]:Clone()
					if instance:IsA("Model") then
						instance:PivotTo(v.CFrame)
					else
						instance.CFrame = v.CFrame
					end
					instance.Parent = workspace.Pickups
					v.Item.Value = instance
					
					local spawnObj : ObjectValue = Instance.new("ObjectValue")
					spawnObj.Name = "SpawnPoint"
					spawnObj.Parent = instance
					spawnObj.Value = v
				end
			end
		end
	end
end)