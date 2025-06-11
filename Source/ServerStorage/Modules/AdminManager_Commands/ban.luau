local TextService : TextService = game:GetService("TextService")
return {
	minimumRequirement = 1,
	func = function(runner : Player, victim : string, duration : string, ... : string)
		local victimUserId : number = game.Players:GetUserIdFromNameAsync(victim)
		local fullString : string = ""

		for _,term in pairs({...}) do
			fullString = fullString .. term .. " "
		end

		local filterResult : TextFilterResult = TextService:FilterStringAsync(fullString,runner.UserId,Enum.TextFilterContext.PrivateChat)
		local filteredString : string = filterResult:GetNonChatStringForUserAsync(victimUserId)

		game.Players:BanAsync({
			UserIds = {victimUserId},
			Duration = tonumber(duration)*60,
			DisplayReason = filteredString,
			PrivateReason = filteredString,
			ExcludeAltAccounts = false,
			ApplyToUniverse = true
		})
	end
}