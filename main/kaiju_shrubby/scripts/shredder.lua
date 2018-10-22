require 'scripts/avatars/common'
-- weapon_shrubby_bite1
local healPerTarget = 2;
local avatar = nil;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_multibite");
	registerAnimationCallbackUntilEnd(this, avatar, "attack");		
end

function onAnimationEvent(a)
	avatar = a;
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 100;
	local beamWidth = 75;

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/shredder.plist", .75, 0, 0, true, false);

	local beamOrigin = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		avatar:gainHealth(healPerTarget);
		applyDamageWithWeapon(avatar, t, "weapon_shrubby_bite1");
	end	
	
	playSound("shrubby_ability_Shredder");
	startCooldown(avatar, abilityData.name);
end
