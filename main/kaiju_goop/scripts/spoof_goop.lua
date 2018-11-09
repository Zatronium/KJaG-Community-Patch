--Active
require 'scripts/common'

--
kaiju = 0;

function onUse(a)
	kaiju = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/goopspoof.plist", durationtime, 0, 50, true, false);
	--view:attachEffectToNode("foot_02", "effects/booster.plist", durationtime, 0, 0, false, true);
	
	kaiju:misdirectMissiles(1, false);
	startCooldown(kaiju, abilityData.name);

	playSound("goop_ability_SpoofGOOP");
end