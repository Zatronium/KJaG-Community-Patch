require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.

local kEncircleDistance = 470.0;
local kEncircleTolerance = 30.0;
local kEncircleDuration = 10.0;

local kStateMoveAway = 0;
local kStateEncircle = 1;
local kStateStrafe = 2;

local gState = kStateMoveAway;
local gEncircleStopTime = 0;

function onHeartbeat(v)
	local vc = v:getControl();
	local a = getPlayerTarget(v);
	if not a then
		return;
	end;

	local distanceFromTarget = getDistance(v, a);

	local target = nil;
	if distanceFromTarget < v:getMinWeaponRange() * 1.5 then
		target = a;
	end		
	
	setTarget(v, target);


	-- Update MoveAway
	if gState == kStateMoveAway then
		if distanceFromTarget < kEncircleDistance then
			vc:moveFrom(a, kEncircleDistance);
		else
			startEncircle(v, a);
		end
	end


	-- Update Encircle
	if gState == kStateEncircle then
		if getRealTime() > gEncircleStopTime then
			-- check if we've reached our desired distance from target, if not continue encircling
			if getDistance(v, a) < (kEncircleDistance - kEncircleTolerance) then
				-- continue encircling until we get far enough away
				gEncircleStopTime = getRealTime() + kEncircleDuration;
			else
				startStrafe(v, a);
			end
		end
	end


	-- Update Strafe
	if gState == kStateStrafe then
		-- Wait until done.
	end


end

function startEncircle(v, a)
	local vc = v:getControl();
	vc:encircleTarget(a, kEncircleDistance);
	gEncircleStopTime = getRealTime() + kEncircleDuration;
	gState = kStateEncircle;
end

function startStrafe(v, a)
	gState = kStateStrafe;
	if v:getVehicleType() ~= VehicleType.Helicopter then
		playSound(getStrafeSound(v));
	end

	local vc = v:getControl();
	vc:strafe(a, kEncircleDistance, "onStrafeDone")
end

function onStrafeDone(v)
	local a = getPlayerAvatar();
	if a then
		startEncircle(v, a);
	else
		gState = kStateMoveAway;
	end
end

function onDeath(self)
	spawnLoot(self);
	spawnAirUnitDebris(self,"");

	local pos = self:getView():getPosition();	
	self:getView():setVisible(false);
	removeEntity(self);
	
	createEffect('effects/explosion_BoomLayer.plist', pos);
	createEffect('effects/explosion_SmokeLayer.plist', pos);
	createEffect('effects/explosion_SparkLayer.plist', pos);
	createEffect('effects/explosion_SparkFireLayer.plist', pos);
end

