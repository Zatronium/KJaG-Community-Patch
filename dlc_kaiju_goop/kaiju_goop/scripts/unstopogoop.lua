require 'kaiju_goop/scripts/goop'
-- Global values.
kaiju = 0;
weapon = "goop_Unstoppable";
weaponDamage = "goop_Goop"
weapon_node = "eyeball"

targetPos = nil;
hasDamage = false;

aoe = 75;
dotTime = 3;
dotDamage = 50;

direction = nil;
minDist = 100;
maxDist = 300;

chanceRepeat = 100;
chanceDecay = 20;

minGoop = 50;
maxGoop = 100;

function onUse(a)
	kaiju = a;
	hasDamage = false;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = dotDamage * multiplier;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	targetPos = position;
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_roar");
	registerAnimationCallback(this, kaiju, "start");
	playSound("goop_ability_UnstopoGoop"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	local proj;
	local target = getAbilityTarget(kaiju, abilityData.name);
	if canTarget(target) then
		targetPos = target:getWorldPosition();
	end
	direction = getDirectionFromPoints(kaiju:getWorldPosition(), targetPos);
	proj = avatarFireAtPoint(kaiju, weapon, weapon_node, targetPos, 90 - view:getFacingAngle());
	proj:setCollisionEnabled(false);
	proj:setCallback(this, 'onHit');
	startCooldown(kaiju, abilityData.name);	
end

-- Projectile hits a target.
function onHit(proj)
	playSound("goop_ability_common_goopsplosion"); -- SOUND
	targetPos = proj:getWorldPosition();
	
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);
	cloud:attachEffect("effects/goop_bubbling.plist", -1, true);
	cloud:attachEffect("effects/goop_cloud.plist", -1, true);
	cloud:attachEffect("effects/goop_cloudybits.plist", -1, true);
	


	local scriptAura = Aura.create(this, cloud);
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(1, 0);
	scriptAura:setStat("Health", 1);
	scriptAura:setTarget(cloud); -- required so aura doesn't autorelease	
	
	if chanceRepeat > math.random(0, 100) then
		local newtarget = getBeamEndWithDir(targetPos, math.random(minDist, maxDist), direction);
		local newproj = fireProjectileAtPoint(kaiju, targetPos, newtarget, weapon);
		newproj:setCollisionEnabled(false);
		newproj:setCallback(this, 'onHit');
		chanceRepeat = chanceRepeat - chanceDecay;
	end
	
	createEffectInWorld("effects/goopball_detonate1.plist", targetPos, 0);
	createEffectInWorld("effects/goopball_detonate2.plist", targetPos, 0);
	createEffectInWorld("effects/goopball_detonate3.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slam.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slam2.plist", targetPos, 0);
end

function onTick(aura)
	if aura:getElapsed() < dotTime then
		kaiju = getPlayerAvatar();
		local targets = getTargetsInRadius(aura:getOwner():getWorldPosition(), aoe, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			if not isSameEntity(kaiju, t) then
				local flying = false;
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t);
					flying = veh:isAir();
				end
				if flying == false then
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
