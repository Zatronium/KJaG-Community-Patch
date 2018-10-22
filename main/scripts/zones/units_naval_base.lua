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
	-- 1-20% Spawn one infantry unit. 
	-- 21-50% Spawn one patrol boat unit. 
	-- 51-80% Spawn one Assault chopper unit. 
	-- 81-100% Spawn one Destroyer 

	local spawnPos = aura:getOwner():getWorldPosition();
	local choice = randomInt(1, 100);
	if choice <=  20 then spawnUnit("InfantryClass",      spawnPos);
	elseif choice <=  50 then spawnUnit("PatrolBoatClass",    spawnPos);
	elseif choice <=  80 then spawnUnit("AttackChopperClass", spawnPos);
	elseif choice <= 100 then spawnUnit("DestroyerClass",     spawnPos);
	end;
end