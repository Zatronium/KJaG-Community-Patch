require 'scripts/avatars/common' --do not need to include "gino" as this is an onUse, not an onHeartbeat

local kaiju = nil

function onUse(a)
	kaiju = a
	local aura = createAura(this, a, 0);
	aura:setTickParameters(3.0, 3.0); --interval is 6.0s and each "onTick" will occur every 3.0s (will happen twice, at 0.0 and at 3.0)
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	startCooldown(a, abilityData.name); --dont forget to recharge the ability
end

function onTick(aura)
	if not aura then return end
	--apply the actions 
	--(in this case, set everything on fire and apply 10 pnts of damage in a 500 m radius)
	local worldPos = kaiju:getWorldPosition();
	local scenePos = kaiju:getView():getPosition();
	createEffect('effects/nova.plist', scenePos);
	local targets = getTargetsInRadius(worldPos, 500, EntityFlags(EntityType.Vehicle, EntityType.Zone)); 
	for t in targets:iterator() do
		createEffect('effects/onFire.plist', t:getView():getPosition());
		applyDamage(kaiju, t, 10); -- assume t is not valid after applyDamage
	end
end