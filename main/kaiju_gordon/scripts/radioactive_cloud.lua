require 'scripts/avatars/common'
local kaiju = nil;
local lastPos = nil;

local aoeRange = 600;
local patchDuration = 30;
local dotDamage = 4;
local dotDuration = 10;

function onUse(a)
	kaiju = a;
	startCooldown(kaiju, abilityData.name);
	local empower = kaiju:hasPassive("enhancement");
	kaiju:removePassive("enhancement", 0);
	dotDamage = dotDamage + dotDamage * empower;

	DotPatch(kaiju:getWorldPosition());
end



function DotPatch(pos) 
	local cloud = spawnEntity(EntityType.Minion, "unit_shrubby_patch", pos);
	setRole(cloud, "Player");
	cloud:attachEffect("effects/radioactiveCloud_core.plist", -1, true);
	cloud:attachEffect("effects/radioactiveCloud_wave.plist", -1, true);
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
		local targets = getTargetsInRadius(aura:getTarget():getWorldPosition(), aoeRange, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
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
					if t:hasAura("radioactive_cloud") then
						t:getAura("radioactive_cloud"):resetElapsed();
					else
						local aura = createAura(this, t, 0);
						aura:setTag("radioactive_cloud");
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
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	if elapsed > dotDuration or not canTarget(target) then
		target:detachAura(aura);
	else
		target:attachEffect("effects/radioactiveCloud.plist", 1, true);
		kaiju = getPlayerAvatar();
		applyDamage(kaiju, target, dotDamage);
	end
end