require 'scripts/avatars/common'

local avatar = nil;
local bonusSpeed = 0.0;
local bonusDamagePercent = 0.2;
local bonusSpeedPercent = 0.3;
local durationtime = 30;
function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "ability_cast");
	
	-- create aura that just calls an update to remove
	local buffAura = Aura.create(this, avatar);
	buffAura:setTag('nuclear_surge');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(durationtime, 0);
	buffAura:setTarget(avatar); -- required so aura doesn't autorelease

	local view = avatar:getView();
	view:attachEffectToNode("foot_01", "effects/redzone.plist", durationtime, durationtime, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/redzone.plist", durationtime, durationtime, 0, false, true);
	view:attachEffectToNode("palm_node_01", "effects/redzone.plist", durationtime, durationtime, 0, false, false);
	view:attachEffectToNode("palm_node_02", "effects/redzone.plist", durationtime, durationtime, 0, false, false);
	
	startAbilityUse(avatar, abilityData.name);
	
	avatar:modStat("damage_amplify", bonusDamagePercent);

	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = avatar:getBaseStat("Speed") * bonusSpeedPercent;
	avatar:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		local avatar = aura:getOwner();
		avatar:modStat("Speed", -bonusSpeed);
		avatar:modStat("damage_amplify", -bonusDamagePercent);
		avatar:detachAura(aura);
	end	
end