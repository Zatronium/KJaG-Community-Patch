require 'scripts/avatars/common'

local kaiju = 0;
local maxHealth = 0;
local healpertick = 10;
local durationtime = 15;

local timer = 0;
local bonusSpeedPercent = 0.1;
local bonusSpeed = 0;
function onUse(a)
	kaiju = a;
	maxHealth = kaiju:getStat("MaxHealth");
	
	bonusSpeed = kaiju:getStat("Speed") * bonusSpeedPercent;
	kaiju:modStat("Speed", bonusSpeed);
	
	playSound("shrubby_ability_RisingSun");
	startAbilityUse(kaiju, abilityData.name);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/risingSun_baseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/risingSun_baseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/risingSun_pulseBack.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/risingSun_pulseFront.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/repairCycle_health.plist", durationtime, 0, 0, true, false);
	local aura = createAura(this, kaiju, 0);
	aura:setTag("rising_sun");
	aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
	playAnimation(kaiju, "ability_channel");
end

function onTick(aura)
	if not aura then return end
	local curHealth = kaiju:getStat("Health");
	if timer < durationtime and curHealth < maxHealth then
		kaiju:gainHealth(healpertick);
	end
	timer = timer + 1;
	if timer >= durationtime then
		kaiju:modStat("Speed", -bonusSpeed);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end