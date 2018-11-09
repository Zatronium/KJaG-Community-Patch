require 'scripts/avatars/common'
require 'kaiju_goop/scripts/goop_common'

-- Auto attack callback.
-- if health < 10 instant kill.
-- else punch dealing 25 damage.

local kaiju = nil;
local alevel = 1;
function calcAttackDamage()
	local retnum = 0;
	if alevel == 1 then
		retnum = math.random (25,35);
	elseif alevel == 2 then
		retnum = math.random (30,55);
	elseif alevel == 3 then
		retnum = math.random (50,75);
	end
	retnum = retnum * kaiju:getStat("melee_damage_amplify");
	return retnum;
end

function onInitStat(a, lv)
	kaiju = a;
	alevel = lv;
	kaiju:addStat("damage_resist", 1);
	kaiju:addStat("acc_notrack", 100);
	kaiju:addStat("block_all", 100);
	kaiju:addStat("Armor_Ballistic", 0);
	kaiju:addStat("damage_amplify", 1);
	kaiju:addStat("melee_damage_amplify", 1);
	kaiju:addStat("CoolDownReductionPercent", 0);
	kaiju:setStat("ExtraDamage_Fire", 0.2);
	kaiju:setStat("ExtraDamage_Cold", 0.2);
end

function onHeal(a, amount)
	if amount > 1 then
		local view = a:getView();
		view:attachEffectToNode("root", "effects/onHeal.plist", 0.2, 0, 0, true, false);
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
		elseif a:hasPassive("attack_disabled") <= 0 then
			if getEntityType(t) == EntityType.Vehicle then -- is vehicle	
				v = entityToVehicle(t);
				if v:isAir() then -- is air
					playAnimation(a, "punch_crit");
				elseif alevel == 1 then -- is ground 
					playAnimation(a, "punch_01");
				else
					playAnimation(a, "punch_02");
				end
			elseif alevel == 1 or alevel == 2 then-- is zone
				local animRand = math.random(1, 5);
				if (animRand == 1) then	
					playAnimation(a, "punch_01");
				elseif (animRand == 2) then			
					playAnimation(a, "punch_02");
				elseif (animRand == 3) then			
					playAnimation(a, "punch_03");
				else			
					playAnimation(a, "punch_04");
				end	
			else
				local animRand = math.random(1, 7);
				if (animRand == 1) then	
					playAnimation(a, "punch_01");
				elseif (animRand == 2) then			
					playAnimation(a, "punch_02");
				elseif (animRand == 3) then	
					playAnimation(a, "punch_03");
				elseif (animRand == 4) then		
					playAnimation(a, "punch_04");
				elseif (animRand == 3) then	
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
	if inwater then
		playSound("gino_footfall_water");
	else
		playSound("gino_footfall_land");
	end
end

function onAnimAttack(a)
	if a:getControl():hasTarget() then
		local t = a:getControl():getTarget();
		local damage = a:modifyDamage(t, calcAttackDamage());
		if getEntityType(t) == EntityType.Zone then
			playSound("building_hit");		
		end
		applyDamageWithWeaponDamage(a, t, "default_melee_attack", damage);
	end	
end

function viralAura(script, tick, target, duration, pri)
	if canTarget(target) then
		local dotAura = nil;
		if target:hasAura("Viral") then
			dotAura = target:getAura("Viral");
			if dotAura:getPriority() < pri then
				local owner = dotAura:getOwner()
				if owner then
					owner:detachAura(dotAura);
				end
				dotAura = nil;
			else
				local remain = dotAura:getRemainingTime();
				if remain < duration then
					dotAura:setDuration(duration);
				end
				if dotAura:getStat("MaxHealth") < duration then
					dotAura:setStat("MaxHealth", duration)
				end
			end
		end
		if not dotAura then
			dotAura = Aura.create(script, target);
			dotAura:setTag("Viral");
			dotAura:setPriority(pri);
			dotAura:setScriptCallback(AuraEvent.OnTick, tick);
			dotAura:setTickParameters(1, duration);
			dotAura:setUpdateDelay(1);
			dotAura:setStat("MaxHealth", duration);
			dotAura:setTarget(target); -- required so aura doesn't autorelease
		end
	end
end