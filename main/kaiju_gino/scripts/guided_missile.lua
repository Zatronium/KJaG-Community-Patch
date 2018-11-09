require 'scripts/avatars/common'

local kaiju = nil
local targetPos = 0;
local weaponRange = 700;
function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_breath")
	registerAnimationCallback(this, kaiju, "start")

	resetMouseCursor();
end

function onAnimationEvent (a)
	local target = getAbilityTarget(kaiju, abilityData.name);
	local proj;
	local view = a:getView();
	if not target then
		target = getClosestAirTargetInRadius(targetPos, 200.0, EntityFlags(EntityType.Vehicle));
	end
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