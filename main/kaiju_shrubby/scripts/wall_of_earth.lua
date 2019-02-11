require 'scripts/common'

local kaiju = nil
local wallRadius = 250

function onUse(a)
	kaiju = a
	playAnimation(kaiju, "stomp")
	registerAnimationCallback(this, kaiju, "attack")
end

function onAnimationEvent(a)
	local origin = kaiju:getWorldPosition()
	local radius = wallRadius
	local unitSize = 100
	local unitSpacing = 0
	local targetHealthLimit = 20
	createHenge("unit_shrubby_earth_wall", origin, radius, unitSize, unitSpacing, targetHealthLimit)
	
	startCooldown(kaiju, abilityData.name)
	playSound("shrubby_ability_WallOfEarth")
end
