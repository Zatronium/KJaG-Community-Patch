--Active
require 'scripts/common'

--
local kaiju = nil

function onUse(a)
	kaiju = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/goop_up.plist", 1, 0, 50, true, false);
--  view:attachEffectToNode("foot_02", "effects/booster.plist", durationtime, 0, 0, false, true);
	
	kaiju:misdirectMissiles(1, true);
	startCooldown(kaiju, abilityData.name);

	playSound("goop_ability_GOOPedUp");
end