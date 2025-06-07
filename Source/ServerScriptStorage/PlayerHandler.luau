local Players : Players = game:GetService("Players")
local InsertService : InsertService = game:GetService("InsertService")

local DataStoreService : DataStoreService = game:GetService("DataStoreService")
local playerSettingsStore : DataStore = DataStoreService:GetDataStore("PlayerSettings")

local InventoryManager = require(game.ServerStorage.Assets.Modules.InventoryManager)

local function playersAroundArea(pos : Vector3, dist : number) : number
	local amount : number = 0
	for _,v in pairs(game.Players:GetPlayers()) do
		if not v:GetAttribute("Playing") then continue end
		
		local part : Part? = nil
		repeat task.wait() -- "WaitForChild()" doesn't help.
			part = v.Character:FindFirstChild("HumanoidRootPart") or v.Character:FindFirstChild("Torso") or v.Character:FindFirstChild("Left Arm") or v.Character:FindFirstChild("Right Arm") or v.Character:FindFirstChild("Right Leg") or v.Character:FindFirstChild("Left Leg")
		until part
		
		if (part.Position - pos).Magnitude <= dist then
			amount += 1
		end
	end
	return amount
end

local accessoriesCache : table<number, Accessory> = {}
Players.PlayerAdded:Connect(function(ply : Player)
	ply:SetAttribute("Frags",0)
	ply:SetAttribute("Deaths",0)
	ply:SetAttribute("Ping",math.floor(ply:GetNetworkPing()*1000))
	
	ply:SetAttribute("CharacterColour",Color3.fromRGB(255,0,0))
	ply:SetAttribute("CharacterShirt","Classic")
	ply:SetAttribute("CharacterPants","Classic")
	ply:SetAttribute("CharacterAccessory1","Red Roblox Cap")
	ply:SetAttribute("CharacterAccessory2","none")
	ply:SetAttribute("CharacterGender","Male")
	
	task.spawn(function()
		local data : table<any>? = nil
		local s,e = pcall(function()
			data = playerSettingsStore:GetAsync(ply.UserId)
		end)
		if (data) then
			ply:SetAttribute("CharacterColour",Color3.fromHSV(data.colourHue,1,1))
			ply:SetAttribute("CharacterShirt",data.shirt)
			ply:SetAttribute("CharacterPants",data.pants)
			ply:SetAttribute("CharacterAccessory1",data.accessory1)
			ply:SetAttribute("CharacterAccessory2",data.accessory2)
			ply:SetAttribute("CharacterGender",data.gender)
		end
	end)
	
	ply:SetAttribute("Playing",false)
	
	task.delay(0.5, function()
		local playerColour : Color3 = ply:GetAttribute("CharacterColour")
		local result : string = "<font color=\"rgb(%d,%d,%d)\">%s</font> has joined the server!"
		game.ReplicatedStorage.Remotes.MessageEvent:FireAllClients(string.format(result,playerColour.R*255,playerColour.G*255,playerColour.B*255,ply.DisplayName))
	end)
	
	workspace.GlobalSounds.playerconnected:Play()
	
	ply.CharacterAdded:Connect(function(chr : Model)
		local humanoid : Humanoid = chr:FindFirstChildWhichIsA("Humanoid") or chr:WaitForChild("Humanoid",2)
		local rootPart : Part = chr:WaitForChild("HumanoidRootPart",2)
		
		if not ply:GetAttribute("Playing") then
			game.ServerStorage.Assets.Interfaces.MenuGui:Clone().Parent = ply.PlayerGui
			for _,part in pairs(chr:GetDescendants()) do
				if not part:IsA("BasePart") then continue end
				part:Destroy()
			end
			return
		end
		
		local ingameScript : LocalScript = game.ServerStorage.Assets.Scripts.IngameUIScript:Clone()
		--local movementScript : LocalScript = game.ServerStorage.Assets.Scripts.MovementScript:Clone()
		
		game.ServerStorage.Assets.Interfaces.InGameGui:Clone().Parent = ply.PlayerGui
		
		ingameScript.Parent = ply.Backpack
		--movementScript.Parent = ply.Backpack
		
		local ff : ForceField = Instance.new("ForceField")
		ff.Parent = ply.Character
		game:GetService("Debris"):AddItem(ff,5)
		
		local oldHealth : number = humanoid.Health
		humanoid.HealthChanged:Connect(function()
			if humanoid.Health < oldHealth then
				local difference : number = oldHealth-humanoid.Health
				local timesToSplatter : number = math.floor(difference%6)
				
				game.ReplicatedStorage.Remotes.BloodSplatter:FireAllClients(rootPart.Position,timesToSplatter)
			end
			oldHealth = humanoid.Health
		end)
		
		humanoid.Died:Once(function()
			if ff then ff:Destroy() end
			ply:SetAttribute("Attacking",nil)
			
			if not ply:FindFirstChild("confirmed") then
				if ply:FindFirstChild("killerID") then
					ply.killerID.Value:SetAttribute("Frags",ply.killerID.Value:GetAttribute("Frags")+1)
					game.ReplicatedStorage.Remotes.NewKillfeed:FireAllClients(ply.killerID.Value,ply)
				else
					game.ReplicatedStorage.Remotes.NewKillfeed:FireAllClients(nil,ply)
				end
			end
			
			InventoryManager:getWeapons()[InventoryManager:getPlayerCurrentWeapon(ply)]:unequip(ply)
			InventoryManager:destroyInventory(ply)
			
			ply:SetAttribute("Deaths",ply:GetAttribute("Deaths")+1)
			
			ingameScript:Destroy()
			--movementScript:Destroy()
			ply.PlayerGui.InGameGui:Destroy()
			
			game.ServerStorage.Assets.Interfaces.DeadGui:Clone().Parent = ply.PlayerGui
			
			game.ReplicatedStorage.Remotes.BloodSplatter:FireAllClients(rootPart.Position,math.random(5,20))
			
			local hue : number,_,_ = ply:GetAttribute("CharacterColour"):ToHSV()
			game.ReplicatedStorage.Remotes.CreateDoll:FireAllClients(rootPart.CFrame,{
				shirtId = require(game.ReplicatedStorage.Assets.Cosmetics.Shirts[ply:GetAttribute("CharacterShirt")]).texture,
				pantsId = require(game.ReplicatedStorage.Assets.Cosmetics.Pants[ply:GetAttribute("CharacterPants")]).texture,
				hue = hue,
				accessory1 = ply:GetAttribute("CharacterAccessory1"),
				accessory2 = ply:GetAttribute("CharacterAccessory2"),
				isFemale = ply:GetAttribute("CharacterGender") == "Female"
			})
			
			local itemCache : Model = game.ServerStorage.Assets.Pickups.ItemCache:Clone()
			itemCache.Parent = workspace.Pickups
			itemCache:PivotTo(CFrame.new(chr.PrimaryPart.Position))
			game:GetService("Debris"):AddItem(itemCache,60)
			
			for _,v in pairs(chr:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("Accessory") then
					v:Destroy()
				end
			end
		end)
		
		humanoid.JumpPower = 35
		
		task.wait(0.1)
		InventoryManager:createInventory(ply)
		InventoryManager:getWeapons()[InventoryManager:getPlayerCurrentWeapon(ply)]:equip(ply)
		InventoryManager:updatePlayerInventory(ply)
		
		-- move player to a spawnpoint with the least surrounding players
		local possiblePoints : table<unknown> = {}
		for _,v in pairs(workspace.Map.Spawns:GetChildren()) do
			if v.Name == "Player" then
				table.insert(possiblePoints,{
					point = v,
					amount = playersAroundArea(v.Position,300)
				})
			end
		end
		
		table.sort(possiblePoints,function(a,b)
			return a.amount > b.amount
		end)
		
		-- gather all points w/ the same amount of surrounding players
		local currentAmount = possiblePoints[1].amount
		local currentSelection : table<Vector3> = {}
		for _,v in pairs(possiblePoints) do
			if v.amount == currentAmount then
				table.insert(currentSelection,v.point.Position)
			end
		end
		
		ply.Character:WaitForChild(ply.Character.PrimaryPart.Name) -- wait until the PrimaryPart has loaded
		
		-- ...then teleport player to a random point
		ply.Character:PivotTo(CFrame.new(currentSelection[math.random(1,#currentSelection)]))
		
		-- give character a proper appearance
		-- giving them gender
		do
			if ply:GetAttribute("CharacterGender") == "Female" then
				local cMesh : CharacterMesh = script.CharacterMesh:Clone()
				cMesh.Parent = ply.Character
			end
		end
		
		-- assigning body colours
		do
			local bodyColours : BodyColors = ply.Character:FindFirstChildWhichIsA("BodyColors")
			for _,v in pairs({"LeftArmColor3","RightArmColor3","TorsoColor3"}) do
				bodyColours[v] = ply:GetAttribute("CharacterColour")
			end
		end
		
		-- giving them shirt
		do
			local shirt : string = ply:GetAttribute("CharacterShirt")
			if game.ReplicatedStorage.Assets.Cosmetics.Shirts:FindFirstChild(shirt) then
				local shirtFile = require(game.ReplicatedStorage.Assets.Cosmetics.Shirts:FindFirstChild(shirt))
				ply.Character:FindFirstChildWhichIsA("Shirt").ShirtTemplate = shirtFile.texture
			end
		end
		
		-- giving them pants
		do
			local pants : string = ply:GetAttribute("CharacterPants")
			if game.ReplicatedStorage.Assets.Cosmetics.Pants:FindFirstChild(pants) then
				local pantsFile = require(game.ReplicatedStorage.Assets.Cosmetics.Pants:FindFirstChild(pants))
				ply.Character:FindFirstChildWhichIsA("Pants").PantsTemplate = pantsFile.texture
			end
		end
		
		-- giving them accessories
		do
			for i = 1,2 do
				local chosenAccessory : string = ply:GetAttribute("CharacterAccessory" .. tostring(i))
				if game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(chosenAccessory) then
					local accessoryFile = require(game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(chosenAccessory))
					local accessoryId : number = accessoryFile.id
					
					if not accessoriesCache[accessoryId] then
						local newObject : Model = InsertService:LoadAsset(accessoryId)
						local newAccessory : Accessory = newObject:GetChildren()[1]
						newAccessory.Parent = nil
						
						accessoriesCache[accessoryId] = newAccessory
						newObject:Destroy()
					end
					
					local acc : Accessory = accessoriesCache[accessoryId]:Clone()
					acc.Parent = workspace
					humanoid:AddAccessory(acc)
				end
			end
		end
	end)
end)

game.Players.PlayerRemoving:Connect(function(ply : Player)
	local hue : number, _ : nil, _ : nil = ply:GetAttribute("CharacterColour"):ToHSV()
	local data : table<any> = {
		colourHue = hue,
		shirt = ply:GetAttribute("CharacterShirt"),
		pants = ply:GetAttribute("CharacterPants"),
		accessory1 = ply:GetAttribute("CharacterAccessory1"),
		accessory2 = ply:GetAttribute("CharacterAccessory2"),
		gender = ply:GetAttribute("CharacterGender")
	}
	playerSettingsStore:SetAsync(ply.UserId,data)
	
	--
	
	local playerColour : Color3 = ply:GetAttribute("CharacterColour")
	local result : string = "<font color=\"rgb(%d,%d,%d)\">%s</font> has left the server!"
	game.ReplicatedStorage.Remotes.MessageEvent:FireAllClients(string.format(result,playerColour.R*255,playerColour.G*255,playerColour.B*255,ply.DisplayName))
	
	workspace.GlobalSounds.playerdisconnected:Play()
end)

local updatePingTimer : number = 0
local updateAttacktimer : number = 0
game:GetService("RunService").Heartbeat:Connect(function(dt : number)
	updatePingTimer += dt
	if updatePingTimer >= 60 then
		for _,v in pairs(Players:GetPlayers()) do
			v:SetAttribute("Ping",math.floor(v:GetNetworkPing()*1000))
		end
		
		updatePingTimer = 0
	end
	
	updateAttacktimer += dt
	if updateAttacktimer >= 1/66 then
		for _,v in pairs(Players:GetPlayers()) do
			if not v then continue end
			if not v.Character then continue end
			if not v:GetAttribute("Playing") then continue end
			if v:GetAttribute("Attacking") then
				InventoryManager:getWeapons()[InventoryManager:getPlayerCurrentWeapon(v)]:attack(v)
			end
		end
		updateAttacktimer = 0
	end
end)