require 'scripts/avatars/common'

local avatar = nil;
function onUse(a)
	avatar = a;
	playAnimation(a, "ability_tailslam");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
end

function onAnimationEvent(a)
	local view = a:getView();
	local scenePos = a:getView():getAnimationNodePosition('tail_node');
	local worldPosition = getWorldPosition(scenePos);
	--local worldPosition = a:getWorldPosition();
	local worldFacing = a:getTailWorldFacing();
	local sceneFacing = a:getTailSceneFacing();

	local targets = getTargetsInCone(worldPosition, 250, 60, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	view:doEffectFromNode('tail_node', 'effects/tailSmash_smoke.plist', sceneFacing);
	view:doEffectFromNode('tail_node', 'effects/tailSmash_smokeCore.plist', sceneFacing);
	view:doEffectFromNode('tail_node', 'effects/impact_flash.plist', sceneFacing);
	view:doEffectFromNode('tail_node', 'effects/tailThump_spark.plist', sceneFacing);
	playSound("tailsmash");
	
	startCooldown(a, abilityData.name);
	for t in targets:iterator() do
		applyDamage(a, t, math.random (45,60));
	end
end