require 'scripts/common'

local kaiju = nil
local targetPos = 0
local seedSpawnRange = 400

function onUse(a)
	kaiju = a
	enableTargetSelection(this, abilityData.name, 'onTarget', seedSpawnRange)
end

-- Target selection is complete.
function onTarget(position)
	targetPos = position
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos)
	kaiju:setWorldFacing(facingAngle)
	playAnimation(kaiju, "ability_roar")
	registerAnimationCallback(this, kaiju, "start")
end

function onAnimationEvent(a)
	local proj = avatarFireAtPoint(kaiju, "weapon_spawnsprout", "breath_node", targetPos, 0)
	proj:setCollisionEnabled(false)
	proj:setCallback(this, 'onHit')
	playSound("shrubby_sprout_muzzle")
	startCooldown(kaiju, abilityData.name)
end

function onHit(proj)	
	targetPos = getNearestRoad(proj:getWorldPosition())
	local ent = spawnEntity(EntityType.Minion, "unit_shrubby_seedling_small", targetPos)
	setRole(ent, "Player")
	local scenePos = ent:getView():getPosition()
	createImpactEffect(proj:getWeapon(), scenePos)
end
