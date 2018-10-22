require 'scripts/avatars/common'

local avatar = nil;
local bonusSpeed = 0.0;
local coolDownReductionPercent = 0.2;
local bonusSpeedPercent = 0.2;
local durationtime = 10;
function onUse(a)
	avatar = a;
	playSound("NuclearSurge");
	playAnimation( a, "ability_cast");
	
	-- create aura that just calls an update to remove
	local buffAura = Aura.create(this, avatar);
	buffAura:setTag('nuclear_surge');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(durationtime, 0);
	buffAura:setTarget(avatar); -- required so aura doesn't autorelease

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/nuclearSurgeBack.plist",durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/nuclearSurgeFront.plist",durationtime, 0, 0, true, false);
	
	startAbilityUse(avatar, abilityData.name);
	
	--since this is actually a percent, it will be like this
	avatar:modStat("CoolDownReductionPercent", coolDownReductionPercent);

	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = avatar:getBaseStat("Speed") * bonusSpeedPercent;
	avatar:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		local avatar = aura:getOwner();
		avatar:modStat("Speed", -bonusSpeed);
		avatar:modStat("CoolDownReductionPercent", -coolDownReductionPercent);
		avatar:detachAura(aura);
	end	
end