require 'kaiju_goop/scripts/goop'
-- Global values.
kaiju = 0;
weapon = "goop_Viral2";
weaponDamage = "goop_StingDamage"
weapon_node = "tail_sting"
anim = "ability_triplesting"

dotDuration = 10;
dotDamage = 10;
durationDecay = 0.5;
minDuration = 2;
infectRange = 50;

targets = 3;
curTarget = 0;
event1 = "attack";
event2 = "attack_02";
lastEvent1 = true;

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
	playSound("goop_ability_ViralBarrage"); -- SOUND
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
	proj:setStat("MaxHealth", dotDuration);
	
	curTarget = curTarget + 1;
end

-- Projectile hits a target.
function onHit(proj)
	local target = proj:getTarget();
	if canTarget(target) then
		target:attachEffect("effects/goop_viral_persist.plist", duration, true);
		target:attachEffect("effects/goop_infusion_viral.plist", duration, true);
		viralAura(this, 'onTick', target, proj:getStat("MaxHealth"), 1);
	end
	createImpactEffectFromPage(weapon, proj:getWorldPosition(), 0);
	playSound("goop_ability_common_goopsplosion2"); -- SOUND
end

function onDryHit(proj)
	local t = getClosestTargetInRadius(proj:getWorldPosition(), infectRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar), getPlayerAvatar());
	if canTarget(t) then
		local p = fireProjectileAtTarget(getPlayerAvatar(), t, proj:getWorldPosition(), Point(0, 0), weapon);
		p:setCallback(this, 'onHit');
		p:setCollisionEnabled(false);
		local dura = proj:getStat("MaxHealth");
		p:setStat("MaxHealth", dura * durationDecay);
	end
	createImpactEffectFromPage(weapon, proj:getWorldPosition(), 0);
	playSound("goop_ability_common_goopsplosion2"); -- SOUND
end

function onTick(aura)
	local target = aura:getTarget();
	local worldpos = target:getWorldPosition();
	applyDamageWithWeaponDamage(getPlayerAvatar(), target, weaponDamage, dotDamage);

	-- if killed explode here
	if not canTarget(target) then
		createEffectInWorld("effects/goop_detonate1_viral.plist", worldpos, 0);
		createEffectInWorld("effects/goop_detonate2_viral.plist", worldpos, 0);
		createEffectInWorld("effects/goop_detonate3_viral.plist", worldpos, 0);

		local dura = math.floor(aura:getStat("MaxHealth") * durationDecay);
		if dura >= minDuration then
			local t = getClosestTargetInRadius(target:getWorldPosition(), infectRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar), getPlayerAvatar());
			if canTarget(t) then
				local p = fireProjectileAtTarget(getPlayerAvatar(), t, target:getWorldPosition(), Point(0, 0), weapon);
				p:setCallback(this, 'onHit');
				p:setCollisionEnabled(false);
				p:setStat("MaxHealth", dura);
			end
		end
		aura:getOwner():detachAura(aura);
	end
end
