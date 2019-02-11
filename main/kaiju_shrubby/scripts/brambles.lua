local range = 150
local damage = 5

function onSet(a)
	a:addPassiveScript(this)
end

function onAvatarAttacked(kaiju, attacker)
	if attacker then
		local counterable = true
		if getEntityType(attacker) == EntityType.Vehicle then
			local veh = entityToVehicle(attacker)
			if veh:isAir() then
				counterable = false
			end
		end
		if counterable then
			local dist = getDistance(kaiju, attacker)
			if dist < range then
				applyDamage(kaiju, attacker, damage)
			end
		end
	end
end