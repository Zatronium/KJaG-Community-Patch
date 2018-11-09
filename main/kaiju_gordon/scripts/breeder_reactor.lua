require 'scripts/avatars/common'

local powerPerTick = 2;
local kaiju = nil;

function onSet(a)
	kaiju = a;
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('breeder_reactor');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(1, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	--view:attachEffectToNode("foot_01", "effects/booster.plist", duration, 0, 0, false, true);
	--view:attachEffectToNode("foot_02", "effects/booster.plist", duration, 0, 0, false, true);
end

function onTick(aura)
	kaiju:gainPower(powerPerTick);
end
