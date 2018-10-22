local enemyAccDebuff = 0.20;
local missileBreak = 0.50;
-- see cratering
function onSet(a)
	a:setPassive("cratering_enemy_acc_debuff", enemyAccDebuff);
	a:setPassive("cratering_missile_dodge", missileBreak);
end
