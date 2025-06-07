return function(event : RemoteEvent, animationName : string)
	local viewmodel : Model? = workspace.CurrentCamera:FindFirstChild("Viewmodel")
	if not viewmodel then warn("Viewmodel does not exist!") return end
	local animationLibrary = require(viewmodel.AnimationsScript)
	
	if not animationLibrary[animationName] then warn("Animation \"" .. animationName .. "\" could not be found.") return end
	animationLibrary[animationName]:Play()
end