require 'scripts/avatars/common'
-- weapon_shrubby_bite1
local healPerTarget = 2;
local kaiju = nil;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_bite");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 50;
	local beamWidth = 50;
	
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/bite_shrubby.plist", .25, 0, 0, true, false);

	local beamOrigin = kaiju:getWorldPosition();
	local beamFacing = kaiju:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		if not getEntityType(t) == EntityType.Zone then
			kaiju:gainHealth(healPerTarget);
		end
		applyDamageWithWeapon(kaiju, t, "weapon_shrubby_bite1");
	end
	playSound("shrubby_ability_Bite");
	startCooldown(kaiju, abilityData.name);	
end
