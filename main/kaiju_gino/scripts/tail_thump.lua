require 'scripts/avatars/common'

local avatar = nil;
function onUse(a)
	avatar = a;
	playAnimation(a, "ability_tailslam");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
end

function onAnimationEvent(a)
	local scenePos = a:getView():getAnimationNodePosition('tail_node');
	local worldPos = getWorldPosition(scenePos);

	createEffect('effects/tailThump_smoke.plist', scenePos);
	createEffect('effects/impact_flash.plist', scenePos);
	createEffect('effects/tailThump_spark.plist', scenePos);
	playSound("gino_tail");

	local targets = getTargetsInRadius(worldPos, 100, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar)); 
	for t in targets:iterator() do
		applyDamage(a, t, math.random (25,40));
	end
end