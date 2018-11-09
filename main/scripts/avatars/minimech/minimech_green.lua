
local kaiju = nil;

local stopdist = 200;

local jumpangle = 45;
local jumpdist = 300;
local jumpstart = nil;
local jumpwait = 2;
local jumpwaittime = 0;

local lasercd = 0;
local laserCooldown = 10;
local laserRange = 600;
local laserMinRange = 200;

local specialcd = 0;
local specialCooldown = 20;
local specialRange = 300;
local specialMinRange = 100;

local moving = false;

local initialSetup = false
local setupFinished = false

function doSpawnSetup(a)
  initialSetup = true
  kaiju = getPlayerAvatar()
  local move = a:getMovement();
  move:addMovementAnim("float");
  setupFinished = true
end

function onHeartbeat(a, dt)
	if not initialSetup then
		doSpawnSetup(a)
	end
	if not setupFinished then
		return
	end
	local v = a:getView();
	local move = a:getMovement();
	local ctrl = a:getControl();
	
	if jumpwaittime > 0 then
		jumpwaittime = jumpwaittime - dt;
		if jumpwaittime <= 0 then
			a:setImmobile(false);
		end
	end
	
	if jumpstart then
		local moveddist = getDistanceFromPoints(jumpstart, a:getWorldPosition());
		if moveddist >= jumpdist then
			a:setEnablePhysicsBody(true);
			a:setImmobile(true);
			v:setAnimation("idle", true);
			jumpwaittime = jumpwait;
			jumpstart = nil;
		end
	end
	
	lasercd = lasercd - dt;
	specialcd = specialcd - dt;
	if not canTarget(kaiju) then
		kaiju = getPlayerTarget(a);
	end
	if not kaiju then
		return;
	end
	if not ctrl:usingAbility() then	
		local used = false;
		local dist = getDistance(kaiju, a);
		if specialcd <= 0 and dist > specialMinRange and dist < specialRange then
			ctrl:useAbility("scripts/avatars/minimech/acidspray.lua", kaiju);
			specialcd = specialCooldown;
			used = true;
		elseif lasercd <= 0 and dist > laserMinRange and dist < laserRange then
			ctrl:useAbility("scripts/avatars/minimech/laserlight.lua", kaiju);
			lasercd = laserCooldown;
			used = true;
		elseif dist > stopdist and jumpwaittime <= 0 and not jumpstart then	
			move:moveTo(kaiju:getWorldPosition());
			moving = true;
		elseif moving and jumpwaittime <= 0 and not jumpstart then
			local fakeFacingPosition = getBeamEndWithPoint(a:getWorldPosition(), 5, kaiju:getWorldPosition())
			move:moveTo(fakeFacingPosition)
			moving = false
		end
		if used then
			jumpstart = nil;
			a:setEnablePhysicsBody(true);
		end
	end	
end

function onStatChanged(e, stat, prev, val)
	if stat == "Health" and prev > 0 then
		local maxHealth = e:getStat("MaxHealth");
		if val <= 0 then
			e:getView():doDeathEffect()
			e:setEnablePhysicsBody(false);
		elseif val > e:getStat("MaxHealth") then
			e:setStat("Health", maxHealth);
		end
	end
end

function onAttack(a)
	if not canTarget(kaiju) then
		return;
	end
	local v = a:getView();
	local jump = false;
	local ctrl = a:getControl()
	if not jumpstart and ctrl:hasTarget() then
		local t = ctrl:getTarget();
		if getEntityType(t) == EntityType.Zone then
			local dist = getDistance(kaiju, a);
			local towards = 1.5;
			if dist < stopdist then
				towards = -1.5;
			end
			local dir = getRandomNormalizedDirection(a:getWorldPosition(), kaiju:getWorldPosition(), jumpangle);
			local jumpto = a:getWorldPosition();
			jumpto.x = jumpto.x + dir.x * jumpdist * towards;
			jumpto.y = jumpto.y + dir.y * jumpdist * towards;
			
			a:setEnablePhysicsBody(false);
			ctrl:resetTarget();
			jumpstart = a:getWorldPosition();
			v:setAnimation("float", true);
			ctrl:resetTarget();
			jump = true;
			local move = a:getMovement();
			move:moveTo(jumpto);
		end
	end
	
	local curanim = v:getCurrentAnimation();
	if not jump and (curanim == "idle" or curanim == "walk") then
		local aroll = math.random(7);
		local attack = "punch_double";
		if aroll == 1 then
			attack = "punch_onetwo"
		elseif aroll == 2 then
			attack = "punch_01"
		elseif aroll == 3 then
			attack = "punch_02"
		elseif aroll == 4 then
			attack = "punch_03"
		elseif aroll == 5 then
			attack = "punch_crit"
		elseif aroll == 6 then
			attack = "kick"
		end

		v:setAnimation(attack, false);
		v:addAnimation("idle", true);
	end
end

function onAnimAttack(a)
	local ctrl = a:getControl()
	if ctrl:hasTarget() then
		local t = ctrl:getTarget();
		if getEntityType(t) == EntityType.Zone then
			playSound("building_hit");
		end
		applyDamage(a, t, math.random(18, 24));
	end	
end