require 'scripts/avatars/common'

local avatar = nil;
local angle = 45;
local weapon = "Arc1"

local protectedDotWeapon = "weapon_gordon_deathArc1"
local unprotectedDotWeapon = "weapon_gordon_deathArc2"

local dotDuration = 10;
local range = 200;

local worldPosition = nil;
local worldFacing = nil;

local empower = 0;

function onUse(a)
	avatar = a;
	playAnimation(a, "ability_stomp");
	registerAnimationCallback(this, a, "attack");
end

function onAnimationEvent(a)
	startCooldown(avatar, abilityData.name);
	empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	playSound("DeathArc");
	local view = avatar:getView();
	worldPosition = avatar:getWorldPosition();
	worldFacing = avatar:getWorldFacing();
	local sceneFacing = avatar:getSceneFacing();

	view:doEffectFromNode('breath_node', 'effects/deathArc_main.plist', sceneFacing);
	
	local zones = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Zone));
	abilityEnhance(empower);
	for z in zones:iterator() do
		applyDamageWithWeapon(avatar, z, weapon);
	end
	abilityEnhance(0);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(0.1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "delayedDamage");
	aura:setTarget(avatar);
	
end

function delayedDamage(aura)
	if aura:getElapsed() > 0 then
		local targets = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
		
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(avatar, t) then
				t:attachEffect("effects/firePunch_sparks.plist", 2, true);
				local aura = createAura(this, t, 0);
				aura:setTickParameters(1, 0);
				if isOrganic(t) then
					aura:setScriptCallback(AuraEvent.OnTick, "onTick");
				else
					aura:setScriptCallback(AuraEvent.OnTick, "onTickProtected");
				end
				aura:setTarget(t);
				t = nil; -- onTick may have killed target at this point
			end
		end
		aura:getOwner():detachAura(aura);
	end
end

function onTick(aura)
	if aura:getElapsed() >= dotDuration then
		aura:getOwner():detachAura(aura);
	else
		abilityEnhance(empower);
		avatar = getPlayerAvatar();
		applyDamageWithWeapon(avatar, aura:getTarget(), unprotectedDotWeapon);
		abilityEnhance(0);
	end
end

function onTickProtected(aura)
	if aura:getElapsed() >= dotDuration then
		aura:getOwner():detachAura(aura);
	else
		abilityEnhance(empower);
		applyDamageWithWeapon(avatar, aura:getTarget(), protectedDotWeapon);
		abilityEnhance(0);
	end
end