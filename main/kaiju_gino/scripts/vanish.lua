
local duration = 5;
local kaiju = nil;
function onUse(a)
	kaiju = a;
	a:misdirectMissiles(1.0, false);
	a:setEnablePhysicsBody(false);
	kaiju:setPassive("ignore_proj", 100);
	a:getView():setKaijuVisible(false);
	startAbilityUse(kaiju, abilityData.name);
	
	local view = a:getView();
	view:attachEffectToNode("root", "effects/vanish_trailing.plist", 0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -80, 40, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 80,40, true, false);
	view:attachEffectToNode("root", "effects/pulseVertical_back.plist", 0, 0,0, false, true);
	view:attachEffectToNode("root", "effects/pulseVertical_front.plist", 0, 0,0, true, false);
	
	local vanishAura = Aura.create(this, a);
	vanishAura:setTag("gino_vanish");
	vanishAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	vanishAura:setTickParameters(duration, 0);
	vanishAura:setTarget(a); -- required so aura doesn't autorelease
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= duration then
		kaiju:setEnablePhysicsBody(true);
		kaiju:removePassive("ignore_proj", 0);
		kaiju:getView():setKaijuVisible(true);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end