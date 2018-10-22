require 'scripts/avatars/common'
local avatar = nil;
local duration = 5;
local aoeRange = 100;
local speedDecrease = -0.5;
local weapon = "weapon_shrubby_poisonCloud1"

function onSet(a)
	avatar = a;
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
	local view = a:getView();
	view:attachEffectToNode("root", "effects/toxicFog.plist", -1, 0, 200, true, false);
	view:attachEffectToNode("root", "effects/toxicFogTrail.plist", -1, 0, 180, true, false);

end

function onTick(aura)
	local targets = getTargetsInRadius(avatar:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(avatar, t) and not t:hasAura("toxic_fog") then
			local aura = createAura(this, t, 0);
			aura:setTag("toxic_fog");
			aura:setTickParameters(1, 0);
			local sd = t:getStat("Speed") * speedDecrease;
			aura:setStat("Speed", t:getStat("Speed") * speedDecrease);
			aura:setScriptCallback(AuraEvent.OnTick, "onDot");
			aura:setTarget(t);
		end
	end
end

function onDot(aura)
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	if elapsed > duration or not canTarget(target) then
		target:detachAura(aura);
	else
		if isOrganic(target) then
			avatar = getPlayerAvatar();
			applyDamageWithWeapon(avatar, target, weapon);
		end
	end
end