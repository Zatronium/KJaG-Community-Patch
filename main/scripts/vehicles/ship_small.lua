require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

require 'scripts/vehicles/trafficcontrol_common'

function onHeartbeat(v)
	if v and not InitialSetup() then
		DoSpawnSetup(v, false, nil, "smallship", nil)
	end
	if not SetupFinished() then
		return
	end
	DoVehicleHeartbeat()
end

function onDeath(self)
	spawnLoot(self);
	
	HaltSound()
	
	local view = self:getView()
	local pos = view:getPosition();	
	view:setVisible(false);
	removeEntity(self);
	
	playSound("explosion");
	createEffect('effects/explosion_BoomLayer.plist', pos);
	createEffect('effects/explosion_SmokeLayer.plist', pos);
	createEffect('effects/explosion_SparkLayer.plist', pos);
	createEffect('effects/explosion_SparkFireLayer.plist', pos);
end