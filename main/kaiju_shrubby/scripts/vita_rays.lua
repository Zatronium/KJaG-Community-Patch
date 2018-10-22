require 'scripts/avatars/common'
local avatar = nil;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_roar");
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/vitarays.plist", 1, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/vitarays_wave.plist", 1, 0, 0, true, false);
	local minions = avatar:getMinions();
	for t in minions:iterator() do
		local m = entityToMinion(t);
		m:gainHealth(t:getStat("MaxHealth"));
	end
	playSound("shrubby_ability_VitaRays");
	startCooldown(avatar, abilityData.name);
end