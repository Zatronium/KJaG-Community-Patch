require 'scripts/common'

local kaiju = nil;
local hasUpdated = false;
local bonusSpeed = 0.0;
local bonusSpeedPct = 0.25;
local bonusBaseRegen = 0.25;
local durationtime = 10;
function onUse(a)
	hasUpdated = false;
	kaiju = a;
	local bonusAura = Aura.create(this, kaiju);
	bonusAura:setTag('shrubby_stimulant');
	bonusAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	bonusAura:setTickParameters(durationtime, durationtime);
	bonusAura:setTarget(kaiju);

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/stimulant1.plist", 0.7, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/booster.plist", durationtime, 0, 0, false, true); -- legL/legR or leg_far/leg_near
--	view:attachEffectToNode("legR", "effects/booster.plist", durationtime, 0, 0, false, true);
	
	playSound("shrubby_ability_Stimulant");
	startAbilityUse(kaiju, abilityData.name);

	bonusSpeed = kaiju:getBaseStat("Speed") * bonusSpeedPct;
	kaiju:modStat("Speed", bonusSpeed);
	kaiju:addPassive("base_heal_bonus", bonusBaseRegen);

end

function onTick(aura)
	if not aura then return end
	if hasUpdated then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("Speed", -bonusSpeed);
		kaiju:addPassive("base_heal_bonus", -bonusBaseRegen);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
		
	hasUpdated = true;
end