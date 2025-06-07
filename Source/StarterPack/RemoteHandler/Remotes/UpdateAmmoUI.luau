local ply : Player = game.Players.LocalPlayer
local plyGui : PlayerGui = ply:WaitForChild("PlayerGui")
local gui : ScreenGui = plyGui:WaitForChild("InGameGui")

return function(event : RemoteEvent, stuff : table<unknown>)
	if not stuff.displayAmmo then
		gui.AmmoFrame.Visible = false
	else
		gui.AmmoFrame.Frame.currentAmmo.Text = tostring(stuff.munitions[stuff.displayAmmo])
		gui.AmmoFrame.Visible = true
	end
	
	gui.MunitionsFrame.Frame.Frame.bulletsLabel.Text = "Bullets : <b>" .. stuff.munitions.bullets .. "</b>"
	gui.MunitionsFrame.Frame.Frame.shellsLabel.Text = "Shells : <b>" .. stuff.munitions.shells .. "</b>"
	gui.MunitionsFrame.Frame.Frame.grenadesLabel.Text = "Grenades : <b>" .. stuff.munitions.grenades .. "</b>"
	gui.MunitionsFrame.Frame.Frame.rocketsLabel.Text = "Rockets : <b>" .. stuff.munitions.rockets .. "</b>"
end