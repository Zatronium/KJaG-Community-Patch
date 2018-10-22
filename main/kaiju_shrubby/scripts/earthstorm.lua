require 'scripts/avatars/common'

local avatar = nil;
local durationtime = 15;
local enemyAcc = 0.30;
local enemyAccNum = 0;
local damage = 10;

local aoeRange = 250;
local timer = 0;

local aircraftChance = 60;
function onUse(a)
	avatar = a;
	if not avatar:hasStat("acc_notrack") then
		avatar:addStat("acc_notrack", 100);
	end
	playAnimation(avatar, "ability_channel");
	enemyAccNum = avatar:getStat("acc_notrack") * enemyAcc;
	avatar:modStat("acc_notrack", -enemyAccNum);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	timer = 0;
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/earthstorm1.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/earthstorm2.plist", durationtime, 0, 0, false, true);
	playSound("shrubby_ability_EarthStorm");
	startAbilityUse(avatar, abilityData.name);
end

function onTick(aura)
	if timer < durationtime then
		avatar = getPlayerAvatar();
		local worldPos = avatar:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Zone, EntityType.Vehicle, EntityType.Avatar))
		for t in targets:iterator() do
			local veh = entityToVehicle(t);
			if getEntityType(t) == EntityType.Vehicle and veh:isAir() and not veh:isSuper() and math.random(100) <= aircraftChance then
				applyDamage(avatar, t, veh:getStat("MaxHealth") + veh:getStat("Armor"));
			else
				applyDamage(avatar, t, damage);
			end
		end
		timer = timer + 1;
	elseif timer >= durationtime then
	--	createFloatingNumber(avatar, avatar:getStat("acc_notrack"), 244, 244, 0);
		endAbilityUse(avatar, abilityData.name);
		avatar:modStat("acc_notrack", enemyAccNum);
		aura:getOwner():detachAura(aura);
	end
end
