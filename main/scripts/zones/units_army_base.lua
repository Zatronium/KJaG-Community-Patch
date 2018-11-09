require 'scripts/common'
require 'scripts/zones/common'

local kaiju = nil

function doSpawnSetup(self)
	kaiju = getPlayerAvatar()
	local interval = 30; -- in seconds
	createUnitSpawner(self, interval, "onTick");
end

function onSpawn(self) 
	if self then
		doSpawnSetup(self)
	end
end

function onTick(aura)
	if not kaiju or not aura then --Zat: For some reason this checks kaiju as well
		return
	end
	
	local self = aura:getOwner()
	if not self then
		aura = nil return
	end
	-- don't spawn unless kaiju is nearby.
	local triggerDistance = 500;
	local distanceFromTarget = getDistance(self, kaiju);
	if distanceFromTarget > triggerDistance then
		return; 
	end

	-- Special: Every ten seconds it makes a percentage check, 
	-- 1-20% Spawn one light tank. 
	-- 21-50% Spawn tank. 
	-- 51-80% Spawn one attack chopper unit. 
	-- 81-100% Spawn one heavy tank

	local spawnPos = self:getWorldPosition()
	local choice = randomInt(1, 100);
	if choice <=  20 then spawnUnit("LightTankClass",     spawnPos);
	elseif choice <=  50 then spawnUnit("TankClass",          spawnPos);
	elseif choice <=  80 then spawnUnit("AttackChopperClass", spawnPos);
	elseif choice <= 100 then spawnUnit("HeavyTankClass",     spawnPos);
	end
end