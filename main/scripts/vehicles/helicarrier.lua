require 'scripts/common'

-- Provides default entity setup.
require 'scripts/vehicles/common'

local kaiju = nil

local kEncircleDistance = 470.0;
local kEncircleTolerance = 30.0;
local kEncircleDuration = 10.0;

local kStateMoveAway = 0;
local kStateEncircle = 1;
local kStateStrafe = 2;

local gState = kStateMoveAway;
local gEncircleStopTime = 0;

local triggerDistance = 800;
local initialSetup = false
local setupComplete = false

function doSpawnSetup(v)
	initialSetup = true
	kaiju = getPlayerAvatar()
	local tickCallback = "onLaunchTick";
	local interval = 10; -- in seconds
	local initialDelay = randomInt(5, 15); -- in seconds, to stagger spawning
	local aura = createAura(this, v, 'heliAura');
	aura:setScriptCallback(AuraEvent.OnTick, tickCallback);
	aura:setTickParameters(interval, 0);
	aura:setUpdateDelay(initialDelay);
	aura:setTarget(v); -- required so aura doesn't autorelease
	setupComplete = true
end

function onLaunchTick(aura)
	local self = aura
	if self then
		self = aura:getOwner()
	end
	
	if not self then
		aura = nil return
	end
	
	-- don't spawn unless kaiju is nearby.
	local distanceFromTarget = getDistance(self, kaiju);
	if distanceFromTarget > triggerDistance then
		return; 
	end

	local spawnPos = self:getWorldPosition();
	spawnUnit("HelicarrierUnit", spawnPos);
end

function onHeartbeat(v)
	if not initialSetup then
		doSpawnSetup(v)
	end
	
	if not setupComplete then
		return
	end
	local vc = v:getControl();

	local distanceFromTarget = getDistance(v, kaiju);

	local target = nil;
	if distanceFromTarget < v:getMinWeaponRange() * 1.5 then
		target = kaiju;
	end		
	
	setTarget(v, target);


	-- Update MoveAway
	if gState == kStateMoveAway then
		if distanceFromTarget < kEncircleDistance then
			vc:moveFrom(kaiju, kEncircleDistance);
		else
			startEncircle(v, kaiju);
		end
	end


	-- Update Encircle
	if gState == kStateEncircle then
		if getRealTime() > gEncircleStopTime then
			-- check if we've reached our desired distance from target, if not continue encircling
			if getDistance(v, kaiju) < (kEncircleDistance - kEncircleTolerance) then
				-- continue encircling until we get far enough away
				gEncircleStopTime = getRealTime() + kEncircleDuration;
			else
				startStrafe(v, kaiju);
			end
		end
	end
end

function startEncircle(v, kaiju)
	local vc = v:getControl();
	vc:encircleTarget(kaiju, kEncircleDistance);
	gEncircleStopTime = getRealTime() + kEncircleDuration;
	gState = kStateEncircle;
end

function startStrafe(v, kaiju)
	gState = kStateStrafe;
	if v:getVehicleType() ~= VehicleType.Helicopter then
		playSound(getStrafeSound(v));
	end
	local vc = v:getControl()
	vc:strafe(kaiju, kEncircleDistance, "onStrafeDone")
end

function onStrafeDone(v)
	startEncircle(v, kaiju)
end

function onDeath(self)
	spawnLoot(self);
	spawnAirUnitDebris(self, "");
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

