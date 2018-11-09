require 'scripts/avatars/common'

local kaiju = nil;
local durationtime = 15;
local enemyAcc = 0.15;
local enemyAccNum = 0;
local damage = 5;

local aoeRange = 120;
local timer = 0;
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
	view:attachEffectToNode("root", "effects/sandstormHalfReverse.plist", durationtime, 0, 140, true, false);
	view:attachEffectToNode("root", "effects/sandstormHalf.plist", durationtime, 0, 140, true, false);
	view:attachEffectToNode("root", "effects/sandstorm.plist", durationtime, 0, 180, true, false);
	view:attachEffectToNode("root", "effects/sandstorm.plist", durationtime, 0, 220, true, false);
	playSound("shrubby_ability_Sandstorm");
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then return end
	if timer < durationtime then
		local worldPos = kaiju:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle))
		for t in targets:iterator() do
			local veh = entityToVehicle(t);
			if veh:isAir() then
				applyDamage(kaiju, t, damage);
			end
		end
		timer = timer + 1;
	elseif timer >= durationtime then
		kaiju:modStat("acc_notrack", enemyAccNum);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
	
end
