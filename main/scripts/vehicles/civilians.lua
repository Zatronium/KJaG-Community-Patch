require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local kSafeDistance = 1500.0;
local kSafeTolerance = 50.0;

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.
function onHeartbeat(v)
	local vc = v:getControl();
	local autoRemove = true;

	local a = getPlayerAvatar();
	if a then	
		local distance = getDistance(v, a);
		if distance < kSafeDistance - kSafeTolerance then
			vc:moveFrom(a, kSafeDistance);
			autoRemove = false;
		else
			-- expire civilians
			autoRemove = true;
		end
	end

	if isEntityOnWater(v) then
		autoRemove = true;
	end
	if not isEntityOnMap(v) then
		autoRemove = true;
	end

	if autoRemove then
		removeEntity(v);
	end
end

function onDeath(self)
	spawnLoot(self);
	
	local pos = self:getView():getPosition();	
	self:getView():setVisible(false);
	removeEntity(self);
	
	playSound("people_smushy");
	

	createEffect('effects/impact_smokeCloudSmall.plist', pos);
	createEffect('effects/moraleHit.plist', pos);

end