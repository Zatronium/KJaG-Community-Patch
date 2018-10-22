require 'kaiju_gino/scripts/gino'

local avatar = nil;
function onUse(a)
	avatar = a;
	playAnimation(a, "punch_01");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("gino_claw");
	local view = a:getView();
	local avatarFacing = a:getSceneFacing();
	
	view:attachEffectToNode("palm_node_01", "effects/megaClaw.plist", 1,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/megaClaw.plist", 1,  0, 0,false, false);

end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar);
	local beamRange = 75;
	local beamWidth = 25;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		applyDamage(a, t, calcAttackDamage());
	end
	targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	dotSetTargets(a, targets, 1, 3, "onTick");
end

function onTick(aura)
	avatar = getPlayerAvatar();
	applyDamageWithWeapon(avatar, aura:getTarget(), "weapon_Plasmaclaw3");
end