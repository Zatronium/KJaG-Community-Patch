require 'scripts/common'

-- Global values.
local kaiju = nil
local targetPos = 0;
local weaponRange = 500;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
end

-- Animation event 'breath_start'.
function onAnimationEvent(a)
	local target = getAbilityTarget(kaiju, abilityData.name);
	if target then
		targetPos = target:getWorldPosition();
	end
	local proj = avatarFireAtPoint(kaiju, "weapon_FireBall", "breath_node", targetPos, 0);
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	playSound("fireball");
	startCooldown(kaiju, abilityData.name);
	
end

-- Projectile hits a target.
function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	playSound("explosion");
	createImpactEffect(proj:getWeapon(), scenePos);
end