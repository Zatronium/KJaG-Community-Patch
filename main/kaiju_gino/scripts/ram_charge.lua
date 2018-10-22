local bonusSpeed = 0.0;
local bonusSpeedPercent = 0.5;
local chargeDuration = 2;
local avatar = 0;
local resist = 0.75;
function onUse(a)
	avatar = a;

	-- create aura that just calls an update to remove
	boostAura = Aura.create(this, a);
	boostAura:setTag('charge');
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(chargeDuration, 0); --updates at time 0 then at time 10
	boostAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/ramCharge.plist", chargeDuration, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/ramCharge.plist", chargeDuration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/ramCharge_triggerBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/ramCharge_triggerFront.plist",0, 0, 0, true, false);
	
	startAbilityUse(avatar, abilityData.name);
	
	if not avatar:hasStat("damage_resist") then
		avatar:addStat("damage_resist", 1.0);
	end
	local damageres = avatar:getStat("damage_resist");
	damageres = damageres * (1 - resist);
	avatar:setStat("damage_resist", damageres);
	
	a:charge();
	--store bonus total (NOTE: may need a "getBaseStat" and go off of that, but minor concern)
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if aura:getElapsed() >= chargeDuration then
		avatar:regainControl();
		avatar:modStat("Speed", -bonusSpeed);
		local damageres = avatar:getStat("damage_resist");
		damageres = damageres / (1 - resist);
		avatar:setStat("damage_resist", damageres);
		endAbilityUse(avatar, abilityData.name);
		avatar:detachAura(aura);
	end
end