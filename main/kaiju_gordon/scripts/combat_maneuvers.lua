require 'scripts/avatars/common'

local enemyAccPercent = 0.05;
local bonusSpeedPercent = 0.3;
local duration = 20;

local kaiju = nil;
local bonusSpeed = 0;
local enemyAcc = 0;

function onUse(a)
	kaiju = a;
	
	playAnimation(kaiju, "ability_stomp");
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('combat_maneuvers');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(duration, 0); 
	buffAura:setTarget(a);

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/combat_maneuvers.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/combat_maneuvers.plist", duration, 0, 0, false, true);
	
	startAbilityUse(kaiju, abilityData.name);

	enemyAcc = kaiju:getStat("acc_notrack") * enemyAccPercent;
	bonusSpeed = kaiju:getBaseStat("Speed") * bonusSpeedPercent;
	kaiju:modStat("Speed", bonusSpeed);
	kaiju:modStat("acc_notrack", -enemyAcc);
	
	playSound("CombatManuevers");
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		kaiju:modStat("Speed", -bonusSpeed);
		kaiju:modStat("acc_notrack", enemyAcc);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end