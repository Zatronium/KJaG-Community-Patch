require 'scripts/avatars/common'

-- Global values.
local kaiju = nil;
local targetPos = 0;
local beamDuration = 1.0;
local tickTime = 0.125;

local waitTime = 0.5;

local numberOfPulses = 3;
local pulseNumber = 0;
local shot = 0;

local weapon = "RadBeam1"
local beamNode = "breath_node"

local beamEnd = nil;
local beamOrigin = nil;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);
	local view = kaiju:getView();
	view:setAnimation("ability_breath", false);
	registerAnimationCallback(this, kaiju, "start");
	startCooldown(kaiju, abilityData.name);
end

function onAnimationEvent(a, event)
	beamOrigin = kaiju:getWorldPosition();
	local view = kaiju:getView();
	view:pauseAnimation(beamDuration * numberOfPulses + (numberOfPulses - 1) * waitTime);
	
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);
	
	local beamAura = Aura.create(this, kaiju);
	beamAura:setTag('eyeBeam');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, 0);
	beamAura:setTarget(kaiju); -- required so aura doesn't autorelease
	playSound("PulsedRads");
end

function onTick(aura)
	if not aura then
		return
	end
	local elapsed = aura:getElapsed();

	if elapsed <= beamDuration then
		local targetEnt = getAbilityTarget(kaiju, abilityData.name);
		if targetEnt then
			targetPos =  targetEnt:getWorldPosition();
		end
		local beamEnd = getBeamEndWithPoint(beamOrigin, getWeaponRange(weapon), targetPos);
		
		local view = kaiju:getView();
		local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
		local sceneBeamEnd = getScenePosition(beamEnd);
		local sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
		
		local currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Vehicle, EntityType.Avatar), kaiju);
		if currentTarget then	
			local pos = getScenePosition(currentTarget:getWorldPosition());
			
			view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_rad.plist', sceneBeamFacing );
			view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
			
			createEffect("effects/explosion_BoomLayer.plist",		pos);
			createEffect("effects/explosion_SmokeLayer.plist",		pos);
			createEffect("effects/explosion_SparkLayer.plist",		pos);
			createEffect("effects/explosion_SparkFireLayer.plist",	pos);
			
			applyFire(kaiju, currentTarget, 0.75);
			applyDamageWithWeapon(kaiju, currentTarget, weapon);
		else 
			view:doBeamEffectFromNode(beamNode, sceneBeamEnd, 'effects/beam_rad.plist', sceneBeamFacing );
			view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
			
			createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
			createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
			createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
			createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
		end
	end
	
	if elapsed >= beamDuration + waitTime then
		pulseNumber = pulseNumber + 1;
		if pulseNumber >= numberOfPulses then
			local view = kaiju:getView();
			view:addAnimation("idle", true);
		
			local self = aura:getOwner()
			if not self then
				aura = nil return;
			else
				self:detachAura(aura);
			end
			abilityEnhance(0);
		else
			aura:resetElapsed();
		end
		
	end
end