require 'scripts/avatars/common'
-- Global values.
local kaiju = nil;
local targetPos = 0;
local beamDuration = 1.0;
local tickTime = 0.125;

local weapon = "RadBeam2"
local beamNode = "breath_node"

local sceneBeamFacing = 0;
local sceneBeamEnd = nil;
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
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
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
	playSound("FocusRads");
end

function onTick(aura)
	local targetEnt = getAbilityTarget(kaiju, abilityData.name);
	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	beamEnd = getBeamEndWithPoint(beamOrigin, getWeaponRange(weapon), targetPos);
	local view = kaiju:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	sceneBeamEnd = getScenePosition(beamEnd);
	sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	local currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Vehicle, EntityType.Avatar), kaiju);
	if currentTarget then	
		local pos = getScenePosition(currentTarget:getWorldPosition());
		
		view:doBeamEffectFromNode(beamNode, pos, 'effects/beam_focusedRad.plist', sceneBeamFacing );
		view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		pos);
		createEffect("effects/explosion_SmokeLayer.plist",		pos);
		createEffect("effects/explosion_SparkLayer.plist",		pos);
		createEffect("effects/explosion_SparkFireLayer.plist",	pos);
		
		applyFire(kaiju, currentTarget, 0.75);
		applyDamageWithWeapon(kaiju, currentTarget, weapon);
	else 
		view:doBeamEffectFromNode(beamNode, sceneBeamEnd, 'effects/beam_focusedRad.plist', sceneBeamFacing );
		view:doEffectFromNode(beamNode, 'effects/muzzle_radBeam.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
	end
	if aura:getElapsed() >= beamDuration then
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end