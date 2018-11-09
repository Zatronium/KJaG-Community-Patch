require 'scripts/avatars/common'

local kaiju = nil;
local angle = 45;
local weapon = "Arc1"

local protectedDotWeapon = "weapon_gordon_deathArc1"
local unprotectedDotWeapon = "weapon_gordon_deathArc2"

local dotDuration = 10;
local range = 200;

local empower = 0;

function onUse(a)
	kaiju = a;
	playAnimation(a, "ability_stomp");
	registerAnimationCallback(this, a, "attack");
end

function onAnimationEvent(a)
	startCooldown(kaiju, abilityData.name);
	empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	playSound("DeathArc");
	local view = kaiju:getView();
	local worldPosition = kaiju:getWorldPosition();
	local worldFacing = kaiju:getWorldFacing();
	local sceneFacing = kaiju:getSceneFacing();

	view:doEffectFromNode('breath_node', 'effects/deathArc_main.plist', sceneFacing);
	
	local zones = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Zone));
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
	if not aura then
		return
	end
	if aura:getElapsed() > 0 then
		local targets = getTargetsInCone(worldPosition, range, angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Avatar));
		
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(kaiju, t) then
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
		applyDamageWithWeapon(kaiju, aura:getTarget(), unprotectedDotWeapon);
		abilityEnhance(0);
	end
end

function onTickProtected(aura)
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
		applyDamageWithWeapon(kaiju, aura:getTarget(), protectedDotWeapon);
		abilityEnhance(0);
	end
end