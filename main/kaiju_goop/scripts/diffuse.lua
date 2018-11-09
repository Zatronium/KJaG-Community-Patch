require 'scripts/common'
-- 50% chance to avoid damage, all Kaiju damage -30%;
local durationtime = 30;
local damagePercent = -0.3;
local absorbPercent = 50;

local kaiju = nil
local scriptAura = nil

function onUse(a)
	kaiju = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/goop_diffusion.plist", durationtime, 0, 0, false, true);
	--view:attachEffectToNode("root", "effects/kineticLayering_intro.plist", durationtime, 0, 0, true, false);

	a:addPassiveScript(this);
	a:modStat("damage_amplify", damagePercent);

	startAbilityUse(kaiju, abilityData.name);
	
	scriptAura = createAura(this, kaiju, 0);
	scriptAura:setTag("goop_diffuse");
	scriptAura:setTickParameters(durationtime, 0);
	scriptAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	scriptAura:setTarget(a);
	
	playSound("goop_ability_Diffuse");
end

function onInterrupt()
	kaiju = entityToAvatar(scriptAura:getOwner());
	endAbilityUse(kaiju, abilityData.name);
	kaiju:removePassiveScript(this);
	kaiju:modStat("damage_amplify", -damagePercent);
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if not aura then return end
	local owner = aura:getOwner()
	if not owner then
		aura = nil return
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(owner, abilityData.name);
		owner:removePassiveScript(this);
		owner:modStat("damage_amplify", -damagePercent);
		owner:detachAura(aura);
	end
end

function onAvatarAbsorb(a, n, w)
	if n.y > 0 and math.random(0, 100) < absorbPercent then
		n.x = 0;
	--	local view = a:getView();
	--	view:attachEffectToNode("root", "effects/kineticLayering_hitShockwave.plist", 0, 0, 0, false, true);
	--	view:attachEffectToNode("root", "effects/kineticLayering_hitAbsorb.plist", 0, 0, 0, true, false);
	end
end