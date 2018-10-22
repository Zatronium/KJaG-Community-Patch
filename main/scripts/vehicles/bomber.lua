require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.

-- If set, movement is handled by AirUnitManager/Squadron.
local gIsInSquadron = false;
function setInSquadron(value)
	gIsInSquadron = value;
end

function onHeartbeat(v)
	local a = getPlayerTarget(v);
	setTarget(v, a);

	if not gIsInSquadron then
		-- add standalone movement logic here
	end
end

function onDeath(self)
	spawnLoot(self);
	spawnAirUnitDebris(self,"");
	
	local pos = self:getView():getPosition();	
	self:getView():setVisible(false);
	removeEntity(self);
	
	playSound("explosion");
	createEffect('effects/explosion_BoomLayer.plist', pos);
	createEffect('effects/explosion_SmokeLayer.plist', pos);
	createEffect('effects/explosion_SparkLayer.plist', pos);
	createEffect('effects/explosion_SparkFireLayer.plist', pos);
end

