require 'scripts/avatars/common'
local avatar = nil;
local organicPerSecond = 10;
local healAura = nil;
local passiveName = "take_root"
function onUse(a)
	avatar = a;
	local curr = avatar:hasPassive(passiveName); -- only need to check 1, we're assuming everything is cleaned and created at the same time
	if curr == 0 then --if off then on
		onON(avatar);
	else -- else if on then off
		onOFF(avatar);
	end
end

function onON(a)
	playSound("shrubby_ability_TakeRoot");
	useResources(avatar, abilityData.name);
	abilityInUse(avatar, abilityData.name, true);
	avatar:setImmobile(true);
	
	healAura = createAura(this, avatar, 0);
	healAura:setTickParameters(1, 0);
	healAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	healAura:setTarget(avatar);

	local view = avatar:getView();
	view:setAnimation("ability_root", false);
	view:addAnimation("idle", true);
	
	local effectID = view:attachEffectToNode("root", "effects/take_root_regen.plist", -1, 0, 0, false, true);
	a:setPassive(passiveName, effectID); -- use a differnet core shield with the next id eg "core_shield_1"	
end

function onOFF(a)
	abilityInUse(avatar, abilityData.name, false);
	startOnlyCooldown(a, abilityData.name);
	avatar:setImmobile(false);
	avatar:detachAura(healAura);
	local view = avatar:getView();
	view:setAnimation("ability_unroot", false);
	view:addAnimation("idle", true);
	
	view:endEffect(a:hasPassive(passiveName)); -- make sure to do these 2 lines for each "core_sheld_x" you used
	a:removePassive(passiveName, 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
end

function onTick(aura)
	if avatar:isImmobile() then
		avatar:gainOrganic(organicPerSecond);
	else
		onOFF(avatar);
	end
end
