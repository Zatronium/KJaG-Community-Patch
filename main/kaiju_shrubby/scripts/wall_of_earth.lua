require 'scripts/avatars/common'

local avatar = 0;
local wallRadius = 250;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "stomp");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)

	local origin = avatar:getWorldPosition();
	local radius = wallRadius;
	local unitSize = 100;
	local unitSpacing = 0;
	local targetHealthLimit = 20;
	createHenge("unit_shrubby_earth_wall", origin, radius, unitSize, unitSpacing, targetHealthLimit);
	
	startCooldown(avatar, abilityData.name);
	playSound("shrubby_ability_WallOfEarth");
end
