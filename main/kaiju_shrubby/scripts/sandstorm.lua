require 'scripts/avatars/common'

local avatar = nil;
local durationtime = 15;
local enemyAcc = 0.15;
local enemyAccNum = 0;
local damage = 5;

local aoeRange = 120;
local timer = 0;
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
	view:attachEffectToNode("root", "effects/sandstormHalfReverse.plist", durationtime, 0, 140, true, false);
	view:attachEffectToNode("root", "effects/sandstormHalf.plist", durationtime, 0, 140, true, false);
	view:attachEffectToNode("root", "effects/sandstorm.plist", durationtime, 0, 180, true, false);
	view:attachEffectToNode("root", "effects/sandstorm.plist", durationtime, 0, 220, true, false);
	playSound("shrubby_ability_Sandstorm");
	startAbilityUse(avatar, abilityData.name);
end

function onTick(aura)
	if timer < durationtime then
		avatar = getPlayerAvatar();
		local worldPos = avatar:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle))
		for t in targets:iterator() do
			local veh = entityToVehicle(t);
			if veh:isAir() then
				applyDamage(avatar, t, damage);
			end
		end
		timer = timer + 1;
	elseif timer >= durationtime then
		avatar:modStat("acc_notrack", enemyAccNum);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
	
end
