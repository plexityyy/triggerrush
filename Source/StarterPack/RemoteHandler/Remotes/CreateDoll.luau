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

return function(event : RemoteEvent, cf : CFrame, appearance : table<any>)
	local body = game.ReplicatedStorage.Assets.Ragdoll:Clone()
	body.Parent = workspace.Ragdolls
	body.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	body.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
	body:PivotTo(cf)
	
	body.Torso.Death:Play()
	
	if appearance.isFemale then
		script.FemaleMesh:Clone().Parent = body
	end
	
	body:FindFirstChildWhichIsA("Shirt").ShirtTemplate = appearance.shirtId
	body:FindFirstChildWhichIsA("Pants").PantsTemplate = appearance.pantsId
	local bColours : BodyColors = body:FindFirstChildWhichIsA("BodyColors")
	for _,v in pairs({"LeftArmColor3","RightArmColor3","TorsoColor3"}) do
		bColours[v] = Color3.fromHSV(appearance.hue,1,1)
	end
	
	for i = 1,2 do
		if not game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(appearance["accessory" .. tostring(i)]) then
			continue
		end
		
		local ac = game.ReplicatedStorage.Assets.Cosmetics.Accessories:FindFirstChild(appearance["accessory" .. tostring(i)]).Hat:Clone()
		ac.Parent = workspace
		addAccessory(body,ac)
	end
	
	for _,v in pairs(body:GetChildren()) do
		if v:IsA("BasePart") then
			v.Velocity = Vector3.new(math.random(-45,45),math.random(1,45),math.random(-45,45))
		end
	end
	
	game:GetService("Debris"):AddItem(body,30)
end