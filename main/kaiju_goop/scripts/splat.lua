require 'scripts/avatars/common'

kaiju = nil;
weapon = "goop_Goop";
dotTime = 3;
dotDamage = 3;
aoeRange1 = 100;
aoeRange2 = 150;
aoeRange3 = 200;

scriptAura = nil;
targetPos = nil;

function onUse(a)
	kaiju = a;	
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weapon) * multiplier;
	playAnimation(kaiju, "ability_splatslam");
	
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a, event)
	kaiju = a;
	
	local view = a:getView();
	targetPos = kaiju:getWorldPosition();
	local splat = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/stompBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/stompFront.plist",0, 0, 0, true, false);
	
	scriptAura = Aura.create(this, splat);
	scriptAura:setTag("goop_splat");
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(1, 0);
	scriptAura:setTarget(splat); -- required so aura doesn't autorelease
			
	playSound("goop_ability_Splat"); -- SOUND
	startCooldown(kaiju, abilityData.name);	
end

function onTick(aura)

	if aura:getElapsed() >= dotTime then
		local owner = aura:getOwner();
		owner:detachAura(aura);
		removeEntity(owner);
		return;
	end
	targetPos = aura:getOwner():getWorldPosition();
	createEffect("effects/stompBack.plist", targetPos);
	local targets = getTargetsInRadius(targetPos, aoeRange3, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		local flying = false;
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			flying = veh:isAir();
		end
		if flying == false then
			local dist = getDistanceFromPoints(targetPos, t:getWorldPosition());
			local damage = dotDamage;
			if dist <= aoeRange1 then
				damage = damage + dotDamage;
			end
			if dist <= aoeRange2 then
				damage = damage + dotDamage;
			end
			applyDamageWithWeaponDamage(kaiju, t, weapon, damage);
		end
	end
	
	createEffectInWorld("effects/goopball_detonate1.plist", targetPos, 0);
	createEffectInWorld("effects/goopball_detonate2.plist", targetPos, 0);
	createEffectInWorld("effects/goopball_detonate3.plist", targetPos, 0);
end