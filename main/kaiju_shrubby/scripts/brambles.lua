local range = 150;
local damage = 5;

function onSet(a)
	a:addPassiveScript(this);
end

function onAvatarAttacked(avatar, attacker)
	if attacker then
		local counterable = true;
		if getEntityType(attacker) == EntityType.Vehicle then
			local veh = entityToVehicle(attacker);
			if veh:isAir() then
				counterable = false;
			end
		end
		if counterable then
			local dist = getDistance(avatar, attacker);
			if dist < range then
				applyDamage(avatar, attacker, damage);
			end
		end
	end
end