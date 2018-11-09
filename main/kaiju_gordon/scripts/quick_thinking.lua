require 'scripts/avatars/common'

local cooldownReduction = 0.5;
local kaiju = nil;

cooldownThreshold = 3 -- anything lower will not trigger

function onUse(a)
	kaiju = a;
	startCooldown(a, abilityData.name);
	kaiju:setPassive("quick_thinking", cooldownReduction);
	kaiju:setPassive("quick_thinking_threshold", cooldownThreshold);

	local view = a:getView();
	--view:attachEffectToNode("foot_01", "effects/booster.plist", duration, 0, 0, false, true);
	--view:attachEffectToNode("foot_02", "effects/booster.plist", duration	., 0, 0, false, true);
end
