local kaiju = nil;
local bonusDamagePct = 1;
local fx1 = 0;
local fx2 = 0;
function onUse(a)
	kaiju = a;
	local view = kaiju:getView();
	kaiju:setPassive("enhancement", bonusDamagePct);
	fx1 = view:attachEffectToNode("root", "effects/enhancement_back.plist",-1, 0, 0, false, true);
	fx2 = view:attachEffectToNode("root", "effects/enhancement_front.plist",-1, 0, 0, true, false);
	local deathAura = Aura.create(this, kaiju);
	deathAura:setTag('enhance_fx');
	deathAura:setScriptCallback(AuraEvent.OnTick, 'onFxCheck');
	deathAura:setTickParameters(2, 0); 
	deathAura:setTarget(kaiju);
end

function onFxCheck(aura)
	if kaiju:hasPassive("enhancement") == 0 then
		local view = kaiju:getView();
		view:endEffect(fx1);
		view:endEffect(fx2);
		kaiju:detachAura(aura);
	end
end

--local empower = kaiju:hasPassive("enhancement");
--kaiju:removePassive("enhancement", 0);
--abilityEnhance(empower);
--abilityEnhance(0);
	