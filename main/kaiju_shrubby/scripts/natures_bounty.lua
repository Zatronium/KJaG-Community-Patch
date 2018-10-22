require 'scripts/common'

local avatar = nil;
local cooldownPercent = 0.25;
local organicCostReduction = 1.0;
local durationtime = 30;
function onUse(a)
	avatar = a;
	local bonusAura = Aura.create(this, avatar);
	bonusAura:setTag('natures_bounty');
	bonusAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	bonusAura:setTickParameters(durationtime, 0);
	bonusAura:setTarget(avatar);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/vitarays.plist", 0.5, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/naturebounty1.plist", durationtime, 0, 0, false, true);
	
	playSound("shrubby_ability_NaturesBounty");
	startAbilityUse(avatar, abilityData.name);
	if a:hasStat("CoolDownReductionPercent") then
		a:modStat("CoolDownReductionPercent", cooldownPercent);
	else
		a:addStat("CoolDownReductionPercent", cooldownPercent);
	end
	avatar:addPassive("reduce_organic_cost", organicCostReduction);

end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		avatar:modStat("CoolDownReductionPercent", -cooldownPercent);
		avatar:addPassive("reduce_organic_cost", -organicCostReduction);
		aura:getOwner():detachAura(aura);
	end
end