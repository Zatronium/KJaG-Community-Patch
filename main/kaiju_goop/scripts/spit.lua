require 'kaiju_goop/scripts/goop'
-- Global values.
kaiju = 0;
weapon = "goop_Spit";
weaponDamage = "goop_Goop"
weapon_node = "eyeball"

targetPos = nil;
hasDamage = false;

dotTime = 5;
dotDamage = 3;

minGoop = 15;
maxGoop = 20;

function onUse(a)
	kaiju = a;
	hasDamage = false;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	target = getAbilityTarget(kaiju, abilityData.name);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_roar");
	registerAnimationCallback(this, kaiju, "start");
	playSound("goop_ability_Spit"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	proj:setCollisionEnabled(false);
	proj:setCallback(this, 'onHit');
	startCooldown(kaiju, abilityData.name);	
end

-- Projectile hits a target.
function onHit(proj)
	targetPos = proj:getWorldPosition();
	
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);
	cloud:attachEffect("effects/goopball_splort.plist", 0, true);
	cloud:attachEffect("effects/goopball_splortsplash.plist", -1, true);

		createEffectInWorld("effects/goopball_detonate1.plist", targetPos, 0);
		createEffectInWorld("effects/goopball_detonate2.plist", targetPos, 0);
		createEffectInWorld("effects/goopball_detonate3.plist", targetPos, 0);
	
	local scriptAura = Aura.create(this, cloud);
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(1, 0);
	scriptAura:setStat("Health", 1);
	scriptAura:setTarget(cloud); -- required so aura doesn't autorelease	
	
	playSound("goop_ability_common_goopsplosion"); -- SOUND
end

function onTick(aura)
	if aura:getElapsed() < dotTime then
		kaiju = getPlayerAvatar();
		local targets = getTargetsInRadius(targetPos, getWeaponRange(weaponDamage), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		local playeffect = 5;
		for t in targets:iterator() do
			if not isSameEntity(kaiju, t) then
				local flying = false;
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t);
					flying = veh:isAir();
				end
				if flying == false then
					t:attachEffect("effects/goop_dissolve.plist", 1, true);
					if playeffect > 0 then
						createEffectInWorld("effects/goop_infusion.plist", t:getWorldPosition(), 0);
						playeffect = playeffect - 1;
					end
					applyDamageWithWeaponDamage(kaiju, t, weaponDamage, dotDamage);
					aura:setStat("Health", 2);
				end
			end
		end
		
	else
		local own = aura:getOwner();
		if aura:getStat("Health") > 1 then
			CreateBlob(own:getWorldPosition(), minGoop, maxGoop);
		end
		own:detachAura(aura);
		removeEntity(own);
	end
end
