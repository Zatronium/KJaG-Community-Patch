require 'kaiju_gordon/scripts/personal_shield'

local avatar = nil;

local shieldCooldown = 40;
local onCD = false;

function onSet(a)
	avatar = a;
	avatar:addPassiveScript(this);
end

function bonusStats(s)
	setAbilityToPassive("ability_gordon_PersonalShield");
end

function onAvatarAbsorb(a, n, w)
	if onCD == false and n.y > 0 then
		onCD = true;
		cdAura = createAura(this, avatar, 0);
		cdAura:setTag("personal_shield");
		cdAura:setTickParameters(shieldCooldown, 0);
		cdAura:setScriptCallback(AuraEvent.OnTick, "onCooldown");
		cdAura:setTarget(avatar);
		onOn();
	end
end

function onCooldown(aura)
	local elapsed = aura:getElapsed();
	if  elapsed >= shieldDuration then
		--avatar:endShield(false);
		onCD = false;
		avatar:detachAura(aura);
	end
end


