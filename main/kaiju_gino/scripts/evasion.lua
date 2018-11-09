require 'scripts/common'
local kaiju = nil
local durationtime = 10;
local evade = 75;
function onUse(a)
	kaiju = a;
	local evadeAura = Aura.create(this, a);
	evadeAura:setTag('gino_evasion');
	evadeAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	evadeAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 10
	evadeAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/evasion.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/evasion_core.plist", durationtime, 0, 0,false, true);
	
	startAbilityUse(kaiju, abilityData.name);
	
	a:setPassive("evasion", evade);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		kaiju:removePassive("evasion", 0);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
