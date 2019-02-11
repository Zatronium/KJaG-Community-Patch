--NoTargetText 'scripts/avatars/common.lua'

require 'scripts/avatars/common'

-- Global values.
local kaiju = nil
local weapon = "weapon_shrubby_vine2"
local weapon_node = "root"
local vineEffect = nil

function setupNewVine(vine)
	if not vine then
		vine = createVine("effects/vine.plist")
	else
		vine = vine:createNextVine(true)
	end
	vine:setOscillation(77)
	vine:setOscillationWidth(30)
	vine:setMaxLength(1000)
	vine:setVineWidth(15)
	vine:setSpeed(10)
	vine:setTailLength(10)
	return vine
end

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
		playAnimation(kaiju, "punch_01")
		registerAnimationCallback(this, kaiju, "attack")
	end
end

function onAnimationEvent(a)
	local view = kaiju:getView()
	local target = getAbilityTarget(kaiju, abilityData.name)
	if target and canTarget(target) then
		local proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle())
		proj:setCallback(this, 'onHit')
	
		vineEffect = setupNewVine(vineEffect)
		vineEffect:setStartEntity(proj)
		vineEffect:setEndPoint(proj:getWorldPosition())
		vineEffect:activate()
		
		playSound("shrubby_ability_Piercer")
		startCooldown(kaiju, abilityData.name);
	else
		NoTargetText(kaiju)
	end
end

function onHit(proj)
	if vineEffect then
		local scenePos = proj:getView():getPosition()
		createImpactEffect(proj:getWeapon(), scenePos)
		vineEffect:endVine()
	end
end