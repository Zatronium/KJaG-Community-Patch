require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Barrage";
local weaponDamage = "goop_Goop"
local dotDamage = 3; -- goop_Goop;
local weapon_node = "eyeball"
local anim = "ability_barrage"

local dotTime = 5;
local aoeRange = 100;

local minGoop = 15;
local maxGoop = 20;

local targets = 3;
local curTarget = 0;
local event1 = "attack";
local event2 = "attack_02";
local lastEvent1 = true;

function onUse(a)
	kaiju = a;
	
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	
	enableTargetSelectionMultiple(this, abilityData.name, 'onTargets', getWeaponRange(weapon), targets);
end

-- Target selection is complete.
function onTargets(position)
	startAbilityUse(kaiju, abilityData.name);
	playAnimation(kaiju, anim);
	registerAnimationCallbackContinuous(this, kaiju, event1);
	playSound("goop_ability_Barrage"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	if curTarget >= targets - 1 then
		endAbilityUse(kaiju, abilityData.name);
		removeAnimationCallback(this, kaiju);
	elseif lastEvent1 then
		registerAnimationCallbackContinuous(this, kaiju, event2);
		lastEvent1 = false;
	else
		registerAnimationCallbackContinuous(this, kaiju, event1);
		lastEvent1 = true;
	end
	
	local targetPos = getAbilityTargetPos(kaiju, abilityData.name, curTarget);
	
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);
	
	local proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	proj:setCollisionEnabled(false);
	proj:setCallback(this, 'onHit');

	curTarget = curTarget + 1;
end

-- Projectile hits a target.
function onHit(proj)
	local targetPos = proj:getWorldPosition();
	
	local patch = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);
	patch:attachEffect("effects/goop_slamsplash1.plist", 0, true);
	patch:attachEffect("effects/goop_slamsplash3.plist", 0, true);
	
	local dotAura = Aura.create(this, patch);
	dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	dotAura:setTickParameters(1, 0);
	dotAura:setStat("MaxHealth", 1);
	dotAura:setTarget(patch); -- required so aura doesn't autorelease	
	
	playSound("goop_ability_common_goopsplosion"); -- SOUND
end

function onTick(aura)
	if not aura then return end
	local own = aura:getOwner()
	if not own then
		aura = nil return
	end
	if aura:getElapsed() < dotTime then
		local targets = getTargetsInRadius(own:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		local playeffect = 5;
		for t in targets:iterator() do
			if not isSameEntity(kaiju, t) then
				local flying = false;
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t);
					flying = veh:isAir();
				end
				if not flying then
					t:attachEffect("effects/goop_dissolve.plist", 1, true);
					if playeffect > 0 then
						createEffectInWorld("effects/goop_infusion.plist", t:getWorldPosition(), 0);
						playeffect = playeffect - 1;
					end
					applyDamageWithWeaponDamage(kaiju, t, weaponDamage, dotDamage);
					aura:setStat("MaxHealth", 2);
				end
			end
		end
	else
		if aura:getStat("MaxHealth") > 1 then
			CreateBlob(own:getWorldPosition(), minGoop, maxGoop);
		end
		own:detachAura(aura);
		removeEntity(own);
	end
end
