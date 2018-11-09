require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_GodGoop";
local weapon_node = "eyeball"

local dotDamage = 20;

local spreadMinRadius = 175;
local spreadMaxRadius = 300;
local spreadCountPer = 3;
local spreadLimit = 4;

local hitRadius = 50;

local targetpos = nil;

function onUse(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weapon) * multiplier;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetpos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) and getEntityType(target) == EntityType.Zone then
		targetpos = target:getWorldPosition();
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetpos);
		kaiju:setWorldFacing(facingAngle);	
		playAnimation(kaiju, "ability_breath");
		registerAnimationCallback(this, kaiju, "start");
		playSound("goop_ability_common_GodGoop"); -- SOUND
	end
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetpos, 0);
	proj:setCallback(this, 'onHit');
	proj:setCollisionEnabled(false);
	proj:setStat("MaxHealth", spreadLimit);
	startCooldown(kaiju, abilityData.name);
end

-- Projectile hits a target.
function onHit(proj)
	local projpos = proj:getWorldPosition();
	local zonetarget = getClosestTargetInRadius(projpos, hitRadius, EntityFlags(EntityType.Zone), getPlayerAvatar());
	
	if canTarget(zonetarget) then
		local scriptAura = Aura.create(this, zonetarget);
		scriptAura:setTag('goop_godgoop');
		scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		scriptAura:setTickParameters(1, 0); --updates at time 0 then at time 20
		scriptAura:setUpdateDelay(1);
		scriptAura:setStat("MaxHealth", proj:getStat("MaxHealth"));
		scriptAura:setTarget(zonetarget); -- required so aura doesn't autorelease
		
		zoneAttachEffect2(zonetarget, "effects/goop_infusion.plist", Point(100, 100));
	end
	createImpactEffectFromPage(weapon, projpos, 0);
end

function onTick(aura)
	if not aura then return end
	local own = aura:getOwner();
	if not own then
		aura = nil return
	end
	if not canTarget(own) then
		aura:setTarget(nil);
		own:detachAura(aura);
		return;
	end
	
	local iter = aura:getStat("MaxHealth");
	local ownPos = own:getWorldPosition();
	applyDamageWithWeaponDamage(kaiju, own, weapon, dotDamage);
	-- if killed explode here
	if not canTarget(own) and iter > 0 then
		local i = 0;
		
		createEffectInWorld("effects/goop_detonate1_god.plist", ownPos, 0);
		createEffectInWorld("effects/goop_detonate2_god.plist", ownPos, 0);
		createEffectInWorld("effects/goop_detonate3_god.plist", ownPos, 0);
		while i < spreadCountPer do
			local randpos = offsetRandomDirection(ownPos, spreadMinRadius, spreadMaxRadius);
			local p = fireProjectileAtPoint(kaiju, ownPos, randpos, weapon);
			p:setCallback(this, 'onHit');
			p:setStat("MaxHealth", iter - 1);
			p:setCollisionEnabled(false);
			i = i + 1;
		end
	end
	if not canTarget(own) then
		aura:setTarget(nil);
		own:detachAura(aura);
	end
end