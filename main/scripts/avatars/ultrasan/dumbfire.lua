require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

local shotdelay = 0.1;
local shotsfired = 3;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
--	playAnimation(kaiju, "ability_project_1H");
	local v = a:getView();
	v:setAnimation("ability_project_1H", false);
	v:addAnimation("walk", true);
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = kaiju:getView();
	local uaura = createAura(this, kaiju, 'ultra_dumb');
	uaura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	uaura:setTickParameters(shotdelay, shotdelay * (shotsfired - 1)); --updates at time 0 then at time 20
	uaura:setTarget(kaiju); -- required so aura doesn't autorelease	
end

function onTick(aura)
	target = kaiju:getWeakTarget();
	if canTarget(target) and canTarget(kaiju) then
		local proj = avatarFireAtTarget(kaiju, "weapon_DumbFire2", "palm_node_01", target, 0);
	end
end