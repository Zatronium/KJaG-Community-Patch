require 'scripts/avatars/common'

local Angle = 20;
local avatar = nil;

local tickTime = 0.7;
local duration = 3.5;
local freezeTime = 1.5;

local breath = 0;
function onUse(a)
	playAnimation(a, "ability_breath");
	registerAnimationCallback(this, a, "start");
	avatar = a;
end
-- damageEffect can be nil

function onAnimationEvent(a)
	
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();
	local sceneFacing = a:getSceneFacing();

	local targets = getTargetsInCone(worldPosition, 200, Angle, worldFacing, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
		
	local aura = createAura(this, a, "gino_prismatic");
	aura:setTickParameters(tickTime, duration + tickTime);
	aura:setScriptCallback(AuraEvent.OnTick, "onBreathTick");
	aura:setTarget(a);
	
	local view = avatar:getView();
	view:pauseAnimation(freezeTime);
	
	playSound("gino_breath");
	startAbilityUse(avatar, abilityData.name);
	dotSetTargets(a, targets, 1, 5, "onTick");
end

function onBreathTick(aura)
	local view = avatar:getView();
	local sceneFacing = avatar:getSceneFacing();
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
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

function onTick(aura)
	dotOnTick(aura, 0, 0, "effects/onCorrosive.plist", 0.00);
	dotOnTick(aura, 10, 15, "effects/onCorrosive_smoke.plist", 0.50);
end