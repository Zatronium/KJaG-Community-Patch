require 'kaiju_goop/scripts/goop'
-- Global values.
kaiju = 0;
weapon = "goop_Viral1";
weaponDamage = "goop_StingDamage"
weapon_node = "tail_sting"

dotDamage = 3; -- goop_Goop;
dotDuration = 10;
durationDecay = 0.5;
minDuration = 2;

infectRange = 50;


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
		if flying == false then
			local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
			kaiju:setWorldFacing(facingAngle);	
			playAnimation(kaiju, "ability_sting");
			registerAnimationCallback(this, kaiju, "attack");
			playSound("goop_ability_ViralGoop"); -- SOUND
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
		target:attachEffect("effects/goop_viral_persist", duration, true);
		viralAura(this, 'onTick', target, duration, 0);
	end
	dotDuration = math.floor(dotDuration * durationDecay);
	createImpactEffectFromPage(weapon, proj:getWorldPosition(), 0);

	createEffectInWorld("effects/sting_viral_impact.plist", proj:getWorldPosition(), 0);
	createEffectInWorld("effects/sting_impact_virus.plist", proj:getWorldPosition(), 0);
	createEffectInWorld("effects/goopball_splortsplash.plist", proj:getWorldPosition(), 0);
	createEffectInWorld("effects/goopball_splort.plist", proj:getWorldPosition(), 0);
	createEffectInWorld("effects/goop_infusion_viral.plist", proj:getWorldPosition(), 0);
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
		if minDuration <= dotDuration then
			local t = getClosestTargetInRadius(target:getWorldPosition(), infectRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar), getPlayerAvatar());
			if canTarget(t) then
				local p = fireProjectileAtTarget(getPlayerAvatar(), t, target:getWorldPosition(), Point(0, 0), weapon);
				p:setCallback(this, 'onHit');
				p:setCollisionEnabled(false);
				p:setStat("MaxHealth", dotDuration);
			end
			aura:getOwner():detachAura(aura);
		end
	end
end