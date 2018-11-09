require 'scripts/avatars/common'

local kaiju = 0;
local durationtime = 15;
local negateChance = 0.2;
function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_cast");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local view = a:getView();
	view:attachEffectToNode("root", "effects/blossoms.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/blossomPetals.plist", durationtime, 0, 0, true, false);
	a:addPassiveScript(this);
	playSound("shrubby_ability_Blossoms");
	startAbilityUse(kaiju, abilityData.name);
	local aura = createAura(this, kaiju, 0);
	aura:setTag("shrubby_blossoms");
	aura:setTickParameters(durationtime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
end

function onTick(aura)
	if not aura then
		return
	end
	if aura:getElapsed() >= durationtime then
		endAbilityUse(kaiju, abilityData.name);
		kaiju:removePassiveScript(this);
		
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function onAvatarAbsorb(a, n, w)
	if math.random(0, 1) < (negateChance) then
		createFloatingText(kaiju, "Negate", 255, 25, 255); --TODO Localization
		n.x = 0;	
	end
end