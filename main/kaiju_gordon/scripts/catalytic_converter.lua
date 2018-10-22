require 'kaiju_gordon/scripts/catalyst'

local avatar = nil;

function onSet(a)
	avatar = a;
	local buffAura = Aura.create(this, a);
	buffAura:setTag('catalyst');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(1, 0); 
	buffAura:setTarget(a);
	
	local view = a:getView();
	
	view:attachEffectToNode("root", "effects/catalyst.plist", -1, 0, 0, true, false);
end


function bonusStats(s)
	setAbilityToPassive("ability_gordon_Catalyst");
end


