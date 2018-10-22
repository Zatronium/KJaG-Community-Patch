require 'scripts/avatars/common'
require 'scripts/common'
local range = 170;
local minDamage = 10;
local maxDamage = 15;
local avatar = nil;
function onUse(a)
	avatar = a;
	playAnimation(a, "stomp");
	registerAnimationCallback(this, a, "attack");
end

function onAnimationEvent(a)
	avatar = a;
	local view = a:getView();
	view:attachEffectToNode("root", "effects/ignition_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/ignition_front.plist",0, 0, 0, true, false);
	a:getView():doEffectFromNode('root', 'effects/ignition_stomp_smoke.plist', 90);
	startCooldown(a, abilityData.name);
	local targets = getTargetsInRadius(a:getWorldPosition(), range, EntityFlags(EntityType.Zone, EntityType.Vehicle,EntityType.Avatar));
	for t in targets:iterator() do
		applyFire(avatar, t, 1.0);
		applyDamage(avatar, t, math.random(minDamage, maxDamage));
	end
end
