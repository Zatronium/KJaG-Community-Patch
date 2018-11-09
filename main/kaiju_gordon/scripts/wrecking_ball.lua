require 'kaiju_gordon/scripts/gordon'

local leapRange = 200;
local leapDev = 100;
local kaiju = 0;
local startPos = nil;
local jumpPower = 300;
local jumpNum = 5;

local weapon = "BlastZone1";
local aoeRange = 130;

local jumping = false;
function onUse(a)
	kaiju = a;
	startCooldown(kaiju, abilityData.name);
	kaiju:setEnablePhysicsBody(false);
	kaiju:misdirectMissiles(1, false);
	local view = kaiju:getView();
	view:setAnimation("ability_jump", true);
	registerAnimationCallbackContinuous(this, kaiju, "start");
end

function Jump()
	kaiju:setEnablePhysicsBody(true);
	kaiju:removeCollisionScript();
	kaiju:getView():setAnimation("idle", true);
	removeAnimationCallback(this, kaiju);
end

function onAnimationEvent(a, event)
	if not jumping then
		jumpNum = jumpNum - 1;
		jumping = true;
		local curPos = kaiju:getWorldPosition();
		local position = offsetRandomDirection(curPos, leapRange, leapRange);
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), position);
		kaiju:setWorldFacing(facingAngle);
		local pos = findLandingPoint(position, position, 50, (jumpNum - 1) * 100, leapDev);
		local dist = getDistanceFromPoints(curPos, pos)
		local dir = getDirectionFromPoints(curPos, pos);
		local view = kaiju:getView();
		--view:togglePauseAnimation(true);
		kaiju:displaceDirection(dir, jumpPower, dist);	
		kaiju:setCollisionScript(this);
	end
end

function onDisplaceEnd(a)
	kaiju = a;
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/superLeapImpact_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/superLeapImpact_front.plist",0, 0, 0, true, false);
	
	view:attachEffectToNode("root", "effects/impact_fireRingBack_med.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/impact_fireRingFront_med.plist",0, 0, 0, true, false);
	jumping = false;
	if jumpNum <= 0 then
		Jump();
	end
		
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), 50, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if not isSameEntity(kaiju, t) then
			local flying = false;
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				flying = veh:isAir();
			end
			if not flying then
				applyDamage(kaiju, t, 40);
			end
		end
	end
	
	BlastZone(kaiju, weapon);
end