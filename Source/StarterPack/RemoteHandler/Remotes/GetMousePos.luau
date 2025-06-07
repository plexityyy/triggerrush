-- taken from https://devforum.roblox.com/t/how-to-get-3d-position-from-middle-of-screen/1601003/9

return function(event : RemoteFunction) : Vector3
	local LEN_IN_STUDS = 100

	local worldPoint = workspace.CurrentCamera:WorldToScreenPoint(workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 2) 
	local unitRay = workspace.CurrentCamera:ScreenPointToRay(worldPoint.X, worldPoint.Y)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {workspace.CurrentCamera, game.Players.LocalPlayer.Character, workspace.Map.Spawns, workspace.Projectiles}
	local rayRes = workspace:Raycast(unitRay.Origin, unitRay.Direction * LEN_IN_STUDS, rayParams)

	return rayRes and rayRes.Position or unitRay.Origin + unitRay.Direction * LEN_IN_STUDS
end