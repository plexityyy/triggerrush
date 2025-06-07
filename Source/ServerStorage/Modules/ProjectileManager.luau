local module = {}
local projectiles : table<any> = {}

function module:createProjectile(class : string, ...)
	assert(script:FindFirstChild(class),string.format("Couldn't find %s!",class))
	
	local obj = require(script:FindFirstChild(class)):new(unpack({...}))
	table.insert(projectiles,obj)
	
	return obj
end

function module:clearProjectiles()
	projectiles = {}
end

function module:destroyProjectil(p) : boolean
	for i,v in pairs(projectiles) do
		if v == p then
			table.remove(projectiles,i)
			return true
		end
	end
	return false
end

game:GetService("RunService").Heartbeat:Connect(function(dt : number)
	for i,v in ipairs(projectiles) do
		if not v or not v:getObject() then
			table.remove(projectiles,i)
		end
		v:update(dt)
	end
end)

return module
