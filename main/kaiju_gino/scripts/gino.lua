require 'scripts/avatars/common'

-- Auto attack callback.
-- if health < 10 instant kill.
-- else punch dealing 25 damage.

local kaiju = nil;
local alevel = 1;

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
		
		local stomp = a:hasPassive("stomp_damage");;
		if alevel == 2 then
			stomp = stomp + 5;
		elseif alevel == 3 then
			stomp = stomp + 10;
		end
		
		a:setPassive("stomp_damage", stomp);
		a:setStat("melee_damage_amplify", 1);
		a:setStat("damage_amplify", 1);
		a:setStat("ExtraDamage_Fire", -1);
		a:setPassive("power_gain_bonus", 0);
	end
end

function onHeal(a, amount)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/onHeal.plist", 0.2, 0, 0, true, false);
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
				if not v then return end
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

function getLevel()
	return alevel
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
	local damage = a:hasPassive("stomp_damage");
	if damage > 0 then
		local view = a:getView();
		view:attachEffectToNode("root", "effects/stomp_flash.plist", durationtime, 0, 0,false, true);	
		view:attachEffectToNode("root", "effects/stomp_smoke.plist", durationtime, 0, 0,false, true);	
		view:attachEffectToNode("root", "effects/stomp_smokeRight.plist", durationtime, 0, 0,false, true);	
		view:attachEffectToNode("root", "effects/stomp_smokeLeft.plist", durationtime, 0, 0,false, true);	
		if not isLairAttack() then -- DS: we don't want the kaiju damaging base buildings.
			local targets = getTargetsInRadius(a:getWorldPosition(), 50, EntityFlags(EntityType.Zone));
			for t in targets:iterator() do
				--createEffect('effects/explosion_BoomLayer.plist', t:getView():getPosition());
				applyDamageWithWeaponDamage(a, t, "default_melee_attack", damage);
			end
		end
	end
end

function onAnimAttack(a)
	local ctrl = a:getControl()
	if ctrl:hasTarget() then
		local t = ctrl:getTarget();
		local damage = a:modifyDamage(t, calcAttackDamage());
		if getEntityType(t) == EntityType.Zone then
			playSound("building_hit");		
		end
		applyDamageWithWeaponDamage(a, t, "default_melee_attack", damage);
	end	
end

function PDEffect(a, proj)
	local view = a:getView();
	view:doBeamEffectFromNode("contactzone01", getScenePosition(proj:getWorldPosition()), "effects/beam_pdLaser.plist", 0);
end