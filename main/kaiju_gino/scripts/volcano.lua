require 'scripts/common'

local avatar = 0;
local targetPos = 0;
local weaponRange = 800;

local durationLow 		= 10
local durationHigh		= 15
local duration 			= 0
local ticktimeLow		= 0.2
local ticktimeHigh		= 0.4
local ticktime			= 0
local fireballRangeLow	= 400
local fireballRangeHigh	= 700
local fireballRange 	= 0
local offset 			= 0

function onUse(a)
	avatar = a;
	enableTargetSelection(this, abilityData.name, 'onTarget', weaponRange);
end

-- Target selection is complete.
function onTarget(position)
	targetPos = position;
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), targetPos);
	avatar:setWorldFacing(facingAngle);	
	playAnimation(avatar, "ability_launch");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local proj = avatarFireAtPoint(avatar, "weapon_VolcanoShell", "gun_node_03", targetPos, 0);
	proj:setCollisionEnabled(false);
	proj:setCallback(this, 'onShellHit');
	playSound("volcano");
	startAbilityUse(avatar, abilityData.name);
end

function onShellHit(proj)
	fireballRange = math.random(fireballRangeLow, fireballRangeHigh)
	offset = math.floor(fireballRange / 3)
	duration = math.random(durationLow, durationHigh)
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	
	targetPos = proj:getWorldPosition();
	local volcano = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);
	
	local volcanoAura = Aura.create(this, volcano);
	volcanoAura:setTag('volcano');
	volcanoAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	ticktime = RandomFloat(ticktimeLow, ticktimeHigh, 100)
	volcanoAura:setTickParameters(ticktime, 0);
	volcanoAura:setTarget(volcano); -- required so aura doesn't autorelease
	playSound("explosion");
	createEffectInWorld("effects/volcano.plist", targetPos, duration);
	createEffectInWorld("effects/volcanoFade.plist", targetPos, duration);
	createEffectInWorld("effects/booster.plist", targetPos, duration);
end

function RandomFloat(v1, v2, divisor)
	return math.random(v1 * divisor, v2 * divisor) / divisor
end

function onTick(aura)
	local self = aura:getOwner();
	if not self then
		aura:setScriptCallback(AuraEvent.OnTick, nil)
		return
	end
	local firePos = offsetRandomDirection(targetPos, offset, fireballRange);
	local proj = fireProjectileAtPoint(getPlayerAvatar(), targetPos, firePos, "weapon_FireBall");
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	playSound("incoming");
	if aura:getElapsed() >= duration then
		endAbilityUse(getPlayerAvatar(), abilityData.name);
		self:detachAura(aura);
		removeEntity(self);
	end
end

function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();
	local weapon = proj:getWeapon();
	
	createImpactEffect(proj:getWeapon(), scenePos);
end