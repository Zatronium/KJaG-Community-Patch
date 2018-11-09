require 'scripts/avatars/common'
local kaiju = nil;
local duration = 30;
local aoeRange = 100;
local dotDuration = 5;
local dotDamage = 5;

function onUse(a)
	kaiju = a;
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/thornWeaveAura_back.plist", duration, 0, 50, false, true);
	view:attachEffectToNode("root", "effects/thornWeaveAura_front.plist", duration, 0, 50, true, false);
	view:attachEffectToNode("root", "effects/thornWeaveAura2_back.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/thornWeaveAura2_front.plist", duration, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/thornWeaveRing_back.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/thornWeaveRing_front.plist", duration, 0, 0, true, false);
	playSound("shrubby_ability_Thornweave");
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() > duration then
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
		return;
	end
	
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar, EntityType.Zone));
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(kaiju, t) and not t:hasAura("thornweave") then
			
			local aura = createAura(this, t, 0);
			aura:setTag("thornweave");
			aura:setTickParameters(1, 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onDot");
			aura:setTarget(t);
		end
	end
end

function onDot(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	local target = aura:getTarget()
	if elapsed > dotDuration or not canTarget(target) then
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	else
		if isOrganic(target) then
			applyDamage(kaiju, target, dotDamage);
		end
	end
end