--NoTargetText 'scripts/avatars/common.lua'

require 'scripts/avatars/common'

local kaiju = nil
local weapon = "weapon_shrubby_airVine1"
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

	local worldPos = kaiju:getWorldPosition()
	local target = getClosestAirTargetInRadius(worldPos, getWeaponRange(weapon), EntityFlags(EntityType.Vehicle))
	local view = kaiju:getView()
	if canTarget(target) then
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle())
		proj:setCallback(this, 'onHit')
		playSound("shrubby_ability_VineStrike")
		startCooldown(kaiju, abilityData.name)
		
		vineEffect = setupNewVine(vineEffect)
		vineEffect:setStartEntity(proj)
		vineEffect:setEndPoint(proj:getWorldPosition())
		vineEffect:activate()
		
		playAnimation(kaiju, "stomp")
	else
		NoTargetText(kaiju)
	end	
end

function onHit(proj)
	local pos = proj:getView():getPosition()
	createImpactEffect(proj:getWeapon(), pos)
	local targ = proj:getTarget()
	if canTarget(targ) then
		vineEffect:setStartEntity(targ)
	end
	vineEffect:endVine()
end