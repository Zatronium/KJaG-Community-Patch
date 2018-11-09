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
	createEffect('effects/impact_fireRingBack_med.plist',pos);
	createEffect('effects/collapseSmoke_med.plist',pos);
	createEffect('effects/explosion_SmokeLayer.plist',pos);
	createEffect('effects/impact_shockwave.plist',pos);
	createEffect('effects/explosion_SparkFireLayer.plist',pos);
	createEffect('effects/impact_BoomRisingLrg.plist',pos);
	createEffect('effects/impact_fireCloud_linger.plist',pos);
	createEffect('effects/impact_boomCore_large.plist',pos);
	createEffect('effects/impact_fireRingFront_med.plist',pos);
end