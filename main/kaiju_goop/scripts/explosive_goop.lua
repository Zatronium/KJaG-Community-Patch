require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Explosive1";
local weaponDamage = "goop_StingDamage"
local weapon_node = "tail_sting"
local dotDamage = 3; -- goop_Goop;
local dotDuration = 10;

function onUse(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local flying = false;
		if getEntityType(target) == EntityType.Vehicle then
			local veh = entityToVehicle(target);
			flying = veh:isAir();
		end
		if not flying then
			local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
			kaiju:setWorldFacing(facingAngle);	
			playAnimation(kaiju, "ability_sting");
			registerAnimationCallback(this, kaiju, "attack");
			playSound("goop_ability_ExplosiveGoop"); -- SOUND
		end
	end
end

function onAnimationEvent(a)
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local view = kaiju:getView();
		local proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle());
		proj:setCallback(this, 'onHit');
		startCooldown(kaiju, abilityData.name);
	end
end

-- Projectile hits a target.
function onHit(proj)
	local target = proj:getTarget();
	if canTarget(target) then
		target:attachEffect("effects/goop_injected_persist", dotDuration, true);
		local dotAura = Aura.create(this, target);
		dotAura:setScriptCallback(AuraEvent.OnTick, 'onTickEx');
		dotAura:setTickParameters(1, dotDuration);
		dotAura:setTarget(target); -- required so aura doesn't autorelease
	end
	createImpactEffectFromPage(weapon, proj:getWorldPosition(), 0);

	createEffectInWorld("effects/goop_infusion_explosive.plist", proj:getWorldPosition(), 0);
	
	playSound("goop_ability_common_goopsplosion"); -- SOUND
end

function onDetach(aura)
	local atarget = aura:getOwner();
	local ahp = aura:getStat("Health");
	if ahp > 0 and not (atarget == nil) and not canTarget(atarget) then
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
