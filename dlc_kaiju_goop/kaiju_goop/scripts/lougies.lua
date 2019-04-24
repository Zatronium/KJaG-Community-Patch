--NoTargetText 'scripts/avatars/common.lua'

require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Lougee";
local weaponDamage = "goop_LougeeDamage";
local weapon_node = "eyeball"

local minGoop = 10;
local maxGoop = 20;

local dotDuration = 5;
local dotDamage = 3;

local numTargets = 5;
local fireDelay = 1;

function onUse(a)
	kaiju = a;
	
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	
	playAnimation(kaiju, "ability_artillery");
	registerAnimationCallback(this, kaiju, "attack");
	
	playSound("goop_ability_Lougies"); -- SOUND
end

function onAnimationEvent(a)
	local check = getClosestAirTargetInRadius(kaiju:getWorldPosition(), getWeaponRange(weapon), EntityFlags(EntityType.Vehicle));
	if not canTarget(check) then
		NoTargetText(kaiju);
		return;
	end
	
	local spitAura = Aura.create(this, kaiju);
	      spitAura:setScriptCallback(AuraEvent.OnTick, 'Spit');
	      spitAura:setTickParameters(fireDelay, 0);
	      spitAura:setTarget(kaiju); -- required so aura doesn't autorelease
	local view = kaiju:getView();
	startAbilityUse(kaiju, abilityData.name);
--	view:togglePauseAnimation(true);
end

function Spit(aura)
	if not aura then return end
	local inc = 1;
	local kaijuWorldPosition = kaiju:getWorldPosition()
	local targets = getTargetsInRadius(kaijuWorldPosition, getWeaponRange(weapon), EntityFlags(EntityType.Vehicle));
	local fired = false;
	local airUnits = 0;
	while not fired do
		airUnits = 0;
		for t in targets:iterator() do
			if canTarget(t) and not fired then
				local veh = entityToVehicle(t);
				if veh:isAir() then
					if not t:hasAura("lougee") or t:getAura("lougee"):getStat("MaxHealth") < inc then
						local facingAngle = getFacingAngle(kaijuWorldPosition, t:getWorldPosition());
						kaiju:setWorldFacing(facingAngle);	
						local proj = avatarFireAtTarget(kaiju, weapon, weapon_node, t, 90 - facingAngle);
						proj:setCallback(this, 'onHit');
						fired = true;
						local airAura = nil;
						if t:hasAura("lougee") then
							airAura = t:getAura("lougee");
						else
							airAura = Aura.create(this, t);
							airAura:setTag("lougee");
							airAura:setTickParameters(dotDuration, dotDuration);
							airAura:setTarget(t); -- required so aura doesn't autorelease
						end
						airAura:setStat("MaxHealth", inc);
						airAura:resetElapsed();
					end
					airUnits = 1;
				end
			end
		end
		if airUnits == 0 then
			fired = true;
		end
		inc = inc + 1;
	end
	
	numTargets = numTargets - 1;
	if numTargets <= 0 or airUnits == 0 then
		local view = kaiju:getView();
		view:togglePauseAnimation(false);
		endAbilityUse(kaiju, abilityData.name);
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
	end
end

-- Projectile hits a target.
function onHit(proj)
	local target = proj:getTarget();
	local scenePos = getScenePosition(proj:getWorldPosition());
--	createEffect("effects/goopball_splort.plist", proj:getWorldPosition());
--	createEffect("effects/goopball_splortsplash.plist",	scenePos);
	createEffect("effects/impact_sharp_splash.plist",	scenePos);

	createEffect("effects/goop_splash.plist",	scenePos);
	createEffect("effects/goopball_splort.plist",	scenePos);
	createEffect("effects/goopball_splortsplash.plist",	scenePos);

	if canTarget(target) then
		local dotAura = Aura.create(this, target);
		if target:hasAura("air_death") then
			local oldAura = target:getAura("air_death");
			oldAura:setTag("");
		end
		dotAura:setTag("air_death");
		dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		dotAura:setTickParameters(1, dotDuration);
		dotAura:setTarget(target); -- required so aura doesn't autorelease
	end
end

-- air_death
function onTick(aura)
	local target = aura:getTarget();
	applyDamageWithWeaponDamage(kaiju, target, weaponDamage, dotDamage);
end

function onAirDeath(ent, success)
	CreateBlob(ent:getWorldPosition(), minGoop, maxGoop);
end
