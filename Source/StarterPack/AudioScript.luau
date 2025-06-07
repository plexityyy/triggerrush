-- Removes core sound effects from all players
-- Also does footstep stuff

local Players : Players = game:GetService("Players")
local LocalPlayer : Player = Players.LocalPlayer
local LocalCharacter : Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid : Humanoid = LocalCharacter:FindFirstChildWhichIsA("Humanoid")
local LocalHead : Part = LocalCharacter:FindFirstChild("Head")

local RunService : RunService = game:GetService("RunService")

local materialToSound : table<string, string> = {
	["Wood"] = "wood",
	["WoodPlanks"] = "wood"
}

local timerDt : number = 0
local footstepDt : number = 0
RunService.RenderStepped:Connect(function(dt : number)
	footstepDt += dt
	if footstepDt >= 0.26 then
		
		if LocalHumanoid.MoveDirection.Magnitude > 0 and LocalHumanoid.FloorMaterial ~= Enum.Material.Air then
			local soundName : string = materialToSound[LocalHumanoid.FloorMaterial.Name] or "generic"
			soundName = "footstep_" .. soundName .. tostring(math.random(1,4))
			LocalHead[soundName]:Play()
			
			footstepDt = 0
		end
		
	end
	
	timerDt += dt
	if timerDt > 1/32 then
	
		for _,ply in pairs(Players:GetPlayers()) do
			if not ply then continue end
			local chr : Model? = ply.Character or ply.CharacterAdded:Wait()
			if not chr then continue end
			local HumanoidRootPart : Part? = chr:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then continue end
			
			for _,v in pairs(HumanoidRootPart:GetChildren()) do
				if v:IsA("Sound") then
					v:Destroy()
				end
			end
		end
		
	end
end)