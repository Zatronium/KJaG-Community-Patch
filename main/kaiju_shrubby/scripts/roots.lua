 -- damage 10 - 18
 -- dot 10
 -- aoe 150
 -- cold
 require 'scripts/avatars/common'
 avatar = nil;

 minDamage = 10;
 maxDamage = 18;
 
 aoeRange = 150;
 
 isDone = false;
 immobileDuration = 3;
 
function onUse(a)
	avatar = a;
	playAnimation(avatar, "stomp");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/bloop.plist", 1.5, 0, 150, true, false);
	avatar = getPlayerAvatar();
	local worldPos = avatar:getWorldPosition();
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone));
	for t in targets:iterator() do
		if getEntityType(t) == EntityType.Vehicle then	
			local veh = entityToVehicle(t);
			if not veh:isAir() then
				t:attachEffect("effects/rootCluster.plist", 3, true);
				t:attachEffect("effects/roots_shockwave.plist", .1, true);
				t:attachEffect("effects/rootSpike.plist", .3, true);
				t:attachEffect("effects/creeper_rocks.plist", .1, true);
				
				t:setImmobile(true);
				local aura = createAura(this, t, 0);
				aura:setTickParameters(immobileDuration, 0);
				aura:setScriptCallback(AuraEvent.OnTick, "immobilize");
				aura:setTarget(t);
				
				applyDamage(avatar, t, math.random(minDamage, maxDamage));	
			end
		elseif canTarget(t) then
			t:attachEffect("effects/rootCluster.plist", 3, true);
			t:attachEffect("effects/roots_shockwave.plist", .1, true);
			t:attachEffect("effects/rootSpike.plist", .3, true);
			t:attachEffect("effects/creeper_rocks.plist", .1, true);
			applyDamage(avatar, t, math.random(minDamage, maxDamage));	
		end
	end
	playSound("shrubby_ability_Roots");
	startCooldown(avatar, abilityData.name);
	isDone = true;
end

function immobilize(aura)
	if isDone == true then
		aura:getOwner():setImmobile(false);
		aura:getOwner():detachAura(aura);
	end
end