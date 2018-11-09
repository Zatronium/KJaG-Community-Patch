require 'scripts/common'

-- Global values.
local kaiju = nil;
local target = nil;

function onUse(a, t)
	kaiju = a;
	a:setWeakTarget(t);
	local facingAngle = getFacingAngle(kaiju:getWorldPosition(), t:getWorldPosition());
	kaiju:setWorldFacing(facingAngle);
	playAnimation(kaiju, "ability_acidspray");
	registerAnimationCallback(this, kaiju, "start");
end

function onAnimationEvent(a)
	target = kaiju:getWeakTarget();
	if not canTarget(target) then
		return;
	end
	local view = a:getView();
	local worldPosition = a:getWorldPosition();
	local worldFacing = a:getWorldFacing();
	local sceneFacing = a:getSceneFacing();

	local targets = getTargetsInCone(worldPosition, 300, 20, worldFacing, EntityFlags(EntityType.Avatar, EntityType.Zone));
	view:doEffectFromNode('breath_node', 'effects/acidSpray_wide.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/acidSpray_core.plist', sceneFacing);
	view:doEffectFromNode('breath_node', 'effects/acidSpray_splash.plist', sceneFacing);
	for t in targets:iterator() do
		local Planto = Aura.create(this, t);
		Planto:setTag('planto_acid');
		Planto:setScriptCallback(AuraEvent.OnTick, 'onTick');
		Planto:setTickParameters(0.2, 0.2);
		Planto:setTarget(t); -- required so aura doesn't autorelease
		
		t:attachEffect("effects/onCorrosive.plist"       ,0.3, true);
		t:attachEffect("effects/onCorrosive_smoke.plist" ,0.3, true);
	end
	playSound("sfx_weap_acid_spray_muzzle");
end

function onTick(aura)
	if not aura then return end
	local self = aura:getOwner()
	if not self then
		aura = nil return;
	end
	applyDamageWithWeapon(kaiju, self, "weapon_planto_acid");
end