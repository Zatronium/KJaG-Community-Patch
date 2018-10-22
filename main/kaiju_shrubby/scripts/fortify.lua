require 'scripts/avatars/common'
local avatar = nil;
local bonusArmor = 50;
local reduceBallistics = 0.5;

local bonusSpeedPercent = -0.25;
local bonusSpeed = 0;

local duration = 45;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_channel");
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	playSound("shrubby_ability_Fortify");
	startAbilityUse(avatar, abilityData.name);
	avatar:addPassiveScript(this);
	bonusSpeed = avatar:getStat("Speed") * bonusSpeedPercent;
	avatar:modStat("Armor", bonusArmor);
	avatar:modStat("Speed", bonusSpeed);
	local aura = createAura(this, avatar, 0);
	aura:setTickParameters(duration, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(avatar);
	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/fortifyBack.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/fortify.plist", duration, 0, 0, true, false);
end

function onTick(aura)
	if aura:getElapsed() >= duration then
		avatar:modStat("Armor", -bonusArmor);
		avatar:modStat("Speed", -bonusSpeed);
		endAbilityUse(avatar, abilityData.name);
		avatar:removePassiveScript(this);
		aura:getOwner():detachAura(aura);
	end
end

function onAvatarAbsorb(a, n, w)
	if n.y <= 1 or not w then
		return;
	end
	local weap = entityToWeapon(w);
	if not weap then
		return;
	end
	if weap:getWeaponType() ~= WeaponType.Beam then
		if not weap:hasMode("EXP") then
			n.x = n.x * reduceBallistics;
		end
	end
end