require 'scripts/avatars/common'

local avatar = 0;
local weapon = "weapon_shrubby_stranglevine";
local weapon_node = "root"
local damage_per_tick = 6;
local number_of_ticks = 10; 
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
		playAnimation(avatar, "ability_project_1H");
	
		registerAnimationCallback(this, avatar, "start");
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
		
		playSound("shrubby_ability_StrangleVine");
		startCooldown(avatar, abilityData.name);	
	else
		NoTargetText(avatar);
	end
end


-- Projectile hits a target.
function onHit(proj)
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	local t = proj:getTarget();
	if canTarget(t) then	
		t:attachEffect("effects/stranglevine.plist", number_of_ticks, true);
		t:attachEffect("effects/strangleGlow.plist", number_of_ticks, true);
		t:setImmobile(true);
		local aura = createAura(this, t, 0);
		aura:setTickParameters(1, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(t);
	end
	vineEffect:endVine();
end

function onTick(aura)
	if aura:getElapsed() < number_of_ticks then
		applyDamage(getPlayerAvatar(), aura:getTarget(), damage_per_tick);
	else
		aura:getTarget():setImmobile(false);
		aura:getOwner():detachAura(aura);
	end
end