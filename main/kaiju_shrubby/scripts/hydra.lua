--NoTargetText 'scripts/avatars/common.lua'
require 'scripts/avatars/common'

local kaiju						= nil
local weapon					= "weapon_shrubby_airVine3"
local weapon_node				= "root"
local hydraHopRange				= 350
local initialTargetCount		= 0
local maxHydraHeads				= 3
local maxHydraTargetHistory		= 3
local maxHydraHops				= 5
local weaponRange				= 0

local isSameEntity_L			= isSameEntity
local entityToVehicle_L			= entityToVehicle
local getTargetsInRadius_L		= getTargetsInRadius
local canTarget_L				= canTarget
		
local targetArray				= {}
local vines						= {}
local projectiles				= {}


function setupNewVine()
	local vine = createRope("sprites/placehold_vine.png", 20, 45)
	vine:setUV(0.7, 0.3, 1)
	vine:setNoise(10, 20)
	vine:setRetract(0.4, 100)
	vine:setEndEntity(kaiju)
	return vine
end

function onUse(a)
	kaiju				= a
	weaponRange			= getWeaponRange("weapon_shrubby_airVine3")
	for i=1,maxHydraHeads do
		targetArray[i]	= {}
	end
	
	playAnimation(kaiju, "stomp")
	registerAnimationCallback(this, kaiju, "attack")
end

function onAnimationEvent(a)
	local avPos							= kaiju:getWorldPosition()
	local targets						= getTargetsInRadius_L(avPos, weaponRange, EntityFlags(EntityType.Vehicle))
	for t in targets:iterator() do
		if initialTargetCount < maxHydraHeads then
			local ent = entityToVehicle_L(t)
			if ent and ent:isAir() then
				initialTargetCount		= initialTargetCount + 1
				targetArray[initialTargetCount][1]	= t
			end
		else
			break
		end
	end
	if initialTargetCount == 0 then
		NoTargetText(kaiju)
	else
		startCooldown(kaiju, abilityData.name)
		playSound("shrubby_ability_Hydra")
		local view = kaiju:getView()
		local proj
		
		for i=1,initialTargetCount do
			if targetArray[i][1] and canTarget_L(targetArray[i][1]) then
				proj					= avatarFireAtTarget(kaiju, weapon, weapon_node, targetArray[i][1], 90 - view:getFacingAngle())
			else
				proj					= avatarFireAtPoint(kaiju, weapon, weapon_node, offsetRandomDirection(avPos, hydraHopRange, weaponRange), 90 - view:getFacingAngle())
			end
			vines[i] = setupNewVine()
			vines[i]:setStartEntity(proj)
			vines[i]:activate()
			projectiles[proj]			= i --Using the unique signature of the projectile as a table index. I believe this is called a map in C++.
			proj:setCallback(this, 'onHit')
		end
	end
end

function onHit(proj)
	if not proj then return end
	local projectileArrayIndex	= projectiles[proj]
	if not projectileArrayIndex then return end
	local pos					= proj:getView():getPosition()
	local worldPos				= proj:getWorldPosition()
	createImpactEffect(proj:getWeapon(), pos)
	local projTargetArray		= targetArray[projectileArrayIndex] --Note: We're creating a reference to the second matrix of targetArray; this is why it appears the second matrix isn't assigned after onAnimationEvent is called.
	if #projTargetArray < maxHydraHops then
		local targets = getTargetsInRadius(worldPos, hydraHopRange, EntityFlags(EntityType.Vehicle)) -- Intentionally using the unchecked target scanner; only nil targets are a problem, not untargetable targets.
		for t in targets:iterator() do
			local v = entityToVehicle_L(t)
			if v and v:isAir() and not isTargetedEntity(projTargetArray, t) then	
				local targetArrayMaxIndex				= #projTargetArray
				projTargetArray[targetArrayMaxIndex]	= t
				local proj1 = fireProjectileAtTarget(kaiju, t, worldPos, Point(0, 0), weapon)
				projectiles[proj]						= nil
				projectiles[proj1]						= projectileArrayIndex
				proj1:setCallback(this, 'onHit')
				vine[projectileArrayIndex]:setStartEntity(proj1)
				return
			end
		end
	end
	projTargetArray[projectileArrayIndex]	= nil
	projectiles[proj]						= nil
	vine[projectileArrayIndex]:endRope()
	vine[projectileArrayIndex]				= nil
	proj									= nil
end

function isTargetedEntity(targetTable, target)
	for i=1,#targetTable do
		if isSameEntity_L(targetTable[i], target) then
			return true
		end
	end
	return false
end