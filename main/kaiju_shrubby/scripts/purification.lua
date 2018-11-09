require 'scripts/avatars/common'

local kaiju = 0;

function onUse(a)
	kaiju = a;
	kaiju:removeDebuffs();
	playAnimation(kaiju, "ability_cast");
	playSound("shrubby_ability_Purification");
	startCooldown(kaiju, abilityData.name);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/purificationBack.plist", 0, 0,0, false, true);
	view:attachEffectToNode("root", "effects/purificationFront.plist", 0, 0,0, true, false);
	
end