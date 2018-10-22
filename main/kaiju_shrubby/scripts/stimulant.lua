require 'scripts/common'

local avatar = nil;
local hasUpdated = false;
local bonusSpeed = 0.0;
local bonusSpeedPct = 0.25;
local bonusBaseRegen = 0.25;
local durationtime = 10;
function onUse(a)
	hasUpdated = false;
	avatar = a;
	local bonusAura = Aura.create(this, avatar);
	bonusAura:setTag('shrubby_stimulant');
	bonusAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	bonusAura:setTickParameters(durationtime, durationtime);
	bonusAura:setTarget(avatar);

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/stimulant1.plist", 0.7, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/booster.plist", durationtime, 0, 0, false, true); -- legL/legR or leg_far/leg_near
--	view:attachEffectToNode("legR", "effects/booster.plist", durationtime, 0, 0, false, true);
	
	playSound("shrubby_ability_Stimulant");
	startAbilityUse(avatar, abilityData.name);

	bonusSpeed = avatar:getBaseStat("Speed") * bonusSpeedPct;
	avatar:modStat("Speed", bonusSpeed);
	avatar:addPassive("base_heal_bonus", bonusBaseRegen);

end

function onTick(aura)
	if hasUpdated then
		endAbilityUse(avatar, abilityData.name);
		avatar:modStat("Speed", -bonusSpeed);
		avatar:addPassive("base_heal_bonus", -bonusBaseRegen);
		local a = aura:getOwner();
		a:detachAura(aura);
	end
		
	hasUpdated = true;
end