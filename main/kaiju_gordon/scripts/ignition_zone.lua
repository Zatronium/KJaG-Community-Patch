require 'scripts/avatars/common'

local kaiju = nil;
local angle = 45;
local weapon = "weapon_gordon_placehold"

local DotWeapon = "weapon_gordon_placehold"

local dotDuration = 10;
local range = 200;

local worldPosition = nil;
local worldFacing = nil;

function onUse(a)
	kaiju = a;
	playAnimation(a, "ability_stomp");
	registerAnimationCallback(this, a, "attack");
end

function onAnimationEvent(a)
	kaiju = a;
	startCooldown(kaiju, abilityData.name);
	playSound("IgnitionZone");
	local view = kaiju:getView();
	worldPosition = kaiju:getWorldPosition();
	worldFacing = kaiju:getWorldFacing();
	local sceneFacing = kaiju:getSceneFacing();
	view:doEffectFromNode('breath_node', 'effects/ignitionZone.plist', sceneFacing);
	local zones = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Zone));
	empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);
	for z in zones:iterator() do
		applyDamageWithWeapon(kaiju, z, weapon);
	end
	abilityEnhance(0);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(0.1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "delayedDamage");
	aura:setTarget(kaiju);
	
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
			end
		end
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= dotDuration then
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	else
		abilityEnhance(empower);
		applyDamageWithWeapon(kaiju, aura:getTarget(), DotWeapon);
		abilityEnhance(0);
	end
end