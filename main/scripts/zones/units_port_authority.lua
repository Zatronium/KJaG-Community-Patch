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
	-- 1-30%-nothing happens. 
	-- 31-70% Spawn one infantry unit. 
	-- 71-100% Spawn one patrol boat unit. 

	local spawnPos = aura:getOwner():getWorldPosition();
	local choice = randomInt(1, 100);
	if choice <=  30 then -- nothing
	elseif choice <=  70 then spawnUnit("InfantryClass",   spawnPos);
	elseif choice <= 100 then spawnUnit("PatrolBoatClass", spawnPos);
	end;
end