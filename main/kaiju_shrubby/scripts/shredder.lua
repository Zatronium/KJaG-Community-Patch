require 'scripts/avatars/common'
-- weapon_shrubby_bite1
local healPerTarget = 2;
local kaiju = nil;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_multibite");
	registerAnimationCallbackUntilEnd(this, kaiju, "attack");		
end

function onAnimationEvent(a)
	kaiju = a;
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 100;
	local beamWidth = 75;

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", .25, 0, 0, true, false);
	view:attachEffectToNode("breath_node", "effects/shredder.plist", .75, 0, 0, true, false);

	local beamOrigin = kaiju:getWorldPosition();
	local beamFacing = kaiju:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	for t in targets:iterator() do
		kaiju:gainHealth(healPerTarget);
		applyDamageWithWeapon(kaiju, t, "weapon_shrubby_bite1");
	end	
	
	playSound("shrubby_ability_Shredder");
	startCooldown(kaiju, abilityData.name);
end
