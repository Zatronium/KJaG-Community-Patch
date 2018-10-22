require 'scripts/avatars/common'
local avatar = nil;
local lastPos = nil;

local distancePatch = 50;
local durationTime = 10;

local patchDuration = 10;
local dotDamage = 2;
local dotDuration = 10;

function onUse(a)
	avatar = a;
	avatar:addPassiveScript(this);
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(durationTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTimeTick");
	aura:setTarget(avatar);
end

function onTimeTick(aura)
	if aura:getElapsed() >= durationTime then
		avatar:removePassiveScript(this);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

function onAvatarMove(a)
	local worldPos = avatar:getWorldPosition();
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
	local elapsed = aura:getElapsed();
	if elapsed > patchDuration then
		local target = aura:getTarget();
		target:detachAura(aura);
		removeEntity(target);
	else
		local targets = getTargetsInRadius(aura:getTarget():getWorldPosition(), distancePatch, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(avatar, t) then
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
	avatar = getPlayerAvatar();
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	if elapsed > dotDuration or not canTarget(target) then
		target:detachAura(aura);
	else
		applyDamage(avatar, target, dotDamage);
	end
end