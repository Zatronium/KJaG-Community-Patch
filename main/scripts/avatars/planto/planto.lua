-- Auto attack callback.
-- if health < 10 instant kill.
-- else punch dealing 25 damage.

local kaiju = nil;

local bitecd = 0;
local biteCooldown = 5;
local biteRange = 100;
local biteMinRange = 0;

local vinecd = 0;
local vineCooldown = 20;
local vineRange = 200;
local vineMinRange = 0;

local acidcd = 0;
local acidCooldown = 20;
local acidRange = 250;
local acidMinRange = 0;

function onHeartbeat(a, dt)
	kaiju = getPlayerAvatar();
	local ctrl = a:getControl();
	bitecd = bitecd - dt;
	vinecd = vinecd - dt;
	acidcd = acidcd - dt;
	
	if not canTarget(kaiju) then
		kaiju = getPlayerTarget(a)
	end
	if not kaiju then
		return;
	end
	if not ctrl:usingAbility() then	
		local dist = getDistance(kaiju, a);
		if acidcd <= 0 and dist > acidMinRange and dist < acidRange then
			ctrl:useAbility("scripts/avatars/planto/acidspray.lua", kaiju);
			acidcd = acidCooldown;
		elseif bitecd <= 0 and dist > biteMinRange and dist < biteRange then
			ctrl:useAbility("scripts/avatars/planto/megachomp.lua", kaiju);
			bitecd = biteCooldown;
		elseif vinecd <= 0 and dist > vineMinRange and dist < vineRange then
			ctrl:useAbility("scripts/avatars/planto/tentacle_whip.lua", kaiju);
			vinecd = vineCooldown;
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
		elseif val > e:getStat("MaxHealth")) then
			e:setStat("Health", maxHealth);
		end
	end
end

function onAttack(a)

	if not canTarget(kaiju) then
		return;
	end
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
	if a:getControl():hasTarget() then
		local t = a:getControl():getTarget();
		if getEntityType(t) == EntityType.Zone then
			playSound("building_hit");
		end
		applyDamage(a, t, math.random(20, 45));
	end	
end