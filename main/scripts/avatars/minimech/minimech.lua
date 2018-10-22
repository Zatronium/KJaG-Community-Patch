local kaiju = nil
local stopdist = 500;

local lasercd = 0;
local laserCooldown = 10;
local laserRange = 1000;
local laserMinRange = 200;

local specialcd = 0;
local specialCooldown = 13;
local specialRange = 600;
local specialMinRange = 300;

local moving = false
local initialSetup = false
local setupFinished = false

function onSpawn(a)
	if not initialSetup then
		doSpawnSetup(a)
	end
end

function doSpawnSetup(a)
		initialSetup = true
		kaiju = getPlayerAvatar()
		setupFinished = true
	end
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
	lasercd = lasercd - dt;
	specialcd = specialcd - dt;
	
	if not ctrl:usingAbility() then	
		local dist = getDistance(kaiju, a);
		if specialcd <= 0 and dist > specialMinRange and dist < specialRange then
			ctrl:useAbility("scripts/avatars/minimech/autocannon.lua", kaiju);
			specialcd = specialCooldown;
		elseif lasercd <= 0 and dist > laserMinRange and dist < laserRange then
			ctrl:useAbility("scripts/avatars/minimech/laserlight.lua", kaiju);
			lasercd = laserCooldown;
		elseif dist > stopdist then	
			move:moveTo(kaiju:getWorldPosition());
			moving = true;
		elseif moving then
			local fakeFacingPosition = getBeamEndWithPoint(a:getWorldPosition(), 5, kaiju:getWorldPosition())
			move:moveTo(fakeFacingPosition)
			moving = false
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
	local v = a:getView();

	local curanim = v:getCurrentAnimation();
	if curanim == "idle" or curanim == "walk" then
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
		applyDamage(a, t, math.random(18, 24));
		if getEntityType(t) == EntityType.Zone then
			playSound("building_hit");
		end
	end	
end