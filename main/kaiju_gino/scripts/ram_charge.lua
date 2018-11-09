local bonusSpeed = 0.0;
local bonusSpeedPercent = 0.5;
local chargeDuration = 2;
local kaiju = nil
local resist = 0.25;
function onUse(a)
	kaiju = a;

	-- create aura that just calls an update to remove
	local boostAura = Aura.create(this, a);
	boostAura:setTag('charge');
	boostAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	boostAura:setTickParameters(chargeDuration, 0); --updates at time 0 then at time 10
	boostAura:setTarget(a); -- required so aura doesn't autorelease

	local view = a:getView();
	view:attachEffectToNode("foot_01", "effects/ramCharge.plist", chargeDuration, 0, 0, false, true);
	view:attachEffectToNode("foot_02", "effects/ramCharge.plist", chargeDuration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/ramCharge_triggerBack.plist",0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/ramCharge_triggerFront.plist",0, 0, 0, true, false);
	
	startAbilityUse(kaiju, abilityData.name);
	
	if not kaiju:hasStat("damage_resist") then
		kaiju:addStat("damage_resist", 1.0);
	end
	local damageres = kaiju:getStat("damage_resist") * resist
	kaiju:setStat("damage_resist", damageres);
	
	a:charge();
	
	bonusSpeed = a:getBaseStat("Speed") * bonusSpeedPercent;
	a:modStat("Speed", bonusSpeed);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= chargeDuration then
		kaiju:regainControl();
		kaiju:modStat("Speed", -bonusSpeed);
		local damageres = kaiju:getStat("damage_resist") / resist
		kaiju:setStat("damage_resist", damageres);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end