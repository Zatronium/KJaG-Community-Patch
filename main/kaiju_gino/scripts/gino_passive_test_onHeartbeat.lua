require 'kaiju_gino/scripts/gino' --need to include this so that the "onAttack" is still used as this would replace the "gino.lua" file

-- this is a script to show how to use an ability to automatically apply an effect
--	(eg: shrubby's roots)
-- pick a time frame
delay = 3.0; -- lets say every 3 seconds it will apply the effect

-- onHeartbeat updates every 0.5 seconds
function onHeartbeat(a)
-- need to count down the delay
	delay = delay - 0.5;
	if delay <= 0.0 then
		--reset the delay
		delay = 3.0;
		
		--apply the actions 
		--(in this case, set everything on fire and apply 10 pnts of damage in a 500 m radius)
		local worldPos = a:getWorldPosition();
		local scenePos = a:getView():getPosition();
		createEffect('effects/nova.plist', scenePos);
		local targets = getTargetsInRadius(worldPos, 500, EntityFlags(EntityType.Vehicle, EntityType.Zone)); 
		for t in targets:iterator() do
			createEffect('effects/onFire.plist', t:getView():getPosition());
			applyDamage(a, t, 10); -- assume t is not valid after applyDamage
		end
	end
end