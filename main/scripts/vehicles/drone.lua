require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds

local kEncircleDistance = 50.0;
local kEncircleTolerance = 30.0;
local kEncircleDuration = 1.0;

local gEnemyTargetRange = 1500;
local gDroneLifetime = 30;

local kStateMoveAway = 0;
local kStateEncircle = 1;
local kStateStrafe = 2;

local gState = kStateMoveAway;
local gEncircleStopTime = 0;

local hasUpdated = false;
local initialSetup = false
local setupFinished = false

local kaiju = nil

function doSpawnSetup(v)
	initialSetup = true
	kaiju = getPlayerAvatar()
	local timeaura = createAura(this, v, 0);
	timeaura:setTickParameters(gDroneLifetime, gDroneLifetime);
	timeaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	timeaura:setTarget(v);
	setupFinished = true
end

function onTick(aura)
	if not aura then
		return
	end
	local self = aura:getOwner()
	if not self then 
		aura = nil return
	end
	if hasUpdated then
		onDeath(self);
	end
	hasUpdated = true;
end

function onHeartbeat(v)
	if not initialSetup then
		doSpawnSetup(v)
	end
	vc = v:getControl();
	
	-- if our target died
	local drone = entityToMinion(v);
	local target = drone:getTarget();
	-- get a new target
	local at = getSelectedTarget();
	if not at and gState ~= kStateStrafe then
		target = at;
	end

	if not canTarget(target) then
		target = drone:findTarget(gEnemyTargetRange);
	end
	
	setTarget(v, target);
	if not target then
		return;
	end
		
	local distanceFromTarget = getDistance(v, target);

	-- Update MoveAway
	if gState == kStateMoveAway then
		if distanceFromTarget < kEncircleDistance then
			vc:moveFrom(target, kEncircleDistance);
		else
			startEncircle(v, target);
		end
	end

	-- Update Encircle
	if gState == kStateEncircle then
		if getRealTime() > gEncircleStopTime then
			-- check if we've reached our desired distance from target, if not continue encircling
			if getDistance(v, target) < (kEncircleDistance - kEncircleTolerance) then
				-- continue encircling until we get far enough away
				gEncircleStopTime = getRealTime() + kEncircleDuration;
			else
				startStrafe(v, target);
			end
		end
	end
end

function startEncircle(v, a)
	vc = v:getControl();
	vc:encircleTarget(a, kEncircleDistance);
	gEncircleStopTime = getRealTime() + kEncircleDuration;
	gState = kStateEncircle;
end

function startStrafe(v, a)
	gState = kStateStrafe;
	vc:strafe(a, kEncircleDistance, "onStrafeDone")
end

function onStrafeDone(v)
	startEncircle(v, kaiju);
end

function onDeath(self)
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

