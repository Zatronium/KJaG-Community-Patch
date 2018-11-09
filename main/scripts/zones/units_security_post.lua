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
	if not kaiju or not aura then --Zat: For some reason this checks kaiju as well, so I retained that function
		return
	end
	
	local self = aura:getOwner()
	if not self then
		--Zat: I don't know if we can unregister an invalid unit spawner. Better safe than sorry.
		return
	end
	
	-- From Design: Special: Every ten seconds it makes a percentage check, 
	-- 1-30%-nothing happens. 
	-- 31-70% Spawn one infantry unit. 
	-- 71-100% Spawn one jeep unit. 

	local spawnPos = self:getWorldPosition();
	local choice = randomInt(1, 100);
	if choice <=  30 then -- nothing
	elseif choice <=  70 then spawnUnit("InfantryClass", spawnPos);
	elseif choice <= 100 then spawnUnit("JeepClass",     spawnPos);
	end;
end