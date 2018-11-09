require 'scripts/avatars/common'

local kaiju = nil;
local bonusSpeed = 0.0;
local bonusDamagePercent = 0.2;
local bonusSpeedPercent = 0.3;
local durationtime = 30;
function onUse(a)
	kaiju = a;
	
	playAnimation(kaiju, "ability_cast");
	
	-- create aura that just calls an update to remove
	local buffAura = Aura.create(this, kaiju);
	buffAura:setTag('nuclear_surge');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(durationtime, 0);
	buffAura:setTarget(kaiju); -- required so aura doesn't autorelease

	local view = kaiju:getView();
	view:attachEffectToNode("foot_01", "effects/redzone.plist", durationtime, durationtime, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/redzone.plist", durationtime, durationtime, 0, false, true);
	view:attachEffectToNode("palm_node_01", "effects/redzone.plist", durationtime, durationtime, 0, false, false);
	view:attachEffectToNode("palm_node_02", "effects/redzone.plist", durationtime, durationtime, 0, false, false);
	
	startAbilityUse(kaiju, abilityData.name);
	
	kaiju:modStat("damage_amplify", bonusDamagePercent);

	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = kaiju:getBaseStat("Speed") * bonusSpeedPercent;
	kaiju:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("Speed", -bonusSpeed);
		kaiju:modStat("damage_amplify", -bonusDamagePercent);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end	
end