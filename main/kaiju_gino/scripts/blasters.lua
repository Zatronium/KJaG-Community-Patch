require 'scripts/common'
require 'scripts/avatars/common'

-- Global values.
local avatar = nil;
local targetPos = 0;
local targetEnt = nil;
local leftBlaster = false;
local shotsFire = 2;
local weaponRange = 600;

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_blasters");
	registerAnimationCallbackUntilEnd(this, avatar, "attack");		
	startCooldown(avatar, abilityData.name);
end

function onAnimationEvent(a)
	if shotsFire > 0 then
		shotsFire = shotsFire - 1;
		local node = "gun_node_01";
		local animcb = "attack";
		if leftBlaster then
			leftBlaster = false;
		else
			node = "gun_node_02";
			animcb = "attack_02";
			leftBlaster = true;
		end
		targetEnt = getAbilityTarget(avatar, abilityData.name);
		if targetEnt then
			targetPos = targetEnt:getWorldPosition();
		end
		local proj = avatarFireAtPoint(avatar, "weapon_Blaster1", node, targetPos, 0);
		proj:setCallback(this, 'onHit');
		proj:fromAvatar(true);
		playSound("blaster");
		registerAnimationCallbackUntilEnd(this, avatar, animcb);
	end
end

-- Projectile hits a target.
function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	createImpactEffect(proj:getWeapon(), scenePos);
end