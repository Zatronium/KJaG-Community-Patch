require 'scripts/common'
require 'scripts/vehicles/common'

local delay = 0.0;
local pauseTick = 0;
-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.
function onHeartbeat(v)
	local vc = v:getControl();
	local a = getPlayerTarget(v);
	if canTarget(a) then
		local distance = getDistance(v, a);
		local weaponRange = v:getMinWeaponRange();
		local target = nil;
		if distance < weaponRange * 1.5 then
			target = a;
		end
		local autoRemove = false;
		if distance < weaponRange * 0.75 and isLineOfSight(v, a) then
			-- Avatar in range and LoS, stop movement and create attack aura.
			if distance < weaponRange * 0.75 then
				local pos = a:getWorldPosition();
				local direction = getFacingAngle(pos, v:getWorldPosition());
				local targetPos = getEndOfBeamPosition(pos, direction, weaponRange * 0.75);
				vc:seekToPosition(targetPos);
			else
				vc:stop();
			end
		else	
			if pauseTick > 0 then
				pauseTick = pauseTick - 1;
				if pauseTick <= 0 and isEntityOnWater(v) then
					autoRemove = true;
				end
			else
			-- Try to get in range.
				vc:seekTo(a);
				if isEntityOnWater(v) then
					pauseTick = 5;
				end
			end
		end
	
		if autoRemove then
			removeEntity(v);
		else
			setTarget(v, target);
		end
	end
end

function onDeath(self)
	spawnLoot(self);
	
	local pos = self:getView():getPosition();	
	self:getView():setVisible(false);
	removeEntity(self);
	
	playSound("explosion");
	createEffect('effects/explosion_BoomLayer.plist', pos);
	createEffect('effects/explosion_SmokeLayer.plist', pos);
	createEffect('effects/explosion_SparkLayer.plist', pos);
	createEffect('effects/explosion_SparkFireLayer.plist', pos);
end