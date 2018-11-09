require 'scripts/avatars/common'
local kaiju = nil;
local damageMult = 0.25; -- takes % damage 
local healMult = 0; -- from Asorbo-blob
local aoeSize = 75;
local damagePer = 10;
local duration = 30;
local tickTime = 1;

local walkAnim = "goop_walk"
local idleAnim = "goop_idle"
local deadAnim = "goop_die"

function onUse(a)
	kaiju = a;
	local multiplier = 1 + kaiju:hasPassive("goop_dot_bonus");
	damagePer = damagePer * multiplier;
	healMult = kaiju:hasPassive("goop_blob_absorbo");
	onON(kaiju);
	-- probably have some transform anim
end

function onAnimationEvent(a, event)
	kaiju:regainControl();
end

function onON(a)
	kaiju:loseControl();
	playSound("goop_ability_Blob_On");

	local view = kaiju:getView();
	local fx1 = 0;
	if healMult > 0 then
		fx1 = view:attachEffectToNode("root", "effects/absorbo_glob.plist", -1, 0, 0, true, false);
	end
	
	a:setPassive("blob_1", fx1);
	
	local targetPos = kaiju:getWorldPosition();
	createEffectInWorld("effects/goop_slam.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slam2.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash1.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash2.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash3.plist", targetPos, 0);
	
	view:lockSWViewOnly(true);
	view:setAnimation("goop_form", false);
	view:addAnimation(idleAnim, true);
	registerAnimationCallback(this, kaiju, "end");
	
	setAbilityDisabled(a, true);
	a:setEnablePhysicsBody(false);
	a:addPassiveScript(this);
	
	local dotAura = Aura.create(this, kaiju);
	dotAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
	dotAura:setTickParameters(tickTime, 0);
	dotAura:setTarget(kaiju); -- required so aura doesn't autorelease
		
	a:getControl():setCurrentIdle(idleAnim);
	a:getControl():setCurrentWalk(walkAnim);
	a:getControl():setCurrentDeath(deadAnim);
	
	startAbilityUse(a, abilityData.name);
end

function onOFF(a)	
	kaiju:loseControl();
	playAnimation(kaiju, "goop_revert");
	registerAnimationCallback(this, kaiju, "end");
	playSound("goop_ability_Blob_Off");

	local targetPos = kaiju:getWorldPosition();
	createEffectInWorld("effects/goop_slam.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slam2.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash1.plist", targetPos, 0);
	createEffectInWorld("effects/goop_slamsplash2.plist", targetPos, 0);
	
	local view = kaiju:getView();
	if healMult > 0 then
		view:endEffect(a:hasPassive("blob_1"));
	end
	
	a:removePassive("blob_1", 0);
	
	view:lockSWViewOnly(false);
	
	setAbilityDisabled(a, false);
	a:setEnablePhysicsBody(true);
	a:removePassiveScript(this);
	
	a:getControl():setCurrentIdle("");
	a:getControl():setCurrentWalk("");
	a:getControl():setCurrentDeath("");
	
	endAbilityUse(a, abilityData.name);
--	view:endEffect(a:hasPassive(passiveName)); -- make sure to do these 2 lines for each "core_sheld_x" you used
--	a:removePassive(passiveName, 0); -- make sure to do these 2 lines for each "core_sheld_x" you used
end

function onAvatarAbsorb(a, n, w)
	if healMult > 0 then
		a:gainHealth(n.x * healMult);
		local view = kaiju:getView();
		a:attachEffect("effects/absorbo_glob2.plist", 0.5, true);
	end
	n.x = n.x * damageMult;
end

function onTick(aura)
	if not aura then return end
	playSound("goop_ability_Blob_walk");
	local targets = getTargetsInRadius(kaiju:getWorldPosition(), aoeSize, EntityFlags(EntityType.Vehicle, EntityType.Zone, EntityType.Avatar));
	for t in targets:iterator() do
		local flying = false;
		if getEntityType(t) == EntityType.Vehicle then
			local veh = entityToVehicle(t);
			flying = veh:isAir();
		end
		if not flying then
			applyDamage(kaiju, t, damagePer);
		end
	end
	
	if aura:getElapsed() >= duration then
		onOFF(kaiju)
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
	end
end