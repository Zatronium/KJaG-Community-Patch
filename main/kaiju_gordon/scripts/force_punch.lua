require 'scripts/avatars/common'

local kaiju = nil;
local weapon = "ForcePunch1"
local weaponFirst = "ForcePunch1_first"
local firstTarget = true;

function onUse(a)
	kaiju = a;
	playAnimation( a, "ability_punch");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("ForcePunch");
	local view = a:getView();
	local avatarFacing = a:getSceneFacing();


	local view = a:getView();
	view:attachEffectToNode("palm_node_01", "effects/doubleCrush.plist", 1,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/doubleCrush.plist", 1, 0, 0, false, false);
	view:attachEffectToNode("palm_node_01", "effects/doubleCrush_sparks.plist", 1, 0, 0, false, false);
	view:attachEffectToNode("palm_node_02", "effects/doubleCrush_sparks.plist", 1,  0, 0,false, false);
end

function onAnimationEvent(a)
	kaiju = a;
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 100; -- switch to weapon 
	local beamWidth = 25;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);

	for t in targets:iterator() do	
		if not isSameEntity(t, kaiju) then
			if firstTarget == true then
				applyDamageWithWeapon(kaiju, t, weaponFirst);
				firstTarget = false;
			else
				applyDamageWithWeapon(kaiju, t, weapon);
			end
		end
	end
	
	abilityEnhance(0);
end
