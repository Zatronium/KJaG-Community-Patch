require 'scripts/avatars/common'

-- Global values.
local avatar = nil;

local shotsFire = 10;
local shotsPer = 2;
local weaponRange = 800;

local tickTime = 0.1;
totalTime = shotsFire * tickTime;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_launch");
	registerAnimationCallback(this, avatar, "attack");		
end

function onAnimationEvent(a)
	local targets = getTargetsInRadius(avatar:getWorldPosition(), weaponRange, EntityFlags(EntityType.Vehicle, EntityType.Projectile));
	local totalshot = shotsFire;
	for t in targets:iterator() do
		if totalshot > 0 then
			local isLegal = false;
			if getEntityType(t) == EntityType.Vehicle then
				local veh = entityToVehicle(t);
				if veh and veh:isAir() then
					isLegal = true;
				end
			else
				local pr = entityToProjectile(t);
				local weap = pr:getWeapon();
				if weap:isTracking() == true then
					isLegal = true;
				end
			end
			if isLegal == true then
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
		startCooldown(avatar, abilityData.name);
		local view = a:getView();
		view:pauseAnimation(totalTime);
	end
	
end

function onFireMissile(aura)
	local proj = avatarFireAtTarget(avatar, "weapon_MissilePD", "gun_node_03", aura:getOwner(), 90);
	proj:setCallback(this, 'onHit');
	aura:getOwner():detachAura(aura);
end
-- Projectile hits a target.
function onHit(proj)
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
end