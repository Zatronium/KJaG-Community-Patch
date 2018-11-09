require 'scripts/avatars/common'

local kaiju = nil;
local bonusDamagePercent = 0.5;
local bonusSpeedPercent = 0.5;
local bonusCDR = 0.2;

local durationtime = 30;
local timer = durationtime;


function onUse(a)
	timer = durationtime
	kaiju = a;
	playAnimation(kaiju, "ability_stomp");
	
	local buffAura = Aura.create(this, a);
	buffAura:setTag('failsafe');
	buffAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	buffAura:setTickParameters(1, 0); 
	buffAura:setTarget(a);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/failsafe_back.plist",durationtime, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/failsafe_front.plist",durationtime, 0, 0, true, false);
	
	startCooldown(a, abilityData.name);
	
	kaiju:modStat("damage_amplify", bonusDamagePercent);
	local bonusSpeed = kaiju:getBaseStat("Speed") * bonusSpeedPercent;
	kaiju:modStat("Speed", bonusSpeed);
	kaiju:modStat("CoolDownReductionPercent", bonusCDR);
end

function onTick(aura)
	if not aura then
		return
	end
	timer = timer - 1;
	if timer <= 0 then
		local wp = kaiju:getWorldPosition();
		createEffectInWorld("effects/impact_fireRingBack_large.plist"	,wp ,1);
		createEffectInWorld("effects/collapseSmokeDark_large.plist"		,wp ,1);
		createEffectInWorld("effects/impact_BoomRisingXlrg.plist"		,wp ,1);
		createEffectInWorld("effects/impact_fireCloud_linger.plist"		,wp ,1);
		createEffectInWorld("effects/impact_dustCloud_med.plist"		,wp ,1);
		createEffectInWorld("effects/impact_boomCore_xlrg.plist"		,wp ,1);
		createEffectInWorld("effects/impact_fireRingFront_large.plist"	,wp ,1);
		createEffectInWorld("effects/impact_boomXlrg.plist"				,wp ,1);
		createEffectInWorld("effects/impact_mushCloud_small.plist"		,wp ,1);

		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
		kaiju:loseControl();
		local deathAura = Aura.create(this, kaiju);
		deathAura:setTag('death_failsafe');
		deathAura:setScriptCallback(AuraEvent.OnTick, 'onDeathDelayTick');
		deathAura:setTickParameters(2, 0); 
		deathAura:setTarget(kaiju);
	else
		createSystemText(timer, 0);
	end
end

function onDeathDelayTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= 1 then
		kaiju:setStat("Health", 0);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end