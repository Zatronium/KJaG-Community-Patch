require 'scripts/avatars/common'

kaiju = nil;
weapon = "goop_Zzap";
orgNode = "root"

duration = 30;
damageMult = 1;
interval = 2;

scriptAura = nil;
fxID = 0;

function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_bodyslam");

	registerAnimationCallback(this, kaiju, "attack");
end 

function onAnimationEvent(a, event)
	kaiju = a;
	targetPos = kaiju:getWorldPosition();
	
	damageMult = 1 + kaiju:hasPassive("goop_dot_bonus");
	
	scriptAura = Aura.create(this, kaiju);
	scriptAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	scriptAura:setTickParameters(interval, 0);
	scriptAura:setTarget(kaiju); -- required so aura doesn't autorelease
	
	startAbilityUse(kaiju, abilityData.name);
	
	local view = kaiju:getView();
	fxID = view:attachEffectToNode("root", "effects/goop_zap2.plist", 0, 0, 0, false, true);
--	view:attachEffectToNode("root", "effects/stompFront.plist",0, 0, 0, true, false);
		
	playSound("goop_ability_zap"); -- SOUND
end 

function onInterrupt()
	kaiju = entityToAvatar(scriptAura:getOwner());
	local view = kaiju:getView();
	view:endEffect(fxID);
	endAbilityUse(kaiju, abilityData.name);
	scriptAura:getOwner():detachAura(scriptAura);
end

function onTick(aura)
	kaiju = entityToAvatar(aura:getOwner());
	
	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/goop_zapsplash2.plist", 0.1, 0, 0, true, false);
	
	local target = getClosestTargetInRadius(kaiju:getWorldPosition(), getWeaponRange(weapon), EntityFlags(EntityType.Vehicle, EntityType.Avatar), kaiju);
	if canTarget(target) then
	--	local view = kaiju:getView();
		local pos = getScenePosition(target:getWorldPosition());
		view:doBeamEffectFromNode(orgNode, pos, 'effects/beam_lightning.plist', 0 );
		view:doBeamEffectFromNode(orgNode, pos, 'effects/beam_lightning_core.plist', 0 );
					
		local dotDamage = getWeaponDamage(weapon) * damageMult;
		applyDamageWithWeaponDamage(kaiju, target, weapon, dotDamage);
	end
	
	if aura:getElapsed() > duration then
		endAbilityUse(kaiju, abilityData.name);
		scriptAura:getOwner():detachAura(scriptAura);
		view:endEffect(fxID);
	end
end