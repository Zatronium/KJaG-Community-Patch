require 'scripts/avatars/common'
local durationtime = 5;
local waveWidth = 300;

local kaiju = nil
local targetpos = 0;
local lastpos = 0;
local eventstate = 0;
local dir = 0;

function onUse(a)
	kaiju = a;
	enableTargetSelection(this, abilityData.name, 'onTargets', 9999);
end

function onTargets(position)
	--createFloatingNumber(kaiju, 22, 0, 255, 255);
	lastpos = kaiju:getWorldPosition();
	dir = getDirectionFromPoints(lastpos, position);
	
	local angle = getFacingAngle(lastpos, position);

	if angle < 0 then
		angle = 360 + angle;
	end

	local v = kaiju:getView();
	if angle > 45 and angle < 225 then
		v:setFacingAngle(0, false);
	else
		v:setFacingAngle(6, false);
	end
	
	v:lockSWViewOnly(true);

	setAbilityDisabled(kaiju, true);
	kaiju:getMovement():setPlayerControl(false);
	kaiju:setInvulnerableTime(durationtime);
	kaiju:setEnablePhysicsBody(false);
	startAbilityUse(kaiju, abilityData.name);
	
	eventstate = 0;
	v:setAnimation("goop_form", false);
	registerAnimationCallback(this, kaiju, "end");
	
	kaiju:getControl():setCurrentWalk("goop_walk");
	kaiju:getControl():setCurrentIdle("goop_idle");
	
	playSound("goop_ability_GOOPnami");
end

function onAnimationEvent(a, event)
	if eventstate == 0 then
		local movement = kaiju:getMovement();
		movement:moveTo(offsetPosition(lastpos, dir.x * 3000, dir.y * 3000));
		
		local timeAura = Aura.create(this, kaiju);
		timeAura:setTag('goop_nami');
		timeAura:setScriptCallback(AuraEvent.OnTick, 'onTick');
		timeAura:setTickParameters(1, 0); 
		timeAura:setTarget(kaiju); 
		
		eventstate = 1;
	else 
		setAbilityDisabled(kaiju, false);
		kaiju:getMovement():moveTo(kaiju:getWorldPosition());
		kaiju:getMovement():setPlayerControl(true);
		kaiju:getView():lockSWViewOnly(false);
		kaiju:setEnablePhysicsBody(true);
		endAbilityUse(a, abilityData.name);
	end
end

function onTick(aura)
	if not aura then return end
	if aura:getElapsed() > durationtime then
		local v = kaiju:getView();
		v:setAnimation("goop_revert", false);
		eventstate = 1;
		registerAnimationCallback(this, kaiju, "end");
		kaiju:getControl():setCurrentWalk("");
		kaiju:getControl():setCurrentIdle("");
		local owner = aura:getOwner()
		if not owner then
			aura = nil return
		else
			owner:detachAura(aura);
		end
	end
	local kaijuWorldPosition = kaiju:getWorldPosition()
	local worlds = kaijuWorldPosition
	local worlde = kaijuWorldPosition
	
	-- just to mark the area
	local estimate = 150;
	worlds.x = worlds.x - dir.y * estimate;
	worlds.y = worlds.y + dir.x * estimate;
	
	worlde.x = worlde.x + dir.y * estimate;
	worlde.y = worlde.y - dir.x * estimate;
	local view = kaiju:getView();
	local worldeScenePosition = getScenePosition(worlde)
	view:doBeamEffectFromNode("root", getScenePosition(worlds), "effects/goop_goopnamibits.plist", 0);
	view:doBeamEffectFromNode("root", worldeScenePosition, "effects/goop_goopnamibits.plist", 0);
	view:doBeamEffectFromNode("root", worldeScenePosition, "effects/goop_slamsplash3.plist", 0);
	--createEffectInWorld("effects/goop_cloudybits.plist", worlds, 2);
	--createEffectInWorld("effects/goop_cloudybits.plist", worlde, 2);
	---
	
	local targets = getTargetsInBeam(kaijuWorldPosition, lastpos, waveWidth, EntityFlags(EntityType.Vehicle));
	lastpos = kaijuWorldPosition
	for t in targets:iterator() do
		local veh = entityToVehicle(t);
		local flying = veh:isAir();
		local super = veh:isSuper();
		if not flying and not super then
			applyDamage(kaiju, t, t:getStat("MaxHealth"));
		end
	end
end