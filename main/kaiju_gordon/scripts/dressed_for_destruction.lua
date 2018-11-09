require 'scripts/avatars/common'
local kaiju = nil;
damageBonus = 0.1; 
local fearDuration = 5;

function onSet(a)
	kaiju = a;
	a:modStat("damage_amplify", damageBonus);
	kaiju:addPassiveScript(this);
end
	
function onAttackDodged(a, ent)
	local aura = nil;
	if ent:hasAura("FEAR") then
		aura = ent:getAura("FEAR");
	else
		aura = createAura(this, ent, 0);
		aura:setTag("FEAR");
		aura:setTarget(ent);
	end
		aura:setDuration(fearDuration);
end
