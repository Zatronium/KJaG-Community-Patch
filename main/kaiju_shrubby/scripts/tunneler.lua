require 'scripts/avatars/common'

local avatar = nil;
local weapon = "weapon_shrubby_tunneler";
local bWidth = 120;
local weaponRange = 0;
local startPos = nil;
local targetsSet = false;
function onUse(a)
	avatar = a;
	playAnimation(avatar, "stomp");
	registerAnimationCallback(this, avatar, "attack");
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Zone);
	weaponRange = getWeaponRange(weapon);
	local beamWidth = bWidth;

	local view = avatar:getView();

	startPos = avatar:getWorldPosition();
	local beamFacing = avatar:getWorldFacing();
	local beamEnd = getBeamEndWithFacing(startPos, weaponRange, beamFacing);
	local targets = getTargetsInBeam(startPos, beamEnd, beamWidth, targetFlags);
	local hastargets = false;
	for t in targets:iterator() do
		local aura = createAura(this, t, 0);
		aura:setTickParameters(0.2, 0);
		aura:setScriptCallback(AuraEvent.OnTick, "onTick");
		aura:setTarget(t);
		hastargets = true;
	end
	if hastargets then
		playSound("shrubby_ability_Tunneler_explosion");
	end
	targetsSet = true;
	playSound("shrubby_ability_Tunneler");
	startCooldown(avatar, abilityData.name);	
end

function onTick(aura)
	if targetsSet then
		local t = aura:getTarget();
		local d = getDistanceFromPoints(t:getWorldPosition(), startPos);
		local e = weaponRange * aura:getElapsed();
		if d < e then
			t:attachEffect("effects/tunnelerVines.plist", 1.5, true);
			t:attachEffect("effects/roots_creeper.plist", 1, true);
			if canTarget(t) then
				avatar = getPlayerAvatar();
				applyDamageWithWeapon(avatar, t, weapon);
			end
			aura:getOwner():detachAura(aura);
		end
	end
end


