require 'kaiju_goop/scripts/goop'

local kaiju = nil;
local weapon = "goop_Fog";
local duration = 20;
local interval = 2;
local dotMult = 1;

local targetPos = nil;

local hasDamage = false;
local minGoop = 75;
local maxGoop = 150;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_bodyslam");
	dotMult = 1 + kaiju:hasPassive("goop_dot_bonus");
	registerAnimationCallback(this, kaiju, "attack");
end 

function onAnimationEvent(a, event)
	targetPos = kaiju:getWorldPosition();

	local view = kaiju:getView();
	view:doEffectFromNode('root ', 'effects/goop_breath.plist', 90);
	view:doEffectFromNode('root ', 'effects/goop_slam.plist', 90);
	view:doEffectFromNode('root ', 'effects/goop_slam2.plist', 90);
	view:doEffectFromNode('root ', 'effects/goop_slamsplash1.plist', 90);
	view:doEffectFromNode('root ', 'effects/goop_slamsplash2.plist', 90);
	view:doEffectFromNode('root ', 'effects/goop_slamsplash3.plist', 90);
	
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", targetPos);
	cloud:attachEffect('effects/goop_cloud_rain.plist', -1, true);
	cloud:attachEffect('effects/goop_cloud.plist', -1, true);
	cloud:attachEffect('effects/goop_cloud2.plist', -1, true);
	
	local dotAura = Aura.create(this, cloud);
	dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	dotAura:setTickParameters(interval, 0);
	dotAura:setTarget(cloud); -- required so aura doesn't autorelease
			
	playSound("goop_ability_GoopFog"); -- SOUND
	startCooldown(kaiju, abilityData.name);	
end

function onTick(aura)
	if not aura then return end
	local own = aura:getOwner();
	if not own then
		aura = nil return
	end
	local targets = getTargetsInRadius(own:getWorldPosition(), getWeaponRange(weapon), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		local dotDamage = getWeaponDamage(weapon) * dotMult;
		applyDamageWithWeaponDamage(kaiju, t, weapon, dotDamage);
		hasDamage = true;
	end
	
	if aura:getElapsed() > duration then
		if hasDamage then
			CreateBlob(own:getWorldPosition(), minGoop, maxGoop);
		end
		own:detachAura(aura);
		removeEntity(own);
	end
end