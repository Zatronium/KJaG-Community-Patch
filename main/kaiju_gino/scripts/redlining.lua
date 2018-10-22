local energyGain = 1.0;
local healthCost = 20;
local avatar = 0;
local duration = 10;
local hasUpdated = false;
function onUse(a)
	avatar = a;
	local health = avatar:getStat("Health");
	health = health - healthCost;
	if health > 0 then
		local curr = avatar:hasPassive("power_gain_bonus");
		curr = curr + energyGain;
		avatar:setPassive("power_gain_bonus", curr);
		startAbilityUse(avatar, abilityData.name);
		local view = a:getView();
		view:attachEffectToNode("root", "effects/redlining_back.plist", duration, 0,0, false, true);
		view:attachEffectToNode("root", "effects/redlining_pulseBack.plist", duration, 0,0, false, true);
		view:attachEffectToNode("root", "effects/redlining_front.plist", duration, 0,0, true, false);
		view:attachEffectToNode("root", "effects/redlining_pulseFront.plist", duration, 0,0, true, false);

		avatar:setStat("Health", health);
		local aura = createAura(this, avatar, "gino_redlining");
		aura:setTickParameters(duration, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(a);
	end
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		local curr = avatar:hasPassive("power_gain_bonus");
		curr = curr - energyGain;
		avatar:removePassive("power_gain_bonus", curr);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end