require 'scripts/avatars/common'
local kaiju = nil;
local lastPos = nil;

local distancePatch = 25;
local deadDistance = distancePatch * 4;
local durationTime = 5;

local patchDuration = 5;
local dotDamage = 5;

local stunDuration = 0;
local elecInfantryDamage = 0;

function onSet(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = dotDamage * multiplier;
	kaiju:addPassiveScript(this);
end

function onAvatarMove(a)
	local worldPos = a:getWorldPosition();
	kaiju = a;
	if not lastPos then
		lastPos = worldPos;
		return;
	end
	local dist = getDistanceFromPoints(lastPos, worldPos);
	if dist >= deadDistance then
		lastPos = worldPos;
	elseif dist > distancePatch then
		DotPatch(lastPos);
		lastPos = worldPos;
	end
end

function DotPatch(pos) 
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", pos);
--	setRole(cloud, "Player");
	if kaiju:hasPassive("goop_electro_stun") > 0 then
		stunDuration = kaiju:hasPassive("goop_electro_stun");
		elecInfantryDamage = kaiju:hasPassive("goop_electro_infantry_damage");
		cloud:attachEffect("effects/goop_electro.plist", -1, true);
		cloud:attachEffect("effects/goop_electro2.plist", -1, true);
	else
		cloud:attachEffect("effects/goop_corrosive.plist", -1, true);
		cloud:attachEffect("effects/goop_bubbling.plist", -1, true);
	end
	cloud:setImmobile(true);
	local aura = createAura(this, cloud, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onPatchTick");
	aura:setTarget(cloud);
end

function onPatchTick(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	if elapsed > patchDuration then
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
			removeEntity(owner);
		end
	else
		local targets = getTargetsInRadius(aura:getTarget():getWorldPosition(), distancePatch, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(kaiju, t) then
				local airUnit = false;
				local damage = dotDamage;
				if getEntityType(t) == EntityType.Vehicle then	
					local veh = entityToVehicle(t);
					if veh:isAir() then
						airUnit = true;
					elseif veh:isVehicleType(VehicleType.Infantry) then
						damage = damage + elecInfantryDamage;
					end
				end
				if not airUnit then
					if stunDuration > 0 and not t:hasAura("goop_electro_stun") then			
						local aura = createAura(this, t, 0);
						aura:setTag("goop_electro_stun");
						aura:setTickParameters(10, 10);
						aura:setTarget(t);
						
						t:disabled(stunDuration);
					end					
					applyDamage(kaiju, t, damage);
				end
			end
		end
	end
end