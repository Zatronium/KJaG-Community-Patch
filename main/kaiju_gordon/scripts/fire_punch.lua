require 'scripts/avatars/common'

local avatar = nil;
local weapon = "ForcePunch2"
local weaponFirst = "ForcePunch2_first"
local firstTarget = true;

function onUse(a)
	avatar = a;
	playAnimation( a, "ability_punch");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("FirePunch");
	local view = a:getView();
	local avatarFacing = a:getSceneFacing();
	local view = a:getView();
	view:attachEffectToNode("palm_node_01", "effects/pummel.plist", 2,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/pummel.plist", 2, 0, 0, false, false);
	view:attachEffectToNode("palm_node_01", "effects/firePunch_sparks.plist", 2,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/firePunch_sparks.plist", 2, 0, 0, false, false);
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 200; -- switch to weapon 
	local beamWidth = 25;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	abilityEnhance(empower);
	
	local view = avatar:getView();
	local offset = beamOrigin;
	offset = offset:add(Point(25, 25));

	fireProjectileAtPoint(nil, offset, beamEnd, weapon);
	
	for t in targets:iterator() do
		if not isSameEntity(t, avatar) then				
			if firstTarget == true then
				applyDamageWithWeapon(avatar, t, weaponFirst);
				firstTarget = false;
			else
				applyDamageWithWeapon(avatar, t, weapon);
			end
		end
	end
	abilityEnhance(0);
end