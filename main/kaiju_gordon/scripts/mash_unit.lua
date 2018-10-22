require 'scripts/avatars/common'

local avatar = 0;

function onUse(a)
	avatar = a;
	--avatar:removeDebuffs();
	startCooldown(avatar, abilityData.name);
	avatar:setStat("Health", avatar:getStat("MaxHealth"));
	--playAnimation(avatar, "ability_cast");
	
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/mash.plist", 0, 0,0, true, false);
	view:attachEffectToNode("root", "effects/mashRing_front.plist", 0, 0,0, true, false);
	view:attachEffectToNode("root", "effects/mashRing_back.plist", 0, 0,0, false, true);

	
end