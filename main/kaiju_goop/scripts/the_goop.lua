require 'scripts/avatars/common'

kaiju = nil;
weapon = "goop_Goop";
dotTime = 5;
dotDamage = 3;

playeffect = 5;

scriptAura = nil;
targetPos = nil;

function onUse(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weapon) * multiplier;
	playAnimation(kaiju, "ability_bodyslam");
	
	registerAnimationCallback(this, kaiju, "attack");
end 

function onAnimationEvent(a, event)
	kaiju = a;
	targetPos = kaiju:getWorldPosition();
	
	local cloud = spawnEntity(EntityType.Minion, 'unit_goop_patch', targetPos);
		
	scriptAura = Aura.create(this, cloud);
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(1, 0);
	scriptAura:setTarget(cloud); -- required so aura doesn't autorelease
			
	playSound("goop_ability_TheGoop"); -- SOUND
	startCooldown(kaiju, abilityData.name);	
	
	createEffectInWorld("effects/goopball_detonate1.plist", targetPos, 0);
	createEffectInWorld("effects/goopball_detonate2.plist", targetPos, 0);
	createEffectInWorld("effects/goopball_detonate3.plist", targetPos, 0);
end

function onTick(aura)
	if aura:getElapsed() > dotTime then	
		local own = aura:getOwner();
		own:detachAura(aura);
		removeEntity(own);
	else
		local targets = getTargetsInRadius(targetPos, getWeaponRange(weapon), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			if not isSameEntity(kaiju, t) then
				local flying = false;
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t);
					flying = veh:isAir();
				end
				if flying == false then
					t:attachEffect("effects/goop_dissolve.plist", 1, true);
					--t:attachEffect("effects/goop_infusion.plist", 1, true);
					if playeffect > 0 then
						createEffectInWorld("effects/goop_infusion.plist", t:getWorldPosition(), 0);
						playeffect = playeffect - 1;
					end
					applyDamageWithWeaponDamage(getPlayerAvatar(), t, weapon, dotDamage);
				end
			end
		end
	end
end