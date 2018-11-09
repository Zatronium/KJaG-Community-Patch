require 'scripts/avatars/common'

local pointdefenserate = 30;
local damagepertick = 15;
local updateRate = 1;
local kaiju = nil

local range = 350;

function onSet(a)
	kaiju = a
	if a:hasStat("PD_Tracking") then
		a:modStat("PD_Tracking", pointdefenserate);
	else
		a:addStat("PD_Tracking", pointdefenserate);
	end
	local pdAura = Aura.create(this, a);
	pdAura:setTag('PDArray');
	pdAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	pdAura:setTickParameters(updateRate, 0.0);
	pdAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(aura)
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), range, EntityFlags(EntityType.Vehicle));
	for t in targets:iterator() do
		local v = entityToVehicle(t);
		if v and v:isAir() then
			createEffect('effects/explosion_BoomLayer.plist', t:getView():getPosition());
			applyDamage(kaiju, t, damagepertick); -- assume t is not valid after applyDamage
		end
	end
end