local ply : Player = game.Players.LocalPlayer

local root : ScreenGui = script.Parent.Parent
local rootMenu : Frame = root.CharacterMenu

local rig : Model = rootMenu.Selection.Frame.ViewportFrame.Character

-- colour
rootMenu.Selection.Frame.TabsFrame.Frame.ColourButton.MouseButton1Click:Connect(function()
	rootMenu.Selection.Frame.ColourPicker.Visible = not rootMenu.Selection.Frame.ColourPicker.Visible
end)

rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.FocusLost:Connect(function()
	local hue : number? = tonumber(rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.Text)
	if not hue then
		rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.Text = "100"
		hue = 100
	end
	if hue < 0 then
		hue = 0
	elseif hue > 100 then
		hue = 100
	end
	rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.Text = tostring(hue)
	
	hue /= 100
	
	rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.TextColor3 = Color3.fromHSV(hue,1,1)
	rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.PlaceholderColor3 = Color3.fromHSV(hue,1,0.7)
	
	rootMenu.Selection.Frame.ColourPicker.Frame.ExampleFrame.Frame.BackgroundColor3 = Color3.fromHSV(hue,1,1)
	rootMenu.Selection.Frame.ColourPicker.Frame.ExampleFrame.Frame.TextLabel.TextColor3 = Color3.fromHSV(hue,1,1)
	
	local bColours : BodyColors = rig:FindFirstChildWhichIsA("BodyColors")
	bColours.LeftArmColor3 = Color3.fromHSV(hue,1,1)
	bColours.RightArmColor3 = Color3.fromHSV(hue,1,1)
	bColours.TorsoColor3 = Color3.fromHSV(hue,1,1)
	
	game.ReplicatedStorage.Remotes.ChangeCharacter:FireServer("hue",hue)
end)
-- gender
rootMenu.Selection.Frame.TabsFrame.Frame.GenderButton.MouseButton1Click:Connect(function()
	if ply:GetAttribute("CharacterGender") == "Male" then
		rootMenu.Selection.Frame.TabsFrame.Frame.GenderButton.Text = "Betty-Bloxxer (Female)..."
		rootMenu.Selection.Frame.TabsFrame.Frame.GenderButton.TextColor3 = Color3.fromRGB(247, 131, 255)
		
		local m : CharacterMesh = script.FemaleMesh:Clone()
		m.Parent = rig
		
		game.ReplicatedStorage.Remotes.ChangeCharacter:FireServer("gender","female")
	else
		rootMenu.Selection.Frame.TabsFrame.Frame.GenderButton.Text = "Billy-/Bexy-Bloxxer (Male/Neutral)..."
		rootMenu.Selection.Frame.TabsFrame.Frame.GenderButton.TextColor3 = Color3.fromRGB(0, 170, 255)
		
		if rig:FindFirstChild("FemaleMesh") then
			rig.FemaleMesh:Destroy()
		end
		
		game.ReplicatedStorage.Remotes.ChangeCharacter:FireServer("gender","male")
	end
end)
-- clothes

-- thnx https://devforum.roblox.com/t/view-port-frame-accessories/227171
local function addAccessory(character, accessory)
	local attachment = accessory.Handle:FindFirstChildOfClass("Attachment")
	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = accessory.Handle
	if attachment then
		local other = character:FindFirstChild(tostring(attachment), true)
		weld.C0 = attachment.CFrame
		weld.C1 = other.CFrame
		weld.Part1 = other.Parent
	else
		weld.C1 = CFrame.new(0, character.Head.Size.Y / 2, 0) * accessory.AttachmentPoint:inverse()
		weld.Part1 = character.Head
	end
	accessory.Handle.CFrame = weld.Part1.CFrame * weld.C1 * weld.C0:inverse()
	accessory.Parent = character
	weld.Parent = accessory.Handle
end

task.wait(0.5)
repeat task.wait() until ply:GetAttribute("CharacterShirt") ~= nil

-- initiate chr
do
	local shirts = game.ReplicatedStorage.Assets.Cosmetics.Shirts
	local pants = game.ReplicatedStorage.Assets.Cosmetics.Pants
	
	-- do shirt
	local shirtData = require(shirts:FindFirstChild(ply:GetAttribute("CharacterShirt")))
	rig:FindFirstChildWhichIsA("Shirt").ShirtTemplate = shirtData.texture
	rootMenu.Selection.Frame.TabsFrame.Frame.ShirtButton.ImageButton.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. shirtData.id .. "&width=420&height=420&format=png"
	rootMenu.Selection.Frame.TabsFrame.Frame.ShirtButton.EquippedLabel.Text = ply:GetAttribute("CharacterShirt")
	
	-- do pants
	local pantsData = require(pants:FindFirstChild(ply:GetAttribute("CharacterPants")))
	rig:FindFirstChildWhichIsA("Pants").PantsTemplate = pantsData.texture
	rootMenu.Selection.Frame.TabsFrame.Frame.PantsButton.ImageButton.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. pantsData.id .. "&width=420&height=420&format=png"
	rootMenu.Selection.Frame.TabsFrame.Frame.PantsButton.EquippedLabel.Text = ply:GetAttribute("CharacterPants")
	
	-- do colour
	local bColours : BodyColors = rig:FindFirstChildWhichIsA("BodyColors")
	local plyColour : Color3 = ply:GetAttribute("CharacterColour")
	for _,v in pairs({"TorsoColor3","LeftArmColor3","RightArmColor3"}) do
		bColours[v] = plyColour
	end
	local hue : number,_,_ = bColours.LeftArmColor3:ToHSV()
	
	rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.Text = tostring(math.floor(hue*100))
	rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.TextColor3 = Color3.fromHSV(hue,1,1)
	rootMenu.Selection.Frame.ColourPicker.Frame.HueBox.PlaceholderColor3 = Color3.fromHSV(hue,1,0.7)
	rootMenu.Selection.Frame.ColourPicker.Frame.ExampleFrame.Frame.BackgroundColor3 = Color3.fromHSV(hue,1,1)
	rootMenu.Selection.Frame.ColourPicker.Frame.ExampleFrame.Frame.TextLabel.TextColor3 = Color3.fromHSV(hue,1,1)
	
	-- do gender
	if ply:GetAttribute("CharacterGender") == "Female" then
		local m : CharacterMesh = script.FemaleMesh:Clone()
		m.Parent = rig
		
		rootMenu.Selection.Frame.TabsFrame.Frame.GenderButton.Text = "Bettybloxxer (Female)..."
		rootMenu.Selection.Frame.TabsFrame.Frame.GenderButton.TextColor3 = Color3.fromRGB(247, 131, 255)
	end
	
	-- do accessories
	local accessoriesTable = game.ReplicatedStorage.Assets.Cosmetics.Accessories:GetChildren()
	for i = 1,2 do
		if not game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(ply:GetAttribute("CharacterAccessory" .. tostring(i))) then
			rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].ImageButton.Image = "rbxassetid://10951216726"
			rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].EquippedLabel.Text = "None"
			continue
		end
		local accessoryObject = game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(ply:GetAttribute("CharacterAccessory" .. tostring(i)))
		local accessoryFile = require(accessoryObject)
		local accessoryID = accessoryFile.id
		rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].ImageButton.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. accessoryID .. "&width=420&height=420&format=png"
		rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].EquippedLabel.Text = ply:GetAttribute("CharacterAccessory" .. tostring(i))
		
		local ac : Accessory = accessoryObject.Hat:Clone()
		ac.Parent = workspace
		ac.Name = "Accessory" .. tostring(i)
		addAccessory(rig,ac)
	end
end

rootMenu.Selection.Frame.TabsFrame.Frame.ShirtButton.ImageButton.MouseButton1Click:Connect(function()
	rootMenu.Selection.Frame.TabsFrame.Frame.Visible = false

	local newFrame : ScrollingFrame = rootMenu.Selection.Frame.TabsFrame.ScrollingFrame:Clone()

	for _,file in pairs(game.ReplicatedStorage.Assets.Cosmetics.Shirts:GetChildren()) do
		local data = require(file)
		local classButton : TextButton = newFrame.None:Clone()
		classButton.Visible = true
		classButton.Name = file.Name
		classButton.NameLabel.Text = classButton.Name
		classButton.IconLabel.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. data.id .. "&width=420&height=420&format=png"
		classButton.Parent = newFrame

		classButton.MouseButton1Click:Once(function()
			rootMenu.Selection.Frame.TabsFrame.Frame.ShirtButton.ImageButton.Image = classButton.IconLabel.Image
			rootMenu.Selection.Frame.TabsFrame.Frame.ShirtButton.EquippedLabel.Text = classButton.Name

			rig:FindFirstChildWhichIsA("Shirt").ShirtTemplate = data.texture
			game.ReplicatedStorage.Remotes.ChangeCharacter:FireServer("shirt",file.Name)

			newFrame:Destroy()
			rootMenu.Selection.Frame.TabsFrame.Frame.Visible = true
		end)
	end
	newFrame.None:Destroy()

	newFrame.Visible = true
	newFrame.Parent = rootMenu.Selection.Frame.TabsFrame
end)

rootMenu.Selection.Frame.TabsFrame.Frame.PantsButton.ImageButton.MouseButton1Click:Connect(function()
	rootMenu.Selection.Frame.TabsFrame.Frame.Visible = false

	local newFrame : ScrollingFrame = rootMenu.Selection.Frame.TabsFrame.ScrollingFrame:Clone()

	for _,file in pairs(game.ReplicatedStorage.Assets.Cosmetics.Pants:GetChildren()) do
		local data = require(file)
		local classButton : TextButton = newFrame.None:Clone()
		classButton.Visible = true
		classButton.Name = file.Name
		classButton.NameLabel.Text = classButton.Name
		classButton.IconLabel.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. data.id .. "&width=420&height=420&format=png"
		classButton.Parent = newFrame

		classButton.MouseButton1Click:Once(function()
			rootMenu.Selection.Frame.TabsFrame.Frame.PantsButton.ImageButton.Image = classButton.IconLabel.Image
			rootMenu.Selection.Frame.TabsFrame.Frame.PantsButton.EquippedLabel.Text = classButton.Name

			rig:FindFirstChildWhichIsA("Pants").PantsTemplate = data.texture
			game.ReplicatedStorage.Remotes.ChangeCharacter:FireServer("pants",file.Name)

			newFrame:Destroy()
			rootMenu.Selection.Frame.TabsFrame.Frame.Visible = true
		end)
	end
	newFrame.None:Destroy()

	newFrame.Visible = true
	newFrame.Parent = rootMenu.Selection.Frame.TabsFrame
end)

for i = 1,2 do
	rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].ImageButton.MouseButton1Click:Connect(function()
		rootMenu.Selection.Frame.TabsFrame.Frame.Visible = false

		local newFrame : ScrollingFrame = rootMenu.Selection.Frame.TabsFrame.ScrollingFrame:Clone()
		newFrame.None.MouseButton1Click:Once(function()
			rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].ImageButton.Image = "rbxassetid://10951216726"
			rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].EquippedLabel.Text = "None"
			
			if rig:FindFirstChild("Accessory" .. tostring(i)) then
				rig["Accessory" .. tostring(i)]:Destroy()
			end
			
			newFrame:Destroy()
			rootMenu.Selection.Frame.TabsFrame.Frame.Visible = true
			game.ReplicatedStorage.Remotes.ChangeCharacter:FireServer("accessory" .. tostring(i),"None")
		end)
		
		for _,f in pairs(game.ReplicatedStorage.Assets.Cosmetics.Accessories:GetChildren()) do
			local file = require(f)
			
			local classButton : TextButton = newFrame.None:Clone()
			classButton.Visible = true
			classButton.Name = f.Name
			classButton.NameLabel.Text = classButton.Name
			classButton.IconLabel.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. file.id .. "&width=420&height=420&format=png"
			classButton.Parent = newFrame
			
			classButton.MouseButton1Click:Once(function()
				rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].ImageButton.Image = classButton.IconLabel.Image
				rootMenu.Selection.Frame.TabsFrame.Frame["Accessory" .. tostring(i) .. "Button"].EquippedLabel.Text = classButton.Name

				if rig:FindFirstChild("Accessory" .. tostring(i)) then
					rig["Accessory" .. tostring(i)]:Destroy()
				end
				local hat = f.Hat:Clone()
				hat.Name = "Accessory" .. tostring(i)
				hat.Parent = workspace
				addAccessory(rig,hat)

				newFrame:Destroy()
				rootMenu.Selection.Frame.TabsFrame.Frame.Visible = true
				
				game.ReplicatedStorage.Remotes.ChangeCharacter:FireServer("accessory" .. tostring(i),f.Name)
			end)
		end
		
		newFrame.Visible = true
		newFrame.Parent = rootMenu.Selection.Frame.TabsFrame
	end)
end