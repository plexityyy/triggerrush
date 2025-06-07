-- Handles the in-game GUI

local Players : Players = game:GetService("Players")

local Player : Player = Players.LocalPlayer
local Character : Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")

local PlyGui : PlayerGui = Player:WaitForChild("PlayerGui")
local Gui : ScreenGui = PlyGui:WaitForChild("InGameGui")

local InputService : UserInputService = game:GetService("UserInputService")
local RunService : RunService = game:GetService("RunService")

InputService.MouseIconEnabled = false

for _,v in pairs({"AmmoFrame","HealthFrame","MunitionsFrame","ScoreFrame"}) do
	Gui[v].Frame.BackgroundColor3 = Player:GetAttribute("CharacterColour")
end

local oldHealth : number = Humanoid.Health
Humanoid.HealthChanged:Connect(function()
	if Humanoid.Health < oldHealth then
		local hurtPercent = (oldHealth-Humanoid.Health)/Humanoid.MaxHealth
		Gui.hurtFrame.BackgroundTransparency -= hurtPercent
		
		Character.Head.Pain:Play()
	end
	oldHealth = Humanoid.Health
end)

local numbers : table<string, number> = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5,
	Six = 6,
	Seven = 7,
	Eight = 8,
	Nine = 9,
	Zero = 0
}

local pressedCtrlAlready = false
InputService.InputBegan:Connect(function(input : InputObject, gp : boolean)
	if gp then return end
	
	if numbers[input.KeyCode.Name] then
		local numberChosen : number = numbers[input.KeyCode.Name]
		
		for _,slot in pairs(Gui.InventoryFrame:GetChildren()) do
			if slot:IsA("UIListLayout") then continue end
			if tonumber(slot.Frame.ItemSlot.Text) == numberChosen then
				game.ReplicatedStorage.Remotes.SwitchWeapon:FireServer(slot.Name)
				break
			end
		end
		
		return
	end
	
	if input.KeyCode == Enum.KeyCode.LeftControl then
		if not pressedCtrlAlready then
			Gui.WarningMsg.Visible = true
			pressedCtrlAlready = true
			
			task.delay(3, function()
				Gui.WarningMsg.Visible = false
				pressedCtrlAlready = false
			end)
		else
			game.ReplicatedStorage.Remotes.JoinGame:FireServer(false)
		end
		return
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		game.ReplicatedStorage.Remotes.AttackEvent:FireServer(true)
	end
end)

InputService.InputEnded:Connect(function(input : InputObject, gp : boolean)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		game.ReplicatedStorage.Remotes.AttackEvent:FireServer(false)
	end
end)

RunService.RenderStepped:Connect(function(dt : number)
	-- firstperson only
	Player.CameraMinZoomDistance = 0.5
	Player.CameraMaxZoomDistance = 0.5
	Player.CameraMode = Enum.CameraMode.LockFirstPerson
	
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = Humanoid
	workspace.CurrentCamera.FieldOfView = 90
	
	-- velocity updatin'
	Gui.CrosshairLabel.SpeedLabel.Text = math.floor(Character.HumanoidRootPart.Velocity.Magnitude)
	
	-- updating viewmodel pos
	if workspace.CurrentCamera:FindFirstChild("Viewmodel") then
		local vModel : Model = workspace.CurrentCamera.Viewmodel
		
		for _,v in pairs(vModel:GetDescendants()) do
			if v:IsA("BasePart") then
				if not v.CanCollide then continue end
				v.CollisionGroup = "Viewmodels"
				v.CanCollide = false
				v.Massless = true
			end
		end
		
		vModel:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(vModel:GetAttribute("Offset") or Vector3.new(0,0,0)))
	end
	
	-- hurt frame transparency
	Gui.hurtFrame.BackgroundTransparency += 1*dt
	if Gui.hurtFrame.BackgroundTransparency >= 1 then
		Gui.hurtFrame.BackgroundTransparency = 1
	end
	
	-- update Health bar
	Gui.HealthFrame.Frame.HpMain.BarCentre.Frame.Size = UDim2.new(1,0,Humanoid.Health/Humanoid.MaxHealth,0)
	Gui.HealthFrame.Frame.HpMain.BarCentre.HpText.Text = math.floor(Humanoid.Health)
	if (Humanoid.Health <= Humanoid.MaxHealth/2) then
		Gui.HealthFrame.Frame.HpMain.BarCentre.Frame.BackgroundColor3 = Color3.new(1,0,0)
	else
		Gui.HealthFrame.Frame.HpMain.BarCentre.Frame.BackgroundColor3 = Color3.new(1,1,1)
	end
end)