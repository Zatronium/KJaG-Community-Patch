local duration = 10;
local avatar = nil;
function onUse(a)
	avatar = a;
	avatar:misdirectMissiles(1.0, false);
	avatar:setEnablePhysicsBody(false);
	avatar:setPassive("ignore_proj", 100);
	
	avatar:getView():setKaijuVisible(false);
	playSound("shrubby_ability_BendingWillow");
	startAbilityUse(avatar, abilityData.name);
	
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/vanish_trailing.plist", 0, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 40, 20, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, -80, 40, true, false);
	view:attachEffectToNode("root", "effects/vanish.plist", 0, 80,40, true, false);
	view:attachEffectToNode("root", "effects/willowBack.plist", duration, 0,0, false, true);
	view:attachEffectToNode("root", "effects/willowFront.plist", duration, 0,0, true, false);
	
	local vanishAura = Aura.create(this, avatar);
	vanishAura:setTag("shrubby_bending_willow");
	vanishAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	vanishAura:setTickParameters(duration, duration);
	vanishAura:setTarget(avatar); -- required so aura doesn't autorelease
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		endAbilityUse(avatar, abilityData.name);
		avatar:setEnablePhysicsBody(true);
		avatar:removePassive("ignore_proj", 0);
		avatar:getView():setKaijuVisible(true);
		aura:getOwner():detachAura(aura);
	end
end