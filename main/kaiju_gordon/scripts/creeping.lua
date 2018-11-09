require 'scripts/avatars/common'
local kaiju = nil;
local bonusSpeedPercent = -0.2;
local zoneDodge = 0.2;

function onUse(a)
	kaiju = a;
	
	if kaiju:hasPassive("creeping") == 0 then --if off then on
		kaiju:setPassive("creeping", 0);
		onON(kaiju);
	else -- else if on then off
		onOFF(kaiju);
	end
end

function onON(a)
--	playSound("shrubby_ability_DigDeep");
	useResources(a, abilityData.name);
	abilityInUse(a, abilityData.name, true);
	local bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:removePassive("creeping", bonusSpeed);
	a:modStat("Speed", bonusSpeed);
	a:modStat("NegateZoneAttack", zoneDodge);
	
--	local effectID = view:attachEffectToNode("root", "effects/take_root_regen.plist", -1, 0, 0, false, true);
--	a:setPassive(passiveName, effectID); -- use a differnet core shield with the next id eg "core_shield_1"	

	local view = a:getView();
	local fx1 = view:attachEffectToNode("foot_01", "effects/creeping.plist", -1, 0, 0, false, true);
	local fx2 = view:attachEffectToNode("foot_02", "effects/creeping.plist", -1, 0, 0, false, true);
	
	a:setPassive("creep_1", fx1);
	a:setPassive("creep_2", fx2);
	
	a:getControl():setCurrentWalk("walk_stealth");
end

function onOFF(a)
	abilityInUse(a, abilityData.name, false);
	startOnlyCooldown(a, abilityData.name);
	local bonusSpeed = a:hasPassive("creeping");
	a:removePassive("creeping", 0);
	
	a:modStat("Speed", -bonusSpeed);
	a:modStat("NegateZoneAttack", -zoneDodge);
	
	local view = a:getView();
	view:endEffect(a:hasPassive("creep_1"));
	view:endEffect(a:hasPassive("creep_2"));
	
	a:removePassive("creep_1", 0);
	a:removePassive("creep_2", 0);
	
	a:getControl():setCurrentWalk("");
	
--	view:endEffect(a:hasPassive(passiveName)); -- make sure to do these 2 lines for each "core_sheld_x" you used
--	a:removePassive(passiveName, 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
end