local damageTaken = 1.2;
local bonusDamageMult = 1;
local duration = 18;
local speedIncrease = 0.25;
local speedValue = 0;
local kaiju = nil;
function onUse(a)
	kaiju = a;
	if a:hasStat("damage_resist") then
		local resist = a:getStat("damage_resist");
		resist = resist * damageTaken;
		a:setStat("damage_resist", damageres);
	else
		a:addStat("damage_resist", damageTaken);
	end
	speedValue = a:getStat("Speed") * speedIncrease;
	a:modStat("Speed", speedValue);
	
	a:setPassive("stack_overflow", bonusDamageMult);
	a:rampage();
	
	startAbilityUse(kaiju, abilityData.name);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/stackOverflow_back.plist", duration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/stackOverflow_front.plist", duration, 0,0, true, false);

	local controlAura = Aura.create(this, a);
	controlAura:setTag("gino_stackoverflow");
	controlAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	controlAura:setTickParameters(duration, 0); --updates at time 0 then at time 10
	controlAura:setTarget(a); -- required so aura doesn't autorelease
end


function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		kaiju:regainControl();
		kaiju:modStat("Speed", -speedValue);
		local damageres = kaiju:getStat("damage_resist") / damageTaken;
		kaiju:setStat("damage_resist", damageres);
		kaiju:removePassive("stack_overflow", 0);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end