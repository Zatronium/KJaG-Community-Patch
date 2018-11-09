require 'scripts/avatars/common'

local kaiju = nil;
local bonusSpeed = 0.0;
local coolDownReductionPercent = 0.2;
local bonusSpeedPercent = 0.2;
local durationtime = 10;
function onUse(a)
	kaiju = a;
	playSound("NuclearSurge");
	playAnimation( a, "ability_cast");
	
	-- create aura that just calls an update to remove
	local buffAura = Aura.create(this, kaiju);
	buffAura:setTag('nuclear_surge');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(durationtime, 0);
	buffAura:setTarget(kaiju); -- required so aura doesn't autorelease

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/nuclearSurgeBack.plist",durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/nuclearSurgeFront.plist",durationtime, 0, 0, true, false);
	
	startAbilityUse(kaiju, abilityData.name);
	
	--since this is actually a percent, it will be like this
	kaiju:modStat("CoolDownReductionPercent", coolDownReductionPercent);

	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = kaiju:getBaseStat("Speed") * bonusSpeedPercent;
	kaiju:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("Speed", -bonusSpeed);
		kaiju:modStat("CoolDownReductionPercent", -coolDownReductionPercent);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end	
end