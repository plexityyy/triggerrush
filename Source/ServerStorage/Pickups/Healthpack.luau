script.Parent.PrimaryPart.Touched:Connect(function() end)

--
local orientation : number = 0
local ogCFrame = script.Parent.PrimaryPart.CFrame
game:GetService("RunService").Heartbeat:Connect(function(dt : number)
	local touchingParts = script.Parent.PrimaryPart:GetTouchingParts()
	if #touchingParts > 0 then
		for _,part in pairs(touchingParts) do
			local ply : Player = game.Players:GetPlayerFromCharacter(part.Parent) or game.Players:GetPlayerFromCharacter(part.Parent.Parent)
			if not ply then continue end
			
			game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireAllClients(script.Parent.PrimaryPart.Position,"rbxassetid://17356010927",function(sound : Sound)
				sound.Volume = 0.2
			end)
			
			ply.Character:FindFirstChildWhichIsA("Humanoid").Health += 50
			game.ReplicatedStorage.Remotes.Flash:FireClient(ply,Color3.fromRGB(255,0,0))
			script.Parent:Destroy()
			return
		end
	end
	
	--
	orientation += 3*dt
	script.Parent:PivotTo(ogCFrame * CFrame.Angles(0,-orientation,0))
end)