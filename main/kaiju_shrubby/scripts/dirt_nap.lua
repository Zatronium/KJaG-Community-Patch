require 'kaiju_shrubby/scripts/shrubby'

local avatar = nil;
local healPerSecond = 10;
local healAura = nil;
local passiveName = "dirt_nap"
local shieldHealth = 300;
local maxHealth = 0;
local hasShields = true;
local terminateSequence = false;

function onUse(a)
	avatar = a;
	local curr = avatar:hasPassive(passiveName); -- only need to check 1, we're assuming everything is cleaned and created at the same time
	if curr == 0 then --if off then on
		onON(avatar);
	else -- else if on then off
		onOFF(avatar);
	end
end

function onON(a)
	avatar:getMovement():moveTo(avatar:getWorldPosition());
	hasShields = true;
	useResources(a, abilityData.name);
	abilityInUse(a, abilityData.name, true);
	avatar:setShieldScript(this);
	avatar:addPassiveScript(this);
	avatar:setPassive("shield", shieldHealth);
	ToggleShields(avatar, false);
	
	maxHealth = avatar:getStat("MaxHealth");
	healAura = createAura(this, avatar, 0);
	healAura:setTickParameters(1, 0);
	healAura:setScriptCallback(AuraEvent.OnTick, "onTick");
	healAura:setTarget(avatar);

	local view = avatar:getView();
	view:setAnimation("ability_root", false);
	view:addAnimation("idle", true);
	
	local shieldEffect = view:attachEffectToNode("root", "effects/dirtnap.plist", -1, 0, 0, true, false);
	avatar:setPassive(passiveName, shieldEffect);
	
	view:attachEffectToNode("root", "effects/dirtnap_spawn.plist", 0.1, 0, 0, true, false);

	playSound("shrubby_ability_DirtNap");
	
	avatar:setImmobile(true);
end

function onOFF(a)
	if not terminateSequence then
		terminateSequence = true;
		playSound("shrubby_ability_DirtNap");
		startOnlyCooldown(a, abilityData.name);
		abilityInUse(a, abilityData.name, false);
		avatar:removePassiveScript(this);
		avatar:setPassive("shield", 0);
		ToggleShields(avatar, true);
		if hasShields then
			avatar:endShield(false);
		end
		avatar:detachAura(healAura);	
		
		local view = avatar:getView();
		view:attachEffectToNode("root", "effects/dirtnap_despawn.plist", 0.1, 0, 0, true, false);
		view:setAnimation("ability_unroot", false);
		view:addAnimation("idle", true);
		
		avatar:setImmobile(false);
		view:endEffect(avatar:hasPassive(passiveName));
		avatar:removePassive(passiveName, 0); 
	end
end

function onAvatarMove(a)
	onOFF(a);
end

function onTick(aura)
	if aura:getElapsed() > 0 then
		avatar:gainHealth(healPerSecond);
		if avatar:getStat("Health") >= maxHealth then
			onOFF(avatar);
		end
	end
end

function onShieldEnd(a, broken)
	if broken == true then
		hasShields = false;
		onOFF(avatar);
	end
end

function onShieldHit(a, n, w)
	if w and w:getWeaponType() == WeaponType.Beam then
		n.x = 0;
	else
		local view = a:getView();
		view:attachEffectToNode("root", "effects/shield_hit.plist", 0, 0, 0, true, false);
		view:attachEffectToNode("root", "effects/forceshield_hit.plist", 0, 0, 0, true, false);
	end
end
