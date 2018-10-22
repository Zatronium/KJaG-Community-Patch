local bonusSpeed = 0.0;
local bonusSpeedPercent = 0.5;
local chargeDuration = 2;
local avatar = 0;
function onUse(a)
	avatar = a;

	-- create aura that just calls an update to remove
	local boostAura = Aura.create(this, a);
	boostAura:setTag("gino_charge");
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(chargeDuration, 0); --updates at time 0 then at time 10
	boostAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/charge.plist", chargeDuration, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/charge.plist", chargeDuration, 0, 0, false, true);

	view:attachEffectToNode("root", "effects/charge_trigger.plist",0, 0, -40, true, false);
	view:attachEffectToNode("root", "effects/charge_trigger.plist",0, -40, -20, true, false);
	view:attachEffectToNode("root", "effects/charge_trigger.plist",0, 40, -20, true, false);
	view:attachEffectToNode("root", "effects/charge_trigger.plist",0, -80, 0, true, false);
	view:attachEffectToNode("root", "effects/charge_trigger.plist",0, 80,0, true, false);
	
	startAbilityUse(avatar, abilityData.name);
	
	a:charge();
	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= chargeDuration then
		avatar:regainControl();
		avatar:modStat("Speed", -bonusSpeed);
		endAbilityUse(avatar, abilityData.name);
		avatar:detachAura(aura);
	end
end