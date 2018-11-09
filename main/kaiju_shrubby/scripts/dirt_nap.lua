require 'kaiju_shrubby/scripts/shrubby'

local kaiju = nil;
local healPerSecond = 10;
local passiveName = "dirt_nap"
local shieldHealth = 300;
local maxHealth = 0;
local hasShields = true;
local terminateSequence = false;

function onUse(a)
	kaiju = a;
	local curr = kaiju:hasPassive(passiveName); -- only need to check 1, we're assuming everything is cleaned and created at the same time
	if curr == 0 then --if off then on
		onON(kaiju);
	else -- else if on then off
		onOFF(kaiju);
	end
end

function onON(a)
	kaiju:getMovement():moveTo(kaiju:getWorldPosition());
	hasShields = true;
	useResources(a, abilityData.name);
	abilityInUse(a, abilityData.name, true);
	kaiju:setShieldScript(this);
	kaiju:addPassiveScript(this);
	kaiju:setPassive("shield", shieldHealth);
	ToggleShields(kaiju, false);
	
	maxHealth = kaiju:getStat("MaxHealth");
	local healAura = createAura(this, kaiju, 0);
	healAura:setTickParameters(1, 0);
	healAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	healAura:setTarget(kaiju);

	local view = kaiju:getView();
	view:setAnimation("ability_root", false);
	view:addAnimation("idle", true);
	
	local shieldEffect = view:attachEffectToNode("root", "effects/dirtnap.plist", -1, 0, 0, true, false);
	kaiju:setPassive(passiveName, shieldEffect);
	
	view:attachEffectToNode("root", "effects/dirtnap_spawn.plist", 0.1, 0, 0, true, false);

	playSound("shrubby_ability_DirtNap");
	
	kaiju:setImmobile(true);
end

function onOFF(a)
	if not terminateSequence then
		terminateSequence = true;
		playSound("shrubby_ability_DirtNap");
		startOnlyCooldown(a, abilityData.name);
		abilityInUse(a, abilityData.name, false);
		kaiju:removePassiveScript(this);
		kaiju:setPassive("shield", 0);
		ToggleShields(kaiju, true);
		if hasShields then
			kaiju:endShield(false);
		end
		kaiju:detachAura(healAura);	
		
		local view = kaiju:getView();
		view:attachEffectToNode("root", "effects/dirtnap_despawn.plist", 0.1, 0, 0, true, false);
		view:setAnimation("ability_unroot", false);
		view:addAnimation("idle", true);
		
		kaiju:setImmobile(false);
		view:endEffect(kaiju:hasPassive(passiveName));
		kaiju:removePassive(passiveName, 0); 
	end
end

function onAvatarMove(a)
	onOFF(a);
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() > 0 then
		kaiju:gainHealth(healPerSecond);
		if kaiju:getStat("Health") >= maxHealth then
			onOFF(kaiju);
		end
	end
end

function onShieldEnd(a, broken)
	if broken then
		hasShields = false;
		onOFF(kaiju);
	end
end

function onShieldHit(a, n, w)
	if not w and w:getWeaponType() == WeaponType.Beam then
		n.x = 0;
	else
		local view = a:getView();
		view:attachEffectToNode("root", "effects/shield_hit.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/forceshield_hit.plist", 0, 0, 0, true, false);
	end
end
