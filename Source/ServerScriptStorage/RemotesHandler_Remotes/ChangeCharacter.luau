return function(event : RemoteEvent, ply : Player, category : string, option : unknown)
	if category == "hue" then
		if type(option) ~= "number" then return end
		local actualHue : number = option
		if actualHue < 0 then
			actualHue = 0
		elseif actualHue > 100 then
			actualHue = 100
		end
		
		ply:SetAttribute("CharacterColour",Color3.fromHSV(actualHue,1,1))
	elseif category == "gender" then
		if type(option) ~= "string" then return end
		
		if option == "female" then
			ply:SetAttribute("CharacterGender","Female")
		else
			ply:SetAttribute("CharacterGender","Male")
		end
	elseif category == "shirt" then
		if type(option) ~= "string" then return end
		if not game.ReplicatedStorage.Assets.Cosmetics.Shirts:FindFirstChild(option) then return end

		ply:SetAttribute("CharacterShirt",option)
	elseif category == "pants" then
		if type(option) ~= "string" then return end
		if not game.ReplicatedStorage.Assets.Cosmetics.Pants:FindFirstChild(option) then return end

		ply:SetAttribute("CharacterPants",option)
	elseif category == "accessory1" then
		if type(option) ~= "string" then return end
		if option ~= "None" and not game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(option) then return end
		
		ply:SetAttribute("CharacterAccessory1",option)
	elseif category == "accessory2" then -- largely the same as "accessory1"
		if type(option) ~= "string" then return end
		if option ~= "None" and not game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(option) then return end

		ply:SetAttribute("CharacterAccessory2",option)
	end
end