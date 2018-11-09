require 'scripts/avatars/common'
local kaiju = nil;
local powerGain = 15;
local disableDuration = 4;

local beamRange = 50;
local beamWidth = 50;
function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_drillpunch");
	registerAnimationCallback(this, kaiju, "start_drill");
end

function onAnimationEvent(a)
	local Drillaura = Aura.create(this, a);
	Drillaura:setTag("gino_siphonizer");
	Drillaura:setTickParameters(0.25, 0.75);
	Drillaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	Drillaura:setTarget(a);
	playSound("gino_drill");
	startCooldown(kaiju, abilityData.name);	

end

function onTick(aura)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);

	local beamOrigin = kaiju:getWorldPosition();
	local beamFacing = kaiju:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		if not isSameEntity(t, kaiju) then
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				veh:disabled(disableDuration);
				t:attachEffect("effects/onEmp.plist", disableDuration, true);
			end
			applyDamageWithWeapon(kaiju, t, "weapon_Drill2");
			kaiju:gainPower(powerGain);
		end
	end
end