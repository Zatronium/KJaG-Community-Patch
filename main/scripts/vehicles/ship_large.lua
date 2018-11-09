require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

require 'scripts/vehicles/trafficcontrol_common'

function onHeartbeat(v)
	if v and not InitialSetup() then
		DoSpawnSetup(v, false, nil, "largeship", nil)
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
	createEffect('effects/impact_fireRingBack_large.plist',pos);
	createEffect('effects/collapseSmokeDark_large.plist',pos);
	createEffect('effects/impact_BoomRisingXlrg.plist',pos);
	createEffect('effects/impact_fireCloud_linger.plist',pos);
	createEffect('effects/impact_dustCloud_med.plist',pos);
	createEffect('effects/impact_boomCore_xlrg.plist',pos);
	createEffect('effects/impact_fireRingFront_large.plist',pos);
	createEffect('effects/impact_boomXlrg.plist',pos);
	createEffect('effects/impact_mushCloud_small.plist',pos);
end