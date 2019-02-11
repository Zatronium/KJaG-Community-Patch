require 'scripts/common'

local g_numShots = 1;
local g_firstpass = 0;
g_targetSceneOffset = 0; -- burst fire needs to targe same location, so location is chosen before weaponFire for everything

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.
function onHeartbeat(w)
	t = w:getTarget();
	owner = getRootEntity(w);
	
	local weaponRange = w:getWeaponStat("Range");
	if owner:hasStat("range_amplify") then
			weaponRange = weaponRange * owner:getStat("range_amplify");
	end
	
	-- Check if we are blinded
	if owner:hasAura("BLIND") then
		local aimRange = weaponRange;
		local aimTargets = getTargetsInRadius(owner:getWorldPosition(), aimRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar, EntityType.Minion));
		local newTarget = nil;
		for aimt in aimTargets:iterator() do
			if not isSameEntity(owner, aimt) and isLineOfSight(owner, aimt) then
				if newTarget or math.random(10) > 5 then
					newTarget = aimt;
				end
			end
		end
		t = newTarget;
		w:setTarget(t);
	end
		
	-- Check to see if we have an attack aura.
	local attackAura = w:getAura('attack');
	if not attackAura and t and t:getStat("Health") > 0 then
		if getDistance(owner, t) < weaponRange and isLineOfSight(owner, t) then
			-- Avatar in range and LoS, stop movement and create attack aura.
			local rof = w:getWeaponStat("ROF");
			if rof > 1 then
				rof = rof + randomFloat(-(rof * 0.1), (rof * 0.1));
			end

			attackAura = Aura.create(this, w);
			attackAura:setTag('attack');
			attackAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
			attackAura:setTickParameters(rof, 0);
			attackAura:setTarget(w); -- required so aura doesn't autorelease
		end
	end
end

-- Callback from attackAura tick.
-- Verifies line of sight and distance and then fires a projectile.
-- If we can't fire then it removes the aura.
function onTick(aura)
	if not aura then return end
	local w = entityToWeapon(aura:getOwner());
	local t = w:getTarget();	
	local owner = getRootEntity(w);
	
	local weaponRange = w:getWeaponStat("Range");
	if owner:hasStat("range_amplify") then
			weaponRange = weaponRange * owner:getStat("range_amplify");
	end
	
	if t and t:getStat("Health") > 0 and getDistance(owner, t) <= weaponRange and isLineOfSight(owner, t) then
		if not w:getAura('burst') then
			--do i need to create another "burst" aura
			g_numShots = 1;
			g_targetSceneOffset = calcTargetSceneOffset(w, t);
			if w:hasMode("BURST") then
				g_numShots = w:getModeX("BURST");
				attackAura = Aura.create(this, w);
				attackAura:setTag('burst');
				attackAura:setScriptCallback(AuraEvent.OnTick, 'onBurst');
				attackAura:setTickParameters(w:getModeY("BURST"), 0);
				attackAura:setTarget(w); -- required so aura doesn't autorelease
			else
				weaponFire(w, t, owner);	
			end
		end
	else
		-- Remove aura if we're not in LoS/range.
		w:detachAura(aura);
	end
end

function calcTargetSceneOffset(weapon, target)
	if weapon:getWeaponType() == WeaponType.Bomb then
		return Point(0,0); -- even if target is kaiju, aim for the ground
	end

	local kaiju = entityToAvatar(target);
	if kaiju then
		local nodeName = 'contactzone0'..tostring(math.random(1, 5));		
		local nodeOffset = kaiju:getView():getAnimationNodePositionOffset(nodeName);
		return nodeOffset;
	end

	return Point(0, 0);
end

function weaponFire(w, t, owner)
	if w:canFire() and t then
		local targetSceneOffset = g_targetSceneOffset;
		local isAvatar = t ~= nil and getEntityType(t) == EntityType.Avatar;
		local kaiju = entityToAvatar(t);
		createMuzzleEffect(owner, t, w, targetSceneOffset, 0);
		local chance = 0;
	
		-- beam doesn't fire projectile
		if w:getWeaponType() == WeaponType.Beam then
			local hit = 0;
			fireBeam(owner, t, w, targetSceneOffset, 0.0, hit);
		else
			local proj = fireProjectile(owner, t, w, targetSceneOffset, 0.0);
			if w:hasMode("EXP") then
				proj:setCallback(this, 'onExplode');
			else
				proj:setCallback(this, 'onHit');
			end
		end
		
	end
end


function onBurst(aura)	
	if not aura then return end
	local w = entityToWeapon(aura:getOwner());
	if g_numShots <= 0 then
		w:detachAura(aura);
	else
		local t = w:getTarget();	
		local owner = getRootEntity(w);
		weaponFire(w, t, owner);
		g_numShots = g_numShots - 1;
	
		if g_numShots <= 0 then
			w:detachAura(aura);
		end	
	end
end

-- Projectile hits a target.
-- heal cannot miss?
function onHit(proj, missed)
	local aura = proj:getAura("tracking");
	if aura then
		proj:detachAura(aura);
	end
	local viewPos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), viewPos);	
end

function onExplode(proj)
--	local worldPos = proj:getWorldPosition();
	local viewPos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), viewPos);
--	local weapon = proj:getWeapon(); 
--	local range = weapon:getModeX("EXP");
--	local center = range * 0.25;
--	local minDamage = weapon:getWeaponStat("MinDamage");
--	local damageDiff = weapon:getWeaponStat("MaxDamage") - minDamage;
--	local targets = getTargetsInRadius(worldPos, range, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
--	for t in targets:iterator() do
--		local distance = getDistance(proj, t);
--		local scale = 1.0 - math.min(math.max(distance - center, 0.0) / (range - center), 1.0);  
--		applyDamage(proj:getOwner(), t, minDamage + (damageDiff * scale));
--	end
end