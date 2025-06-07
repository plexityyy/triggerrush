-- Handles the Core GUI

local Players : Players = game:GetService("Players")

local Player : Player = Players.LocalPlayer
local Character : Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")

local PlyGui : PlayerGui = Player:WaitForChild("PlayerGui")
local Gui : ScreenGui = PlyGui:WaitForChild("CoreGui")

local InputService : UserInputService = game:GetService("UserInputService")
local RunService : RunService = game:GetService("RunService")

if not workspace:FindFirstChild("Ragdolls") then
	local ragdollsFolder : Folder = Instance.new("Folder",workspace)
	ragdollsFolder.Name = "Ragdolls"
end

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)

if not workspace:FindFirstChild("ViewmodelSounds") then
	local vSounds : Folder = Instance.new("Folder")
	vSounds.Name = "ViewmodelSounds"
	vSounds.Parent = workspace
end

local audioInput : AudioDeviceInput? = nil
task.spawn(function()
	audioInput = Player:WaitForChild("AudioDeviceInput")
	if audioInput then audioInput.Muted = true end
end)

InputService.InputBegan:Connect(function(input : InputObject, gp : boolean)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		for _,ply in pairs(Players:GetPlayers()) do
			if not ply then continue end
			
			local fr : TextButton = script.PlayerboardFrame:Clone()
			if ply.Name ~= Player.Name then
				fr.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
			end
			fr.NameLabel.Text = ply.DisplayName .. " (@" .. ply.Name .. ")"
			fr.StatsLabel.Text = tostring(ply:GetAttribute("Frags")) .. " | " .. tostring(ply:GetAttribute("Deaths")) .. " | " .. tostring(ply:GetAttribute("Ping"))
			fr.NameLabel.TextColor3,fr.StatsLabel.TextColor3 = ply:GetAttribute("CharacterColour"),ply:GetAttribute("CharacterColour")
			
			fr.Parent = Gui.PlayerboardFrame.Frame.ScrollingFrame
		end
		
		Gui.PlayerboardFrame.Visible = true
	elseif input.KeyCode == Enum.KeyCode.V and audioInput then
		audioInput.Muted = false
		Gui.HealthFrame.Frame.UsingVCIcon.Visible = true
	end
end)
InputService.InputEnded:Connect(function(input : InputObject)
	if input.KeyCode == Enum.KeyCode.Tab then
		for _,v in pairs(Gui.PlayerboardFrame.Frame.ScrollingFrame:GetChildren()) do
			if v:IsA("UIListLayout") then continue end
			v:Destroy()
		end
		
		Gui.PlayerboardFrame.Visible = false
	elseif input.KeyCode == Enum.KeyCode.V and audioInput then
		audioInput.Muted = true
		Gui.HealthFrame.Frame.UsingVCIcon.Visible = false
	end
end)

Gui.ChatBoxLabel:GetPropertyChangedSignal("Text"):Connect(function()
	if #Gui.ChatBoxLabel.Text > 75 then
		Gui.ChatBoxLabel.Text = string.sub(Gui.ChatBoxLabel.Text,1,75)
	end
end)

Gui.ChatBoxLabel.FocusLost:Connect(function(enterPressed : boolean)
	if not enterPressed then return end
	if #Gui.ChatBoxLabel.Text == 0 then return end
	
	game.ReplicatedStorage.Remotes.ChatEvent:FireServer(Gui.ChatBoxLabel.Text)
	Gui.ChatBoxLabel.Text = ""
end)

InputService.InputBegan:Connect(function(input : InputObject)
	if input.KeyCode == Enum.KeyCode.Slash and not Gui.ChatBoxLabel:IsFocused() then
		local oldText : string = Gui.ChatBoxLabel.Text
		Gui.ChatBoxLabel:CaptureFocus()
		RunService.RenderStepped:Wait()
		Gui.ChatBoxLabel.Text = oldText
	end
end)