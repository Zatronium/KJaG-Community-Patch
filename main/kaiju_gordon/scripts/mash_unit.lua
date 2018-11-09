require 'scripts/avatars/common'

local kaiju = 0;

function onUse(a)
	kaiju = a;
	--kaiju:removeDebuffs();
	startCooldown(kaiju, abilityData.name);
	kaiju:setStat("Health", kaiju:getStat("MaxHealth"));
	--playAnimation(kaiju, "ability_cast");
	
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/mash.plist", 0, 0,0, true, false);
	view:attachEffectToNode("root", "effects/mashRing_front.plist", 0, 0,0, true, false);
	view:attachEffectToNode("root", "effects/mashRing_back.plist", 0, 0,0, false, true);

	
end