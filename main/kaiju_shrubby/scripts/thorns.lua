require 'scripts/avatars/common'
local kaiju = nil;
local centerPoint = nil;
local maxRange = 350;
local areaWidth = 150;
local currDist = 0;
local increment = 50;
local dotDamage = 5;
local duration = 8;

function onUse(a)
	kaiju = a;
	currDist = maxRange - areaWidth;
	centerPoint = kaiju:getWorldPosition();
	local targets = getTargetsInRadius(centerPoint, maxRange, EntityFlags(EntityType.Vehicle, EntityType.Avatar, EntityType.Zone));
	for t in targets:iterator() do
		if canTarget(t) and not isSameEntity(kaiju, t) then
			local isAir = false;
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				if veh:isAir() then
					isAir = true;
				end
			end
			if not isAir then
				local aura = createAura(this, t, 0);
				aura:setDebuff(false);
				aura:setTickParameters(1, 0);
				aura:setScriptCallback(AuraEvent.OnTick, "onDot");
				aura:setTarget(t);
			end
		end
	end
	
	local creepaura = createAura(this, kaiju, 0);
	creepaura:setTickParameters(1, 0);
	creepaura:setScriptCallback(AuraEvent.OnTick, "onTick");
	creepaura:setTarget(kaiju);
	playSound("shrubby_ability_Thorns");
	startCooldown(kaiju, abilityData.name);
end

function onTick(aura)
	currDist = currDist - increment;
	if currDist <= 0 then
		aura:getOwner():detachAura(aura);
	end
end
--
function onDot(aura)
	if not aura then return end
	local target = aura:getTarget()
	if aura:isDebuff() then
		if aura:getElapsed() > duration then
			target:setImmobile(false);
			
			local self = aura:getOwner()
			if not self then
				aura = nil return;
			else
				self:detachAura(aura);
			end
		else
			applyDamage(kaiju, target, dotDamage);
		end
	else
		local dist = getDistanceFromPoints(target:getWorldPosition(), centerPoint);
		if currDist <= 0 or dist > currDist then
			aura:setDebuff(true);
			target:setImmobile(true);
			target:attachEffect("effects/roots_thorns.plist", duration, true);
			target:attachEffect("effects/creeper_shrapnelLeft.plist", .1, true);
			target:attachEffect("effects/creeper_shrapnelRight.plist", .1, true);
			aura:resetElapsed();
		end
	end	
end
