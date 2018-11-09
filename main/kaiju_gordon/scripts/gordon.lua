require 'scripts/avatars/common'

-- Auto attack callback.
-- if health < 10 instant kill.
-- else punch dealing 25 damage.

local kaiju = nil;
local alevel = 1;
function calcAttackDamage()
	local retnum = 0;
	if alevel == 1 then
		retnum = (math.random (25,35));
	elseif alevel == 2 then
		retnum = (math.random (30,55));
	elseif alevel == 3 then
		retnum = (math.random (50,75));
	end
	retnum = retnum * kaiju:getStat("melee_damage_amplify");
	return retnum;
end

function onInitStat(a, lv)
	if not kaiju then
		kaiju = a;
		alevel = lv;
		kaiju:addStat("damage_resist", 1);
		kaiju:addStat("acc_notrack", 100);
		kaiju:addStat("damage_amplify", 1);
		kaiju:addStat("melee_damage_amplify", 1);
		kaiju:addStat("CoolDownReductionPercent", 0);
		--a:setStat("ExtraDamage_Fire", -1);
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
				if v:isAir() then -- is air
					playAnimation(a, "punch_crit");
				elseif alevel == 1 then -- is ground 
					playAnimation(a, "punch_01");
				else
					playAnimation(a, "punch_02");
				end
			elseif alevel == 1 or alevel == 2 then-- is zone
				local animRand = math.random(1, 5);
				if animRand == 1 then	
					playAnimation(a, "punch_01");
				elseif animRand == 2 then			
					playAnimation(a, "punch_02");
				elseif animRand == 3 then			
					playAnimation(a, "punch_03");
				else			
					playAnimation(a, "punch_04");
				end	
			else
				local animRand = math.random(1, 7);
				if animRand == 1 then	
					playAnimation(a, "punch_01");
				elseif animRand == 2 then			
					playAnimation(a, "punch_02");
				elseif animRand == 3 then	
					playAnimation(a, "punch_03");
				elseif animRand == 4 then		
					playAnimation(a, "punch_04");
				elseif animRand == 3 then	
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
	if a:hasPassive("sneaking") ~= 0 or a:hasPassive("creeping") ~= 0 then
		return;
	end
	if inwater == true then
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

function BlastZone(kaiju, weapon)

	local view = kaiju:getView();	
	view:attachEffectToNode("root", "effects/blastZone_back.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/blastZone_front.plist",0, 0, 0, true, false);
	local worldPos = kaiju:getWorldPosition();
		
	local targets = getTargetsInRadius(worldPos, getWeaponRange(weapon), EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		applyDamageWithWeapon(kaiju, t, weapon);
	end
	--	playSound("shrubby_ability_VineWave");
end

function PDEffect(a, proj)
	local view = a:getView();
	view:doBeamEffectFromNode("contactzone01", getScenePosition(proj:getWorldPosition()), "effects/beam_pdLaser.plist", 0);
end