require 'scripts/avatars/common'

local avatar = nil;
local weapon = "ForcePunch2"
local weaponFirst = "ForcePunch2_first"

function onUse(a)
	avatar = a;
	playAnimation(a, "ability_punch");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("TripleAtomicPunch");
	local avatarFacing = a:getSceneFacing();
	local view = a:getView();
	view:attachEffectToNode("palm_node_01", "effects/pummel.plist", 2,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/pummel.plist", 2, 0, 0, false, false);
	view:attachEffectToNode("palm_node_01", "effects/firePunch_sparks.plist", 2,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/firePunch_sparks.plist", 2, 0, 0, false, false);
end

function onAnimationEvent(a)
	local origin = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	
	local spacing = 50;
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	abilityEnhance(empower);
	ForcePunch(origin, beamFacing);
	ForcePunch(getBeamEndWithFacing(origin, spacing, beamFacing + 90), beamFacing);
	ForcePunch(getBeamEndWithFacing(origin, spacing, beamFacing - 90), beamFacing);
	abilityEnhance(0);	
end

function ForcePunch(beamOrigin, beamFacing)
	avatar = getPlayerAvatar();
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 600; -- switch to weapon 
	local beamWidth = 50;

	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	
	local view = avatar:getView();
	local offset = beamOrigin;
	offset = offset:add(Point(25, 25));

	fireProjectileAtPoint(nil, offset, beamEnd, weapon);
	--avatarFireAtPoint(avatar,  weapon, "palm_node_01", beamEnd, 0);
	local firstTarget = true;
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
end