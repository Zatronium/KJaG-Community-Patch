require 'scripts/avatars/common'

local enemyAccPercent = 0.05;
local bonusSpeedPercent = 0.3;
local duration = 20;

local avatar = nil;
local bonusSpeed = 0;
local enemyAcc = 0;

function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "ability_stomp");
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('combat_maneuvers');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(duration, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/combat_maneuvers.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/combat_maneuvers.plist", duration, 0, 0, false, true);
	
	startAbilityUse(avatar, abilityData.name);

	enemyAcc = avatar:getStat("acc_notrack") * enemyAccPercent;
	bonusSpeed = avatar:getBaseStat("Speed") * bonusSpeedPercent;
	avatar:modStat("Speed", bonusSpeed);
	avatar:modStat("acc_notrack", -enemyAcc);
	
	playSound("CombatManuevers");
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		local a = aura:getOwner();
		a:modStat("Speed", -bonusSpeed);
		a:modStat("acc_notrack", enemyAcc);
		endAbilityUse(avatar, abilityData.name);
		a:detachAura(aura);
	end
end