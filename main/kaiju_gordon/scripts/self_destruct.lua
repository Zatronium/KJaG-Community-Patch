require 'scripts/avatars/common'

local avatar = nil;
--weapon = "weapon_gordon_placehold";
local damage = 80;
local aoeRange = 200;

function onUse(a)
	avatar = a;
	playAnimation(avatar, "ability_stomp");
		
	registerAnimationCallback(this, avatar, "attack");
end 

function onAnimationEvent(a, event)
	avatar = a;
	local view = avatar:getView();
	local worldPos = avatar:getWorldPosition();
	
	createEffectInWorld("effects/impact_fireRingBack_large.plist"	, worldPos, 1);
	createEffectInWorld("effects/collapseSmokeDark_large.plist"		, worldPos, 1);
	createEffectInWorld("effects/impact_BoomRisingXlrg.plist"		, worldPos, 1);
	createEffectInWorld("effects/impact_fireCloud_linger.plist"		, worldPos, 1);
	createEffectInWorld("effects/impact_dustCloud_med.plist"		, worldPos, 1);
	createEffectInWorld("effects/impact_boomCore_xlrg.plist"		, worldPos, 1);
	createEffectInWorld("effects/impact_fireRingFront_large.plist"	, worldPos, 1);
	createEffectInWorld("effects/impact_boomXlrg.plist"				, worldPos, 1);
	createEffectInWorld("effects/impact_mushCloud_small.plist"		, worldPos, 1);
		
	local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		applyDamage(avatar, t, damage);
	end
	avatar:addPassive("keep_resource", 1);
	
--	playSound("shrubby_ability_VineWave");
	startAbilityUse(avatar, abilityData.name);	
	avatar:loseControl();
	local deathAura = Aura.create(this, avatar);
	deathAura:setTag('death_failsafe');
	deathAura:setScriptCallback(AuraEvent.OnTick, 'onDeathDelayTick');
	deathAura:setTickParameters(2, 0); 
	deathAura:setTarget(avatar);
end

function onDeathDelayTick(aura)
	if aura:getElapsed() >= 1 then
		avatar:setStat("Health", 0);
		avatar:detachAura(aura);
	end
end

