

require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

local weaponRange = 1000;

local healAmount = 20;

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
	
	view:doBeamEffectFromNode('palm_node_01', pos, 'effects/healRay.plist', 0 );
	view:doEffectFromNode('palm_node_01', 'effects/deathStare_muzzleGlow.plist', 0);
	
	view:doBeamEffectFromNode('palm_node_02', pos, 'effects/healRay.plist', 0 );
	view:doEffectFromNode('palm_node_02', 'effects/deathStare_muzzleGlow.plist', 0);

	createEffect("effects/explosion_SparkLayer.plist",		pos);
	
	target:attachEffect("effects/onHeal.plist"  , 0.5, true);
	
	local hp = target:getStat("Health") + healAmount;
	local maxh = target:getStat("MaxHealth");
	if hp > maxh then
		hp = maxh;
	end
	target:setStat("Health", hp);
end
