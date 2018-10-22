require 'scripts/common'

local avatar = 0;
local weapon = "weapon_shrubby_vine3";
local weapon_node = "root"
local damage_per_tick = 3;
local number_of_ticks = 5; 
local target = nil;
local targetPos = nil;
local kbPower = 500;
local kbDistance = 1000; -- max distance

local vine = nil;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
		avatar:setWorldFacing(facingAngle);	
		playAnimation(avatar, "punch_01");
		registerAnimationCallback(this, avatar, "attack");
	end
end

function onAnimationEvent(a)
	local view = avatar:getView();
	local proj;
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		proj = avatarFireAtTarget(avatar, weapon, weapon_node, target, 90 - view:getFacingAngle());
	else
		proj = avatarFireAtPoint(avatar, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	end
	
	vine = createRope("sprites/placehold_vine.png", 20, 45);
	-- uv setUV(tip, root, segments to divide the middle uv) default 1.0, 0.0, 1 
	vine:setUV(0.7, 0.3, 1);
	-- setNoise(min distance, max distance) default 0, 0
	vine:setNoise(0, 10);
	-- setRetract(delay between vert culling, lower = more culled per update) default  0.0, 30
	vine:setRetract(0.0, 100);
	vine:setStartEntity(proj);
	vine:setEndEntity(avatar);
	vine:activate();
	
	proj:setCallback(this, 'onHit');
	playSound("shrubby_ability_FangStrike");
	startCooldown(avatar, abilityData.name);	
end

-- Projectile hits a target.
function onHit(proj)
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	local t = proj:getTarget();
	if canTarget(t) then
		local worldPos = avatar:getWorldPosition();
		local otherPos = t:getWorldPosition();
		local distance = getDistanceFromPoints(otherPos, worldPos);
		if distance > kbDistance then
			distance = kbDistance;
		else
			vine:setStartEntity(t);
		end
		local dir = getDirectionFromPoints(otherPos, worldPos);
		t:displaceDirection(dir, kbPower, distance);
		if not t:hasStat("Speed") then
			vine:setStartEntity(nil);
		end
		
		vine:setNoise(0, 0);
		vine:endRope();
		
		local aura = createAura(this, t, 0);
		aura:setTickParameters(1, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(t);
	else
		vine:endRope();
	end
end

function onTick(aura)
	if aura:getElapsed() < number_of_ticks then
		avatar = getPlayerAvatar();
		applyDamage(avatar, aura:getTarget(), damage_per_tick);
	else
		vine:setStartEntity(nil);
		aura:getOwner():detachAura(aura);
	end
end