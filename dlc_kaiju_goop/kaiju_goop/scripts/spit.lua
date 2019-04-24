require 'kaiju_goop/scripts/goop'

local kaiju = nil
local weapon = "goop_Spit";
local weaponDamage = "goop_Goop"
local weapon_node = "eyeball"

local targetPos = nil
local dotTime = 5
local dotDamage = 3

local minGoop = 15
local maxGoop = 20

function onUse(a)
	kaiju = a
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus")
	dotDamage = getWeaponDamage(weaponDamage) * multiplier
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon))
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position
	target = getAbilityTarget(kaiju, abilityData.name)
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos)
	kaiju:setWorldFacing(facingAngle)
	playAnimation(kaiju, "ability_roar")
	registerAnimationCallback(this, kaiju, "start")
	playSound("goop_ability_Spit") -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView()
	local proj
	local target = getAbilityTarget(kaiju, abilityData.name)
	if canTarget(target) then
		targetPos = target:getWorldPosition()
	end
	proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle())
	proj:setCollisionEnabled(false)
	proj:setCallback(this, 'onHit')
	startCooldown(kaiju, abilityData.name);
end

-- Projectile hits a target.
function onHit(proj)
	targetPos = proj:getWorldPosition()
	
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos)
	cloud:attachEffect("effects/goopball_splort.plist", 0, true)
	cloud:attachEffect("effects/goopball_splortsplash.plist", -1, true)

		createEffectInWorld("effects/goopball_detonate1.plist", targetPos, 0)
		createEffectInWorld("effects/goopball_detonate2.plist", targetPos, 0)
		createEffectInWorld("effects/goopball_detonate3.plist", targetPos, 0)
	
	local scriptAura = Aura.create(this, cloud)
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick')
	scriptAura:setTickParameters(1, 0)
	scriptAura:setStat("Health", 1)
	scriptAura:setTarget(cloud) -- required so aura doesn't autorelease	
	
	playSound("goop_ability_common_goopsplosion"); -- SOUND
end

function onTick(aura)
	if not aura then return end
	local owner = aura:getOwner()
	if not owner then return end
	if aura:getElapsed() < dotTime then
		local targets = getTargetsInRadius(targetPos, getWeaponRange(weaponDamage), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar))
		local playeffect = 5
		for t in targets:iterator() do
			if not isSameEntity(kaiju, t) then
				local flying = false
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t)
					flying = veh:isAir()
				end
				if not flying then
					t:attachEffect("effects/goop_dissolve.plist", 1, true);
					if playeffect > 0 then
						createEffectInWorld("effects/goop_infusion.plist", t:getWorldPosition(), 0)
						playeffect = playeffect - 1
					end
					applyDamageWithWeaponDamage(kaiju, t, weaponDamage, dotDamage)
					aura:setStat("Health", 2)
				end
			end
		end
	else
		if aura:getStat("Health") > 1 then
			CreateBlob(owner:getWorldPosition(), minGoop, maxGoop);
		end
		owner:detachAura(aura)
		removeEntity(owner)
	end
end
