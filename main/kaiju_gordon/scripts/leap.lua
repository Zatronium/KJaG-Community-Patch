require 'scripts/avatars/common'

local leapRange = 200;
local leapDev = 100;
local avatar = 0;
local buildingThresh = 40;
local jumpPower = 300;

local dir = nil;
local dist = 0;
local landingPos = nil;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', leapRange + leapRange * avatar:hasPassive("gordon_leap_distance"));
end

function onTargets(position)
	buildingThresh = buildingThresh * (1 + avatar:hasPassive("zone_health_threshold"));
	local origin = avatar:getWorldPosition();
	local facingAngle = getFacingAngle(origin, position);
	avatar:setWorldFacing(facingAngle);
	landingPos = findLandingPoint(origin, position, 50, buildingThresh, leapDev);
	dir = getDirectionFromPoints(avatar:getWorldPosition(), landingPos);
	dist = getDistanceFromPoints(avatar:getWorldPosition(), landingPos)
	local view = avatar:getView();
	if dist > 50 then
		view:setAnimation("ability_jump", false);
		view:addAnimation("idle", true);
		registerAnimationCallback(this, avatar, "start");
	end
end

function onAnimationEvent(a)
	startCooldown(avatar, abilityData.name);
	avatar:getView():togglePauseAnimation(true);
	avatar:setCollisionScript(this);
	avatar:displaceDirection(dir, jumpPower, dist);
	avatar:setEnablePhysicsBody(false);
	avatar:misdirectMissiles(1, false);
end

function onDisplaceEnd(a)
	avatar = getPlayerAvatar();
	local view = avatar:getView();
	view:togglePauseAnimation(false);
	avatar:setEnablePhysicsBody(true);
	avatar:removeCollisionScript();
	local targets = getTargetsInRadius(avatar:getWorldPosition(), 50, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/leapImpact_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/leapImpact_front.plist",0, 0, 0, true, false);
	
	view:attachEffectToNode("root", "effects/impact_fireRingBack_med.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/impact_fireRingFront_med.plist",0, 0, 0, true, false);
	
	playSound("Leap");
	
	for t in targets:iterator() do
		if not isSameEntity(a, t) then
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				if not veh:isAir() then
					applyDamage(avatar, t, buildingThresh);
				end
			elseif getEntityType(t) == EntityType.Zone then
				if t:getStat("Health") > buildingThresh then
					applyDamage(avatar, t, buildingThresh);
				elseif not isLairAttack() then
					t:modStat("Health", -t:getStat("Health"));
				end
			else 
				applyDamage(avatar, t, buildingThresh);
			end
		end
	end
end