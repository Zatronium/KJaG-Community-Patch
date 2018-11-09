require 'scripts/avatars/common'

-- Global values.
local kaiju = nil;
local targetPos = 0;
local beamDuration = 1.0;
local tickTime = beamDuration / 7;

local weapon = "RadBeam1"
local beamNode = "breath_node"

local beamWidth = 180;

local beamOrigin = nil;

local empower = 0;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
	empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	startCooldown(kaiju, abilityData.name);
end

function onAnimationEvent(a)
	beamOrigin = kaiju:getWorldPosition();
	local view = kaiju:getView();
	view:pauseAnimation(beamDuration);
	
	local beamAura = Aura.create(this, kaiju);
	beamAura:setTag('eyeBeam');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, beamDuration);
	beamAura:setTarget(kaiju); -- required so aura doesn't autorelease
	playSound("RadBeam");
end

function onTick(aura)
	if not aura then return end
	local targetEnt = getAbilityTarget(kaiju, abilityData.name);
	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	local beamEnd = getBeamEndWithPoint(beamOrigin, getWeaponRange(weapon), targetPos);
	
	local view = kaiju:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	local sceneBeamEnd = getScenePosition(beamEnd);
	local sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	local currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, beamWidth, EntityFlags(EntityType.Vehicle, EntityType.Avatar), kaiju);
	if currentTarget then	
		local pos = getScenePosition(currentTarget:getWorldPosition());
		
		view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_rad.plist', sceneBeamFacing );
		view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		pos);
		createEffect("effects/explosion_SmokeLayer.plist",		pos);
		createEffect("effects/explosion_SparkLayer.plist",		pos);
		createEffect("effects/explosion_SparkFireLayer.plist",	pos);
		
		applyFire(kaiju, currentTarget, 0.75);
		abilityEnhance(empower);
		applyDamageWithWeapon(kaiju, currentTarget, weapon);
		abilityEnhance(0);		
	else 
		view:doBeamEffectFromNode(beamNode, sceneBeamEnd, 'effects/beam_rad.plist', sceneBeamFacing );
		view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
	end
	local self = aura:getOwner()
	if aura:getElapsed() >= beamDuration then
		if not self then
			aura = nil return;
		else
			self:detachAura(aura)
		end
	end
end