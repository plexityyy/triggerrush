local root : ScreenGui = script.Parent.Parent

if workspace.CurrentCamera:FindFirstChild("Viewmodel") then
	workspace.CurrentCamera.Viewmodel:Destroy()
end
game:GetService("UserInputService").MouseIconEnabled = true

root.MainMenu.Button["1PlayButton"].MouseButton1Click:Connect(function()
	game.ReplicatedStorage.Remotes.JoinGame:FireServer(true)
end)

root.MainMenu.Button["2CharacterButton"].MouseButton1Click:Connect(function()
	root.MainMenu.Visible = false
	root.CharacterMenu.Visible = true
end)

root.CharacterMenu.gradient.BackButton.MouseButton1Click:Connect(function()
	root.MainMenu.Visible = true
	root.CharacterMenu.Visible = false
end)

--
task.wait(1)
game:GetService("RunService").RenderStepped:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = workspace.Map.CameraCFrame.Value
end)