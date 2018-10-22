require 'scripts/common'

local avatar = nil;
local hasUpdated = false;
local bonusBaseRegen = 1.00;
local bonusSpeed = 0.0;
local bonusSpeedPct = -0.15;
local durationtime = 15;
function onUse(a)
	hasUpdated = false;
	avatar = a;
	local bonusAura = Aura.create(this, avatar);
	bonusAura:setTag('shrubby_regen_catalyst');
	bonusAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	bonusAura:setTickParameters(durationtime, 0);
	bonusAura:setTarget(avatar);

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/regen_catalyst.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/wildvines_trigger1.plist", durationtime, 0, 0, false, true);
	
	playSound("shrubby_ability_RegenCatalyst");
	startAbilityUse(avatar, abilityData.name);
	
	bonusSpeed = avatar:getBaseStat("Speed") * bonusSpeedPct;
	avatar:modStat("Speed", bonusSpeed);
	avatar:addPassive("base_heal_bonus", bonusBaseRegen);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		avatar:modStat("Speed", -bonusSpeed);
		avatar:addPassive("base_heal_bonus", -bonusBaseRegen);
		local a = aura:getOwner();
		a:detachAura(aura);
	end
		
end