require 'scripts/common'

local kaiju = nil
local weapon = "weapon_shrubby_creeper"

function onUse(a)
	kaiju = a
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon))
end

-- Target selection is complete.
function onTargets(position)
	local target = getAbilityTarget(kaiju, abilityData.name)
	if target and canTarget(target) then
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position)
		kaiju:setWorldFacing(facingAngle)
		playAnimation(kaiju, "stomp")
		registerAnimationCallback(this, kaiju, "attack")
	end
end

function onAnimationEvent(a)
	kaiju = a
	local view = kaiju:getView()
	local target = getAbilityTarget(kaiju, abilityData.name)
	if target and canTarget(target) then
		local success = true
		if getEntityType(target) == EntityType.Vehicle then	
			local veh = entityToVehicle(target)
			if veh:isAir() then
				success = false
			end
		end
		if success then
			local targetPos = target:getWorldPosition()
			applyDamageWithWeapon(kaiju, target, weapon)
			createEffectInWorld("effects/roots_creeper.plist", targetPos, 1)
			createEffectInWorld("effects/creeper_rocks.plist", targetPos, 0.2)
			createEffectInWorld("effects/creeper_shrapnelLeft.plist", targetPos, 0.2)
			createEffectInWorld("effects/creeper_shrapnelRight.plist", targetPos, 0.2)
			playSound("shrubby_ability_Creeper");
			startCooldown(kaiju, abilityData.name);	
		end
	end
end