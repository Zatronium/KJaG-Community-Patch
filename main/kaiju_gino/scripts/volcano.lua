require 'scripts/common'

local kaiju = nil
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
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTarget', weaponRange);
end

-- Target selection is complete.
function onTarget(position)
	targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_launch");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local proj = avatarFireAtPoint(kaiju, "weapon_VolcanoShell", "gun_node_03", targetPos, 0);
	proj:setCollisionEnabled(false);
	proj:setCallback(this, 'onShellHit');
	playSound("volcano");
	startAbilityUse(kaiju, abilityData.name);
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
	local firePos = offsetRandomDirection(targetPos, offset, fireballRange);
	local proj = fireProjectileAtPoint(kaiju, targetPos, firePos, "weapon_FireBall");
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	playSound("incoming");
	if aura:getElapsed() >= duration then
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
			removeEntity(self);
		end
	end
end

function onHit(proj)
	local scenePos = proj:getView():getPosition();
	local weapon = proj:getWeapon();
	
	createImpactEffect(weapon, scenePos);
end