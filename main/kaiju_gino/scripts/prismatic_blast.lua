require 'scripts/avatars/common'

local angle = 20;
local kaiju = nil;

local tickTime = 0.7;
local duration = 3.5;
local freezeTime = 1.5;

local breakTick = false;

local breath = 0;
function onUse(a)
	playAnimation(a, "ability_breath");
	registerAnimationCallback(this, a, "start");
	kaiju = a;
end
-- damageEffect can be nil

function onAnimationEvent(a)
	
	breakTick = false
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();

	local targets = getTargetsInCone(worldPosition, 200, angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
		
	local aura = createAura(this, a, "gino_prismatic");
	aura:setTickParameters(tickTime, duration + tickTime);
	aura:setScriptCallback(AuraEvent.OnTick, "onBreathTick");
	aura:setTarget(a);
	
	local view = kaiju:getView();
	view:pauseAnimation(freezeTime);
	
	playSound("gino_breath");
	startAbilityUse(kaiju, abilityData.name);
	dotSetTargets(a, targets, 1, 5, "onTick");
end

function onBreathTick(aura)
	if breakTick then
		return
	end
	local view = kaiju:getView();
	local sceneFacing = kaiju:getSceneFacing();
	if breath == 0 then
		view:doEffectFromNode('breath_node', 'effects/acidSpray_wide.plist', sceneFacing);
		view:doEffectFromNode('breath_node', 'effects/acidSpray_core.plist', sceneFacing);
		view:doEffectFromNode('breath_node', 'effects/acidSpray_splash.plist', sceneFacing);
		breath = 1;
	elseif breath == 1 then
		view:doEffectFromNode('breath_node', 'effects/fireBreath_smoke.plist', sceneFacing);
		view:doEffectFromNode('breath_node', 'effects/fireBreath_main.plist', sceneFacing);
		view:doEffectFromNode('breath_node', 'effects/fireBreath_core.plist', sceneFacing);

		breath = 2;
	elseif breath == 2 then
		view:doEffectFromNode('breath_node', 'effects/icefire.plist', sceneFacing);
		view:doEffectFromNode('breath_node', 'effects/icefire_snowflakes.plist', sceneFacing);
		view:doEffectFromNode('breath_node', 'effects/icefire_snowflakeBurst.plist', sceneFacing);
		breath = 3;
	else
		endAbilityUse(kaiju, abilityData.name);
		
		if not aura then
			breakTick = true
			return
		end
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
		end
	end
end

function onTick(aura)
	if not aura then
		return
	end
	dotOnTick(aura, 0, 0, "effects/onCorrosive.plist", 0.00);
	dotOnTick(aura, 10, 15, "effects/onCorrosive_smoke.plist", 0.50);
end