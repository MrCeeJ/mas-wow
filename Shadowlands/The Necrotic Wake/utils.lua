
do_boss_mechanic = function()
    local unit_name = UnitName('boss1') or nil
    if (unit_name ~= nil) then
        debug_msg(false, 'Boss Found! :' .. unit_name)
        boss_fight = true
    else
        boss_fight = false
    end