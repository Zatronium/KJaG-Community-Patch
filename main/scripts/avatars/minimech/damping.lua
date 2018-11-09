

require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

local weaponRange = 1000;

local debuffTime = 3;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_beam");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = kaiju:getView();
    
	local pos = getScenePosition(target:getWorldPosition());
	
	view:doBeamEffectFromNode('palm_node_01', pos, 'effects/dampingBeam.plist', 0 );
	    view:doEffectFromNode('palm_node_01', 'effects/gigablast_muzzle.plist', 0);
	
	view:doBeamEffectFromNode('palm_node_02', pos, 'effects/dampingBeam.plist', 0 );
	    view:doEffectFromNode('palm_node_02', 'effects/gigablast_muzzle.plist', 0);
	
	createEffect("effects/explosion_BoomLayer.plist",		pos);
	createEffect("effects/explosion_SmokeLayer.plist",		pos);
	createEffect("effects/explosion_SparkLayer.plist",		pos);
	createEffect("effects/explosion_SparkFireLayer.plist",	pos);
	
	local   miniMech = Aura.create(this, target);
	miniMech:setTag('minimech_first');
	miniMech:setScriptCallback(AuraEvent.OnTick, 'debuff');
	miniMech:setTickParameters(debuffTime, debuffTime);
	miniMech:setTarget(target); -- required so aura doesn't autorelease
	
--	target:attachEffect("effects/onFreeze.plist"  ,debuffTime, true);
	
	applyDamageWithWeapon(kaiju, target, "weapon_EyeBeam1");
end

function debuff(aura)
	if not aura then return end
	if aura:getTag() == 'minimech_first' then
		aura:setTag('minimech_second');
		local val = 0.9;
		if target:hasStat("damage_amplify") then
			val = val * target:getStat("damage_amplify");
		else
			target:addStat("damage_amplify", 1.0);
		end
		target:setStat("damage_amplify", val);
	else
		local val = target:getStat("damage_amplify");
		val = val / 0.9;
		target:setStat("damage_amplify", val);
		local self = aura:getOwner()
		if not self then
			aura = nil return
		else
			self:detachAura(aura)
		end
	end
end