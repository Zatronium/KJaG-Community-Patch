-- Auto attack callback.
-- if health < 10 instant kill.
-- else punch dealing 25 damage.

local kaiju = nil;
local g_randomDamageDealt = 0;

local jumpcd = 0;
local jumpcooldown = 5;

local beamcd = 0;
local beamCooldown = 20;
local beamRange = 525;
local beamMinRange = 200;

local blastercd = 0;
local blasterCooldown = 5;
local blasterRange = 300;
local blasterMinRange = 150;

local dumbfirecd = 0;
local dumbfireCooldown = 5;
local dumbfireRange = 400;
local dumbfireMinRange = 100;

local initialSetup = false

function onSpawn(a)
	if not initialSetup then
		doSpawnSetup()
	end
end

function doSpawnSetup(a)
	initialSetup = true
	local move = a:getMovement();
	move:addMovementAnim("jump");
	move:addMovementAnim("land");
end

function onHeartbeat(a, dt)
	if not initialSetup then
		doSpawnSetup()
	end
	kaiju = getPlayerAvatar();
	local ctrl = a:getControl();
	
	if jumpcd > 0 then
		jumpcd = jumpcd - dt;
		if jumpcd > 0 and jumpcd < jumpcooldown - 2.0 then
			a:setEnablePhysicsBody(true);
		elseif jumpcd > jumpcooldown - 2.0 then
			a:getControl():resetTarget();
		end
	end
	
	beamcd = beamcd - dt;
	blastercd = blastercd - dt;
	dumbfirecd = dumbfirecd - dt;
	if not canTarget(kaiju) then
		kaiju = getPlayerTarget(a);
	end
	if not kaiju then
		return;
	end
	if not ctrl:usingAbility() then
		local dist = getDistance(kaiju, a);
		if beamcd <= 0 and dist > beamMinRange and dist < beamRange then
			ctrl:useAbility("scripts/avatars/ultrasan/laserheavy.lua", kaiju);
			beamcd = beamCooldown;
		elseif blastercd <= 0 and dist > blasterMinRange and dist < blasterRange then
			ctrl:useAbility("scripts/avatars/ultrasan/blaster.lua", kaiju);
			blastercd = blasterCooldown;
		elseif dumbfirecd <= 0 and dist > dumbfireMinRange and dist < dumbfireRange then
			ctrl:useAbility("scripts/avatars/ultrasan/dumbfire.lua", kaiju);
			dumbfirecd = dumbfireCooldown;
		else
			local move = a:getMovement();
			move:moveTo(kaiju:getWorldPosition());
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
	kaiju = getPlayerTarget(a);
	if not canTarget(kaiju) then
		return;
	end
	if jumpcd < jumpcooldown - 2.0 then
		local v = a:getView();
		local jump = false;
		if jumpcd <= 0 and a:getControl():hasTarget() then
			local t = a:getControl():getTarget();
			if getEntityType(t) == EntityType.Zone then
				a:setEnablePhysicsBody(false);
				a:getControl():resetTarget();
				jumpcd = jumpcooldown;
				v:setAnimation("jump", false);
				v:addAnimation("land", false);
				v:addAnimation("walk", true);
				jump = true;
				local move = a:getMovement();
				move:moveTo(kaiju:getWorldPosition());
			end
		end
		local curanim = v:getCurrentAnimation();
		if not jump and (curanim == "idle" or curanim == "walk") then
			local aroll = math.random(4);
			local attack = "punch_double";
			if aroll == 1 then
				attack = "punch_onetwo"
			elseif aroll == 2 then
				attack = "punch_01"
			elseif aroll == 3 then
				attack = "punch_02"
			end
			v:setAnimation(attack, false);
			v:addAnimation("walk", true);
		end
	end
end

function onAnimAttack(a)
	local ctrl = a:getControl()
	if ctrl:hasTarget() then
		local t = ctrl:getTarget();
		if getEntityType(t) == EntityType.Zone then
			playSound("building_hit");
		end
		applyDamage(a, t, math.random(40, 65));
	end	
end