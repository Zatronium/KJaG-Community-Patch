require 'scripts/avatars/common'

local hpPerSecond = 2;
local durationTime = 90;
local avatar = nil;

function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "ability_stomp");
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('catalyst');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTickActive');
	buffAura:setTickParameters(1, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	
	startAbilityUse(avatar, abilityData.name);
	
	view:attachEffectToNode("root", "effects/catalyst.plist", durationTime, 0, 0, true, false);

end

function onTickActive(aura)
	if aura:getElapsed() > durationTime then
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
	avatar:gainHealth(hpPerSecond);
end

function onTick(aura)
	avatar:gainHealth(hpPerSecond);
end