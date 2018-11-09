require 'kaiju_gordon/scripts/gordon'

local kaiju = nil;
local shieldBase = 50;
local shieldDuration = 20;
local abilityName = "passive"

function onUse(a)
	kaiju = a;
	onOn();
	abilityName = abilityData.name;
	useResources(a, abilityName);
	abilityInUse(a, abilityName, true);
	playAnimation( a, "ability_cast");
	abilityEnabled(a, "ability_gordon_PersonalShield", false);
end

function onOn()
	if kaiju:hasPassive("shield") == 0 then
		kaiju:setShield(shieldBase);
		kaiju:setShieldScript(this);
		kaiju:createShieldEffect("root", "effects/solarShield_core.plist", 0, 0, true, false);
		playSound("PersonalShield");
		
		local shieldAura = createAura(this, kaiju, 0);
		shieldAura:setTag("personal_shield");
		shieldAura:setTickParameters(1, 0);
		shieldAura:setScriptCallback(AuraEvent.OnTick, "onTick");
		shieldAura:setTarget(kaiju);
		
		if kaiju:hasPassive("impentrable_shield") > 0 then
			kaiju:setInvulnerableTime(kaiju:hasPassive("impentrable_shield"));
		end
	end
end

function onTick(aura)
	if not aura then
		return
	end
	local elapsed = aura:getElapsed();
	if  elapsed >= shieldDuration then
		kaiju:endShield(false);
	end
end


function onShieldEnd(a, broken)
	abilityEnabled(a, "ability_gordon_PersonalShield", true);
	a:detachAura(shieldAura);
	a:addPassive("shield_cd", a:hasPassive("field_mastery_cd"));
	abilityInUse(a, abilityName, false);
	startOnlyCooldown(a, abilityName);
	a:removePassive("shield_cd", 0);
end

-- y is how much is remaining total eg dampened
-- x is how much to subtract from the shield eg actual damage
function onShieldHit(a, n, w)
	if not w and w:getWeaponType() == WeaponType.Beam then
		n.x = 0;
	else
		local view = a:getView();
		view:attachEffectToNode("root", "effects/shield_hit.plist", 0, 0, 0, true, false);
	end
end