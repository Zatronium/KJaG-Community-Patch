require 'scripts/avatars/common'

local kaiju = 0;
local targetPos = 0;
local weapon = "weapon_shrubby_airVine3";
local weapon_node = "root"
local number_targets = 5;
local jump_range = 350;

local target1 = nil;
local target2 = nil;
local target3 = nil;
local target4 = nil;

local vine = nil;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "stomp");
	registerAnimationCallback(this, kaiju, "attack");
end


function onAnimationEvent (a)

	target = getClosestAirTargetInRadius(kaiju:getWorldPosition(), getWeaponRange(weapon), EntityFlags(EntityType.Vehicle));
	target1 = target;
	local view = kaiju:getView();
	local proj;
	if canTarget(target) then
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle());
		
		playSound("shrubby_ability_AirSpike");
		startCooldown(kaiju, abilityData.name);
		
		--vine = createRope("sprite", segments, strokeWidth, tipUV, endUV);
		vine = createRope("sprites/placehold_vine.png", 20, 45);
		-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
		vine:setUV(0.7, 0.3, 1);
		-- setNoise(min distance, max distance) default 0, 0
		vine:setNoise(10, 20);
		-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
		vine:setRetract(0.2, 50);
		vine:setStartEntity(proj);
		vine:setEndEntity(kaiju);
		vine:activate();
		proj:setCallback(this, 'onHit');
	else
		NoTargetText(kaiju);
	end
end

function onHit(proj)
	local pos = proj:getView():getPosition();
	local worldPos = proj:getWorldPosition();
	createImpactEffect(proj:getWeapon(), pos);
	local fired = false;
	if number_targets > 1 then
		local targets = getTargetsInRadius(worldPos, jump_range, EntityFlags(EntityType.Vehicle));
		for t in targets:iterator() do
			if not fired then
				local v = entityToVehicle(t);
				if v:isAir() then
					local ret = true;
					if isSameEntity(target1, t) then
						ret = false;
					end
					if isSameEntity(target2, t) then
						ret = false;
					end
					if isSameEntity(target3, t) then
						ret = false;
					end
					if isSameEntity(target4, t) then
						ret = false;
					end
					
					if ret then
						incrementTargets();
						target1 = t;
						local nproj = fireProjectileAtTarget(kaiju, t, worldPos, Point(0, 0), weapon);
						number_targets = number_targets - 1;
						nproj:setCallback(this, 'onHit');

						vine:setStartEntity(nproj);
						fired = true;
					end
				end
			end
		end
	end
	if not fired then
		vine:endRope();
	end
end

function incrementTargets()
	target4 = target3;
	target3 = target2;
	target2 = target1;
end