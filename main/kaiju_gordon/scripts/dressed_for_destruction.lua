require 'scripts/avatars/common'
local avatar = nil;
local damageBonus = 0.1; 
local fearDuration = 5;

function onSet(a)
	avatar = a;
	a:modStat("damage_amplify", damageBonus);
	avatar:addPassiveScript(this);
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
