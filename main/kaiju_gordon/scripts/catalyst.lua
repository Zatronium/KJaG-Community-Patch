require 'scripts/avatars/common'

local hpPerSecond = 2;
local durationTime = 90;
local kaiju = nil;

function onUse(a)
	kaiju = a;
	
	playAnimation(kaiju, "ability_stomp");
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('catalyst');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTickActive');
	buffAura:setTickParameters(1, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	
	startAbilityUse(kaiju, abilityData.name);
	
	view:attachEffectToNode("root", "effects/catalyst.plist", durationTime, 0, 0, true, false);

end

function onTickActive(aura)
	if not aura then
		return
	end
	if aura:getElapsed() > durationTime then
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
	kaiju:gainHealth(hpPerSecond);
end