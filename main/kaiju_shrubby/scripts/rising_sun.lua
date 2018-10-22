require 'scripts/avatars/common'

local avatar = 0;
local maxHealth = 0;
local healpertick = 10;
local durationtime = 15;

local timer = 0;
local bonusSpeedPercent = 0.1;
local bonusSpeed = 0;
function onUse(a)
	avatar = a;
	maxHealth = avatar:getStat("MaxHealth");
	
	bonusSpeed = avatar:getStat("Speed") * bonusSpeedPercent;
	avatar:modStat("Speed", bonusSpeed);
	
	playSound("shrubby_ability_RisingSun");
	startAbilityUse(avatar, abilityData.name);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/risingSun_baseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/risingSun_baseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/risingSun_pulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/risingSun_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", durationtime, 0, 0, true, false);
	local aura = createAura(this, avatar, 0);
	aura:setTag("rising_sun");
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
	playAnimation(avatar, "ability_channel");
end

function onTick(aura)
	local curHealth = avatar:getStat("Health");
	if timer < durationtime and curHealth < maxHealth then
		avatar:gainHealth(healpertick);
	end
	timer = timer + 1;
	if timer >= durationtime then
		avatar:modStat("Speed", -bonusSpeed);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end