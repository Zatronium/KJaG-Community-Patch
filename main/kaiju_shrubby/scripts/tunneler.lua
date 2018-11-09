require 'scripts/avatars/common'

local kaiju = nil;
local weapon = "weapon_shrubby_tunneler";
local bWidth = 120;
local weaponRange = 0;
local startPos = nil;
local targetsSet = false;
function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "stomp");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local targetFlags = EntityFlags(EntityType.Zone);
	weaponRange = getWeaponRange(weapon);
	local beamWidth = bWidth;

	local view = kaiju:getView();

	startPos = kaiju:getWorldPosition();
	local beamFacing = kaiju:getWorldFacing();
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
	startCooldown(kaiju, abilityData.name);	
end

function onTick(aura)
	if not aura then return end
	if targetsSet then
		local t = aura:getTarget();
		local d = getDistanceFromPoints(t:getWorldPosition(), startPos);
		local e = weaponRange * aura:getElapsed();
		if d < e then
			t:attachEffect("effects/tunnelerVines.plist", 1.5, true);
			t:attachEffect("effects/roots_creeper.plist", 1, true);
			if canTarget(t) then
				applyDamageWithWeapon(kaiju, t, weapon);
			end
			
			local self = aura:getOwner()
			if not self then
				aura = nil return;
			else
				self:detachAura(aura);
			end
		end
	end
end


