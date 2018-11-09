require 'scripts/common'

------------------------------------------------------------
-- Defaults.
------------------------------------------------------------
function defaultSpawn(e)
	e:setStat('Energy', 100);
end

function defaultStatChanged(e, stat, prev, val)
	if stat == "Health" and prev > 0 then
		local maxHealth = e:getStat("MaxHealth");
		if val <= 0 then
			e:getView():doDeathEffect()
			print 'Kaiju Dead';
		elseif val > maxHealth then
			e:setStat("Health", maxHealth);
		end
	end
end

------------------------------------------------------------
-- Generic event handlers.
------------------------------------------------------------

function onSpawn(v)
	defaultSpawn(v);
end

function onHit(e, p, s)
end

function dotSetTargets(owner, targets, interval, duration, onAuraTick)
	for t in targets:iterator() do
		local aura = createAura(this, owner, 0);
		aura:setTickParameters(interval, duration);
		aura:setScriptCallback(AuraEvent.OnTick, onAuraTick);
		aura:setTarget(t);
	end
end

function dotOnTick(aura, minDamage, maxDamage, damageEffect, igniteOdds)
	if not aura then return end
	local target = aura:getTarget();
	local owner = aura:getOwner();
	if not target then
		if not owner then
			aura = nil return;
		else
			owner:detachAura(aura);
		end
		return
	else
		-- optional fire
		if igniteOdds then
			applyFire(owner, target, igniteOdds);
		end
		
		-- optional effect
		if damageEffect and getEntityType(target) ~= EntityType.Avatar then 
			local pos = target:getView():getPosition();
			createEffect(damageEffect, pos);
		end
		applyDamage(owner, target, math.random (minDamage,maxDamage));
	end
end

function NoTargetText(kaiju)
	createFloatingText(kaiju, "no targets in range", 255, 116, 25); --TODO LOCALIZATION
end

------------------------------------------------------------
-- Player event handlers.
------------------------------------------------------------

function playerStatChanged(e, stat, prev, val)
	if stat == "Health" then
		local maxHealth = e:getStat("MaxHealth");
		local doDeath = false;
		if prev > 0 then
			if val <= 0 then
				doDeath = true;
			elseif val > maxHealth then
					e:setStat("Health", maxHealth);
			end
		end
		
		if getEntityType(e) == EntityType.Avatar then
			local locAv = entityToAvatar(e);
			if locAv then
				if doDeath and locAv:hasPassive("goop_revive_timer") > 0 then
					doDeath = false;
					e:setStat("Health", 1);
					if locAv:hasPassive("goop_revive_active") <= 0 then
						locAv:setPassive("goop_revive_active", 1);
						local view = locAv:getView();
						view:attachEffectToNode("root", "effects/goop_cloudybits.plist", locAv:hasPassive("goop_revive_timer"), 0, 50, true, false);
					end
				elseif val <= 0 and locAv:hasPassive("goop_revive_active") > 0 and locAv:hasPassive("goop_revive_timer") <= 0 then
					doDeath = true;
				end
			end
		end
		
		if doDeath then
			e:getView():doDeathEffect()
			print 'Player Dead';
		end
	end
end