local bonusSensory = -10;
local invurDuration = 8;
local kaiju = nil;
function onSet(a)
	kaiju = a;
	kaiju:misdirectMissiles(1, false);
	kaiju:setInvulnerable(true);
	kaiju:setPassive("predict", invurDuration);
	
	local buffAura = Aura.create(this, kaiju);
	buffAura:setTag('predict');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(1, 0); 
	buffAura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then
		return
	end
	kaiju:misdirectMissiles(1, false);
	if aura:getElapsed() >= 1 then
		kaiju:setInvulnerable(false);
	end
end

function bonusStats(s)
	s:modStat("SensorsSignature", bonusSensory);
end