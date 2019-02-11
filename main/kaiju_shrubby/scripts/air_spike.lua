--NoTargetText 'scripts/avatars/common.lua'

require 'scripts/avatars/common'

local kaiju = nil
local weapon = "weapon_shrubby_airVine3"
local weapon_node = "root"
local number_targets = 5
local jump_range = 350

local target1 = nil
local target2 = nil
local target3 = nil
local target4 = nil

local vine = nil

function onUse(a)
	kaiju = a
	playAnimation(kaiju, "stomp")
	registerAnimationCallback(this, kaiju, "attack")
end


function onAnimationEvent(a)
	local target = getClosestAirTargetInRadius(kaiju:getWorldPosition(), getWeaponRange(weapon), EntityFlags(EntityType.Vehicle))
	target1 = target
	local view = kaiju:getView()
	local proj
	if target and canTarget(target) then
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle())
		
		playSound("shrubby_ability_AirSpike")
		startCooldown(kaiju, abilityData.name)
		
		--vine = createRope("sprite", segments, strokeWidth, tipUV, endUV);
		vine = createRope("sprites/placehold_vine.png", 20, 45)
		-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
		vine:setUV(0.7, 0.3, 1)
		-- setNoise(min distance, max distance) default 0, 0
		vine:setNoise(10, 20)
		-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
		vine:setRetract(0.2, 50)
		vine:setStartEntity(proj)
		vine:setEndEntity(kaiju)
		vine:activate()
		proj:setCallback(this, 'onHit')
	else
		NoTargetText(kaiju)
	end
end

function onHit(proj)
	local isSameEntity_L			= isSameEntity
	local entityToVehicle_L 		= entityToVehicle
	local fireProjectileAtTarget_L	= fireProjectileAtTarget
	local pos = proj:getView():getPosition()
	local worldPos = proj:getWorldPosition()
	createImpactEffect(proj:getWeapon(), pos)
	if number_targets > 1 then
		local targets = getTargetsInPointRadius(worldPos, jump_range, EntityFlags(EntityType.Vehicle))
		if targets then
			for t in targets:iterator() do
				local v = entityToVehicle_L(t)
				if v:isAir() and not isSameEntity_L(target1, t) and not isSameEntity_L(target2, t) and not isSameEntity_L(target3, t) and not isSameEntity_L(target4, t) then
					target4 = target3
					target3 = target2
					target2 = target1
					target1 = t
					local nproj = fireProjectileAtTarget_L(kaiju, t, worldPos, Point(0, 0), weapon)
					number_targets = number_targets - 1
					nproj:setCallback(this, 'onHit')
					vine:setStartEntity(nproj)
					return
				end
			end
		end
	end
	vine:endRope()
end