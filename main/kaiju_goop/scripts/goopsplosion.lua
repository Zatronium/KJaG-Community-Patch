require 'scripts/common'

local damagethresh 	= 10;
local damage 		= 5;
local range 		= 250;
local flying		= 1;

passiveThresh 		= "goop_splash_step";
passiveDamage 		= "goop_splash_damage";
passiveRange 		= "goop_splash_range";
passiveHitFlying 	= "goop_splash_flying";

kaiju = nil

function onSet(a)
	kaiju = a;
	kaiju:setPassive(passiveThresh 		, damagethresh);
	kaiju:setPassive(passiveDamage 		, damage 		);
	kaiju:setPassive(passiveRange 			, range 		);
	kaiju:setPassive(passiveHitFlying 		, flying		);
end