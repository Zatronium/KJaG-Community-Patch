require 'kaiju_gordon/scripts/gordon'

local leapRange = 200;
local leapDev = 100;
local avatar = 0;
local startPos = nil;
local jumpPower = 300;
local jumpNum = 5;

local weapon = "BlastZone1";
local aoeRange = 130;

local jumping = false;
function onUse(a)
	avatar = a;
	startCooldown(avatar, abilityData.name);
	avatar:setEnablePhysicsBody(false);
	avatar:misdirectMissiles(1, false);
	local view = avatar:getView();
	view:setAnimation("ability_jump", true);
	registerAnimationCallbackContinuous(this, avatar, "start");
end

function Jump()
	avatar:setEnablePhysicsBody(true);
	avatar:removeCollisionScript();
	avatar:getView():setAnimation("idle", true);
	removeAnimationCallback(this, avatar);
end

function onAnimationEvent(a, event)
	if not jumping then
		jumpNum = jumpNum - 1;
		jumping = true;
		local curPos = avatar:getWorldPosition();
		local position = offsetRandomDirection(curPos, leapRange, leapRange);
		local facingAngle = getFacingAngle(avatar:getWorldPosition(), position);
		avatar:setWorldFacing(facingAngle);
		local pos = findLandingPoint(position, position, 50, (jumpNum - 1) * 100, leapDev);
		local dist = getDistanceFromPoints(curPos, pos)
		local dir = getDirectionFromPoints(curPos, pos);
		local view = avatar:getView();
		--view:togglePauseAnimation(true);
		avatar:displaceDirection(dir, jumpPower, dist);	
		avatar:setCollisionScript(this);
	end
end

function onDisplaceEnd(a)
	avatar = a;
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/superLeapImpact_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/superLeapImpact_front.plist",0, 0, 0, true, false);
	
	view:attachEffectToNode("root", "effects/impact_fireRingBack_med.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/impact_fireRingFront_med.plist",0, 0, 0, true, false);
	jumping = false;
	if jumpNum <= 0 then
		Jump();
	end
		
	local targets = getTargetsInRadius(avatar:getWorldPosition(), 50, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if not isSameEntity(avatar, t) then
			local flying = false;
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				flying = veh:isAir();
			end
			if not flying then
				applyDamage(avatar, t, 40);
			end
		end
	end
	
	BlastZone(avatar, weapon);
end