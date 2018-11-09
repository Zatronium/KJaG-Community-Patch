require 'scripts/avatars/common'

local kaiju = nil;
--weapon = "weapon_gordon_placehold";
local damage = 80;
local aoeRange = 200;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_stomp");
		
	registerAnimationCallback(this, kaiju, "attack");
end 

function onAnimationEvent(a, event)
	kaiju = a;
	local view = kaiju:getView();
	local worldPos = kaiju:getWorldPosition();
	
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
		applyDamage(kaiju, t, damage);
	end
	kaiju:addPassive("keep_resource", 1);
	
--	playSound("shrubby_ability_VineWave");
	startAbilityUse(kaiju, abilityData.name);	
	kaiju:loseControl();
	local deathAura = Aura.create(this, kaiju);
	deathAura:setTag('death_failsafe');
	deathAura:setScriptCallback(AuraEvent.OnTick, 'onDeathDelayTick');
	deathAura:setTickParameters(2, 0); 
	deathAura:setTarget(kaiju);
end

function onDeathDelayTick(aura)
	if not aura then return end
	if aura:getElapsed() >= 1 then
		kaiju:setStat("Health", 0);
		if not self then
			aura = nil return
		else
			self:detachAura(aura)
		end
	end
end

