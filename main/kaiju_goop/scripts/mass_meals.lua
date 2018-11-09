require 'scripts/common'

local damagethresh = 2;
local healperhit = 10;

local passiveName = "goop_meals";
local passiveHeal = "goop_meals_heal";

local kaiju = nil

function onSet(a)
	kaiju = a;
	kaiju:setPassive(passiveName, damagethresh);
	kaiju:setPassive(passiveHeal, healperhit);
end