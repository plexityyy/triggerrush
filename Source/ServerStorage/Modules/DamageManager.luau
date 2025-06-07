local manager = {}

local Debris : Debris = game:GetService("Debris")
function manager:damagePlayer(victim : Player, amount : number)
	local ff : ForceField? = victim.Character:FindFirstChildWhichIsA("ForceField")
	if ff then ff:Destroy() end
	
	if victim:FindFirstChild("killerID") then
		victim.killerID:Destroy()
	end
	victim.Character.Humanoid:TakeDamage(amount)
end

function manager:damagePlayerWithAttacker(attacker : Player, victim : Player, amount : number, weapon : string, criticalHit : boolean)
	if victim.Character:FindFirstChildWhichIsA("ForceField") then return end
	
	if victim:FindFirstChild("killerID") then
		victim.killerID:Destroy()
	end
	local killerID : ObjectValue = Instance.new("ObjectValue")
	killerID.Name = "killerID"
	killerID.Value = attacker
	killerID.Parent = victim
	
	Debris:AddItem(killerID,3)
	victim.Character.Humanoid:TakeDamage(amount)
	
	if victim.Character.Humanoid.Health <= 0 then
		if attacker ~= victim then
			attacker.PlayerGui.Sounds.killsound:Play()
			attacker:SetAttribute("Frags",attacker:GetAttribute("Frags")+1)
		end
		
		local confirmed : BoolValue = Instance.new("BoolValue")
		confirmed.Name = "confirmed"
		confirmed.Parent = victim
		Debris:AddItem(confirmed,3)
		
		game.ReplicatedStorage.Remotes.NewKillfeed:FireAllClients(attacker,victim,weapon)
	else
		if criticalHit then
			game.ReplicatedStorage.Remotes.PlaySoundAsPart:FireClient(victim.Character.PrimaryPart.Position,"rbxassetid://6405267300")
		end
		if attacker ~= victim then
			attacker.PlayerGui.Sounds.hitsound:Play()
		end
	end
	game.ReplicatedStorage.Remotes.SummonHitEffect:FireClient(attacker,victim.Character.PrimaryPart.Position,amount,criticalHit)
end

return manager