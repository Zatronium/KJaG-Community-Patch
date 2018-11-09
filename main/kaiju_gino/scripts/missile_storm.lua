require 'scripts/common'

-- Global values.
local kaiju = nil
local targetPos = 0;
local distance = 1;
local weaponRange = 600;
local weaponInterval = 0.1;
local burst = 7;
local deviation = 100; 

local durationtime = 0;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	local worldPos = kaiju:getWorldPosition();
	distance = getDistanceFromPoints(worldPos, targetPos) / weaponRange;
	local facingAngle = getFacingAngle(worldPos, targetPos);
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_breath");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	local furyAura = Aura.create(this, a);
	furyAura:setTag('missile_storm');
	durationtime = weaponInterval * (burst - 1);
	furyAura:setTickParameters(weaponInterval, 0);
	furyAura:setScriptCallback(AuraEvent.OnTick, 'onTick');	
	furyAura:setTarget(a); -- required so aura doesn't autorelease
	startAbilityUse(kaiju, abilityData.name);
	playSound("missilestorm");
end

function onTick(aura)
	if not aura then
		return
	end
	local targetEnt = getAbilityTarget(kaiju, abilityData.name);
	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	local offset = deviation * distance;
	local locPos = targetPos;
	locPos["x"] = targetPos["x"] + math.random(-offset, offset);
	locPos["y"] = targetPos["y"] + math.random(-offset, offset);
	local proj = avatarFireAtPoint(kaiju, "weapon_DumbFire1", "breath_node", locPos, 0);
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

-- Projectile hits a target.
function onHit(proj)
	playSound("explosion");
end