require 'scripts/avatars/common'
-- Global values.
local kaiju = 0;
local weapon = "Bolter1";

local weapon_node = "breath_node"

local target = nil;
local targetPos = nil;

local disableDuration = 5;

local empower = 0;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
		kaiju:setWorldFacing(facingAngle);	
		playAnimation(kaiju, "ability_breath");
		registerAnimationCallback(this, kaiju, "start");
		playSound("Bolter");
	end
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;
	target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) and not (getEntityType(target) == EntityType.Zone) then
		proj = avatarFireAtTarget(kaiju, weapon, weapon_node, target, 90 - view:getFacingAngle());
	else
		proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	end
	proj:setCallback(this, 'onHit');
	--playSound("shrubby_ability_FangStrike");
	startCooldown(kaiju, abilityData.name);	
	empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
end

-- Projectile hits a target.
function onHit(proj)
	kaiju = getPlayerAvatar();
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	local t = proj:getTarget();
	if canTarget(t) then
		t:disabled(disableDuration);
		abilityEnhance(empower);
		applyDamageWithWeapon(kaiju, t, weapon);
		abilityEnhance(0);
	end
end


