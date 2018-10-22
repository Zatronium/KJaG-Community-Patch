require 'scripts/avatars/common'

local avatar = 0;
local targetPos = 0;
local weaponRange = 700;
function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_breath")
	registerAnimationCallback(this, avatar, "start")

	resetMouseCursor();
end

function onAnimationEvent (a)
	local target = getAbilityTarget(avatar, abilityData.name);
	if not target then
		target = getClosestAirTargetInRadius(targetPos, 200.0, EntityFlags(EntityType.Vehicle));
	end
	local view = a:getView();
	local proj;
	if target then
		proj = avatarFireAtTarget(a, "weapon_MissileGuided1", "breath_node", target, 90 - view:getFacingAngle());
	else
		proj = avatarFireAtPoint(a, "weapon_MissileGuided1", "breath_node", targetPos, 90 - view:getFacingAngle());
	end
	proj:setCallback(this, 'onHit')
	startCooldown(a, abilityData.name);
end

function onHit(proj)
	local pos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), pos);
	playSound("explosion");
end