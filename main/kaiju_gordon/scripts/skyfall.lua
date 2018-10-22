require 'scripts/avatars/common'

local leapRange = 1000;
local leapDev = 200;
local avatar = 0;
local buildingThresh = 150;
local jumpPower = 2000;
local damageaoe = 250;

local jumpHeight = 1000;
local firstDisplace = true;
local landingPos = nil;
local dir = nil;

local weapon = "Skyfall1"
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
	dir = getDirectionFromPoints(origin, landingPos);
	local dist = getDistanceFromPoints(avatar:getWorldPosition(), landingPos)
	local view = avatar:getView();
	playSound("Skyfall");
	if dist > 50 then
		view:setAnimation("ability_jump", false);
		registerAnimationCallback(this, avatar, "start");
		avatar:setPassive("teleport_camera_focus_disable", 1);
	end
end

function onAnimationEvent(a)
	startCooldown(avatar, abilityData.name);
	avatar:setCollisionScript(this);
	dir.x = 0.5;
	dir.y = 0.5;
	avatar:getMovement():setDisplaceClamp(false);
	avatar:displaceDirection(dir, jumpPower, jumpHeight);
	avatar:setEnablePhysicsBody(false);
	avatar:misdirectMissiles(1, false);
	avatar:getMovement():moveTo(landingPos);
end

function onDisplaceEnd(a)
	avatar = a;
	if firstDisplace == true then
		landingPos.x = landingPos.x + jumpHeight * 0.5;
		landingPos.y = landingPos.y + jumpHeight * 0.5;
		dir.x = -0.5;
		dir.y = -0.5;
		avatar:displaceDirection(dir, jumpPower, jumpHeight);
		avatar:teleportTo(landingPos);
		firstDisplace = false;
	else
		avatar:getMovement():setDisplaceClamp(true);
		local view = avatar:getView();
		view:addAnimation("idle", true);
		avatar:setEnablePhysicsBody(true);
		avatar:removeCollisionScript();
		avatar:removePassive("teleport_camera_focus_disable", 0);
				
		local targets = getTargetsInRadius(avatar:getWorldPosition(), damageaoe, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));

		local view = avatar:getView();
		view:attachEffectToNode("root", "effects/skyfall_mainBack.plist",0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/skyfall_mainFront.plist",0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/skyfall_dustBack.plist",0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/skyfall_dustFront.plist",0, 0, 0, true, false);

		local empower = avatar:hasPassive("enhancement");
		avatar:removePassive("enhancement", 0);
		abilityEnhance(empower);
		for t in targets:iterator() do
			if not isSameEntity(avatar, t) then
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t);
					if not veh:isAir() then
						applyDamageWithWeapon(avatar, t, weapon);
					end
				elseif getEntityType(t) == EntityType.Zone then
					if t:getStat("Health") > buildingThresh then
						applyDamageWithWeapon(avatar, t, weapon);
					elseif not isLairAttack() then
						t:modStat("Health", -t:getStat("Health"));
					end
				else 
					applyDamageWithWeapon(avatar, t, weapon);
				end
			end
		end
		abilityEnhance(0);
	end
end