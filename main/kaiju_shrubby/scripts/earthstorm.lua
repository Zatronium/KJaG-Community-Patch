require 'scripts/avatars/common'

local kaiju = nil;
local durationtime = 15;
local enemyAcc = 0.30;
local enemyAccNum = 0;
local damage = 10;

local aoeRange = 250;
local timer = 0;

local aircraftChance = 60;
function onUse(a)
	kaiju = a;
	if not(kaiju:hasStat("acc_notrack")) then
		kaiju:addStat("acc_notrack", 100);
	end
	playAnimation(kaiju, "ability_channel");
	enemyAccNum = kaiju:getStat("acc_notrack") * enemyAcc;
	kaiju:modStat("acc_notrack", -enemyAccNum);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	timer = 0;
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/earthstorm1.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/earthstorm2.plist", durationtime, 0, 0, false, true);
	playSound("shrubby_ability_EarthStorm");
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then return end
	if timer < durationtime then
		kaiju = getPlayerAvatar();
		local worldPos = kaiju:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Zone, EntityType.Vehicle, EntityType.Avatar))
		for t in targets:iterator() do
			local veh = entityToVehicle(t);
			if getEntityType(t) == EntityType.Vehicle and veh:isAir() and not veh:isSuper() and math.random (100) <= aircraftChance then
				applyDamage(kaiju, t, veh:getStat("MaxHealth") + veh:getStat("Armor"));
			else
				applyDamage(kaiju, t, damage);
			end
		end
		timer = timer + 1;
	elseif timer >= durationtime then
	--	createFloatingNumber(kaiju, kaiju:getStat("acc_notrack"), 244, 244, 0);
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("acc_notrack", enemyAccNum);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
