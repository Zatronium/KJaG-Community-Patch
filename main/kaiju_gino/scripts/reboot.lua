require 'scripts/common'

local kaiju = nil;

local freezeDuration = 5;

function onUse(a)
	kaiju = a;
	
	playAnimation(kaiju, "roar");
	registerAnimationCallback(this, kaiju, "start");
	
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/powerDown_back.plist", 0, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/powerDown_front.plist", 0, 0, 0, true, false);
	view:pauseAnimation(freezeDuration);
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('reboot');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rebootAura:setTickParameters(freezeDuration, 0)
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
	a:loseControl();
	startAbilityUse(kaiju, abilityData.name);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= freezeDuration then
		local maxHealth = kaiju:getStat("MaxHealth");
		kaiju:gainHealth(maxHealth);
		local curPower = getKaijuResource("power");
		local lostPower = 0.5 * curPower;
		addKaijuResource("power", -lostPower);
		kaiju:regainControl();
		local view = kaiju:getView();
		view:attachEffectToNode("root", "effects/pulseVertical_back.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/pulseVertical_front.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/reboot_health.plist", 0, 0, 0, true, false);
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end
