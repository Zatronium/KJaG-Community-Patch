require 'scripts/common'
require 'scripts/zones/common'

function onSpawn(self)
	local interval = 30; -- in seconds
	createUnitSpawner(self, interval, "onTick");
end

function onTick(aura)
	if not getPlayerAvatar() then
		return;
	end

	-- don't spawn unless kaiju is nearby.
	local triggerDistance = 500;
	local distanceFromTarget = getDistance(aura:getOwner(), getPlayerAvatar());
	if distanceFromTarget > triggerDistance then
		return; 
	end

	-- Special: Every ten seconds it makes a percentage check, 
	-- 1-50%-nothing happens. 
	-- 51-80% Spawn one infantry unit. 
	-- 81-100% Spawn one jeep unit. 

	local spawnPos = aura:getOwner():getWorldPosition();
	local choice = randomInt(1, 100);
	if choice <=  50 then -- nothing
	elseif choice <=  80 then spawnUnit("InfantryClass", spawnPos);
	elseif choice <= 100 then spawnUnit("JeepClass",     spawnPos);
	end;
end