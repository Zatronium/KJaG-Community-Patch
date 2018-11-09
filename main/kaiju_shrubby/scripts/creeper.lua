require 'scripts/common'

-- Global values.
local kaiju = 0;
local weapon = "weapon_shrubby_creeper";
local target = nil;
local targetPos = nil;
function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
		kaiju:setWorldFacing(facingAngle);	
		playAnimation(kaiju, "stomp");
		registerAnimationCallback(this, kaiju, "attack");
	end
end

function onAnimationEvent(a)
	kaiju = a;
	local view = kaiju:getView();
	target = getAbilityTarget(kaiju, abilityData.name);
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
			applyDamageWithWeapon(kaiju, target, weapon);
			createEffectInWorld("effects/roots_creeper.plist", targetPos, 1);
			createEffectInWorld("effects/creeper_rocks.plist", targetPos, .2);
			createEffectInWorld("effects/creeper_shrapnelLeft.plist", targetPos,.2);
			createEffectInWorld("effects/creeper_shrapnelRight.plist", targetPos, .2);
			playSound("shrubby_ability_Creeper");
			startCooldown(kaiju, abilityData.name);	
		end
	end
end