require 'scripts/avatars/common'

local avatar = 0;
local durationtime = 15;
local negateChance = 0.2;
function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_cast");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/blossoms.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/blossomPetals.plist", durationtime, 0, 0, true, false);
	a:addPassiveScript(this);
	playSound("shrubby_ability_Blossoms");
	startAbilityUse(avatar, abilityData.name);
	local aura = createAura(this, avatar, 0);
	aura:setTag("shrubby_blossoms");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	if aura:getElapsed() >= durationtime then
		endAbilityUse(avatar, abilityData.name);
		avatar:removePassiveScript(this);
		aura:getOwner():detachAura(aura);
	end
end

function onAvatarAbsorb(a, n, w)
	if math.random(0, 1) < (negateChance) then
		createFloatingText(avatar, "Negate", 255, 25, 255); --TODO Localization
		n.x = 0;	
	end
end