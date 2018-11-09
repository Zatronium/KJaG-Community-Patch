 require 'scripts/common'
 local kaiju = nil;
 
 local tickTime = 0.2;
 local totalDuration = 20;

 local minDamage = 13;
 local maxDamage = 18;
 
 initalShellHeight = 1000;
function onUse(a)
	kaiju = a;
	playAnimation(kaiju, "ability_launch");
	registerAnimationCallback(this, kaiju, "attack");
end

function onAnimationEvent(a)
	local targetPos = kaiju:getWorldPosition();
	targetPos.x = targetPos.x + initalShellHeight;
	targetPos.y = targetPos.y + initalShellHeight;
	local proj = avatarFireAtPoint(kaiju, "weapon_GlobalMortar", "gun_node_03", targetPos, 0);
	proj:setCallback(this, 'onShellHit');
	startCooldown(kaiju, abilityData.name);
end

function onShellHit(proj)
	local cloud = spawnEntity(EntityType.Minion, "unit_goop_patch", proj:getWorldPosition());
	
	local aura = createAura(this, cloud, "gino_brimstone");
	aura:setTickParameters(tickTime, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(cloud);
	
	local scenePos = proj:getView():getPosition();
	createImpactEffect(proj:getWeapon(), scenePos);
	playSound("brimstone");
end

function onTick(aura)
	if not aura then
		return
	end
	local targetPos = getWorldSize();
	targetPos.x = math.random(0, targetPos.x);
	targetPos.y = math.random(0, targetPos.y);
	--local firePos = kaiju:getWorldPosition();
	local firePos = getWorldSize();
	firePos.x = targetPos.x + 300;
	firePos.y = targetPos.y + 300;

	local proj = fireProjectileAtPoint(kaiju, firePos, targetPos, "weapon_FireBallDirect");
	proj:setCallback(this, 'onHit');
	proj:fromAvatar(true);
	if aura:getElapsed() >= totalDuration then
		local self = aura:getOwner()
		if not self then
			aura = nil return;
		else
			self:detachAura(aura);
			removeEntity(self);
		end
	end
end

function onHit(proj)
	local scenePos = proj:getView():getPosition();

	local weapon = proj:getWeapon();
	playSound("explosion");
	createImpactEffect(weapon, scenePos);
end
