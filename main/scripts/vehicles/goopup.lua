require 'kaiju_goop/scripts/goop_common'

local target = nil;
local avatar = nil;

local pickupDelay = 3;
local updateRate = 0.5;
local pickupRange = 100;

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.
function onSpawn(v)
	avatar = getPlayerAvatar();
end

function onHeartbeat(v)
	if combatEnded() then
		return;
	end
	if pickupDelay > 0 then
		pickupDelay = pickupDelay - updateRate;
		return;
	end
	
	avatar = getPlayerAvatar();
	if not avatar then
		return;
	end
	
	local dist = getDistance(v, avatar);
	if dist <= pickupRange and avatar:getStat("Health") < avatar:getStat("MaxHealth") then
		avatar:gainHealth(10);
		GoopPickedUp();
		v:getView():setVisible(false);
		removeEntity(v);
	end
end

function onStatChanged(e, stat, prev, val)
	if stat == "Health" then
		local maxHealth = e:getStat("MaxHealth");
		if val > maxHealth then
			e:setStat("Health", maxHealth);
		end
	end
end

function onDeath(self)
	local pos = self:getView():getPosition();	
	self:getView():setVisible(false);
	removeEntity(self);
end