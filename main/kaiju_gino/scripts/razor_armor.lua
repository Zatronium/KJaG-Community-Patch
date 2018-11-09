require 'kaiju_gino/scripts/gino'

local kaiju = nil
local updateRate = 1.0;
local damage = 5;
local range = 50;

function onSet(a)
	kaiju = a
	local razorAura = Aura.create(this, a);
	razorAura:setTag('razorArmor');
	razorAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	razorAura:setTickParameters(updateRate, 0.0);
	razorAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(aura)
	
	local entityFlags = EntityFlags(EntityType.Zone,EntityType.Vehicle);
	if isLairAttack() then
		entityFlags = EntityFlags(EntityType.Vehicle);
	end

	local targets = getTargetsInRadius(kaiju:getWorldPosition(), range, entityFlags);
	for t in targets:iterator() do
		createEffect('effects/explosion_BoomLayer.plist', t:getView():getPosition());
		applyDamage(kaiju, t, damage); -- assume t is not valid after applyDamage
	end
end