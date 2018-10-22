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
	-- 1-20%-nothing happens. 
	-- 21-40% Spawn one infantry unit. 
	-- 41-80% Spawn one rocket trooper unit. 
	-- 81-100% Spawn one rocket truck unit. 

	local spawnPos = aura:getOwner():getWorldPosition();
	local choice = randomInt(1, 100);
	if choice <=  20 then -- nothing
	elseif choice <=  40 then spawnUnit("InfantryClass",       spawnPos);
	elseif choice <=  80 then spawnUnit("RocketInfantryClass", spawnPos);
	elseif choice <= 100 then spawnUnit("RocketTruckClass",    spawnPos);
	end
end