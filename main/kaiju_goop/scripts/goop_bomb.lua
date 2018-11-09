require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_GoopBomb";
local weapon2 = "goop_GoopBombSplit";
local weaponDamage = "goop_Goop" -- used for aoe range
local weapon_node = "eyeball"

local targetPos = nil;

local dotTime = 5;
local mainDot = 15;

local dotDamage = 3; -- goop_Goop;

local minGoop = 60;
local maxGoop = 80;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	mainDot = getWeaponDamage(weapon) * multiplier;
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_roar");
	registerAnimationCallback(this, kaiju, "start");
	playSound("goop_ability_GoopBomb"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	proj:setCallback(this, 'onHit');
	proj:setCollisionEnabled(false);
	startCooldown(kaiju, abilityData.name);	
end

-- Projectile hits a target.
function onHit(proj)
	targetPos = proj:getWorldPosition();
	
	local patch = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);
	patch:attachEffect("effects/goopball_splort.plist", 0, true);
	patch:attachEffect("effects/goopball_splortsplash.plist", -1, true);
	patch:attachEffect("effects/goopball_detonate1.plist", 0, true);
	patch:attachEffect("effects/goopball_detonate2.plist", 0, true);
	patch:attachEffect("effects/goopball_detonate3.plist", 0, true);
	
	local dotAura = Aura.create(this, patch);
	dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	dotAura:setTickParameters(1, 0);
	dotAura:setTarget(patch); -- required so aura doesn't autorelease	
	
	playSound("goop_ability_common_goopsplosion"); -- SOUND
end

function onTick(aura)
	if aura:getElapsed() < dotTime then
		local targets = getTargetsInRadius(targetPos, getWeaponRange(weaponDamage), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			local flying = false;
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				flying = veh:isAir();
			end
			if not flying then
				applyDamageWithWeaponDamage(kaiju, t, weapon, mainDot);
			end
		end
	else
		aura:getOwner():detachAura(aura);
		CreateBlob(targetPos, minGoop, maxGoop);
		createSplit(targetPos);
		createSplit(targetPos);
		createSplit(targetPos);
	end
end

function createSplit(org)
	local targ = offsetRandomDirection(org, getWeaponRange(weaponDamage), getWeaponRange(weapon2));
	local p = fireProjectileAtPoint(kaiju, org,  targ, weapon2);
	p:setCallback(this, 'onSplitHit');
	p:setCollisionEnabled(false);
end

function onSplitHit(proj)
	local projPos = proj:getWorldPosition();
	
	local patch = spawnEntity(EntityType.Minion, "unit_goop_patch", projPos);
	patch:attachEffect("effects/goopball_splortsplash.plist", -1, true);
	
	local dotAura = Aura.create(this, patch);
	dotAura:setScriptCallback(AuraEvent.OnTick, 'onSplitTick');
	dotAura:setTickParameters(1, 0);
	dotAura:setTarget(patch); -- required so aura doesn't autorelease	
	
	playSound("goop_ability_common_goopsplosion"); -- SOUND
end

function onSplitTick(aura)
	if not aura then return end
	local own = aura:getOwner();
	if not own then
		aura = nil return
	end
	if aura:getElapsed() < dotTime then
		local targets = getTargetsInRadius(own:getWorldPosition(), getWeaponRange(weaponDamage), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			local flying = false;
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				flying = veh:isAir();
			end
			if not flying then
				applyDamageWithWeaponDamage(kaiju, t, weaponDamage, dotDamage);
			end
		end
	else
		
		own:detachAura(aura);
		removeEntity(own);
	end
end

