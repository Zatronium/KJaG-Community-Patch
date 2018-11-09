 -- damage 10 - 12
 -- dot 10
 -- aoe 150
 -- cold
require 'scripts/avatars/common'
local kaiju = nil;
 
local disableTime = 5;
 
local minDamage = 10;
local maxDamage = 12;
 
local initalShellHeight = 1000;
 
local tickTime = 0.2;
local totalDuration = 20;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_launch");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local targetPos = kaiju:getWorldPosition();
	targetPos.x = targetPos.x + initalShellHeight;
	targetPos.y = targetPos.y + initalShellHeight;
	local proj = avatarFireAtPoint(kaiju, "weapon_GlobalMortar", "gun_node_03", targetPos, 0);
	proj:setCallback(this, 'onShellHit');
	startCooldown(kaiju, abilityData.name);
end

function onShellHit(proj)
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", proj:getWorldPosition());
	
	local aura = createAura(this, cloud, "gino_nuclearwinter");
	aura:setTickParameters(tickTime, totalDuration);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(cloud);
	
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);

end

function onTick(aura)
	if not aura then
		return
	end
	local targetPos = getWorldSize();
	targetPos.x = math.random(0, targetPos.x);
	targetPos.y = math.random(0, targetPos.y);
	local firePos = Point(targetPos.x + 300, targetPos.y + 300);

	local proj = fireProjectileAtPoint(kaiju, firePos, targetPos, "weapon_IceBallDirect");
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	
	if aura:getElapsed() >= totalDuration then
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
			removeEntity(self);
		end
	end
end

function onHit(proj)
	local worldPos = proj:getWorldPosition();
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	local targets = getTargetsInRadius(worldPos, 50, EntityFlags(EntityType.Vehicle, EntityType.Zone)); 
	playSound("ice-freeze");
	for t in targets:iterator() do
		t:disabled(disableTime);
		t:attachEffect("effects/onFreeze.plist", disableTime, true);
	end
	createImpactEffect(weapon, scenePos);
end