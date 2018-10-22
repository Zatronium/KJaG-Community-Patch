require 'scripts/avatars/common'
local avatar = nil;
function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_drillpunch");
	registerAnimationCallback(this, avatar, "start_drill");
end

function onAnimationEvent(a)
	local Drillaura = Aura.create(this, a);
	Drillaura:setTickParameters(0.25, 0.5);
	Drillaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	Drillaura:setTarget(a);
	playSound("gino_drill");
	startCooldown(avatar, abilityData.name);	
end

function onTick(aura)
	avatar = getPlayerAvatar();
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar);
	local beamRange = 50;
	local beamWidth = 50;

	local beamOrigin = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		applyDamageWithWeapon(avatar, t, "weapon_Drill1");
	end
end

