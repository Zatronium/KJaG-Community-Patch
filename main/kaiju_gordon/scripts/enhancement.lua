local avatar = nil;
local bonusDamagePct = 1;
local fx1 = 0;
local fx2 = 0;
function onUse(a)
	avatar = a;
	local view = avatar:getView();
	avatar:setPassive("enhancement", bonusDamagePct);
	fx1 = view:attachEffectToNode("root", "effects/enhancement_back.plist",-1, 0, 0, false, true);
	fx2 = view:attachEffectToNode("root", "effects/enhancement_front.plist",-1, 0, 0, true, false);
	local deathAura = Aura.create(this, avatar);
	deathAura:setTag('enhance_fx');
	deathAura:setScriptCallback(AuraEvent.OnTick, 'onFxCheck');
	deathAura:setTickParameters(2, 0); 
	deathAura:setTarget(avatar);
end

function onFxCheck(aura)
	if avatar:hasPassive("enhancement") == 0 then
		local view = avatar:getView();
		view:endEffect(fx1);
		view:endEffect(fx2);
		avatar:detachAura(aura);
	end
end

--local empower = avatar:hasPassive("enhancement");
--avatar:removePassive("enhancement", 0);
--abilityEnhance(empower);
--abilityEnhance(0);
	