require 'scripts/common'

local avatar = nil;
local targetPos = nil
local weaponRange = 750;
local beamDuration = 1.0;
local tickTime = 0.1;
local totalTime = 0
local weaponFiringAngle = 60

local beamOrigin = nil;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), position);
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_eyeblast");
	registerAnimationCallback(this, avatar, "start");
	startCooldown(avatar, abilityData.name);
end

function onAnimationEvent(a)
	beamOrigin = a:getWorldPosition();
	local view = a:getView();
	view:pauseAnimation(beamDuration);
	
	local beamAura = Aura.create(this, a);
	beamAura:setTag('deathStare');
	beamAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	beamAura:setTickParameters(tickTime, beamDuration);
	beamAura:setTarget(a); -- required so aura doesn't autorelease
	playSound("deathstare");
end

function onTick(aura)
	local self = aura:getOwner()
	if not self then
		aura:setScriptCallback(AuraEvent.OnTick, nil);
		return
	end
	local targetEnt = getAbilityTarget(avatar, abilityData.name);
	local newTargetPos = 0;
	local kaijuFacing = avatar:getWorldFacing()
	local worldPos = avatar:getWorldPosition()
	if not targetEnt then
		local newTargets = getTargetsInRadius(worldPos, weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar))
		for t in newTargets:iterator() do
			if canTarget(t) and not isSameEntity(t, avatar) then
				local targetAngleRelativeToKaiju = getFacingAngle(avatar, t) - kaijuFacing
				if targetAngleRelativeToKaiju <= weaponFiringAngle and targetAngleRelativeToKaiju >= -weaponFiringAngle then
					targetEnt = t
					break
				end
			end
		end
	end
	if targetEnt then
		newTargetPos = targetEnt:getWorldPosition();
	else
		local newTargets = getTargetsInRadius(worldPos, weaponRange, EntityFlags(EntityType.Zone))
		for t in newTargets:iterator() do
			if canTarget(t) then
				local targetAngleRelativeToKaiju = getFacingAngle(avatar, t) - kaijuFacing
				if targetAngleRelativeToKaiju <= weaponFiringAngle and targetAngleRelativeToKaiju >= -weaponFiringAngle then
					targetEnt = t
					break
				end
			end
		end
	end
	if targetEnt and canTarget(targetEnt) then
		newTargetPos = targetEnt:getWorldPosition();
	else
		newTargetPos = targetPos
	end
	if not newTargetPos then
		newTargetPos = worldPos
	end
	local beamEnd = getBeamEndWithPoint(beamOrigin, weaponRange, newTargetPos);
	
	local view = avatar:getView();
	local sceneBeamOrigin = view:getAnimationNodePosition('breath_node');
	local sceneBeamEnd = getScenePosition(beamEnd);
	local sceneBeamFacing = getFacingAngle(sceneBeamOrigin, sceneBeamEnd);
	
	local currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Vehicle, EntityType.Avatar), avatar);
	
	if not currentTarget then
		currentTarget = getClosestTargetInBeam(beamOrigin, beamEnd, 35, EntityFlags(EntityType.Zone), avatar);
	end
	if currentTarget then	
		local position = getScenePosition(currentTarget:getWorldPosition());
		
		view:doBeamEffectFromNode('eye_node_01', position, 'effects/deathStare.plist', sceneBeamFacing );
		view:doBeamEffectFromNode('eye_node_02', position, 'effects/deathStare.plist', sceneBeamFacing);
		view:doEffectFromNode('eye_node_01', 'effects/deathStare_muzzleGlow.plist', 0);
		view:doEffectFromNode('eye_node_02', 'effects/deathStare_muzzleGlow.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		position);
		createEffect("effects/explosion_SmokeLayer.plist",		position);
		createEffect("effects/explosion_SparkLayer.plist",		position);
		createEffect("effects/explosion_SparkFireLayer.plist",	position);
		
		applyDamageWithWeapon(avatar, currentTarget, "weapon_EyeBeam2");
		createEffect("effects/onRadiated.plist", position);
	else 
		view:doBeamEffectFromNode('eye_node_01', sceneBeamEnd, 'effects/deathStare.plist', sceneBeamFacing );
		view:doBeamEffectFromNode('eye_node_02', sceneBeamEnd, 'effects/deathStare.plist', sceneBeamFacing);
		view:doEffectFromNode('eye_node_01', 'effects/deathStare_muzzleGlow.plist', 0);
		view:doEffectFromNode('eye_node_02', 'effects/deathStare_muzzleGlow.plist', 0);
		
		createEffect("effects/explosion_BoomLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SmokeLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkLayer.plist",		sceneBeamEnd);
		createEffect("effects/explosion_SparkFireLayer.plist",	sceneBeamEnd);
	end
	
	totalTime = totalTime + tickTime;
	if totalTime >= beamDuration then
		self:detachAura(aura);
	end
end