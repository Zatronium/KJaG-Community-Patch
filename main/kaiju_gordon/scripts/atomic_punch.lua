require 'scripts/avatars/common'

local avatar = nil;
local weapon = "AtomicPunch1"
local weaponCollision = "AtomicPunch1_collision"

local kbDistance = 50;
local kbPower = 400;

function onUse(a)
	avatar = a;
	playAnimation(a, "ability_punch");
	registerAnimationCallback(this, a, "attack");
	startCooldown(a, abilityData.name);
	playSound("AtomicPunch");

	local view = a:getView();
	view:attachEffectToNode("palm_node_01", "effects/doubleCrush.plist", 1,  0, 0,false, false);
	view:attachEffectToNode("palm_node_02", "effects/doubleCrush.plist", 1, 0, 0, false, false);

end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar);
	local beamRange = 100;
	local beamWidth = 25;

	local beamOrigin = a:getWorldPosition();
	local beamFacing = a:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(beamOrigin, beamRange, beamFacing);
	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	local dir = getDirectionFromPoints(beamOrigin, beamEnd);
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	abilityEnhance(empower);
	for t in targets:iterator() do
		if not isSameEntity(t, avatar) then
		
			t:displaceDirection(dir, kbPower, kbDistance);
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				veh:setCollisionScript(this);
			end
			applyDamageWithWeapon(avatar, t, weapon);
		end
	end
	abilityEnhance(0);
end

function onCollide(first, other)
	if other and getEntityType(other) == EntityType.Zone then
		first:resetDisplace();
		first:removeCollisionScript();
		avatar = getPlayerAvatar();
		applyDamageWithWeapon(avatar, other, weaponCollision);
		applyDamageWithWeapon(avatar, first, weaponCollision);
	end
end