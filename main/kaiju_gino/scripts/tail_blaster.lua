require 'scripts/avatars/common'

-- Global values.
local kaiju = nil;
local targetPos = 0;
local targetEnt = nil;
local shotsFire = 2;
local hasFired = 0;
local positionVector = nil;
local positionTargets = 0;
local weaponRange = 600;
local beamEnd = nil;
local shotAngle = 25;
function onUse(a)
	kaiju = a;
--	local facingAngle = getFacingAngle(targetPos, kaiju:getWorldPosition());
--	kaiju:setWorldFacing(facingAngle);
	local beamFacing = kaiju:getView():getTailFacingAngle();
	local beamOrigin = kaiju:getWorldPosition();
	beamEnd = getBeamEndWithFacing(beamOrigin, weaponRange, beamFacing - 45.0);
	playAnimation(kaiju, "ability_tailblaster");
	registerAnimationCallbackUntilEnd(this, kaiju, "attack");		
	startCooldown(kaiju, abilityData.name);
--	local targets = getTargetsInBeam(beamOrigin, beamEnd, beamWidth, targetFlags);
	local targets = getTargetsInCone(beamOrigin, weaponRange, shotAngle, beamFacing - 45.0, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	positionVector = PointVector();
	local total = targets:size();
	local ignore = total - shotsFire - 1;
	for t in targets:iterator() do
		if positionTargets < shotsFire then
			if ignore > 0 and math.random(100) > 50 then
				ignore = ignore - 1;
			else
				if getEntityType(t) == EntityType.Avatar then
					local av = entityToAvatar(t);
					if not av:isPlayer() then
						positionVector:push_back(t:getWorldPosition());
						positionTargets = positionTargets + 1;
					end
				else
					positionVector:push_back(t:getWorldPosition());
					positionTargets = positionTargets + 1;
				end
			end
		end
	end
	local maxRange = weaponRange *( shotAngle * 0.0167 ); -- approximate arclen
	while positionTargets < shotsFire do
		positionVector:push_back(offsetRandomDirection(beamEnd, 0, maxRange));
		positionTargets = positionTargets + 1;
	end
end

function onAnimationEvent(a)
	if hasFired < shotsFire then
		local node = "tail_node";
		local animcb = "attack";
		if hasFired < positionTargets then
			targetPos = positionVector:get(hasFired);
		else
			targetPos = beamEnd;
		end
		local proj = avatarFireAtPoint(kaiju, "weapon_Blaster1", node, targetPos, 0);
		proj:setCallback(this, 'onHit');
		proj:fromAvatar(true);
		registerAnimationCallbackUntilEnd(this, kaiju, animcb);
		playSound("blaster");
		hasFired = hasFired + 1;
	end
end

-- Projectile hits a target.
function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	createImpactEffect(proj:getWeapon(), scenePos);
end