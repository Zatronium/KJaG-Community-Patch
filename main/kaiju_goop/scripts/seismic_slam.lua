require 'scripts/avatars/common'

kaiju = nil;
targetPos = nil;
aoeRange = 300;

avatarDisable = 1.5;
vehicleSlow = 0.5;
vehicleSlowDuration = 5;

attackChance = 100;
attackDecay = 20;
quakeDelay = 5;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_bodyslam");
	registerAnimationCallback(this, kaiju, "attack");
	
	playSound("goop_ability_SeismicSlam"); -- SOUND
	startAbilityUse(kaiju, abilityData.name);
end 

function onAnimationEvent(a, event)
	kaiju = a;
	targetPos = kaiju:getWorldPosition();

	local view = kaiju:getView();
--	view:attachEffectToNode("root", "effects/goop_slam.plist", 0.1, 0, 0, false, true);
--	view:attachEffectToNode("root", "effects/goop_slam2.plist",0.1, 0, 0, true, false);
--	view:attachEffectToNode("root", "effects/goop_slamsplash1.plist",0.1, 0, 0, true, false);
--	view:attachEffectToNode("root", "effects/goop_slamsplash2.plist",0.1, 0, 0, true, false);

--	createEffectInWorld("effects/goop_slam.plist", targetPos, 0);
--	createEffectInWorld("effects/goop_slam2.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash1.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash2.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash3.plist", targetPos, 0);
	createEffectInWorld("effects/seismicslam_shockwave.plist", targetPos, 0);
	createEffectInWorld("effects/seismicslam_shockwave2.plist", targetPos, 0);
	
	view:togglePauseAnimation(true);
	kaiju:setImmobile(true);
	kaiju:loseControl();
		
	local stunAura = Aura.create(this, kaiju);
	stunAura:setScriptCallback(AuraEvent.OnTick, 'onStunAura');
	stunAura:setTickParameters(avatarDisable, 0);
	stunAura:setTarget(kaiju); -- required so aura doesn't autorelease
	
	local patch = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);
	local dotAura = Aura.create(this, patch);
	dotAura:setScriptCallback(AuraEvent.OnTick, 'onRelapseAura');
	dotAura:setTickParameters(quakeDelay, 0);
	dotAura:setStat("MaxHealth", 1);
	dotAura:setTarget(patch); -- required so aura doesn't autorelease	
end

function onRelapseAura(aura)
	kaiju = getPlayerAvatar();
	local targets = getTargetsInRadius(targetPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		if not isSameEntity(kaiju, t) then
			local flying = false;
			local entType = getEntityType(t);
			if entType == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				flying = veh:isAir();
			end
			if entType == EntityType.Zone then
				applyDamage(kaiju, t, math.random(75, 125));
			elseif flying == false then
				if t:hasAura("goop_seismic_slam_slow") then
					t:getAura("goop_seismic_slam_slow"):resetElapsed();
				else
					
					local slowAura = Aura.create(this, t);
					slowAura:setTag("goop_seismic_slam_slow");
					slowAura:setScriptCallback(AuraEvent.OnTick, 'onSlowAura');
					slowAura:setTickParameters(vehicleSlowDuration, 0);
					local spd = t:getStat("Speed");
					slowAura:setStat("Speed", spd * vehicleSlow);
					t:setStat("Speed", spd * vehicleSlow);
					slowAura:setTarget(t); -- required so aura doesn't autorelease
				
				end
				
				applyDamage(kaiju, t, math.random(25, 40));
			end
		end
	end
	
--	createEffectInWorld("effects/goop_slam2.plist", targetPos, 0.1);
	createEffectInWorld("effects/goop_slamsplash1.plist", targetPos, 0.1);
	createEffectInWorld("effects/goop_slamsplash2.plist", targetPos, 0.1);
	
	local rand = math.random(0, 100);
	if attackChance >= rand then
		attackChance = attackChance - attackDecay;
		createEffectInWorld("effects/goop_slam.plist", targetPos, quakeDelay);
	else
		endAbilityUse(kaiju, abilityData.name);
		local own = aura:getOwner();
		own:detachAura(aura);
		removeEntity(own);
	end
end

function onInterrupt()
	endAbilityUse(kaiju, abilityData.name);
end

function onStunAura(aura)
	if aura:getElapsed() > avatarDisable then
		local view = kaiju:getView();
		view:togglePauseAnimation(false);
		kaiju:setImmobile(false);
		kaiju:regainControl();
		aura:getOwner():detachAura(aura);
	end
end

function onSlowAura(aura)
	if aura:getElapsed() > vehicleSlowDuration then
		aura:getOwner():modStat("Speed", aura:getStat("Speed"));
		aura:getOwner():detachAura(aura);
	end
end