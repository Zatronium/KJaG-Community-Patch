require 'scripts/common'

-- Global values.
local kaiju = nil
local targetPos = 0;
local weaponRange = 1500;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	local proj = avatarFireAtPoint(kaiju, "weapon_mortar1", "breath_node", targetPos, 90);
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	playSound("starcannon");
	startCooldown(a, abilityData.name);	
end

function onHit(proj)
	local scenePos = proj:getView():getPosition();
	playSound("explosion");
	local weapon = proj:getWeapon();
	createImpactEffect(weapon, scenePos);
end