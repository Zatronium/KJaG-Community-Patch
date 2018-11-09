require 'scripts/avatars/common'

local kaiju = 0;
local durationtime = 10;

local PdValue = 100;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_channel");
	
	kaiju:misdirectMissiles(1.0, false);
	kaiju:modStat("PD_Tracking", PdValue);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/chaffBlossomLeft.plist", durationtime, -110, 100, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomRight.plist", durationtime, 110, 100, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomLeft.plist", durationtime, -80, 180, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomRight.plist", durationtime, 80, 180, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomLeft.plist", durationtime, -50, 280, true, false);
	view:attachEffectToNode("root", "effects/chaffBlossomRight.plist", durationtime, 50, 280, true, false);
	playSound("shrubby_ability_ChaffBlossom");
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTag("shrubby_chaff_blossom");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("PD_Tracking", -PdValue);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end