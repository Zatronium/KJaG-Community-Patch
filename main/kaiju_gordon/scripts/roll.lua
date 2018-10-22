require 'scripts/avatars/common'

local avatar = nil;
local weaponCollision = "weapon_gordon_atomic_punch_collision"

local kbDistance = 200;
local kbPower = 400;

local worldFacing = 0;

function onUse(a)
	avatar = a;

	worldFacing = avatar:getWorldFacing();
	local dEnd = getBeamEndWithFacing(avatar:getWorldPosition(), kbDistance, worldFacing);
	local dir = getDirectionFromPoints(avatar:getWorldPosition(), dEnd);

	local view = avatar:getView();
	view:attachEffectToNode("root", "effects/leapSmoke.plist",1, 0, 0, false, true);
	
	local v = avatar:getView();
	
	v:lockSWViewOnly(true);
	v:setAnimation("ability_roll", true);
	
	avatar:displaceDirection(dir, kbPower, kbDistance);
	avatar:setCollisionScript(this);
	
	avatar:getMovement():moveTo(dEnd);
	
	startAbilityUse(avatar, abilityData.name);
end

function onCollide(first, other)
	avatar = getPlayerAvatar();
	--	first:resetDisplace();
	--	first:removeCollisionScript();
		avatar:getMovement():decreaseDisplace(10);
		applyDamageWithWeapon(avatar, other, weaponCollision);
	--	applyDamageWithWeapon(avatar, first, weaponCollision);
end

function onDisplaceEnd(a)
	local v = avatar:getView();
	endAbilityUse(avatar, abilityData.name);
	v:lockSWViewOnly(false);
	avatar:setWorldFacing(worldFacing);
	avatar:removeCollisionScript();
	v:setAnimation("idle", true);
	avatar:getMovement():moveTo(avatar:getWorldPosition());
end