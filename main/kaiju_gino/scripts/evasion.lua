require 'scripts/common'
local avatar = 0;
local durationtime = 10;
local evade = 75;
function onUse(a)
	avatar = a;
	local evadeAura = Aura.create(this, a);
	evadeAura:setTag('gino_evasion');
	evadeAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	evadeAura:setTickParameters(durationtime, 0); --updates at time 0 then at time 10
	evadeAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("root", "effects/evasion.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/evasion_core.plist", durationtime, 0, 0,false, true);
	
	startAbilityUse(avatar, abilityData.name);
	
	a:setPassive("evasion", evade);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		avatar:removePassive("evasion", 0);
		endAbilityUse(avatar, abilityData.name);
		avatar:detachAura(aura);
	end
end
