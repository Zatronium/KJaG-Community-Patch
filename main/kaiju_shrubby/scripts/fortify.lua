require 'scripts/avatars/common'
local kaiju = nil;
local bonusArmor = 50;
local reduceBallistics = 0.5;

local bonusSpeedPercent = -0.25;
local bonusSpeed = 0;

local duration = 45;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_channel");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	playSound("shrubby_ability_Fortify");
	startAbilityUse(kaiju, abilityData.name);
	kaiju:addPassiveScript(this);
	bonusSpeed = kaiju:getStat("Speed") * bonusSpeedPercent;
	kaiju:modStat("Armor", bonusArmor);
	kaiju:modStat("Speed", bonusSpeed);
	local aura = createAura(this, kaiju, 0);
	aura:setTickParameters(duration, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(kaiju);
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/fortifyBack.plist", duration, 0, 0, false, true);
	view:attachEffectToNode("root", "effects/fortify.plist", duration, 0, 0, true, false);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() >= duration then
		kaiju:modStat("Armor", -bonusArmor);
		kaiju:modStat("Speed", -bonusSpeed);
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