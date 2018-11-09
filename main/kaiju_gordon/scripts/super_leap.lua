require 'scripts/avatars/common'

local leapRange = 500;
local leapDev = 100;
local kaiju = 0;
local buildingThresh = 80;
local jumpPower = 300;
local damageaoe = 100;
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
	playSound("SuperLeap");
	if dist > 50 then
		view:setAnimation("ability_jump", false);
		view:addAnimation("idle", true);
		registerAnimationCallback(this, kaiju, "start");
	end
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/leapSmoke.plist",2, 0, 0, false, true);
	view:togglePauseAnimation(true);
	startCooldown(kaiju, abilityData.name);
	kaiju:setCollisionScript(this);
	kaiju:displaceDirection(dir, jumpPower, dist);
	kaiju:setEnablePhysicsBody(false);
	kaiju:misdirectMissiles(1, false);
end

function onDisplaceEnd(a)
	kaiju = a;
	local view = kaiju:getView();
	view:togglePauseAnimation(false);
	kaiju:setEnablePhysicsBody(true);
	kaiju:removeCollisionScript();
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), damageaoe, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	view:attachEffectToNode("root", "effects/superLeapImpact_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/superLeapImpact_front.plist",0, 0, 0, true, false);
	
	view:attachEffectToNode("root", "effects/impact_fireRingBack_med.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/impact_fireRingFront_med.plist",0, 0, 0, true, false);
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	abilityEnhance(empower);
	for t in targets:iterator() do
		if not isSameEntity(a, t) then
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				if not veh:isAir() then
					applyDamage(kaiju, t, buildingThresh * 0.5);
				end
			elseif getEntityType(t) == EntityType.Zone then
				if t:getStat("Health") > buildingThresh then
					applyDamage(kaiju, t, buildingThresh);
				elseif not isLairAttack() then
					t:modStat("Health", -t:getStat("Health"));
				end
			else 
				applyDamage(kaiju, t, buildingThresh * 0.5);
			end
		end
	end
	abilityEnhance(0);
end