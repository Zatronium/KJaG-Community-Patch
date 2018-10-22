require 'scripts/avatars/common'

local healPercent = 0.5;
local avatar = nil;

local weapon = "weapon_shrubby_bite4"

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_bite");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 50;
	local beamWidth = 50;

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/feast.plist", .75, 0, 0, true, false);

	local beamOrigin = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		local hp = t:getStat("Health");
		if hp <= 60 then
			avatar:gainHealth(hp * healPercent);
		end
		applyDamageWithWeapon(avatar, t, weapon);
	end
	playSound("shrubby_ability_Feast");
	startCooldown(avatar, abilityData.name);	

end
