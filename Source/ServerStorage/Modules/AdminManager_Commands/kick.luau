local TextService : TextService = game:GetService("TextService")
return {
	minimumRequirement = 1,
	func = function(runner : Player, victim : string, ... : string)
		local victimPlayer : Player? = game.Players:FindFirstChild(victim)
		if victimPlayer then
			local fullString : string = ""

			for _,term in pairs({...}) do
				fullString = fullString .. term .. " "
			end

			local filterResult : TextFilterResult = TextService:FilterStringAsync(fullString,runner.UserId,Enum.TextFilterContext.PrivateChat)
			local filteredString : string = filterResult:GetNonChatStringForUserAsync(victimPlayer.UserId)

			victimPlayer:Kick(filteredString)
		end
	end
}