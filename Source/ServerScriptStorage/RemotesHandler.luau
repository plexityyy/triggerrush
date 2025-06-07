for _,v in pairs(game.ReplicatedStorage.Remotes:GetDescendants()) do
	if not script.Remotes:FindFirstChild(v.Name) then continue end
	if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
		v.OnServerEvent:Connect(function(ply,...)
			require(script.Remotes[v.Name])(v,ply,unpack({...}))
		end)
	elseif v:IsA("RemoteFunction") then
		v.OnServerInvoke = function(ply,...)
			return require(script.Remotes[v.Name])(v,ply,unpack({...}))
		end
	end
end