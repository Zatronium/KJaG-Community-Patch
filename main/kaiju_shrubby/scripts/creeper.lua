require 'scripts/common'

-- Global values.
local avatar = 0;
local weapon = "weapon_shrubby_creeper";
local target = nil;
local targetPos = nil;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
		avatar:setWorldFacing(facingAngle);	
		playAnimation(avatar, "stomp");
		registerAnimationCallback(this, avatar, "attack");
	end
end

function onAnimationEvent(a)
	avatar = a;
	local view = avatar:getView();
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		local success = true;
		if getEntityType(target) == EntityType.Vehicle then	
			local veh = entityToVehicle(target);
			if veh:isAir() == true then
				success = false;
			end
		end
		if success == true then
			targetPos = target:getWorldPosition();
			applyDamageWithWeapon(avatar, target, weapon);
			createEffectInWorld("effects/roots_creeper.plist", targetPos, 1);
			createEffectInWorld("effects/creeper_rocks.plist", targetPos, .2);
			createEffectInWorld("effects/creeper_shrapnelLeft.plist", targetPos,.2);
			createEffectInWorld("effects/creeper_shrapnelRight.plist", targetPos, .2);
			playSound("shrubby_ability_Creeper");
			startCooldown(avatar, abilityData.name);	
		end
	end
end