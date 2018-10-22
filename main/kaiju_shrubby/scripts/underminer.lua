require 'scripts/avatars/common'

local avatar = nil;
local targetPos = nil;
local weapon = "weapon_shrubby_underminer";
local bWidth = 100;
local zoneDamage = 25;
local aoeRange = 50;
local weaponRange = 0;
local startPos = nil;
local targetsSet = false;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "stomp");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	startCooldown(avatar, abilityData.name);	
	playSound("shrubby_ability_Underminer");
	startPos = avatar:getWorldPosition();
	weaponRange = getDistanceFromPoints(startPos, targetPos);
	local targetZones = getTargetsInBeam(startPos, targetPos, bWidth, EntityFlags(EntityType.Zone));
	for z in targetZones:iterator() do
		local aura = createAura(this, z, 0);
		aura:setTickParameters(0.2, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(z);		
	end
	
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTickEnd");
	aura:setTarget(avatar);	
	
	targetsSet = true;
end

function onTickEnd(aura)
	if targetsSet then
		createEffectInWorld("effects/roots_shockwave_big.plist", targetPos, 0.1);
		createEffectInWorld("effects/roots_undermine.plist", targetPos, 2);
		createEffectInWorld("effects/underminerSpike.plist", targetPos, .5);
		avatar = getPlayerAvatar();
		local targets = getTargetsInRadius(targetPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			applyDamageWithWeapon(avatar, t, weapon);
		end
		playSound("shrubby_ability_Underminer_explosion");
		aura:getOwner():detachAura(aura);
	end
end
function onTick(aura)
	if targetsSet then
		local t = aura:getTarget();
		local d = getDistanceFromPoints(t:getWorldPosition(), startPos);
		local e = weaponRange * aura:getElapsed();
		if d < e then
			t:attachEffect("effects/roots_undermine.plist", 0.5, true);
			if canTarget(t) then
				applyDamage(avatar, t, zoneDamage);
			end
			aura:getOwner():detachAura(aura);
		end
	end
end
