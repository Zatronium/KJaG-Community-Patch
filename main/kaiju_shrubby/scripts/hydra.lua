require 'scripts/avatars/common'

local avatar = 0;
local targetPos = 0;
local weapon = "weapon_shrubby_airVine3";
local weapon_node = "root"
local number_targets1 = 5;
local number_targets2 = 5;
local number_targets3 = 5;
local jump_range = 350;

local target1_1 = nil;
local target1_2 = nil;
local target1_3 = nil;
local target1_4 = nil;

local target2_1 = nil;
local target2_2 = nil;
local target2_3 = nil;
local target2_4 = nil;

local target3_1 = nil;
local target3_2 = nil;
local target3_3 = nil;
local target3_4 = nil;

local vine1 = nil;
local vine2 = nil;
local vine3 = nil;

function setupNewVine()
	--vine = createRope("sprite", segments, strokeWidth);
	local vine = createRope("sprites/placehold_vine.png", 20, 45);
	-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
	vine:setUV(0.7, 0.3, 1);
	-- setNoise(min distance, max distance) default 0, 0
	vine:setNoise(10, 20);
	-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
	vine:setRetract(0.4, 100);
	vine:setEndEntity(avatar);
	return vine;
end

function onUse(a)
	avatar = a;
	playAnimation(avatar, "stomp");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent (a)
	local targetsfound = 0;
	local avPos = avatar:getWorldPosition()
	local targets = getTargetsInRadius(avPos, getWeaponRange(weapon), EntityFlags(EntityType.Vehicle));
	target1_1 = nil;
	target2_1 = target1_1;
	target3_1 = target1_1;
	for t in targets:iterator() do
		if targetsfound < 3 then
			local v = entityToVehicle(t);
			if v:isAir() then
					target3_1 = target2_1;
					target2_1 = target1_1;
					target1_1 = t;
					targetsfound = targetsfound + 1;
			end
		end
	end
	if targetsfound <= 0 then
		NoTargetText(avatar);
	else
		startCooldown(avatar, abilityData.name);
		playSound("shrubby_ability_Hydra");
		local view = avatar:getView();
		local proj;
		if canTarget(target1_1) then
			proj = avatarFireAtTarget(avatar, weapon, weapon_node, target1_1, 90 - view:getFacingAngle());
		else
			proj = avatarFireAtPoint(avatar, weapon, weapon_node, offsetRandomDirection(avPos, jump_range, getWeaponRange(weapon)), 90 - view:getFacingAngle());
		end
		vine1 = setupNewVine();
		vine1:setStartEntity(proj);
		vine1:activate();
		proj:setCallback(this, 'onHit1');	
		
		if canTarget(target2_1) then
			proj = avatarFireAtTarget(avatar, weapon, weapon_node, target2_1, 90 - view:getFacingAngle());
		else
			proj = avatarFireAtPoint(avatar, weapon, weapon_node, offsetRandomDirection(avPos, jump_range, getWeaponRange(weapon)), 90 - view:getFacingAngle());
		end
		vine2 = setupNewVine();
		vine2:setStartEntity(proj);
		vine2:activate();
		proj:setCallback(this, 'onHit2');	
		
		if canTarget(target3_1) then
			proj = avatarFireAtTarget(avatar, weapon, weapon_node, target3_1, 90 - view:getFacingAngle());
		else
			proj = avatarFireAtPoint(avatar, weapon, weapon_node, offsetRandomDirection(avPos, jump_range, getWeaponRange(weapon)), 90 - view:getFacingAngle());
		end
		vine3 = setupNewVine();
		vine3:setStartEntity(proj);
		vine3:activate();
		proj:setCallback(this, 'onHit3');
	end
end

function onHit1(proj)
	local pos = proj:getView():getPosition();
	local worldPos = proj:getWorldPosition();
	createImpactEffect(proj:getWeapon(), pos);
	local fired = false;
	if number_targets1 > 1 then
		local targets = getTargetsInRadius(worldPos, jump_range, EntityFlags(EntityType.Vehicle));
		for t in targets:iterator() do
			if not fired then
				local v = entityToVehicle(t);
				if v:isAir() then					
					if check1(t) then
						incrementTargets1();
						target1_1 = t;
						local proj1 = fireProjectileAtTarget(avatar, t, worldPos, Point(0, 0), weapon);
						number_targets1 = number_targets1 - 1;
						proj1:setCallback(this, 'onHit1');	
						vine1:setStartEntity(proj1);

						fired = true;
					end
				end
			end
		end
	end
	if not fired then
		vine1:endRope();
	end
end

function onHit2(proj)
	local pos = proj:getView():getPosition();
	local worldPos = proj:getWorldPosition();
	createImpactEffect(proj:getWeapon(), pos);
	local targets = getTargetsInRadius(worldPos, jump_range, EntityFlags(EntityType.Vehicle));
	local fired = false;
	if number_targets2 > 1 then
		local targets = getTargetsInRadius(worldPos, jump_range, EntityFlags(EntityType.Vehicle));
		for t in targets:iterator() do
			if not fired then
				local v = entityToVehicle(t);
				if v:isAir() then					
					if check2(t) then
						incrementTargets2();
						target2_1 = t;
						local proj2 = fireProjectileAtTarget(avatar, t, worldPos, Point(0, 0), weapon);
						number_targets2 = number_targets2 - 1;
						proj2:setCallback(this, 'onHit2');
						vine2:setStartEntity(proj2);

						fired = true;
					end
				end
			end
		end
	end
	if not fired then
		vine2:endRope();
	end
end

function onHit3(proj)
	local pos = proj:getView():getPosition();
	local worldPos = proj:getWorldPosition();
	createImpactEffect(proj:getWeapon(), pos);
	local targets = getTargetsInRadius(worldPos, jump_range, EntityFlags(EntityType.Vehicle));
	local fired = false;
	if number_targets3 > 1 then
		local targets = getTargetsInRadius(worldPos, jump_range, EntityFlags(EntityType.Vehicle));
		for t in targets:iterator() do
			if not fired then
				local v = entityToVehicle(t);
				if v:isAir() then					
					if check3(t) then
						incrementTargets3();
						target3_1 = t;
						local proj3 = fireProjectileAtTarget(avatar, t, worldPos, Point(0, 0), weapon);
						number_targets3 = number_targets3 - 1;
						proj3:setCallback(this, 'onHit3');
						vine3:setStartEntity(proj3);

						fired = true;
					end
				end
			end
		end
	end
	if not fired then
		vine3:endRope();
	end
end

function check1(t)
	local ret = true;
	if isSameEntity(target1_1, t) then
		ret = false;
	end
	if isSameEntity(target1_2, t) then
		ret = false;
	end
	if isSameEntity(target1_3, t) then
		ret = false;
	end
	if isSameEntity(target1_4, t) then
		ret = false;
	end
	return ret;
end

function incrementTargets1()
	target1_4 = target1_3;
	target1_3 = target1_2;
	target1_2 = target1_1;
end


function check2(t)
	local ret = true;
	if isSameEntity(target2_1, t) then
		ret = false;
	end
	if isSameEntity(target2_2, t) then
		ret = false;
	end
	if isSameEntity(target2_3, t) then
		ret = false;
	end
	if isSameEntity(target2_4, t) then
		ret = false;
	end
	return ret;
end

function incrementTargets2()
	target2_4 = target2_3;
	target2_3 = target2_2;
	target2_2 = target2_1;
end

function check3(t)
	local ret = true;
	if isSameEntity(target3_1, t) then
		ret = false;
	end
	if isSameEntity(target3_2, t) then
		ret = false;
	end
	if isSameEntity(target3_3, t) then
		ret = false;
	end
	if isSameEntity(target3_4, t) then
		ret = false;
	end
	return ret;
end

function incrementTargets3()
	target3_4 = target3_3;
	target3_3 = target3_2;
	target3_2 = target3_1;
end