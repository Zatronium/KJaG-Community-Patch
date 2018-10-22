require 'scripts/common'

local avatar = nil;
local target = nil;

local radius = 100;
local debuffTime = 5;
local tickTime = 1;
local tickDamage = 10;

function onUse(a, t)
	avatar = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(avatar:getWorldPosition(), t:getWorldPosition());
	avatar:setWorldFacing(facingAngle);
	playAnimation(avatar, "ability_vinewhip");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	target = avatar:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local worldPos = target:getWorldPosition();
	--createEffectInWorld("effects/clearingLeaves.plist", worldPos, 0.5);

	local targets = getTargetsInRadius(worldPos, radius, EntityFlags(EntityType.Avatar, EntityType.Zone)); 
	for t in targets:iterator() do
	local   planto = Aura.create(this, t);
		planto:setTag('planto_whip');
		planto:setScriptCallback(AuraEvent.OnTick, 'debuff');
		planto:setTickParameters(tickTime, debuffTime);
		if t:hasStat("Speed") then
			local spd = t:getStat("Speed") * 0.5;
			planto:setStat("Health", 0);
			planto:setStat("Speed", spd);
			t:modStat("Speed", -spd);
		else
			planto:setStat("Speed", 0);
		end
		planto:setTarget(t); -- required so aura doesn't autorelease
		t:attachEffect("effects/clearingLeaves.plist"  ,debuffTime, true);
		applyDamage(a, t, math.random(15, 20));
	end
end

function debuff(aura)
	local owner = aura:getOwner();
	if aura:getStat("Speed") > 0 then
		local count = aura:getStat("Health");
		count = count + 1;
		if count == 5 then
			owner:modStat("Speed", aura:getStat("Speed"));
		end
		aura:setStat("Health", count);
	end
	applyDamage(a, owner, tickDamage);
end