require 'scripts/avatars/common'

local kaiju = nil;
local weaponCollision = "weapon_gordon_atomic_punch_collision"

local kbDistance = 200;
local kbPower = 400;

local worldFacing = 0;

function onUse(a)
	kaiju = a;

	worldFacing = kaiju:getWorldFacing();
	local dEnd = getBeamEndWithFacing(kaiju:getWorldPosition(), kbDistance, worldFacing);
	local dir = getDirectionFromPoints(kaiju:getWorldPosition(), dEnd);

	local view = kaiju:getView();
	view:attachEffectToNode("root", "effects/leapSmoke.plist",1, 0, 0, false, true);
	
	local v = kaiju:getView();
	
	v:lockSWViewOnly(true);
	v:setAnimation("ability_roll", true);
	
	kaiju:displaceDirection(dir, kbPower, kbDistance);
	kaiju:setCollisionScript(this);
	
	kaiju:getMovement():moveTo(dEnd);
	
	startAbilityUse(kaiju, abilityData.name);
end

function onCollide(first, other)
	kaiju = getPlayerAvatar();
	--	first:resetDisplace();
	--	first:removeCollisionScript();
		kaiju:getMovement():decreaseDisplace(10);
		applyDamageWithWeapon(kaiju, other, weaponCollision);
	--	applyDamageWithWeapon(kaiju, first, weaponCollision);
end

function onDisplaceEnd(a)
	local v = kaiju:getView();
	endAbilityUse(kaiju, abilityData.name);
	v:lockSWViewOnly(false);
	kaiju:setWorldFacing(worldFacing);
	kaiju:removeCollisionScript();
	v:setAnimation("idle", true);
	kaiju:getMovement():moveTo(kaiju:getWorldPosition());
end