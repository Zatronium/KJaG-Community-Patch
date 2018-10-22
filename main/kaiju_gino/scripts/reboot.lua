require 'scripts/common'

local avatar = nil;

local freezeDuration = 5;

function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "roar");
	registerAnimationCallback(this, avatar, "start");
	
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/powerDown_back.plist", 0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/powerDown_front.plist", 0, 0, 0, true, false);
	view:pauseAnimation(freezeDuration);
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('reboot');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rebootAura:setTickParameters(freezeDuration, 0); --updates every second                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
	
	a:loseControl();
	startAbilityUse(avatar, abilityData.name);
end

function onTick(aura)
	if aura:getElapsed() >= freezeDuration then
		local maxHealth = avatar:getStat("MaxHealth");
		avatar:gainHealth(maxHealth);
		local curPower = getKaijuResource("power");
		local lostPower = 0.5 * curPower;
		addKaijuResource("power", -lostPower);
		avatar:regainControl();
		local view = avatar:getView();
		view:attachEffectToNode("root", "effects/pulseVertical_back.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/pulseVertical_front.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/reboot_health.plist", 0, 0, 0, true, false);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end
