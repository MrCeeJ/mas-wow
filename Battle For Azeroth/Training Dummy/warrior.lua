------------------------------------------------------------------------------------------------------------
---------------                                    Arms                                      ---------------
------------------------------------------------------------------------------------------------------------
function arms(env)
    debug_msg(false, '.. In arms Code')
    -- Check for priority targets
    get_priority_target()
    do_boss_mechanic()

    local kicking = handle_interupts('Pummel')
    if (kicking == false) then
        if (UnitExists('target')) then
            local target_hp = env:evaluate_variable('unit.target.health')
            local target_distance = env:evaluate_variable('unit.target.distance')
            local rage = UnitPower('player', 1)

            local my_hp = env:evaluate_variable('myself.health')
            local _, die_by_sword_cd, _, _ = GetSpellCooldown('Die by the Sword')
            local _, charge_cd, _, _ = GetSpellCooldown('Charge')
            local _, execute_cd, _, _ = GetSpellCooldown('Execute')
            local _, victory_rush_cd, _, _ = GetSpellCooldown('Victory Rush')
            local victory_rush_duration = env:evaluate_variable('myself.buff.Victory Rush') -- Check
            local _, sweeping_strikes_cd, _, _ = GetSpellCooldown('Sweeping Strikes')
            local _, colossus_smash_cd, _, _ = GetSpellCooldown('Colossus Smash')
            local _, mortal_strike_cd, _, _ = GetSpellCooldown('Mortal Strike')
            local _, overpower_cd, _, _ = GetSpellCooldown('Overpower')
            local _, whirlwind_cd, _, _ = GetSpellCooldown('whirlwind')
            -- Die by the Sword
            -- Whirlwind (no cd)
            --sweeping_strikes_cd
            if (target_distance > 8 and target_distance < 25 and charge_cd == 0) then
                check_cast('Charge')
            elseif (execute_cd == 0 and target_hp < 20 and rage > 20) then
                check_cast('Execute')
            elseif (victory_rush_cd == 0 and victory_rush_duration > 0) then
                check_cast('Victory Rush')
            elseif (mortal_strike_cd == 0 and rage > 30) then
                check_cast('Mortal Strike')
            elseif (rage > 20) then
                check_cast('Slam')
            end
        else
            if (main_tank) then
                RunMacroText('/assist ' .. main_tank)
            end
        end
    end
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
