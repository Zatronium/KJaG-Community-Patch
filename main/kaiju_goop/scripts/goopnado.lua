require 'kaiju_goop/scripts/goop'
-- Global values.
local kaiju = nil
local weapon = "goop_Spit";
local weaponDamage = "goop_Goop"
local weapon_node = "eyeball"

local targetPos = nil;
local scriptAura = nil;

local minrange = 300;
local maxrange = 400;

local dotTime = 5;
local dotDamage = 3;

local minGoop = 15;
local maxGoop = 20;

local timeTick = 0.20;
local fireTick = 0.4;
local lastFire = -1;
local timeDuration = 4;


function onUse(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	dotDamage = getWeaponDamage(weaponDamage) * multiplier;
	
	targetPos = kaiju:getWorldPosition();
	
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), targetPos);
	kaiju:setWorldFacing(facingAngle);
	local view = a:getView();
	view:setAnimation("ability_artillery", true);

	registerAnimationCallback(this, kaiju, "attack");
	playSound("goop_ability_Goopnado"); -- SOUND
	startAbilityUse(kaiju, abilityData.name);


	local view = a:getView();
	view:attachEffectToNode("root", "effects/goopnado2_smallbit.plist", timeDuration, 0, 45, true, false);
	view:attachEffectToNode("root", "effects/goopnado_smallbit.plist", timeDuration, 0, 80, true, false);
	view:attachEffectToNode("root", "effects/goopnado2_medbit.plist", timeDuration, 0, 125, true, false);
	view:attachEffectToNode("root", "effects/goopnado_medbit.plist", timeDuration, 0, 175, true, false);
	view:attachEffectToNode("root", "effects/goopnado2.plist", timeDuration, 0, 225, true, false);
	view:attachEffectToNode("root", "effects/goopnado.plist", timeDuration, 0, 275, true, false);

end

function onAnimationEvent(a)
	local view = a:getView();
--	view:togglePauseAnimation(true);
	
	kaiju:loseControl();
	
	scriptAura = Aura.create(this, a);
	scriptAura:setTag('goop_goopnado');
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onNadoTick');
	scriptAura:setTickParameters(timeTick, 0); --updates at time 0 then at time 20
	scriptAura:setTarget(a); -- required so aura doesn't autorelease
end

function onInterrupt()
	local view = kaiju:getView();
--	view:togglePauseAnimation(false);
	view:setAnimation("ability_artillery", false);
	view:addAnimation("idle", true);
	endAbilityUse(kaiju, abilityData.name);
	scriptAura:getOwner():detachAura(scriptAura);
	kaiju:regainControl();
end

function onNadoTick(aura)
	if not aura then return end
	local elapsed = aura:getElapsed();
	if elapsed >= timeDuration then
		local view = kaiju:getView();
	--	view:togglePauseAnimation(false);
		view:setAnimation("ability_artillery", false);
		view:addAnimation("idle", true);
		endAbilityUse(kaiju, abilityData.name);
		kaiju:regainControl();
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
	else
	--	local randPos = offsetRandomDirection(targetPos, minrange, getWeaponRange(weapon));
		local randPos = offsetRandomDirection(targetPos, minrange, maxrange);

		local facingAngle = getFacingAngle(kaiju:getWorldPosition(), randPos);
		kaiju:setWorldFacing(facingAngle);
		
		if elapsed > fireTick + lastFire then
			local proj = avatarFireAtPoint(kaiju, weapon, weapon_node, randPos, 0);
			proj:setCollisionEnabled(false);
			proj:setCallback(this, 'onHit');
			
			lastFire = elapsed;
		end
	end
end

-- Projectile hits a target.
function onHit(proj)
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", proj:getWorldPosition());
	cloud:attachEffect("effects/goopball_splort.plist", 0, true);
	cloud:attachEffect("effects/goopball_splortsplash.plist", -1, true);
	local scriptAura = Aura.create(this, cloud);
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(1, 0);
	scriptAura:setStat("Health", 1);
	scriptAura:setTarget(cloud); -- required so aura doesn't autorelease	
end

function onTick(aura)
	if not aura then return end
	local own = aura:getOwner();
	if not own then
		aura = nil return
	end
	if aura:getElapsed() < dotTime then
		kaiju = getPlayerAvatar();
		local targets = getTargetsInRadius(own:getWorldPosition(), getWeaponRange(weaponDamage), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
		for t in targets:iterator() do
			if not isSameEntity(kaiju, t) then
				local flying = false;
				if getEntityType(t) == EntityType.Vehicle then
					local veh = entityToVehicle(t);
					flying = veh:isAir();
				end
				if not flying  then
					applyDamageWithWeaponDamage(kaiju, t, weaponDamage, dotDamage);
					aura:setStat("Health", 2);
				end
			end
		end
	else
		if aura:getStat("Health") > 1 then
			CreateBlob(own:getWorldPosition(), minGoop, maxGoop);
		end
		own:detachAura(aura);
		removeEntity(own);
	end
end
