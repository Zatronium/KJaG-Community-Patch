require 'scripts/avatars/common'
local kaiju = nil;
local aoeRange = 100;
local dotDamage = 5;

function onSet(a)
	kaiju = a
	local aura = createAura(this, a, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	if not aura then return end
	if kaiju then
		local targets = getTargetsInRadius(kaiju:getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar, EntityType.Zone));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(kaiju, t) then
				applyDamage(kaiju, t, dotDamage);
			end
		end
	end
end