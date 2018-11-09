 -- damage 10 - 12
 -- dot 10
 -- aoe 150
 -- cold
 require 'scripts/avatars/common'
 require 'scripts/common'
local kaiju = nil;
 
local tickTime = 0.34;
local totalDuration = 10;
 
local disableTime = 5;
 
local minDamage = 10;
local maxDamage = 12;
 
local aoeRange = 150;
 
local timer = 1.0;
local damageTimer = 1.0;
function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "channel");
	local view = a:getView();
	view:attachEffectToNode("root", "effects/iceStorm_cloud.plist", totalDuration, 0, 150, true, false);
	view:attachEffectToNode("root", "effects/iceStorm_cloudStorm.plist", totalDuration, 0, 400, true, false);
	abilityEnabled(a, abilityData.name, false);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(tickTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	playSound("ice-storm");
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
		local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
		for t in targets:iterator() do
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				veh:disabled(disableTime);
			end
			t:attachEffect("effects/onFreeze.plist", disableTime, true);
			applyDamage(kaiju, t, math.random(minDamage, maxDamage));	
		end
	end
	
	local targetPos = worldPos;
	targetPos.x = worldPos.x + math.random(-aoeRange, aoeRange);
	targetPos.y = worldPos.y + math.random(-aoeRange, aoeRange);
	local firePos = Point(targetPos.x + 300, targetPos.y + 300);

	local proj = fireProjectileAtPoint(kaiju, firePos, targetPos, "weapon_iceShard");
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
