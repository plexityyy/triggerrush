local weaponToMessage = {
	["Dagger"] = {
		"VICTIM let ATTACKER get a bit too close...",
		"VICTIM got turned into a pincushion by ATTACKER!",
		"VICTIM learned that hugs from ATTACKER hurt. A lot."
	},
	["Pistol"] = {
		"ATTACKER gunned down VICTIM!",
		"VICTIM was slowly, painfully erased by ATTACKER!",
		"VICTIM lost a staring contest with ATTACKER!"
	},
	["Trench Shotgun"] = {
		"ATTACKER blasted VICTIM's skull open!",
		"VICTIM got ventilated like drywall by ATTACKER!",
		"VICTIM mistook ATTACKER's gun for a party popper...Ooops."
	},
	["Sten Gun"] = {
		"VICTIM got stitched into a meat quilt by ATTACKER!",
		"VICTIM was shredded into confetti by ATTACKER!",
		"VICTIM tried to catch bullets... with their face. Thanks, ATTACKER!"
	},
	["Revolver"] = {
		"VICTIM was dropped clean by ATTACKER!",
		"VICTIM's skull took a scenic exit, courtesy of ATTACKER!",
		"VICTIM played Russian Roulette with ATTACKER...and lost!"
	},
	["Kaboominator"] = {
		"VICTIM was reduced to a fine mist by ATTACKER!",
		"ATTACKER knew where VICTIM was going ahead of time...",
		"VICTIM thought ATTACKER's weapon was a toy...until they exploded!"
	},
	["Doomscreamer"] = {
		"VICTIM couldn't outscream ATTACKER's Doomscreamer",
		"VICTIM was vaporised into a tragic memory by ATTACKER!",
		"VICTIM tried to hug ATTACKER's Doomscreamer...they exploded instead!"
	}
}

local ply : Player = game.Players.LocalPlayer
local plyGui : PlayerGui = ply:WaitForChild("PlayerGui")
local gui : ScreenGui = plyGui:WaitForChild("CoreGui")

local Debris : Debris = game:GetService("Debris")
local TweenService : TweenService = game:GetService("TweenService")

return function(event : RemoteEvent, attacker : Player?, victim : Player, weapon : string?)
	local randomSentence : string = "ATTACKER finished off VICTIM!"
	if not attacker or attacker == victim then
		randomSentence = "VICTIM bid farewell, cruel world!"
	elseif weaponToMessage[weapon] then
		randomSentence = weaponToMessage[weapon][math.random(1,#weaponToMessage[weapon])]
	end
	
	if attacker then
		local attackerString : string = "<font color=\"rgb(%d,%d,%d)\">" .. attacker.DisplayName .. "</font>"
		local attackerColour : Color3 = attacker:GetAttribute("CharacterColour")
		attackerString = string.format(attackerString,attackerColour.R*255,attackerColour.G*255,attackerColour.B*255)
		randomSentence = string.gsub(randomSentence,"ATTACKER",attackerString)
	end
	
	local victimString : string = "<font color=\"rgb(%d,%d,%d)\">" .. victim.DisplayName .. "</font>"
	local victimColour : Color3 = victim:GetAttribute("CharacterColour")
	victimString = string.format(victimString,victimColour.R*255,victimColour.G*255,victimColour.B*255)
	
	randomSentence = string.gsub(randomSentence,"VICTIM",victimString)
	
	if weapon then
		randomSentence = randomSentence .. " (" .. weapon .. ")"
	end
	
	if #gui.KillBroadcasterFrame:GetChildren() > 5 then
		for _,v in pairs(gui.KillBroadcasterFrame:GetChildren()) do
			if v:IsA("UIListLayout") then continue end
			v:Destroy()
			break
		end
	end
	
	local cln : TextLabel = script.KillfeedMsg:Clone()
	cln.RichText = true
	cln.Text = randomSentence
	cln.Parent = gui.KillBroadcasterFrame
	
	if attacker and attacker.UserId == ply.UserId or victim.UserId == ply.UserId then
		cln.BackgroundColor3 = Color3.fromRGB(77,77,77)
	end
	
	Debris:AddItem(cln,7)
	task.wait(5)
	if not cln then return end
	TweenService:Create(cln,TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TextTransparency=1,BackgroundTransparency=1,TextStrokeTransparency=1}):Play()
end