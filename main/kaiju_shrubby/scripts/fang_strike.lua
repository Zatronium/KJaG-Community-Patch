require 'scripts/common'

local kaiju = nil
local weapon = "weapon_shrubby_vine3"
local weapon_node = "root"
local damage_per_tick = 3
local number_of_ticks = 5
local kbPower = 500
local kbDistance = 1000 -- max distance
local vine = nil

function onUse(a)
	kaiju = a
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon))
end

-- Target selection is complete.
function onTargets(position)
	local target = getAbilityTarget(kaiju, abilityData.name);
	if target and canTarget(target) then
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position)
		kaiju:setWorldFacing(facingAngle)
		playAnimation(kaiju, "punch_01")
		registerAnimationCallback(this, kaiju, "attack")
	end
end

function onAnimationEvent(a)
	local view = kaiju:getView()
	local proj
	local target = getAbilityTarget(kaiju, abilityData.name)
	local targetPos = target:getView():getPosition()
	if target and canTarget(target) then
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle())
	else
		proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle())
	end
	
	vine = createRope("sprites/placehold_vine.png", 20, 45)
	-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
	vine:setUV(0.7, 0.3, 1)
	-- setNoise(min distance, max distance) default 0, 0
	vine:setNoise(0, 10)
	-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
	vine:setRetract(0.0, 100)
	vine:setStartEntity(proj)
	vine:setEndEntity(kaiju)
	vine:activate()
	
	proj:setCallback(this, 'onHit')
	playSound("shrubby_ability_FangStrike")
	startCooldown(kaiju, abilityData.name)
end

-- Projectile hits a target.
function onHit(proj)
	if not vine then return end
	local scenePos = proj:getView():getPosition()
	createImpactEffect(proj:getWeapon(), scenePos)
	local t = proj:getTarget()
	if t and canTarget(t) then
		local worldPos = kaiju:getWorldPosition()
		local otherPos = t:getWorldPosition()
		local distance = getDistanceFromPoints(otherPos, worldPos)
		if distance > kbDistance then
			distance = kbDistance
		else
			vine:setStartEntity(t)
		end
		local dir = getDirectionFromPoints(otherPos, worldPos)
		t:displaceDirection(dir, kbPower, distance)
		if not t:hasStat("Speed") then
			vine:setStartEntity(nil)
		end
		
		vine:setNoise(0, 0)
		vine:endRope()
		
		local aura = createAura(this, t, 0)
		aura:setTickParameters(1, 0)
		aura:setScriptCallback(AuraEvent.OnTick, "onTick")
		aura:setTarget(t)
	else
		vine:endRope()
	end
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() < number_of_ticks then
		applyDamage(kaiju, aura:getTarget(), damage_per_tick)
	else
		if vine then
			vine:setStartEntity(nil)
		end
		
		local self = aura:getOwner()
		if not self then
			aura = nil return
		else
			self:detachAura(aura)
		end
	end
end