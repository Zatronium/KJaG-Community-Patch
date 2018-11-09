local healPerTick = 2;
local durationtime = 30;
local ticktime = 1;

local kaiju = nil
local scriptAura = nil

function onUse(a)
	kaiju = a;

	local view = a:getView();
	--view:attachEffectToNode("root", "effects/nature_regenCore.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/absorption_heal.plist", durationtime, 0, 0, true, false);
	
	scriptAura = createAura(this, kaiju, 0);
	scriptAura:setTag("goop_regenerative");
	scriptAura:setTickParameters(ticktime, 0);
	scriptAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	scriptAura:setTarget(kaiju);
	
	startAbilityUse(kaiju, abilityData.name);

	playSound("goop_ability_Regenerative");
end

function onInterrupt()
	kaiju = entityToAvatar(scriptAura:getOwner());
	endAbilityUse(kaiju, abilityData.name);
	local owner = scriptAura:getOwner()
	if not owner then
		scriptAura = nil return
	else
		owner:detachAura(scriptAura);
	end
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= durationtime then
		local owner = aura:getOwner()
		endAbilityUse(kaiju, abilityData.name);
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
	else
		kaiju:gainHealth(healPerTick);
	end
end