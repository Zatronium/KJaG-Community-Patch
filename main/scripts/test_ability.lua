--[==[require 'scripts/common'
require 'scripts/avatars/common'

function onUse(a)
	playAnimation(a, "ability_breath");
	registerAnimationCallback(this, a, "start");
end

function onAnimationEvent(a)
	a:getView():doEffectFromNode('breath_node', 'effects/recon.plist', 0);
	startCooldown(a, abilityData.name);
	local targets = getTargetsInRadius(a:getWorldPosition(), 250, EntityFlags(EntityType.Zone));
	dotSetTargets(a, targets, 1, 10, "onTick");
end

function onTick(aura)
	if not aura then return end
	dotOnTick(aura, 7, 7);
end]==]