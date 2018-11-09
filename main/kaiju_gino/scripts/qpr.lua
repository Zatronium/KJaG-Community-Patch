local extraPower = 100
local kaiju = nil;

function bonusStats(s)
	s:modStat("MaxPower", extraPower);
end

function onSet(a)
	kaiju = a;
	local regenAura = Aura.create(this, a);
	regenAura:setTag('qpr');
	regenAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	regenAura:setTickParameters(1, 0)
	regenAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(a)
	kaiju:gainPower(3);
end