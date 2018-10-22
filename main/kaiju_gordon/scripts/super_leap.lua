require 'scripts/avatars/common'

local leapRange = 500;
local leapDev = 100;
local avatar = 0;
local buildingThresh = 80;
local jumpPower = 300;
local damageaoe = 100;
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
	playSound("SuperLeap");
	if dist > 50 then
		view:setAnimation("ability_jump", false);
		view:addAnimation("idle", true);
		registerAnimationCallback(this, avatar, "start");
	end
end

function onAnimationEvent(a)
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/leapSmoke.plist",2, 0, 0, false, true);
	view:togglePauseAnimation(true);
	startCooldown(avatar, abilityData.name);
	avatar:setCollisionScript(this);
	avatar:displaceDirection(dir, jumpPower, dist);
	avatar:setEnablePhysicsBody(false);
	avatar:misdirectMissiles(1, false);
end

function onDisplaceEnd(a)
	avatar = a;
	local view = avatar:getView();
	view:togglePauseAnimation(false);
	avatar:setEnablePhysicsBody(true);
	avatar:removeCollisionScript();
	local targets = getTargetsInRadius(avatar:getWorldPosition(), damageaoe, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	view:attachEffectToNode("root", "effects/superLeapImpact_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/superLeapImpact_front.plist",0, 0, 0, true, false);
	
	view:attachEffectToNode("root", "effects/impact_fireRingBack_med.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/impact_fireRingFront_med.plist",0, 0, 0, true, false);
	local empower = avatar:hasPassive("enhancement");
	avatar:removePassive("enhancement", 0);
	abilityEnhance(empower);
	for t in targets:iterator() do
		if not isSameEntity(a, t) then
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				if not veh:isAir() then
					applyDamage(avatar, t, buildingThresh * 0.5);
				end
			elseif getEntityType(t) == EntityType.Zone then
				if t:getStat("Health") > buildingThresh then
					applyDamage(avatar, t, buildingThresh);
				elseif not isLairAttack() then
					t:modStat("Health", -t:getStat("Health"));
				end
			else 
				applyDamage(avatar, t, buildingThresh * 0.5);
			end
		end
	end
	abilityEnhance(0);
end