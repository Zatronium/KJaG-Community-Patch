require 'scripts/avatars/common'

local kaiju = 0;
local number_attacks = 3;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_roar");
	kaiju:addPassiveScript(this);
	playSound("shrubby_ability_Sway");
	startAbilityUse(kaiju, abilityData.name);
end

function endAbility()
	endAbilityUse(kaiju, abilityData.name);
	kaiju:removePassiveScript(this);
end


function onAvatarAbsorb(a, n, w)
	if number_attacks > 0 then
		createFloatingText(kaiju, "Dodge", 255, 25, 255); --TODO Localization
		local view = a:getView();
		view:attachEffectToNode("root", "effects/swayBack.plist", durationtime, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/swayFront.plist", durationtime, 0, 0, true, false);
		n.x = 0;	
		number_attacks = number_attacks - 1;
	end
	if number_attacks <= 0 then
		endAbility();
	end
end