local enemyAccDebuff = 0.15;
local missileBreak = 0.20;
-- see cratering
function onSet(a)
	a:setPassive("cratering_enemy_acc_debuff", enemyAccDebuff);
	a:setPassive("cratering_missile_dodge", missileBreak);
end
