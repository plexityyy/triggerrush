local function WaitForChildWhichIsA(part : any, class : string, timeout : number?) : any?
	local t = tick()
	timeout = timeout or 2
	
	while task.wait() do
		local p : unknown? = part:FindFirstChildWhichIsA(class)
		if p then return p end
		
		if (tick() - t) >= timeout then
			warn("Took too long!")
			break
		end
	end
end

local firstTime : boolean = true
return function(event : RemoteEvent, viewmodelName : string)
	local viewmodel : Model? = game.ReplicatedStorage.Assets.Viewmodels:FindFirstChild(viewmodelName)
	if not viewmodel then warn("Viewmodel \"" .. viewmodelName .. "\" could not be found.") return end
	local vCln : Model = viewmodel:Clone()
	
	if workspace.CurrentCamera:FindFirstChild("Viewmodel") then
		workspace.CurrentCamera.Viewmodel:Destroy()
	end
	workspace.ViewmodelSounds:ClearAllChildren()
	
	for _,sound in pairs(vCln.PrimaryPart:GetChildren()) do
		if not sound:IsA("Sound") then continue end
		local cln : Sound = sound:Clone()
		cln.Parent = workspace.ViewmodelSounds or workspace:WaitForChild("ViewmodelSounds")
	end
	
	vCln:PivotTo(workspace.CurrentCamera.CFrame)
	vCln.Name = "Viewmodel"
	
	vCln.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	vCln.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
	
	vCln.Parent = workspace.CurrentCamera
	
	if firstTime then
		task.wait(0.5)
		firstTime = false
	end
	local shirt : Shirt = Instance.new("Shirt")
	shirt.Parent = vCln
	shirt.ShirtTemplate = WaitForChildWhichIsA(game.Players.LocalPlayer.Character,"Shirt",5).ShirtTemplate
	
	local bColours : BodyColors = Instance.new("BodyColors")
	local plyBColours = WaitForChildWhichIsA(game.Players.LocalPlayer.Character,"BodyColors",5)
	for _,v in pairs({"HeadColor3","LeftArmColor3","RightArmColor3","LeftLegColor3","RightLegColor3","TorsoColor3"}) do
		bColours[v] = plyBColours[v]
	end
	bColours.Parent = vCln
end