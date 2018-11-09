require 'scripts/avatars/common'
local kaiju = nil;
local moveAura = nil;
local passiveName = "dig_deep"
function onUse(a)
	kaiju = a;
	local curr = kaiju:hasPassive(passiveName); -- only need to check 1, we're assuming everything is cleaned and created at the same time
	if curr == 0 then --if off then on
		onON(kaiju);
	else -- else if on then off
		onOFF(kaiju);
	end
end

function onON(a)
	playSound("shrubby_ability_DigDeep");
	useResources(kaiju, abilityData.name);
	abilityInUse(kaiju, abilityData.name, true);
	abilityEnabled(kaiju, "ability_TakeRoot", false);
	kaiju:setImmobile(true);
	kaiju:addPassive("reduce_organic_cost", 1);
	
	moveAura = createAura(this, kaiju, 0);
	moveAura:setTickParameters(1, 0);
	moveAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	moveAura:setTarget(kaiju);

	local view = kaiju:getView();
	view:setAnimation("ability_root", false);
	view:addAnimation("idle", true);
	
	local effectID = view:attachEffectToNode("root", "effects/take_root_regen.plist", -1, 0, 0, false, true);
	a:setPassive(passiveName, effectID); -- use a differnet core shield with the next id eg "core_shield_1"	
end

function onOFF(a)
	startOnlyCooldown(a, abilityData.name);
	abilityInUse(a, abilityData.name, false);
	abilityEnabled(kaiju, "ability_TakeRoot", true);
	kaiju:setImmobile(false);
	kaiju:addPassive("reduce_organic_cost", -1);
	kaiju:detachAura(moveAura);
	local view = kaiju:getView();
	view:setAnimation("ability_unroot", false);
	view:addAnimation("idle", true);
	
	view:endEffect(a:hasPassive(passiveName)); -- make sure to do these 2 lines for each "core_sheld_x" you used
	a:removePassive(passiveName, 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
end

function onTick(aura)
	if not kaiju:isImmobile() then
		onOFF(kaiju);
	end
end
