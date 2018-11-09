require 'kaiju_gordon/scripts/gordon'
local kaiju = nil;

local weaponName = "BlastZone3"

local freezeDuration = 3;

function onUse(a)
	kaiju = a;
	
	playAnimation(kaiju, "ability_jump");
	registerAnimationCallback(this, kaiju, "end");
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/powerDown_back.plist", freezeDuration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/powerDown_front.plist", freezeDuration, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/nuclearCharge_back.plist", freezeDuration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/nuclearCharge_front.plist", freezeDuration, 0, 0, true, false);

	view:pauseAnimation(freezeDuration);
	
	local rebootAura = Aura.create(this, a);
	rebootAura:setTag('shockwave');
	rebootAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	rebootAura:setTickParameters(freezeDuration, freezeDuration); --updates every second
	rebootAura:setTarget(a); -- required so aura doesn't autorelease
	
	a:loseControl();
	startAbilityUse(kaiju, abilityData.name);
	
	playSound("Shockwave");
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() > freezeDuration then
		playAnimation(kaiju, "ability_stomp");
		local empower = kaiju:hasPassive("enhancement");
		kaiju:removePassive("enhancement", 0);
		abilityEnhance(empower);
		BlastZone(kaiju, weaponName);
		abilityEnhance(0);
		kaiju:regainControl();
		endAbilityUse(kaiju, abilityData.name);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
		local view = kaiju:getView();
		view:attachEffectToNode("root", "effects/shockwave_back.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/shockwave_front.plist", 0, 0, 0, true, false);		
	end

end
