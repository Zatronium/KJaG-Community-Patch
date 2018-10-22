require 'scripts/common'

local avatar = nil;
local target = nil;

local shotdelay = 0.1;
local shotsfired = 3;

function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
--	playAnimation(avatar, "ability_project_offhand");
	local v = a:getView();
	v:setAnimation("ability_project_offhand", false);
	v:addAnimation("walk", true);
	registerAnimationCallback(this, avatar, "start");
end

function onAnimationEvent(a)
	target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = avatar:getView();
	local uaura = createAura(this, avatar, 'ultra_blaster');
	uaura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	uaura:setTickParameters(shotdelay, shotdelay * (shotsfired - 1)); --updates at time 0 then at time 20
	uaura:setTarget(avatar); -- required so aura doesn't autorelease	
end

function onTick(aura)
	target = avatar:getWeakTarget();
	if canTarget(target) and canTarget(avatar) then
		local proj = avatarFireAtTarget(avatar, "weapon_Blaster1", "palm_node_01", target, 0);
		playSound("blaster");
	end
end