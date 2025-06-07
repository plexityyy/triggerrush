local Players : Players = game:GetService("Players")

if workspace.CurrentCamera:FindFirstChild("Viewmodel") then workspace.CurrentCamera.Viewmodel:Destroy() end

local ply : Player = Players.LocalPlayer
task.delay(1,function()
	game:GetService("RunService").RenderStepped:Connect(function()
		ply.CameraMinZoomDistance = 20
		ply.CameraMaxZoomDistance = 20
		ply.CameraMode = Enum.CameraMode.Classic
	end)
end)

--
for i = 4,1,-1 do
	script.Parent.respawning.Text = "You will respawn in " .. tostring(i) .. "..."
	task.wait(1)
end

script.Parent.respawning.Text = "LET'S GO! :D"
script.Parent.Beep:Play()