require 'scripts/avatars/common'
local kaiju = nil;

local beamRange = 50;
local beamWidth = 50;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_drillpunch");
	registerAnimationCallback(this, kaiju, "start_drill");
end

function onAnimationEvent(a)
	local Drillaura = Aura.create(this, a);
	Drillaura:setTickParameters(0.25, 0.5);
	Drillaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	Drillaura:setTarget(a);
	playSound("gino_drill");
	startCooldown(kaiju, abilityData.name);	
end

function onTick(aura)
	if not aura then
		return
	end
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar);

	local beamOrigin = kaiju:getWorldPosition();
	local beamFacing = kaiju:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		applyDamageWithWeapon(kaiju, t, "weapon_Drill1");
	end
end

