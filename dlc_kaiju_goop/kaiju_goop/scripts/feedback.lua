require 'scripts/avatars/common'

local kaiju = nil;
local weapon = "goop_Feedback";
local orgNode = "root"

local damageMult = 1;
local interval = 2;

local lastfire = -2;
local scriptAura = nil;

local powerPerSecond = 5;
local fxID = 0;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_bodyslam");

	registerAnimationCallback(this, kaiju, "attack");
end 

function onAnimationEvent(a, event)
	targetPos = kaiju:getWorldPosition();
	
	damageMult = 1 + kaiju:hasPassive("goop_dot_bonus");
	
	scriptAura = Aura.create(this, kaiju);
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(1, 0);
	scriptAura:setTarget(kaiju); -- required so aura doesn't autorelease
	
	startAbilityUse(kaiju, abilityData.name);
	
	local view = kaiju:getView();
	fxID = view:attachEffectToNode("root", "effects/goop_zap.plist", 0, 0, 0, false, true);
		
	playSound("goop_ability_Feedback"); -- SOUND
end 

function onInterrupt()
	endAbilityUse(kaiju, abilityData.name);
	local view = kaiju:getView();
	view:endEffect(fxID);
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	if not aura then return end
	local view = kaiju:getView();
	if aura:getElapsed() >= lastfire + interval then
		view:attachEffectToNode("root", "effects/goop_zapsplash.plist", 0.1, 0, 0, true, false);
	
		local target = getClosestTargetInRadius(kaiju:getWorldPosition(), getWeaponRange(weapon), EntityFlags(EntityType.Vehicle, EntityType.Avatar), kaiju);
		if canTarget(target) then
			local view = kaiju:getView();
			local pos = getScenePosition(target:getWorldPosition());
			view:doBeamEffectFromNode(orgNode, pos, 'effects/beam_lightning.plist', 0 );
			view:doBeamEffectFromNode(orgNode, pos, 'effects/beam_lightning_core.plist', 0 );
			
			local dotDamage = getWeaponDamage(weapon) * damageMult;
			applyDamageWithWeaponDamage(kaiju, target, weapon, dotDamage);
			
			lastfire = aura:getElapsed();
		end
	end
	local power = getKaijuResource("power");
	
	if power < powerPerSecond then
		endAbilityUse(kaiju, abilityData.name);
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
		view:endEffect(fxID);
	else 
		addKaijuResource("power"	,  -powerPerSecond );
	end
end