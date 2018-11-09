require 'scripts/avatars/common'

-- Global values.
local kaiju = nil;

local shotsFire = 10;
local shotsPer = 2;
local weaponRange = 800;

local tickTime = 0.1;
local totalTime = shotsFire * tickTime;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_launch");
	registerAnimationCallback(this, kaiju, "attack");		
end

function onAnimationEvent(a)
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Projectile));
	local totalshot = shotsFire;
	for t in targets:iterator() do
		if totalshot > 0 then
			local isLegal = false;
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				if not veh and veh:isAir() then
					isLegal = true;
				end
			else
				local pr = entityToProjectile(t);
				local weap = pr:getWeapon();
				if weap:isTracking() then
					isLegal = true;
				end
			end
			if isLegal then
				local aura = createAura(this, t, 0);
				aura:setTag("aimed");
				aura:setTickParameters(tickTime, totalTime);
				aura:setScriptCallback(AuraEvent.OnTick, "onFireMissile");
				aura:setUpdateDelay(tickTime * (shotsFire - totalshot)); 
				aura:setTarget(t);
				totalshot = totalshot - 1;
			end
		end
	end
	if totalshot < shotsFire then
		startCooldown(kaiju, abilityData.name);
		local view = a:getView();
		view:pauseAnimation(totalTime);
	end
	
end

function onFireMissile(aura)
	if not aura then return end
	local self = aura:getOwner()
	if not self then
		aura = nil return
	end
	local proj = avatarFireAtTarget(kaiju, "weapon_MissilePD", "gun_node_03", self, 90);
	proj:setCallback(this, 'onHit');
	self:detachAura(aura);
end
-- Projectile hits a target.
function onHit(proj)
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
end