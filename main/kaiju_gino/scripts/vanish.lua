local hasUpdated = false;
local duration = 5;
local avatar = nil;
function onUse(a)
	avatar = a;
	hasUpdated = false;
	a:misdirectMissiles(1.0, false);
	a:setEnablePhysicsBody(false);
	avatar:setPassive("ignore_proj", 100);
	a:getView():setKaijuVisible(false);
	startAbilityUse(avatar, abilityData.name);
	
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
	if aura:getElapsed() >= duration then
		avatar:setEnablePhysicsBody(true);
		avatar:removePassive("ignore_proj", 0);
		avatar:getView():setKaijuVisible(true);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
	hasUpdated = true;
end