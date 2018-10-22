require 'kaiju_gordon/scripts/gordon'
local avatar = nil;

local weaponName = "BlastZone3"

local freezeDuration = 3;

function onUse(a)
	avatar = a;
	
	playAnimation(avatar, "ability_jump");
	registerAnimationCallback(this, avatar, "end");
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
	startAbilityUse(avatar, abilityData.name);
	
	playSound("Shockwave");
end

function onTick(aura)
	if aura:getElapsed() > freezeDuration then
		playAnimation(avatar, "ability_stomp");
		local empower = avatar:hasPassive("enhancement");
		avatar:removePassive("enhancement", 0);
		abilityEnhance(empower);
		BlastZone(avatar, weaponName);
		abilityEnhance(0);
		avatar:regainControl();
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
		local view = avatar:getView();
		view:attachEffectToNode("root", "effects/shockwave_back.plist", 0, 0, 0, false, true);
		view:attachEffectToNode("root", "effects/shockwave_front.plist", 0, 0, 0, true, false);		
	end

end
