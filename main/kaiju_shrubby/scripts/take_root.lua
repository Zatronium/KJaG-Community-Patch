require 'scripts/avatars/common'
local kaiju = nil;
local organicPerSecond = 10;
local healAura = nil;
local passiveName = "take_root"
function onUse(a)
	kaiju = a;
	local curr = kaiju:hasPassive(passiveName); -- only need to check 1, we're assuming everything is cleaned and created at the same time
	if curr == 0 then --if off then on
		onON(kaiju);
	else -- else if on then off
		onOFF(kaiju);
	end
end

function onON()
	playSound("shrubby_ability_TakeRoot");
	useResources(kaiju, abilityData.name);
	abilityInUse(kaiju, abilityData.name, true);
	kaiju:setImmobile(true);
	
	healAura = createAura(this, kaiju, 0);
	healAura:setTickParameters(1, 0);
	healAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	healAura:setTarget(kaiju);

	local view = kaiju:getView();
	view:setAnimation("ability_root", false);
	view:addAnimation("idle", true);
	
	local effectID = view:attachEffectToNode("root", "effects/take_root_regen.plist", -1, 0, 0, false, true);
	kaiju:setPassive(passiveName, effectID); -- use a differnet core shield with the next id eg "core_shield_1"	
end

function onOFF()
	abilityInUse(kaiju, abilityData.name, false);
	startOnlyCooldown(kaiju, abilityData.name);
	kaiju:setImmobile(false);
	kaiju:detachAura(healAura);
	local view = kaiju:getView();
	view:setAnimation("ability_unroot", false);
	view:addAnimation("idle", true);
	
	view:endEffect(kaiju:hasPassive(passiveName)); -- make sure to do these 2 lines for each "core_sheld_x" you used
	kaiju:removePassive(passiveName, 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
end

function onTick(aura)
	if kaiju:isImmobile() then
		kaiju:gainOrganic(organicPerSecond);
	else
		onOFF();
	end
end
