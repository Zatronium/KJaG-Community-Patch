require 'scripts/common'

local enemyAcc = -15;
local durationtime = 60;

local kaiju = nil
local scriptAura = nil

function onUse(a)
	kaiju = a;
	
	kaiju:modStat("acc_notrack", enemyAcc);

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/goop_amorphous.plist", durationtime, 0, 0, false, true);
	--view:attachEffectToNode("root", "effects/kineticLayering_intro.plist", durationtime, 0, 0, true, false);
	
	playSound("goop_ability_MorpheusForm");

	startAbilityUse(kaiju, abilityData.name);
	
	scriptAura = createAura(this, kaiju, 0);
	scriptAura:setTag("goop_morpheus_form");
	scriptAura:setTickParameters(durationtime, 0);
	scriptAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	scriptAura:setTarget(a);
end

function onInterrupt()
	kaiju:modStat("acc_notrack", -enemyAcc);
	endAbilityUse(kaiju, abilityData.name);
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		kaiju:modStat("acc_notrack", -enemyAcc);
		endAbilityUse(kaiju, abilityData.name);
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
	end
end
