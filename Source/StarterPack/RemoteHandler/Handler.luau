for _,v in pairs(game.ReplicatedStorage.Remotes:GetDescendants()) do
	if not script.Parent.Remotes:FindFirstChild(v.Name) then continue end
	if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
		v.OnClientEvent:Connect(function(...)
			require(script.Parent.Remotes[v.Name])(v,unpack({...}))
		end)
	elseif v:IsA("RemoteFunction") then
		v.OnClientInvoke = function(...)
			return require(script.Parent.Remotes[v.Name])(v,unpack({...}))
		end
	end
end