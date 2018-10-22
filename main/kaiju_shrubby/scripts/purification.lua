require 'scripts/avatars/common'

local avatar = 0;

function onUse(a)
	avatar = a;
	avatar:removeDebuffs();
	playAnimation(avatar, "ability_cast");
	playSound("shrubby_ability_Purification");
	startCooldown(avatar, abilityData.name);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/purificationBack.plist", 0, 0,0, false, true);
	view:attachEffectToNode("root", "effects/purificationFront.plist", 0, 0,0, true, false);
	
end