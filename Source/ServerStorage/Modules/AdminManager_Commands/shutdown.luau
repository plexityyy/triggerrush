return {
	minimumRequirement = 2,
	func = function(runner : Player)
		for _,v in pairs(game.Players:GetPlayers()) do
			v:Kick("Server is shutting down.")
		end
	end
}