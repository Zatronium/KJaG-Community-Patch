require 'scripts/avatars/common'
require 'scripts/common'
local kaiju = nil;
 
local tickTime = 0.34;
local totalDuration = 10;
 
local minDamage = 13;
local maxDamage = 18;
 
local aoeRange = 120;

local timer = 1.0;
local damageTimer = 1.0;
function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_channel");
	abilityEnabled(a, abilityData.name, false);
	local aura = createAura(this, kaiju, "gino_firestorm");
	aura:setTickParameters(tickTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	timer = 0;
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then
		return
	end
	timer = timer + tickTime;
	local worldPos = kaiju:getWorldPosition();
	if timer >= damageTimer then
		timer = 0;
		local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar))
		for t in targets:iterator() do
			if t then
				applyFire(kaiju, t, 1.0);
				applyDamage(kaiju, t, math.random(minDamage, maxDamage));
			end
		end
	end
	local targetPos = worldPos;
	targetPos.x = worldPos.x + math.random(-aoeRange, aoeRange);
	targetPos.y = worldPos.y + math.random(-aoeRange, aoeRange);
	local firePos = Point(targetPos.x + 300, targetPos.y + 300);

	local proj = fireProjectileAtPoint(kaiju, firePos, targetPos, "weapon_fireShard");
	proj:setCollisionEnabled(false);
	
	if aura:getElapsed() >= totalDuration then
		abilityEnabled(kaiju, abilityData.name, true);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
