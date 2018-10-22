require 'scripts/avatars/common'

local avatar = nil;
local angle = 45;
local weapon = "weapon_gordon_placehold"

local DotWeapon = "weapon_gordon_placehold"

local dotDuration = 10;
local range = 200;

local worldPosition = nil;
local worldFacing = nil;

function onUse(a)
	avatar = a;
	playAnimation(a, "ability_stomp");
	registerAnimationCallback(this, a, "attack");
end

function onAnimationEvent(a)
	avatar = a;
	startCooldown(avatar, abilityData.name);
	playSound("IgnitionZone");
	local view = avatar:getView();
	worldPosition = avatar:getWorldPosition();
	worldFacing = avatar:getWorldFacing();
	local sceneFacing = avatar:getSceneFacing();
	view:doEffectFromNode('breath_node', 'effects/ignitionZone.plist', sceneFacing);
	local zones = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Zone));
	empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
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
		local targets = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Vehicle));
		
		for t in targets:iterator() do
			if canTarget(t) then
				t:attachEffect("effects/firePunch_sparks.plist", 2, true);
				local aura = createAura(this, t, 0);
				aura:setTickParameters(1, 0);
				aura:setScriptCallback(AuraEvent.OnTick, "onTick");
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
		applyDamageWithWeapon(avatar, aura:getTarget(), DotWeapon);
		abilityEnhance(0);
	end
end