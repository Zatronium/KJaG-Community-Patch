local energyGain = 1.0;
local healthCost = 20;
local kaiju = nil
local duration = 10;
local hasUpdated = false;
function onUse(a)
	kaiju = a;
	local health = kaiju:getStat("Health");
	health = health - healthCost;
	if health > 0 then
		local curr = kaiju:hasPassive("power_gain_bonus");
		curr = curr + energyGain;
		kaiju:setPassive("power_gain_bonus", curr);
		startAbilityUse(kaiju, abilityData.name);
		local view = a:getView();
		view:attachEffectToNode("root", "effects/redlining_back.plist", duration, 0,0, false, true);
		view:attachEffectToNode("root", "effects/redlining_pulseBack.plist", duration, 0,0, false, true);
		view:attachEffectToNode("root", "effects/redlining_front.plist", duration, 0,0, true, false);
		view:attachEffectToNode("root", "effects/redlining_pulseFront.plist", duration, 0,0, true, false);

		kaiju:setStat("Health", health);
		local aura = createAura(this, kaiju, "gino_redlining");
		aura:setTickParameters(duration, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(a);
	end
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		local curr = kaiju:hasPassive("power_gain_bonus");
		curr = curr - energyGain;
		kaiju:removePassive("power_gain_bonus", curr);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end