return function(event : RemoteEvent, sender : Player, wantsToAttack : boolean)
	if not sender or not sender.Character then return end
	if sender.Character.Humanoid.Health <= 0 then return end
	if type(wantsToAttack) ~= "boolean" then return end
	
	sender:SetAttribute("Attacking",wantsToAttack)
end