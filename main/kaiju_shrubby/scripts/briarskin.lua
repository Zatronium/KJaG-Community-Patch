require 'scripts/avatars/common'
local avatar = nil;
local aoeRange = 100;
local dotDamage = 5;

function onSet(a)
	local aura = createAura(this, a, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	avatar = getPlayerAvatar();
	if avatar then
		local targets = getTargetsInRadius(avatar:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar, EntityType.Zone));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(avatar, t) then
				applyDamage(avatar, t, dotDamage);
			end
		end
	end
end