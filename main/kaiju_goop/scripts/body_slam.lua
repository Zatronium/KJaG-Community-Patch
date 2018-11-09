require 'scripts/avatars/common'

local kaiju = nil;
local aoeRange = 300;

local avatarDisable = 1.5;
local vehicleSlow = 0.5;
local vehicleSlowDuration = 5;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_bodyslam");
	registerAnimationCallback(this, kaiju, "attack");
	
	playSound("goop_ability_BodySlam"); -- SOUND
	startAbilityUse(kaiju, abilityData.name);
end 

function onAnimationEvent(a, event)
	local view = kaiju:getView();
	local targetPos = kaiju:getWorldPosition();

	createEffectInWorld("effects/goop_slam.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slam2.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash1.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash2.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash3.plist", targetPos, 0);
	createEffectInWorld("effects/bodyslam_shockwave.plist", targetPos, 0);
	createEffectInWorld("effects/bodyslam_shockwave2.plist", targetPos, 0);

	--view:attachEffectToNode("root", "effects/stompBack.plist",0, 0, 0, false, true);
	--view:attachEffectToNode("root", "effects/stompFront.plist",0, 0, 0, true, false);
	
	view:togglePauseAnimation(true);
	kaiju:setImmobile(true);
	kaiju:loseControl();
	
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
			elseif not flying then
				local slowAura = Aura.create(this, t);
				slowAura:setScriptCallback(AuraEvent.OnTick, 'onSlowAura');
				slowAura:setTickParameters(vehicleSlowDuration, 0);
				local spd = t:getStat("Speed");
				slowAura:setStat("Speed", spd * vehicleSlow);
				t:setStat("Speed", spd * vehicleSlow);
				slowAura:setTarget(t); -- required so aura doesn't autorelease
				applyDamage(kaiju, t, math.random(25, 40));
			end
		end
	end
	
	local stunAura = Aura.create(this, kaiju);
	stunAura:setScriptCallback(AuraEvent.OnTick, 'onStunAura');
	stunAura:setTickParameters(avatarDisable, 0);
	stunAura:setTarget(kaiju); -- required so aura doesn't autorelease
end

function onStunAura(aura)
	if aura:getElapsed() > avatarDisable then
		local view = kaiju:getView();
		view:togglePauseAnimation(false);
		kaiju:setImmobile(false);
		kaiju:regainControl();
		endAbilityUse(kaiju, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

function onSlowAura(aura)
	if not aura then return end
	local owner = aura:getOwner()
	if not owner then
		aura = nil return
	end
	if aura:getElapsed() > vehicleSlowDuration then
		owner:modStat("Speed", aura:getStat("Speed"));
		owner:detachAura(aura);
	end
end