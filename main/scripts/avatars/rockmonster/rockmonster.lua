-- Auto attack callback.
-- if health < 10 instant kill.
-- else punch dealing 25 damage.

local kaiju = nil;

local punchcd = 0;
local punchCooldown = 10;
local punchRange = 100;
local punchMinRange = 0;

local sandcd = 0;
local sandCooldown = 35;
local sandRange = 1000;
local sandMinRange = 0;

local bouldercd = 0;
local boulderCooldown = 20;
local boulderRange = 1500;
local boulderMinRange = 200;

function onHeartbeat(a, dt)
	kaiju = getPlayerAvatar();
	local ctrl = a:getControl();
	punchcd = punchcd - dt;
	sandcd = sandcd - dt;
	bouldercd = bouldercd - dt;
	if not canTarget(kaiju) then
		kaiju = getPlayerTarget(a);
	end
	if not kaiju then
		return;
	end
	if not ctrl:usingAbility() then	
		local dist = getDistance(kaiju, a);
		if punchcd <= 0 and dist > punchMinRange and dist < punchRange then
			ctrl:useAbility("scripts/avatars/rockmonster/megapunch.lua", kaiju);
			punchcd = punchCooldown;
		elseif bouldercd <= 0 and dist > boulderMinRange and dist < boulderRange then
			ctrl:useAbility("scripts/avatars/rockmonster/boulder.lua", kaiju);
			bouldercd = boulderCooldown;
		elseif sandcd <= 0 and dist > sandMinRange and dist < sandRange then
			ctrl:useAbility("scripts/avatars/rockmonster/sandstorm.lua", kaiju);
			sandcd = sandCooldown;
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
		local aroll = math.random(5);
		local attack = "punch_02";
		if aroll == 1 then
			attack = "punch_01"
		elseif aroll == 2 then
			attack = "punch_01"
		elseif aroll == 3 then
			attack = "punch_02"
		elseif aroll == 4 then
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