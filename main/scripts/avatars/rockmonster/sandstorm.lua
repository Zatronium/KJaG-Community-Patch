require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

local radius = 300;
local debuffTime = 5;
local tickTime = 1;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_sandstorm");
	registerAnimationCallback(this, kaiju, "attack");	
--	_log("duDUdu");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local worldPos = target:getWorldPosition();
	
	target:attachEffect("effects/tornado_back.plist", 3.0 , false);
	target:attachEffect("effects/tornado_front.plist", 3.0, true);
	
	local targets = getTargetsInRadius(worldPos, radius, EntityFlags(EntityType.Avatar, EntityType.Zone)); 
	for t in targets:iterator() do
		local rock = Aura.create(this, t);
		rock:setTag('rock_sand');
		rock:setScriptCallback(AuraEvent.OnTick, 'debuff');
		rock:setTickParameters(tickTime, 0);
		rock:setTarget(t); -- required so aura doesn't autorelease
		t:attachEffect("effects/sandstorm.plist"  ,debuffTime, false);
		t:setImmobile(true);
	--	applyDamage(a, t, math.random(15, 20));
	end
end

function debuff(aura)
	if not aura then return end
	local owner = aura:getOwner();
	if not owner then
		aura = nil return
	end
	if aura:getElapsed() >= debuffTime then
		owner:setImmobile(false);
		owner:detachAura(aura);
	else
		applyDamage(a, owner, math.random(15, 20));
	end
end