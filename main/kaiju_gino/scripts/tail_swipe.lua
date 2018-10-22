require 'scripts/avatars/common'

local avatar = nil;
function onUse(a)
	avatar = a;
	playAnimation(a, "ability_tailblaster");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
end

function onAnimationEvent(a)
	local scenePos = a:getView():getAnimationNodePosition('tail_node');
	local worldPos = getWorldPosition(scenePos);

	createEffect('effects/tailSmash_spark.plist', scenePos);
	createEffect('effects/tailSmash_smoke.plist', scenePos);
	playSound("gino_tail");

	local targets = getTargetsInRadius(worldPos, 65, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar)); 
	for t in targets:iterator() do
		applyDamage(a, t, math.random (45,60));
	end
end