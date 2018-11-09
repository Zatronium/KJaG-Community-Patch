require 'scripts/avatars/common'

local leapRange = 200;
local leapDev = 100;
local kaiju = 0;
local buildingThresh = 40;
local jumpPower = 300;

local dir = nil;
local dist = 0;
local landingPos = nil;
function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', leapRange + leapRange * kaiju:hasPassive("gordon_leap_distance"));
end

function onTargets(position)
	buildingThresh = buildingThresh * (1 + kaiju:hasPassive("zone_health_threshold"));
	local origin = kaiju:getWorldPosition();
	local facingAngle = getFacingAngle(origin, position);
	kaiju:setWorldFacing(facingAngle);
	landingPos = findLandingPoint(origin, position, 50, buildingThresh, leapDev);
	dir = getDirectionFromPoints(kaiju:getWorldPosition(), landingPos);
	dist = getDistanceFromPoints(kaiju:getWorldPosition(), landingPos)
	local view = kaiju:getView();
	if dist > 50 then
		view:setAnimation("ability_jump", false);
		view:addAnimation("idle", true);
		registerAnimationCallback(this, kaiju, "start");
	end
end

function onAnimationEvent(a)
	startCooldown(kaiju, abilityData.name);
	kaiju:getView():togglePauseAnimation(true);
	kaiju:setCollisionScript(this);
	kaiju:displaceDirection(dir, jumpPower, dist);
	kaiju:setEnablePhysicsBody(false);
	kaiju:misdirectMissiles(1, false);
end

function onDisplaceEnd(a)
	kaiju = getPlayerAvatar();
	local view = kaiju:getView();
	view:togglePauseAnimation(false);
	kaiju:setEnablePhysicsBody(true);
	kaiju:removeCollisionScript();
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), 50, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	local view = kaiju:getView();
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
					applyDamage(kaiju, t, buildingThresh);
				end
			elseif getEntityType(t) == EntityType.Zone then
				if t:getStat("Health") > buildingThresh then
					applyDamage(kaiju, t, buildingThresh);
				elseif not isLairAttack() then
					t:modStat("Health", -t:getStat("Health"));
				end
			else 
				applyDamage(kaiju, t, buildingThresh);
			end
		end
	end
end