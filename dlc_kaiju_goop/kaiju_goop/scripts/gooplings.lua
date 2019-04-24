require 'kaiju_goop/scripts/goop'

local kaiju = nil;
local hasUpdated = false;
function onUse(a)
	kaiju = a;

	playAnimation(kaiju, "ability_bodyslam");
	registerAnimationCallback(this, kaiju, "attack");
		
	startCooldown(kaiju, abilityData.name);
end

function onAnimationEvent(a)
--	_log("spawn");
	pos = kaiju:getWorldPosition();
	SpawnGoopling(pos);
	createEffectInWorld("effects/goopball_splortsplash.plist", pos, 0);
	createEffectInWorld("effects/goopball_splort.plist", pos, 0);
	playSound("goop_ability_Gooplings"); -- SOUND
end