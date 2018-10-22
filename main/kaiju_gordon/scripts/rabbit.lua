require 'scripts/avatars/common'

local leapRange = 100;
local leapDev = 20;
local avatar = 0;
local startPos = nil;
local jumpPower = 300;
local jumpNum = 5;
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
		--createFloatingNumber(avatar, jumpNum, 255, 255, 0);
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
	--local view = a:getView();
	--view:togglePauseAnimation(false);
	--local view = avatar:getView();
	--view:addAnimation("ability_punchone", true);
	jumping = false;
	--createFloatingNumber(a, jumpNum, 255, 255, 0);
	if jumpNum <= 0 then
		Jump();
	end
	avatar = a;
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
end