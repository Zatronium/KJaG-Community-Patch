require 'scripts/common'

local kaiju = nil;
local cooldownPercent = 0.25;
local organicCostReduction = 1.0;
local durationtime = 30;
function onUse(a)
	kaiju = a;
	local bonusAura = Aura.create(this, kaiju);
	bonusAura:setTag('natures_bounty');
	bonusAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	bonusAura:setTickParameters(durationtime, 0);
	bonusAura:setTarget(kaiju);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/vitarays.plist", 0.5, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/naturebounty1.plist", durationtime, 0, 0, false, true);
	
	playSound("shrubby_ability_NaturesBounty");
	startAbilityUse(kaiju, abilityData.name);
	if a:hasStat("CoolDownReductionPercent") then
		a:modStat("CoolDownReductionPercent", cooldownPercent);
	else
		a:addStat("CoolDownReductionPercent", cooldownPercent);
	end
	kaiju:addPassive("reduce_organic_cost", organicCostReduction);

end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("CoolDownReductionPercent", -cooldownPercent);
		kaiju:addPassive("reduce_organic_cost", -organicCostReduction);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end