require 'scripts/avatars/common'
local count = 0;
local avatar = nil;
function onUse(a)
	avatar = a;
	playAnimation(a, "ability_doublecrush");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("gino_claw");
	local view = a:getView();
	view:attachEffectToNode("palm_node_01", "effects/doubleCrush.plist", 1,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/doubleCrush.plist", 1, 0, 0, false, false);
	view:attachEffectToNode("palm_node_01", "effects/doubleCrush_sparks.plist", 1, 0, 0, false, false);
	view:attachEffectToNode("palm_node_02", "effects/doubleCrush_sparks.plist", 1,  0, 0,false, false);
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar);
	local beamRange = 75;
	local beamWidth = 50;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	dotSetTargets(a, targets, 1, 3, "onTick");
end

function onTick(aura)
	avatar = getPlayerAvatar();
	applyDamageWithWeapon(avatar, aura:getTarget(), "weapon_Plasmaclaw2");
	count = count + 1;
	if count >= 3 then
		aura:getOwner():detachAura(aura);
	end
end