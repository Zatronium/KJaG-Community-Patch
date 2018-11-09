require 'scripts/common'

local passiveMult = "goop_redist_mult";
local passiveName = "goop_redist_damage";

local kaiju = nil

function onSet(a)
	kaiju = a;
	kaiju:setPassive(passiveName, 1);
	kaiju:setPassive(passiveMult, 0.02);
end