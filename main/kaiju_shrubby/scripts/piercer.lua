require 'scripts/avatars/common'

-- Global values.
local avatar = 0;
local weapon = "weapon_shrubby_vine2";
local weapon_node = "root"
local target = nil;
local targetPos = nil;

local vineEffect = nil;
function setupNewVine(vine)
	if not vine then
		vine = createVine("effects/vine.plist");
	else
		vine = vine:createNextVine(true);
	end
	vine:setOscillation(77);
	vine:setOscillationWidth(30);
	vine:setMaxLength(1000);
	vine:setVineWidth(15);
	vine:setSpeed(10);
	vine:setTailLength(10);
	return vine;
end

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
	target = getAbilityTarget(avatar, abilityData.name);
	if canTarget(target) then
		local proj = avatarFireAtTarget(avatar, weapon, weapon_node, target, 90 - view:getFacingAngle());
		proj:setCallback(this, 'onHit');
	
		vineEffect = setupNewVine(vineEffect);
		vineEffect:setStartEntity(proj);
		vineEffect:setEndPoint(proj:getWorldPosition());
		vineEffect:activate();
		
		playSound("shrubby_ability_Piercer");
		startCooldown(avatar, abilityData.name);	
	else
		NoTargetText(avatar);
	end
end

function onHit(proj)
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	
	vineEffect:endVine();
end