require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Explosive2";
local weaponDamage = "goop_StingDamage"
local weapon_node = "tail_sting"
local anim = "ability_triplesting"

local dotDuration = 10;
local dotDamage = 10;

local targets = 3;
local curTarget = 0;
local event1 = "attack";
local event2 = "attack_02";
local lastEvent1 = true;

function onUse(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	enableTargetSelectionMultiple(this, abilityData.name, 'onTargets', getWeaponRange(weapon), targets);
end

-- Target selection is complete.
function onTargets(position)
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
	kaiju:setWorldFacing(facingAngle);
	startAbilityUse(kaiju, abilityData.name);
	playAnimation(kaiju, anim);
	registerAnimationCallbackContinuous(this, kaiju, event1);
	playSound("goop_ability_ExplosiveBarrage"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj = nil

	if curTarget >= targets - 1 then
		endAbilityUse(kaiju, abilityData.name);
		removeAnimationCallback(this, kaiju);
	elseif lastEvent1 then
		registerAnimationCallbackContinuous(this, kaiju, event2);
		lastEvent1 = false;
	else
		registerAnimationCallbackContinuous(this, kaiju, event1);
		lastEvent1 = true;
	end
	
	local t = getAbilityTargetEnt(kaiju, abilityData.name, curTarget);
	local targetPos = getAbilityTargetPos(kaiju, abilityData.name, curTarget);
	
	if canTarget(t) then	
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, t, 90 - view:getFacingAngle());
		proj:setCallback(this, 'onHit');
	else
		proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	end	
	
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);
	
	proj:setCollisionEnabled(false);

	curTarget = curTarget + 1;	
end

-- Projectile hits a target.
function onHit(proj)
	local target = proj:getTarget();
	if canTarget(target) then
		target:attachEffect("effects/goop_injected_persist", dotDuration, true);
		local dotAura = Aura.create(this, target);
		dotAura:setScriptCallback(AuraEvent.OnTick, 'onTickEx');
		dotAura:setTickParameters(1, dotDuration);
		dotAura:setStat("Health", 10);
		dotAura:setTarget(target); -- required so aura doesn't autorelease
	end
	createImpactEffectFromPage(weapon, proj:getWorldPosition(), 0);

	createEffectInWorld("effects/goop_infusion_explosive.plist", proj:getWorldPosition(), 0);
	playSound("goop_ability_common_goopsplosion"); -- SOUND
end

function onDetach(aura)
	if not aura then return end
	local atarget = aura:getOwner();
	if not atarget then return end
	local ahp = aura:getStat("Health");
	if ahp > 0 and atarget and not canTarget(atarget) then
		explode(atarget:getWorldPosition(), ahp);
	end
end

function explode(position, hp)
	createEffectInWorld("effects/goopball_detonate1.plist", position, 0);
	createEffectInWorld("effects/goopball_detonate2.plist", position, 0);
	createEffectInWorld("effects/goopball_detonate3.plist", position, 0);
	createEffectInWorld("effects/impact_BoomXlrg.plist", position, 0);
	createEffectInWorld("effects/impact_boomCore_xlrg.plist", position, 0);
	createEffectInWorld("effects/impact_boomRisingXlrg.plist", position, 0);
	playSound("goop_ability_common_goopsplosion"); -- SOUND
	local targets = getTargetsInRadius(position, hp + 50, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if canTarget(t) then
			applyDamage(kaiju, t, hp);
		end
	end
end

function onTickEx(aura)
	if not aura then return end
	local owner = aura:getOwner()
	if not owner then
		aura = nil return
	end
	local target = aura:getTarget();
	if not canTarget(target) then
		owner:detachAura(aura);
		return;
	end
	aura:setStat("Health", target:getStat("MaxHealth"));
	applyDamageWithWeaponDamage(kaiju, target, weaponDamage, dotDamage);

	-- if killed explode here
	if not canTarget(target) then
		owner:detachAura(aura);
	end
end
