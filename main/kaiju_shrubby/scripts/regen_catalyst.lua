require 'scripts/common'

local kaiju = nil;
local hasUpdated = false;
local bonusBaseRegen = 1.00;
local bonusSpeed = 0.0;
local bonusSpeedPct = -0.15;
local durationtime = 15;
function onUse(a)
	hasUpdated = false;
	kaiju = a;
	local bonusAura = Aura.create(this, kaiju);
	bonusAura:setTag('shrubby_regen_catalyst');
	bonusAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	bonusAura:setTickParameters(durationtime, 0);
	bonusAura:setTarget(kaiju);

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/regen_catalyst.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/wildvines_trigger1.plist", durationtime, 0, 0, false, true);
	
	playSound("shrubby_ability_RegenCatalyst");
	startAbilityUse(kaiju, abilityData.name);
	
	bonusSpeed = kaiju:getBaseStat("Speed") * bonusSpeedPct;
	kaiju:modStat("Speed", bonusSpeed);
	kaiju:addPassive("base_heal_bonus", bonusBaseRegen);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
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
		
end