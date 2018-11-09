require 'scripts/avatars/common'

-- Auto attack callback.
-- if health < 10 instant kill.
-- else punch dealing 25 damage.

local kaiju = nil;
local alevel = 1;
local baseHPRegen = 5;
local healaura = nil;

function calcAttackDamage()
	if alevel == 1 then
		return (math.random (25,35));
	elseif alevel == 2 then
		return (math.random (30,55));
	elseif alevel == 3 then
		return (math.random (50,75));
	end
	return 0;
end

function onInitStat(a, lv)
	if not kaiju then
		kaiju = a;
		alevel = lv;
		
		healaura = createAura(this, kaiju, 0);
		healaura:setTag("base_regen");
		healaura:setTickParameters(5, 0);
		healaura:setScriptCallback(AuraEvent.OnTick, "onBaseHeal");
		healaura:setTarget(kaiju);
		
		a:setStat("ExtraDamage_Fire", 1);
		a:setStat("ExtraDamage_Gas", -1);
	end
end

function onBaseHeal(aura)
	if not canTarget(kaiju) then
		aura:getOwner():detachAura(aura);
	else
		local heal = baseHPRegen * ( 1 + kaiju:hasPassive("base_heal_bonus"));
		local surv = kaiju:hasPassive("shrubby_survival_regen");
		if surv > 0 then
			local scale = kaiju:getStat("Health")/kaiju:getStat("MaxHealth");
			if scale <= kaiju:hasPassive("shrubby_survival") then
				heal = heal + heal * surv;
			end
		end
		kaiju:gainHealth(heal);
	end
end

function onHeal(a, amount)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/onHeal.plist", 0.2, 0, 0, true, false);
	
	local compost = a:hasPassive("compost");
	if compost > 0 then
		addKaijuResource("organic", amount * compost);
	end
end

function onAttack(a)
	local buildingThreshhold = 10;
	if alevel == 2 then
		buildingThreshhold = 20;
	elseif alevel == 3 then
		buildingThreshhold = 50;
	end
	
	local t = a:getControl():getTarget();	
	local currentHealth = t:getStat("Health");
	if currentHealth > 0 then
		local maxHealth = t:getStat("MaxHealth");
		if getEntityType(t) == EntityType.Zone and maxHealth <= buildingThreshhold then 
			t:modStat("Health", -maxHealth); 
		else
			if getEntityType(t) == EntityType.Vehicle then -- is vehicle
				v = entityToVehicle(t);						
				if v:isAir() then -- is air
					playAnimation(a, "punch_crit");
				elseif alevel == 1 then -- is ground 
					playAnimation(a, "stomp");
				else
					local animRand = math.random(1, 3);
					if animRand == 1 then
						playAnimation(a, "stomp");
					else
						playAnimation(a, "stomp");
					end
				end
			elseif alevel == 1 or alevel == 2 then-- is zone
				local animRand = math.random(1, 4);
				if animRand == 1 then	
					playAnimation(a, "punch_01");
				elseif animRand == 2 then			
					playAnimation(a, "punch_03");
				else			
					playAnimation(a, "punch_02");
				end	
			else
				local animRand = math.random(1, 6);
				if animRand == 1 then	
					playAnimation(a, "punch_01");
				elseif animRand == 2 then			
					playAnimation(a, "punch_02");
				elseif animRand == 3 then	
					playAnimation(a, "punch_03");
				elseif animRand == 4 then		
					playAnimation(a, "punch_crit");
				else
					playAnimation(a, "punch_onetwo");
				end	
			end
		end
	end
end

function onStatChanged(e, stat, prev, val)
	playerStatChanged(e, stat, prev, val);
end

function onStomp(a, inwater)
	if inwater == true then
		playSound("shrubby_footfall_water");
	else
		playSound("shrubby_footfall_land");
	end
end

function onAnimAttack(a)
	if a:getControl():hasTarget() then
		local t = a:getControl():getTarget();
		local damage = a:modifyDamage(t, calcAttackDamage());
		if getEntityType(t) == EntityType.Zone then
			playSound("shrubby_claw");
		end
		applyDamageWithWeaponDamage(a, t, "default_melee_attack", damage);
	end	
end

function ToggleShields(a, on)
	abilityEnabled(a, "ability_SolarRays", on);
	abilityEnabled(a, "ability_DirtNap", on);
	abilityEnabled(a, "ability_AuraOfEarth", on);
	abilityEnabled(a, "ability_SolarShield", on);
	abilityEnabled(a, "ability_SolarProminence", on);
	abilityEnabled(a, "ability_ShieldOfEarth", on);
end

function ThornPatch(pos) 
	local cloud = spawnEntity(EntityType.Minion, "unit_shrubby_patch", pos);
	setRole(cloud, "Player");
	cloud:attachEffect("effects/brambles.plist", -1, true);
	cloud:setImmobile(true);
	local aura = createAura(this, cloud, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onThornTick");
	aura:setTarget(cloud);
end

function onThornTick(aura)
	kaiju = getPlayerAvatar();
	local thornLife = 30;
	local slowPercent = -0.5;
	local patchAoe = 50;
	local elapsed = aura:getElapsed();
	if elapsed > thornLife then
		local target = aura:getTarget();
		target:detachAura(aura);
		removeEntity(target);
	else
		local targets = getTargetsInRadius(aura:getTarget():getWorldPosition(), patchAoe, EntityFlags(EntityType.Vehicle ,EntityType.Avatar));
		for t in targets:iterator() do
			if canTarget(t) and not isSameEntity(kaiju, t) then
				local airUnit = false;
				if getEntityType(t) == EntityType.Vehicle then	
					local veh = entityToVehicle(t);
					if veh:isAir() == true then
						airUnit = true;
					end
				end
				if not airUnit then
					if t:hasAura("thorn_patch") then
						t:getAura("thorn_patch"):resetElapsed();
					else
						local aura = createAura(this, t, 0);
						aura:setTag("thorn_patch");
						aura:setTickParameters(1, 0);
						local sd = t:getStat("Speed") * slowPercent;
						aura:setStat("Speed", sd);
						t:modStat("Speed", sd);
						aura:setScriptCallback(AuraEvent.OnTick, "onThornDot");
						aura:setTarget(t);
					end
				end
			end
		end
	end
end

function onThornDot(aura)
	local dotDamage = 3;
	local elapsed = aura:getElapsed();
	local target = aura:getTarget();
	if elapsed > 2 or not canTarget(target) then
		target:modStat("Speed", -(aura:getStat("Speed")));
		target:detachAura(aura);
	else
		kaiju = getPlayerAvatar();
		applyDamage(kaiju, target, dotDamage);
	end
end

function PDEffect(a, proj)
	createEffectInWorld("effects/sporeShroud_Missile.plist", proj:getWorldPosition(), 0.5);
end
