require 'scripts/avatars/common'

local Angle = 30;

function onUse(a)
	playAnimation(a, "ability_breath");
	registerAnimationCallback(this, a, "start");
end
-- damageEffect can be nil

function onAnimationEvent(a)
	local view = a:getView();
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();
	local sceneFacing = a:getSceneFacing();
	
	playSound("sfx_weap_acid_spray_muzzle");
	
	local targets = getTargetsInCone(worldPosition, 200, Angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
	view:doEffectFromNode('breath_node', 'effects/acidSpray_wide.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/acidSpray_core.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/acidSpray_splash.plist', sceneFacing);
	startCooldown(a, abilityData.name);
	dotSetTargets(a, targets, 1, 5, "onTick");
end

function onTick(aura)
	dotOnTick(aura, 0, 0, "effects/onCorrosive.plist", 0.00);
	dotOnTick(aura, 18, 22, "effects/onCorrosive_smoke.plist", 0.00);
end