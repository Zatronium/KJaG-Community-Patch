require 'scripts/common'

-- Global values.
local avatar = 0;
local target = 0;
local targetPos = 0;
local distance = 1;
local weaponRange = 600;
local weaponInterval = 0.1;
local burst = 7;
local deviation = 100; 
local explodeRadius = 50;

local durationtime = 0;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	local worldPos = avatar:getWorldPosition();
	distance = getDistanceFromPoints(worldPos, targetPos) / weaponRange;
	local facingAngle = getFacingAngle(worldPos, targetPos);
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_breath");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	furyAura = Aura.create(this, a);
	furyAura:setTag('missile_storm');
	durationtime = weaponInterval * (burst - 1);
	furyAura:setTickParameters(weaponInterval, 0);
	furyAura:setScriptCallback(AuraEvent.OnTick, 'onTick');	
	furyAura:setTarget(a); -- required so aura doesn't autorelease
	startAbilityUse(avatar, abilityData.name);
	playSound("missilestorm");
end

function onTick(aura)
	local targetEnt = getAbilityTarget(avatar, abilityData.name);
	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	local offset = deviation * distance;
	local locPos = targetPos;
	locPos["x"] = targetPos["x"] + math.random(-offset, offset);
	locPos["y"] = targetPos["y"] + math.random(-offset, offset);
	local proj = avatarFireAtPoint(avatar, "weapon_DumbFire1", "breath_node", locPos, 0);
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		avatar:detachAura(aura);
	end
end

-- Projectile hits a target.
function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	playSound("explosion");
end