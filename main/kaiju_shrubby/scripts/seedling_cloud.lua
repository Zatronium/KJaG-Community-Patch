require 'scripts/common'

local kaiju = nil
local seedSpawnRange = 300

local max_seeds = 5
local min_seeds = 3

function onUse(a)
	kaiju = a
	playAnimation(kaiju, "ability_roar")
	
	local amount = randomInt(min_seeds, max_seeds)
	local worldPos = kaiju:getWorldPosition()
	while amount > 0 do
		amount = amount - 1
		local targetPos = offsetRandomDirection(worldPos, 0, seedSpawnRange)
		local proj = avatarFireAtPoint(kaiju, "weapon_spawnseedling", "breath_node", targetPos, 0)
		proj:setCollisionEnabled(false)
		proj:setCallback(this, 'onHit')
	end
	playSound("shrubby_ability_SeedlingCloud")
	startCooldown(kaiju, abilityData.name)
end

function onHit(proj)
	local targetPos = getNearestRoad(proj:getWorldPosition())
	local ent = spawnEntity(EntityType.Minion, "unit_shrubby_seedling", targetPos)
	setRole(ent, "Player")
	local scenePos = ent:getView():getPosition()
	createImpactEffect(proj:getWeapon(), scenePos)
end
