require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Viral2";
local weaponDamage = "goop_StingDamage"
local weapon_node = "tail_sting"
local anim = "ability_triplesting"

local dotDuration = 10;
local dotDamage = 10;
local infectRange = 50;

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
	local targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);
	startAbilityUse(kaiju, abilityData.name);
	playAnimation(kaiju, anim);
	registerAnimationCallbackContinuous(this, kaiju, event1);
	playSound("goop_ability_Infestation"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;

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
		proj:setCallback(this, 'onDryHit');
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
		target:attachEffect("effects/goop_viral_persist", duration, true);
		viralAura(this, 'onTick', target, dotDuration, 2);
	end
	createImpactEffectFromPage(weapon, proj:getWorldPosition(), 0);
	playSound("goop_ability_common_goopsplosion2"); -- SOUND
end

function onDryHit(proj)
	local projectileWorldPostition = proj:getWorldPosition()
	local t = getClosestTargetInRadius(projectileWorldPostition, infectRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar), kaiju);
	if canTarget(t) then
		local p = fireProjectileAtTarget(kaiju, t, projectileWorldPostition, Point(0, 0), weapon);
		p:setCallback(this, 'onHit');
		p:setCollisionEnabled(false);
	end
	createImpactEffectFromPage(weapon, projectileWorldPostition, 0);
	playSound("goop_ability_common_goopsplosion2"); -- SOUND
end

function onTick(aura)
	if not aura then return end
	local target = aura:getTarget();
	local worldpos = target:getWorldPosition();
	applyDamageWithWeaponDamage(kaiju, target, weaponDamage, dotDamage);

	-- if killed explode here
	if not canTarget(target) then
		createEffectInWorld("effects/goop_detonate1_viral.plist", worldpos, 0);
		createEffectInWorld("effects/goop_detonate2_viral.plist", worldpos, 0);
		createEffectInWorld("effects/goop_detonate3_viral.plist", worldpos, 0);
		local t = getClosestTargetInRadius(worldpos, infectRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar), kaiju);
		if canTarget(t) then
			local p = fireProjectileAtTarget(kaiju, t, worldpos, Point(0, 0), weapon);
			p:setCallback(this, 'onHit');
			p:setCollisionEnabled(false);
		end
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura)
		end
	end
end
