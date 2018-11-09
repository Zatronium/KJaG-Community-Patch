require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local offsetDir = 0.0;
local explodeRange = 40;
local chargeRange = 200;

local initialSetup = false
local setupComplete = false

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.

function onHeartbeat(v)
	if not initialSetup then
		doInitialSetup(v)
	end
	if not setupComplete then
		return
	end
	
	local vehicleController = v:getControl()
	local a = getPlayerTarget(v);
	local dist = getDistance(a, v);
	if canTarget(a) then
		if dist < chargeRange then
			vehicleController:directMove(a:getWorldPosition());
		else
			vehicleController:seekToPosition(a:getWorldPosition());
		end
		setTarget(v, a);
	end
	if dist <= explodeRange then
		v:setStat("Health", 0);
	end
end

function doInitialSetup(v)
	initialSetup = true
	if coinFlip() then
		offsetDir = 90.0;
	else
		offsetDir = -90.0;
	end
	setupComplete = true
end

function onDeath(self)
	local worldpos = self:getWorldPosition();
	playSound("explosion");
	spawnLoot(self);
	
	local view = self:getView()
	local pos = view:getPosition();	
	view:setVisible(false);
	removeEntity(self);
	fireProjectileAtPoint(nil, worldpos, worldpos, "weapon_Skitter");
end