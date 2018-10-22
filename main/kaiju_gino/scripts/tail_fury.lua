require 'scripts/avatars/common'

-- Global values.
local avatar = nil;
local targetPos = 0;
local targetEnt = nil;
local shotsPer = 3;
local shotsFire = shotsPer * 2;
local hasFired = 0;
local positionVector = nil;
local positionTargets = 0;
local weaponRange = 600;
local beamEnd = nil;
local shotAngle = 25;
function onUse(a)
	avatar = a;
--	local facingAngle = getFacingAngle(targetPos, avatar:getWorldPosition());
--	avatar:setWorldFacing(facingAngle);
	local beamFacing = avatar:getView():getTailFacingAngle();
	local beamOrigin = avatar:getWorldPosition();
	beamEnd = getBeamEndWithFacing(beamOrigin, weaponRange, beamFacing - 45.0);
	playAnimation(avatar, "ability_tailblaster");
	registerAnimationCallbackUntilEnd(this, avatar, "attack");		
	startCooldown(avatar, abilityData.name);
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
	local shots = shotsPer;
	while shots > 0 do
	
		if hasFired < shotsFire then
			local node = "tail_node";
			local animcb = "attack";
			if hasFired < positionTargets then
				targetPos = positionVector:get(hasFired);
			else
				targetPos = beamEnd;
			end
			local proj = avatarFireAtPoint(avatar, "weapon_Blaster2", node, targetPos, 0);
			proj:setCallback(this, 'onHit');
			proj:fromAvatar(true);
			registerAnimationCallbackUntilEnd(this, avatar, animcb);
			playSound("blaster");
			hasFired = hasFired + 1;
		end
		shots = shots - 1;
	end
end

-- Projectile hits a target.
function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	createImpactEffect(proj:getWeapon(), scenePos);
end