local kaiju = nil
local laserDamage = 0.5

function onSet(a)
	kaiju = a
	a:addPassiveScript(this)
	local view = a:getView()
	view:attachEffectToNode("root", "effects/glitter.plist", -1, 0, 0, true, false)
end

function onAvatarAbsorb(a, n, w)
	if n.y <= 1 or not w then
		return
	end
	local weap = entityToWeapon(w)
	if not weap then
		return
	end
	if weap:getWeaponType() == WeaponType.Beam then
		n.x = n.x * laserDamage
	end
end