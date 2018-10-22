require 'scripts/avatars/common'
local healPerTarget = 2;
local avatar = nil;
local armorReduction = 0.25;
local weapon = "weapon_shrubby_bite2";

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_bite");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 80;
	local beamWidth = 80;

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/chomp.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/impact.plist", .25, 0, 0, true, false);

	local beamOrigin = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		applyDamageWithWeapon(avatar, t, weapon);
	end
	playSound("shrubby_ability_Chomp");
	startCooldown(avatar, abilityData.name);	

end
