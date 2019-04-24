require 'kaiju_goop/scripts/goop'
-- Global values.
kaiju = 0;
weapon = "goop_Sting";
weaponDamage = "goop_StingDamage"
weapon_node = "tail_sting"

targetPos = nil;
hasDamage = false;
totalDamage = 0;

dotDuration = 10;
dotDamage = 10;

function onUse(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local flying = false;
		if getEntityType(target) == EntityType.Vehicle then
			local veh = entityToVehicle(target);
			flying = veh:isAir();
		end
		if flying == false then
			local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
			kaiju:setWorldFacing(facingAngle);	
			playAnimation(kaiju, "ability_sting");
			registerAnimationCallback(this, kaiju, "attack");
			playSound("goop_ability_Sting"); -- SOUND
		end
	end
end

function onAnimationEvent(a)
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local view = kaiju:getView();
		local proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, view:getFacingAngle());
		proj:setCallback(this, 'onHit');
		startCooldown(kaiju, abilityData.name);
	end
end

-- Projectile hits a target.
function onHit(proj)
	local atarget = proj:getTarget();
	local fxpos = proj:getWorldPosition();
	if canTarget(atarget) then
		fxpos = atarget:getWorldPosition();
		local dotAura = Aura.create(this, atarget);
		dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		dotAura:setTickParameters(1, dotDuration);
		dotAura:setTarget(atarget); -- required so aura doesn't autorelease	
	end
	createEffectInWorld("effects/sting_impact.plist", fxpos, 0);
	createEffectInWorld("effects/sting_impact_splash.plist", fxpos, 0);
	createEffectInWorld("effects/goopball_splortsplash.plist", fxpos, 0);
	createEffectInWorld("effects/goopball_splort.plist", fxpos, 0);
	createEffectInWorld("effects/goop_infusion.plist", fxpos, 0);
end

function onDetach(aura)
	local atarget = aura:getTarget();
	if canTarget(atarget) then
		targetPos = target:getWorldPosition();
	end
	CreateBlob(targetPos, totalDamage, 0);
end

function onTick(aura)
	local atarget = aura:getTarget();
	local orgHp = 0;
	local hp = 0;
	if canTarget(atarget) then
		targetPos = atarget:getWorldPosition();
		orgHp = atarget:getStat("Health");
		applyDamageWithWeaponDamage(getPlayerAvatar(), atarget, weaponDamage, dotDamage);
		if (not canTarget(atarget)) then
			hp = 0;
		else
			hp = atarget:getStat("Health");
		end
	end
	
	totalDamage = totalDamage + (orgHp - hp);
	
	if not canTarget(atarget) then
		aura:getOwner():detachAura(aura);
	end
end
