require 'scripts/avatars/common'

local bonusRepair = 0.2;
local hpPerTick = 1;
local tickRate = 3; --seconds
local avatar = nil;

function onSet(a)
	avatar = a;
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('nano_machines');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(tickRate, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	--view:attachEffectToNode("foot_01", "effects/booster.plist", duration, 0, 0, false, true);
	--view:attachEffectToNode("foot_02", "effects/booster.plist", duration, 0, 0, false, true);
end

function onTick(aura)
	avatar:gainHealth(hpPerTick);
end

function bonusStats(s)
	s:modStat("RepairRateMod", bonusRepair);
end