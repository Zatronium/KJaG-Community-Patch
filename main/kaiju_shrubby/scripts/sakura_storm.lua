require 'scripts/avatars/common'

local kaiju = 0;
local durationtime = 30;
local hasUpdated = false;

local PdValue = 100;
local accDebuff = -0.1;
local accValue = 0;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_channel");
	
	kaiju:misdirectMissiles(1.0, false);
	accValue = kaiju:getStat("acc_notrack") * accDebuff;
	kaiju:modStat("acc_notrack", accValue);
	kaiju:modStat("PD_Tracking", PdValue);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/sakuraStormPetals.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormAura_back.plist", durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/sakuraStormAura_front.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormLeft.plist", durationtime, -110, 100, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormRight.plist", durationtime, 110, 100, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormLeft.plist", durationtime, -80, 180, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormRight.plist", durationtime, 80, 180, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormLeft.plist", durationtime, -50, 280, true, false);
	view:attachEffectToNode("root", "effects/sakuraStormRight.plist", durationtime, 50, 280, true, false);
	playSound("shrubby_ability_SakuraStorm");
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
end

function onTick(aura)
	if not aura then return end
	if hasUpdated then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:modStat("acc_notrack", -accValue);
		kaiju:modStat("PD_Tracking", -PdValue);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
	hasUpdated = true;
end