require 'scripts/avatars/common'
local kaiju = nil;
local lastPos = nil;

local distancePatch = 50;
local durationTime = 10;

local patchDuration = 10;
local dotDamage = 2;
local dotDuration = 10;

function onUse(a)
	kaiju = a;
	kaiju:addPassiveScript(this);
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(durationTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTimeTick");
	aura:setTarget(kaiju);
end

function onTimeTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationTime then
		kaiju:removePassiveScript(this);
		endAbilityUse(kaiju, abilityData.name);
		local self = aura:getOwner()
		if not self then
			aura = nil return
		else
			self:detachAura(aura)
		end
	end
end

function onAvatarMove(a)
	local worldPos = kaiju:getWorldPosition();
	if not lastPos then
		lastPos = worldPos;
	end
	local dist = getDistanceFromPoints(lastPos, worldPos);
	if dist > distancePatch then
		DotPatch(lastPos);
		lastPos = worldPos;
	end
end



function DotPatch(pos) 
	local cloud = spawnEntity(EntityType.Minion, "unit_shrubby_patch", pos);
	setRole(cloud, "Player");
	cloud:attachEffect("effects/reactorLeak.plist", -1, true);
	cloud:setImmobile(true);
	local aura = createAura(this, cloud, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onPatchTick");
	aura:setTarget(cloud);
end

function onPatchTick(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	if elapsed > patchDuration then
		target:detachAura(aura);
		removeEntity(target);
	else
		local targets = getTargetsInRadius(target:getWorldPosition(), distancePatch, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(kaiju, t) then
				local airUnit = false;
				if getEntityType(t) == EntityType.Vehicle then	
					local veh = entityToVehicle(t);
					if veh:isAir() == true then
						airUnit = true;
					end
				end
				if not airUnit then
					if t:hasAura("reactor_leak") then
						t:getAura("reactor_leak"):resetElapsed();
					else
						local aura = createAura(this, t, 0);
						aura:setTag("reactor_leak");
						aura:setTickParameters(1, 0);
						aura:setScriptCallback(AuraEvent.OnTick, "onDotTick");
						aura:setTarget(t);
					end
				end
			end
		end
	end
end

function onDotTick(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	local self = aura:getOwner()
	if elapsed > dotDuration or not canTarget(target) then
		if not self then
			aura = nil return
		else
			self:detachAura(aura);
		end
	else
		applyDamage(kaiju, target, dotDamage);
	end
end