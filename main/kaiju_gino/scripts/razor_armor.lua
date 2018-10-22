require 'kaiju_gino/scripts/gino'

local updateRate = 1.0;
local damage = 5;
local range = 50;
local razorAura = nil;

function onSet(a)
	razorAura = Aura.create(this, a);
	razorAura:setTag('razorArmor');
	razorAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	razorAura:setTickParameters(updateRate, 0.0);
	razorAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(aura)
	local avatar = entityToAvatar(aura:getOwner());
	
	local entityFlags = EntityFlags(EntityType.Zone,EntityType.Vehicle);
	if isLairAttack() then
		entityFlags = EntityFlags(EntityType.Vehicle);
	end

	local targets = getTargetsInRadius(avatar:getWorldPosition(), range, entityFlags);
	for t in targets:iterator() do
		createEffect('effects/explosion_BoomLayer.plist', t:getView():getPosition());
		applyDamage(avatar, t, damage); -- assume t is not valid after applyDamage
	end
end