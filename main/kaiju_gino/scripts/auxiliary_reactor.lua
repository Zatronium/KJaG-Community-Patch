local interval = 5
local regenAmount = 2;

function onSet(a)
	regenAura = Aura.create(this, a);
	regenAura:setTag('regen');
	regenAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	regenAura:setTickParameters(interval, 0); --updates at time 0 then at time 10
	regenAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(a)
	addKaijuResource("power", regenAmount);
end