require 'scripts/common'

local avatar = 0;

local durationtime = 20;
local reduction = 0.75;
local aoeRange = 200;

local hasUpdated = false;
function onUse(a)
	avatar = a;

	local view = a:getView();
	view:attachEffectToNode("root", "effects/energyPrisim_core.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/IFFScrambler_pulseFrontVertical.plist", durationtime, 0, 0, true, false);
	view:attachEffectToNode("root", "effects/IFFScrambler_pulseBackVertical.plist", durationtime, 0, 0, false, true);

	startAbilityUse(avatar, abilityData.name);
	
	local aura = createAura(this, avatar, "gino_energy_prism");
	aura:setTickParameters(durationtime, 0);
	--aura:setTickParameters(1, 0);
	aura:setScriptCallback(AuraEvent.OnTick, "onTick");
	aura:setTarget(a);
	
	a:addPassiveScript(this);
end

function onTick(aura)
	if aura:getElapsed() > durationtime then
		avatar:removePassiveScript(this);
		endAbilityUse(avatar, abilityData.name);
		aura:getOwner():detachAura(aura);
	end
end

function onAvatarAbsorb(a, n, w)
	if n.y <= 1 or not w then
		return;
	end
	local weap = entityToWeapon(w);
	if not weap then
		return;
	end
	
	if weap:getWeaponType() == WeaponType.Beam then
		local damage = math.ceil(n.x * reduction);
		local offset = weap:getTargetSceneOffset();
		local weapID = weap:getWeaponID();
		local view = a:getView();
		n.x = math.max (0, n.x - damage);
		local worldPos = a:getWorldPosition();
		local targets = getTargetsInRadius(worldPos, aoeRange, EntityFlags(EntityType.Vehicle, EntityType.Zone,EntityType.Avatar));
		local firebeams = 1;
		for t in targets:iterator() do
			view:doBeamWeaponFromNode("root", getScenePosition(t:getWorldPosition()), weapID, offset);
			firebeams = firebeams - 1;
			applyDamage(a, t, damage);
		end
		if firebeams > 0 then --ensures visually a beam is redirected
			view:doBeamWeaponFromNode("root", getScenePosition(offsetRandomDirection(worldPos, aoeRange, aoeRange)), weapID, offset);
		end
	end
end