require 'scripts/avatars/common'
local avatar = nil;
local powerGain = 15;
local disableDuration = 4;
function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_drillpunch");
	registerAnimationCallback(this, avatar, "start_drill");
end

function onAnimationEvent(a)
	local Drillaura = Aura.create(this, a);
	Drillaura:setTag("gino_siphonizer");
	Drillaura:setTickParameters(0.25, 0.75);
	Drillaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	Drillaura:setTarget(a);
	playSound("gino_drill");
	startCooldown(avatar, abilityData.name);	

end

function onTick(aura)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 50;
	local beamWidth = 50;
	avatar = getPlayerAvatar();
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);

	local beamOrigin = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		if not isSameEntity(t, avatar) then
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				veh:disabled(disableDuration);
				t:attachEffect("effects/onEmp.plist", disableDuration, true);
			end
			applyDamageWithWeapon(avatar, t, "weapon_Drill2");
			avatar:gainPower(powerGain);
		end
	end
	
end