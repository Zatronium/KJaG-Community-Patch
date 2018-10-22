local bonusSensory = -10;
local invurDuration = 8;
local avatar = nil;
function onSet(a)
	avatar = a;
	avatar:misdirectMissiles(1, false);
	avatar:setInvulnerable(true);
	avatar:setPassive("predict", invurDuration);
	
	local buffAura = Aura.create(this, avatar);
	buffAura:setTag('predict');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(1, 0); 
	buffAura:setTarget(avatar);
end

function onTick(aura)
	avatar:misdirectMissiles(1, false);
	if aura:getElapsed() >= 1 then
		avatar:setInvulnerable(false);
	end
end

function bonusStats(s)
	s:modStat("SensorsSignature", bonusSensory);
end