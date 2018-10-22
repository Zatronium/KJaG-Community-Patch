require 'scripts/avatars/common'
local avatar = nil;
local bonusSpeedPercent = -0.2;
local zoneDodge = 0.5;
function onUse(a)
	avatar = a;
	if avatar:hasPassive("sneaking") == 0 then --if off then on
		avatar:setPassive("sneaking", 0);
		onON(avatar);
	else -- else if on then off
		onOFF(avatar);
	end
end

function onON(a)
--	playSound("shrubby_ability_DigDeep");
	useResources(a, abilityData.name);
	abilityInUse(a, abilityData.name, true);
	local bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:removePassive("sneaking", bonusSpeed);
	a:modStat("Speed", bonusSpeed);
	a:modStat("NegateZoneAttack", zoneDodge);
	
--	local effectID = view:attachEffectToNode("root", "effects/take_root_regen.plist", -1, 0, 0, false, true);
--	a:setPassive(passiveName, effectID); -- use a differnet core shield with the next id eg "core_shield_1"	
	local view = a:getView();
	local fx1 = view:attachEffectToNode("foot_01", "effects/creeping.plist", -1, 0, 0, false, true);
	local fx2 = view:attachEffectToNode("foot_02", "effects/creeping.plist", -1, 0, 0, false, true);
	
	a:setPassive("sneak_1", fx1);
	a:setPassive("sneak_2", fx2);
	
	a:getControl():setCurrentWalk("walk_stealth");
end

function onOFF(a)
	abilityInUse(a, abilityData.name, false);
	startOnlyCooldown(a, abilityData.name);
	local bonusSpeed = avatar:hasPassive("sneaking");
	a:removePassive("sneaking", 0);
	
	a:modStat("Speed", -bonusSpeed);
	a:modStat("NegateZoneAttack", -zoneDodge);
	
	local view = a:getView();
	view:endEffect(a:hasPassive("sneak_1"));
	view:endEffect(a:hasPassive("sneak_2"));
	
	a:removePassive("sneak_1", 0);
	a:removePassive("sneak_2", 0);
	
	a:getControl():setCurrentWalk("");
--	view:endEffect(a:hasPassive(passiveName)); -- make sure to do these 2 lines for each "core_sheld_x" you used
--	a:removePassive(passiveName, 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
end