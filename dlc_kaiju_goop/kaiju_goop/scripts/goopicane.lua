require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Goopicane";
local angle = 90;

local dotTime = 20;
local dotDamage = 1;
local cloudAoe = 300;

local minGoop = 20;
local maxGoop = 30;

local worldpos = nil;
local endpt = nil;

function onUse(a)
	kaiju = a;
	local dotMult = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weapon) * dotMult;
	enableTargetSelection(this, abilityData.name, 'onTargets', getWeaponRange(weapon));
end

-- Target selection is complete.
function onTargets(position)
	worldpos = kaiju:getWorldPosition();
	local direction = getDirectionFromPoints(worldpos, position);
	endpt = getBeamEndWithDir(worldpos, dotTime * 100, direction);
	
--	target = getAbilityTarget(kaiju, abilityData.name);
	local facingAngle = getFacingAngle(worldpos, position);
	kaiju:setWorldFacing(facingAngle);	
	playAnimation(kaiju, "ability_bodyslam");
	registerAnimationCallback(this, kaiju, "attack");
	playSound("goop_ability_Goopicane"); -- SOUND
end

function onAnimationEvent(a)
	local view = kaiju:getView();
	view:doEffectFromNode('root ', 'effects/goop_breath.plist', 90);
	
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_goopicane", worldpos);
	cloud:attachEffect('effects/goop_cloud_rain.plist', -1, true);
	cloud:attachEffect('effects/goop_cloud.plist', -1, true);
	cloud:attachEffect('effects/goop_cloud2.plist', -1, true);
	local veh = entityToVehicle(cloud);
	if veh then
		local ctrl = veh:getControl();
		ctrl:directMove(endpt);
		
		local dotAura = Aura.create(this, cloud);
		dotAura:setTag("goop_goopicane");
		dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		dotAura:setTickParameters(1, 0);
		dotAura:setTarget(cloud); -- required so aura doesn't autorelease	
	end
	
	startCooldown(kaiju, abilityData.name);	
	
end

function onTick(aura)
	if not aura then return end
	local own = aura:getOwner();
	if not own then
		aura = nil return
	end
	if aura:getElapsed() < dotTime then
		local targets = getTargetsInRadius(own:getWorldPosition(), cloudAoe, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			if not isSameEntity(t, getPlayerAvatar()) then
				local veh = entityToVehicle(t)
				local flying = 1;
				if veh and veh:isAir() then
					flying = 2;
				end
				applyDamage(kaiju, t, dotDamage * flying);
			end
		end
	else
		CreateBlob(own:getWorldPosition(), minGoop, maxGoop);
		own:detachAura(aura);
		removeEntity(own);
	end
end
