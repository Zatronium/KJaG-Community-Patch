require 'scripts/avatars/common'
local kaiju = nil;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_roar");
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/vitarays.plist", 1, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/vitarays_wave.plist", 1, 0, 0, true, false);
	local minions = kaiju:getMinions();
	for t in minions:iterator() do
		local m = entityToMinion(t);
		m:gainHealth(t:getStat("MaxHealth"));
	end
	playSound("shrubby_ability_VitaRays");
	startCooldown(kaiju, abilityData.name);
end