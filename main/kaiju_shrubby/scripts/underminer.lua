require 'scripts/avatars/common'

local kaiju = nil;
local targetPos = nil;
local weapon = "weapon_shrubby_underminer";
local bWidth = 100;
local zoneDamage = 25;
local aoeRange = 50;
local weaponRange = 0;
local startPos = nil;
local targetsSet = false;
function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "stomp");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	startCooldown(kaiju, abilityData.name);	
	playSound("shrubby_ability_Underminer");
	startPos = kaiju:getWorldPosition();
	weaponRange = getDistanceFromPoints(startPos, targetPos);
	local targetZones = getTargetsInBeam(startPos, targetPos, bWidth, EntityFlags(EntityType.Zone));
	for z in targetZones:iterator() do
		local aura = createAura(this, z, 0);
		aura:setTickParameters(0.2, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(z);		
	end
	
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTickEnd");
	aura:setTarget(kaiju);	
	
	targetsSet = true;
end

function onTickEnd(aura)
	if not aura then return end
	if targetsSet then
		createEffectInWorld("effects/roots_shockwave_big.plist", targetPos, 0.1);
		createEffectInWorld("effects/roots_undermine.plist", targetPos, 2);
		createEffectInWorld("effects/underminerSpike.plist", targetPos, 0.5);
		local targets = getTargetsInRadius(targetPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			applyDamageWithWeapon(kaiju, t, weapon);
		end
		playSound("shrubby_ability_Underminer_explosion");
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
function onTick(aura)
	if not aura then return end
	if targetsSet then
		local t = aura:getTarget();
		local d = getDistanceFromPoints(t:getWorldPosition(), startPos);
		local e = weaponRange * aura:getElapsed();
		if d < e then
			t:attachEffect("effects/roots_undermine.plist", 0.5, true);
			if canTarget(t) then
				applyDamage(kaiju, t, zoneDamage);
			end
			
			local self = aura:getOwner()
			if not self then
				aura = nil return;
			else
				self:detachAura(aura);
			end
		end
	end
end
