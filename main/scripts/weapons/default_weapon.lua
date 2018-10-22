require 'scripts/common'

local g_numShots = 1;
local g_targetSceneOffset = 0; -- burst fire needs to targe same location, so location is chosen before weaponFire for everything

-- Entity control logic goes in here. Heartbeats happen every
-- 0.5 seconds, so we have to create an attack aura that ticks
-- faster so we can spam shots.
function onHeartbeat(w)
	if combatEnded() or not combatStarted() then
		return;
	end
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
				if not newTarget or math.random(10) > 5 then
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
			rof = rof + rof * owner:getStat("ROF_mult");
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
	local w = entityToWeapon(aura:getOwner());
	local t = w:getTarget();	
	local owner = getRootEntity(w);
	
	local weaponRange = w:getWeaponStat("Range");
	if owner:hasStat("range_amplify") then
		weaponRange = weaponRange * owner:getStat("range_amplify");
	end	
	local continueAttack = true;
	if not canTarget(t) or getDistance(owner, t) > weaponRange then
		continueAttack = false;
	end
	
	if not w:skipLOS() and not isLineOfSight(owner, t) then
		continueAttack = false;
	end
	if continueAttack then
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
		return Point(0,0); -- even if target is avatar, aim for the ground
	end

	local avatar = entityToAvatar(target);
	if avatar then
		local nodeName = 'contactzone0'..tostring(math.random(1, 5));		
		local nodeOffset = avatar:getView():getAnimationNodePositionOffset(nodeName);
		return nodeOffset;
	end

	return Point(0, 0);
end

function weaponFire(w, t, owner)
	if w:canFire() and canTarget(t) then
		local skip = false;
		-- Weapon Negated
		if owner and getEntityType(owner) == EntityType.Zone then
			local negateChance = t:getStat("NegateZoneAttack");
			if negateChance > math.random() then
				skip = true;
			end
		end
		
		if not skip then	
			local targetSceneOffset = g_targetSceneOffset;
			local isAvatar = t ~= nil and getEntityType(t) == EntityType.Avatar;
			local avatar = entityToAvatar(t);
			createMuzzleEffect(owner, t, w, targetSceneOffset, 0);
			local chance = 0;
		
			-- beam doesn't fire projectile
			if w:getWeaponType() == WeaponType.Beam then
				local hit = 0;
				if hit == 0 and t:hasStat("acc_notrack") then
					chance = t:getStat("acc_notrack");
					local roll = math.random (0,100);
					if roll > chance then
			--			hit = "miss";
						hit = 2;
					end
				end
				-- evade is 0 if none and 75 when active
				if hit == 0 and isAvatar then
					chance = avatar:getEvasion();
					local evaderoll = math.random (0,100);
					if evaderoll < chance then
			--			hit = "miss";
						hit = 2;
					end
				end
				if hit == 0 and t:hasStat("block_all") then
					chance = t:getStat("block_all");
					local roll = math.random (0,100);
					if roll > chance then
			--		hit = "block";
						hit = 3;
					end
				end
				if hit == 0 and t:hasStat("def_beam") then -- beam
					chance = t:getStat("def_beam");
					local roll = math.random (0,100);
					if roll > chance then
			--			hit = "deflect";
						hit = 1;
					end
				end
				fireBeam(owner, t, w, targetSceneOffset, 0.0, hit);
			else
				local proj = fireProjectile(owner, t, w, targetSceneOffset, 0.0);
				if w:hasMode("EXP") then
					proj:setCallback(this, 'onExplode');
				else
					proj:setCallback(this, 'onHit');
				end
				
				if w:getWeaponType() == WeaponType.Tracking and t:hasStat("PD_Tracking") then -- tracking
					local pdChance = t:getStat("PD_Tracking");
					local continue = true;
					if pdChance > 0 then
						local pdRoll = math.random(0, 100);
						if pdChance > pdRoll then
							proj:PDProjectile();
							continue = false;
						end
					end
				else
					if t:hasStat("acc_notrack") then
						chance = t:getStat("acc_notrack");
						local roll = math.random (0,100);
						if roll > chance then
							proj:miss();
						end
					end
					if isAvatar then
						chance = avatar:getEvasion();
						local evaderoll = math.random (0,100);
						if evaderoll < chance then
							proj:miss();
						end
					end
				end
				if t:hasStat("block_all") then
					local chance = t:getStat("block_all");
					local roll = math.random(0,100);
					if roll > chance then
						proj:blocked();
					end
				end
			end -- end beam / else		
		end -- end negate skip
	end -- safty check
end


function onBurst(aura)	
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
function onHit(proj, missed)
	local aura = proj:getAura("tracking");
	if aura then
		proj:detachAura(aura);
	end
	
	if not missed then
		local viewPos = proj:getView():getPosition();
		if proj:getWeapon() and proj:getWeapon():getWeaponType() == WeaponType.Direct then
			playSound("impact_50cal");
		else
			playSound("impact_missile");
		end
		createImpactEffect(proj:getWeapon(), viewPos);
	end
end

function onExplode(proj)
	local viewPos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), viewPos);
end