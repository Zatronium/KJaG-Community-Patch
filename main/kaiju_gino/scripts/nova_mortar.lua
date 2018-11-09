require 'scripts/common'

-- Global values.
local kaiju = nil

local targetPos = 0;
local distance = 1;
local weaponRange = 1800;
local weaponInterval = 0.1;
local burst = 5;
local shotsper = 2;
local deviation = 300; 

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', weaponRange);
end

function onTargets(position)
	targetPos = position;
	local worldPos = kaiju:getWorldPosition();
	distance = getDistanceFromPoints(worldPos, targetPos) / weaponRange;
	local facingAngle = getFacingAngle(worldPos, targetPos);
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_launch");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local furyAura = Aura.create(this, a);
	furyAura:setTag('nova_mortar');
	furyAura:setTickParameters(weaponInterval, weaponInterval * (burst - 1));
	furyAura:setScriptCallback(AuraEvent.OnTick, 'onTick');	
	furyAura:setTarget(a); -- required so aura doesn't autorelease
	local view = a:getView();
	view:pauseAnimation(weaponInterval * (burst - 1));
	startCooldown(a, abilityData.name);
	playSound("novamortar");
end

function onTick(aura)
	local targetEnt = getAbilityTarget(kaiju, abilityData.name);
	if targetEnt then
		targetPos =  targetEnt:getWorldPosition();
	end
	local shots = shotsper;
	while shots > 0 do
		shots = shots - 1;
		local offset = deviation * distance;
		local locPos = targetPos;
		locPos["x"] = targetPos["x"] + math.random(-offset, offset);
		locPos["y"] = targetPos["y"] + math.random(-offset, offset);
		local proj = avatarFireAtPoint(kaiju, "weapon_mortar2", "gun_node_03", locPos, 0);
		proj:fromAvatar(true);
		proj:setCallback(this, 'onHit');
	end
end

function onHit(proj)
	local scenePos = proj:getView():getPosition();
	local weapon = proj:getWeapon();
	createImpactEffect(weapon, scenePos);
	playSound("explosion");
	createEffect('effects/explosion_BoomLayer.plist', scenePos);
end