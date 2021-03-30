------------------------------------------------------------------------------------------------------------
---------------                                     Prot                                  ---------------
------------------------------------------------------------------------------------------------------------
function protection(env)
    debug_msg(false, 'In paladin, no gcd')
    get_npc_info()
    --  eecc = env:evaluate_variable("npcs.attackable.range_8") -- temporay debugging

    -- A fix for no target spam
    RunMacroText('/cleartarget [dead][noexists]')
    get_priority_target()
    do_boss_mechanic()
    if (UnitExists('target') == false) then
        debug_msg(false, '.. no target, fixing')
        --  env:execute_action("target_nearest_enemy")
        RunMacroText('/targetenemy [nodead][exists]')
    else
        debug_msg(false, '.. Checking for dispels')
        local dispelling = handle_new_debuffs_mpdc(nil, 'Cleanse Toxins', 'Cleanse Toxins', nil)
        debug_msg(false, '..  Finished checking for dispels')
        debug_msg(false, ' .. dispell result :' .. tostring(dispelling))

        local kicking = handle_interupts('Rebuke')
        debug_msg(false, ' .. interrupt result :' .. tostring(kicking))

        if (dispelling == false and kicking == false) then
            debug_msg(false, '.. fetching cooldowns')
            local _, hoj_cd = GetSpellCooldown('Hammer of Justice')
            local _, lotp_cd = GetSpellCooldown('Light Of The Protector')
            local _, ardent_cd = GetSpellCooldown('Ardent Defender')
            local _, hands_cd = GetSpellCooldown('Lay on Hands')
            local _, guardian_cd = GetSpellCooldown('Guardian Of Ancient Kings')
            local _, divine_protection_cd = GetSpellCooldown('Divine Protection')
            local _, avenging_wrath_cd = GetSpellCooldown('Avenging Wrath')
            local shining_light_duration = env:evaluate_variable('myself.buff.327510') -- shining light (182104 is for building stacks)

            local life = env:evaluate_variable('myself.health')
            local holy_power = UnitPower('player', 9)
            -- Trinket spam
            use_trinkets()
            debug_msg(false, '.. checking defensives')
            -- defensives
            if (hands_cd == 0 and life < 10) then
                RunMacroText('/cast [@player] Lay on Hands')
            elseif (guardian_cd == 0 and life < 40) then
                check_cast('Guardian Of Ancient Kings')
            elseif (ardent_cd == 0 and life < 60) then
                -- elseif (lotp_cd == 0 and life < 70) then
                --     check_cast("Light Of The Protector")
                check_cast('Ardent Defender')
            elseif (divine_protection_cd == 0 and life < 80) then
                check_cast('Divine Protection')
            elseif (life < 70 and holy_power >= 3) then
                RunMacroText('/cast [@player] Word of Glory')
            elseif (life < 90 and shining_light_duration > 0) then
                RunMacroText('/cast [@player] Word of Glory')
            else
                --    print("Attackable range 8 :", eecc, " enemy_count:", get_enemy_count()) -- temporay debugging
                debug_msg(false, '.. loading dps cooldowns')

                -- tank rotation
                local _, avengers_shield_cd = GetSpellCooldown("Avenger's Shield")
                local _, hammer_cd = GetSpellCooldown('Blessed Hammer')
                local _, judgment_cd = GetSpellCooldown('Judgment')
                local target_health = env:evaluate_variable('unit.target.health')
                local _, wrath_cd = GetSpellCooldown('Hammer Of Wrath')

                -- local _, crusader_strike_cd = GetSpellCooldown("Crusader Strike")
                local _, consecration_cd = GetSpellCooldown('Consecration')
                local consecration_duration = env:evaluate_variable('myself.buff.Consecration')
                -- local shield_charges, shield_max_harges, shield_cooldown_start, shield_cooldown_duration, _ = GetSpellCharges("Shield of the Righteous")
                local shield_duration = env:evaluate_variable('myself.buff.132403') -- 132403 for dmg reduction effect, 53600 for spell

                debug_msg(false, '.. performing roation')

                -- Use shield if we have taken damage and don't have it up
                if
                    (life < 100 and shield_duration == -1 and holy_power > 2 and
                        env:evaluate_variable('npcs.attackable.range_8') >= 1)
                 then
                    check_cast('Shield of the Righteous')
                elseif (holy_power == 5) then
                    check_cast('Shield of the Righteous')
                elseif (avenging_wrath_cd == 0 and boss_mode ~= 'Save_CDs') then
                    check_cast('Avenging Wrath')
                elseif (check_azerites()) then
                elseif (avengers_shield_cd == 0) then
                    check_cast("Avenger's Shield")
                elseif
                    (consecration_duration == -1 and consecration_cd == 0 and
                        env:evaluate_variable('npcs.attackable.range_8') >= 1)
                 then
                    check_cast('Consecration')
                elseif (wrath_cd == 0 and target_health < 20) then
                    check_cast('Hammer Of Wrath')
                elseif (hammer_cd == 0) then
                    check_cast('Blessed Hammer')
                elseif (judgment_cd == 0) then
                    check_cast('Judgment')
                elseif (consecration_cd == 0 and env:evaluate_variable('npcs.attackable.range_8') >= 1) then
                    check_cast('Consecration')
                elseif (hoj_cd == 0) then
                    check_cast('Hammer of Justice')
                end
                debug_msg(false, '.. finished paladin code')
            end
        end
    end
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
