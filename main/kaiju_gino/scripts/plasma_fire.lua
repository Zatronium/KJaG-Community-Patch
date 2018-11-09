require 'scripts/avatars/common'

local angle = 30;

function onUse(a)
	playAnimation(a, "ability_breath");
	registerAnimationCallback(this, a, "start");
end

function onAnimationEvent(a)
	local view = a:getView();
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();
	local sceneFacing = a:getSceneFacing();

	local targets = getTargetsInCone(worldPosition, 200, angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
	view:doEffectFromNode('breath_node', 'effects/plasmaFire_core.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/plasmaFire_sparks.plist', sceneFacing);
	playSound("gino_breath");
	startCooldown(a, abilityData.name);
	dotSetTargets(a, targets, 1, 3, "onTick");
end

function onTick(aura)
	if not aura then
		return
	end
	dotOnTick(aura, 5, 10, "effects/onFire.plist", 0.90);
end