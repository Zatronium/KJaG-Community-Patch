local extraPower = 100
local avatar = nil;

function bonusStats(s)
	s:modStat("MaxPower", extraPower);
end

function onSet(a)
	avatar = a;
	local regenAura = Aura.create(this, a);
	regenAura:setTag('qpr');
	regenAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	regenAura:setTickParameters(1, 0); --updates every second                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	regenAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(a)
	avatar:gainPower(3);
end