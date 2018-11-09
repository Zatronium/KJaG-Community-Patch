require 'scripts/avatars/common'

local leapRange = 1000;
local leapDev = 200;
local kaiju = 0;
local buildingThresh = 150;
local jumpPower = 2000;
local damageaoe = 250;

local jumpHeight = 1000;
local firstDisplace = true;
local landingPos = nil;
local dir = nil;

local weapon = "Skyfall1"
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
	dir = getDirectionFromPoints(origin, landingPos);
	local dist = getDistanceFromPoints(kaiju:getWorldPosition(), landingPos)
	local view = kaiju:getView();
	playSound("Skyfall");
	if dist > 50 then
		view:setAnimation("ability_jump", false);
		registerAnimationCallback(this, kaiju, "start");
		kaiju:setPassive("teleport_camera_focus_disable", 1);
	end
end

function onAnimationEvent(a)
	startCooldown(kaiju, abilityData.name);
	kaiju:setCollisionScript(this);
	dir.x = 0.5;
	dir.y = 0.5;
	kaiju:getMovement():setDisplaceClamp(false);
	kaiju:displaceDirection(dir, jumpPower, jumpHeight);
	kaiju:setEnablePhysicsBody(false);
	kaiju:misdirectMissiles(1, false);
	kaiju:getMovement():moveTo(landingPos);
end

function onDisplaceEnd(a)
	kaiju = a;
	if firstDisplace == true then
		landingPos.x = landingPos.x + jumpHeight * 0.5;
		landingPos.y = landingPos.y + jumpHeight * 0.5;
		dir.x = -0.5;
		dir.y = -0.5;
		kaiju:displaceDirection(dir, jumpPower, jumpHeight);
		kaiju:teleportTo(landingPos);
		firstDisplace = false;
	else
		kaiju:getMovement():setDisplaceClamp(true);
		local view = kaiju:getView();
		view:addAnimation("idle", true);
		kaiju:setEnablePhysicsBody(true);
		kaiju:removeCollisionScript();
		kaiju:removePassive("teleport_camera_focus_disable", 0);
				
		local targets = getTargetsInRadius(kaiju:getWorldPosition(), damageaoe, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));

		local view = kaiju:getView();
		view:attachEffectToNode("root", "effects/skyfall_mainBack.plist",0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/skyfall_mainFront.plist",0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/skyfall_dustBack.plist",0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/skyfall_dustFront.plist",0, 0, 0, true, false);

		local empower = kaiju:hasPassive("enhancement");
		kaiju:removePassive("enhancement", 0);
		abilityEnhance(empower);
		for t in targets:iterator() do
			if not isSameEntity(kaiju, t) then
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t);
					if not veh:isAir() then
						applyDamageWithWeapon(kaiju, t, weapon);
					end
				elseif getEntityType(t) == EntityType.Zone then
					if t:getStat("Health") > buildingThresh then
						applyDamageWithWeapon(kaiju, t, weapon);
					elseif not isLairAttack() then
						t:modStat("Health", -t:getStat("Health"));
					end
				else 
					applyDamageWithWeapon(kaiju, t, weapon);
				end
			end
		end
		abilityEnhance(0);
	end
end