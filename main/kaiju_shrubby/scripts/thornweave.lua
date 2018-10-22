require 'scripts/avatars/common'
local avatar = nil;
local duration = 30;
local aoeRange = 100;
local dotDuration = 5;
local dotDamage = 5;

function onUse(a)
	avatar = a;
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/thornWeaveAura_back.plist", duration, 0, 50, false, true);
	view:attachEffectToNode("root", "effects/thornWeaveAura_front.plist", duration, 0, 50, true, false);
	view:attachEffectToNode("root", "effects/thornWeaveAura2_back.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/thornWeaveAura2_front.plist", duration, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/thornWeaveRing_back.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/thornWeaveRing_front.plist", duration, 0, 0, true, false);
	playSound("shrubby_ability_Thornweave");
	startAbilityUse(avatar, abilityData.name);
end

function onTick(aura)
	if aura:getElapsed() > duration then
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
		return;
	end
	
	avatar = getPlayerAvatar();
	local targets = getTargetsInRadius(avatar:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar, EntityType.Zone));
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(avatar, t) and not t:hasAura("thornweave") then
			
			local aura = createAura(this, t, 0);
			aura:setTag("thornweave");
			aura:setTickParameters(1, 0);
			aura:setScriptCallback(AuraEvent.OnTick, "onDot");
			aura:setTarget(t);
		end
	end
end

function onDot(aura)
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	if elapsed > dotDuration or not canTarget(target) then
		target:detachAura(aura);
	else
		if isOrganic(target) then
			applyDamage(getPlayerAvatar(), target, dotDamage);
		end
	end
end