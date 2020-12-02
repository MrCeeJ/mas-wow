------------------------------------------------------------------------------------------------------------
---------------                                     Balance                                  ---------------
------------------------------------------------------------------------------------------------------------
function balance(env)
    debug_msg(false, '.. checking dispels')
    local dispelling = handle_new_debuffs_mpdc(false, 'Remove Corruption', false, 'Remove Corruption')
    debug_msg(false, '.. checking purges')
    local purging = handle_purges('Soothe')
    -- Check for priority targets
    get_priority_target()
    do_boss_mechanic()
    if (dispelling == false and purging == false) then
        if (UnitExists('target')) then
            debug_msg(false, '.. checking cooldowns')
            -- Check for renewal
            local my_hp = env:evaluate_variable('myself.health')
            local _, renewal_cd, _, _ = GetSpellCooldown('Renewal')
            local renewal_hp = 70
            local _, barkskin_cd, _, _ = GetSpellCooldown('Barkskin')
            local barksin_hp = 50
            debug_msg(false, '.. checking target')
            local target_hp = env:evaluate_variable('unit.target.health')
            local moonfire_duration = env:evaluate_variable('unit.target.debuff.Moonfire')
            local sunfire_duration = env:evaluate_variable('unit.target.debuff.Sunfire')
            local _, berserking_cd, _, _ = GetSpellCooldown('Berserking')
            local _, alignment_cd, _, _ = GetSpellCooldown('Celestial Alignment') --39
            local _, incarnation_cd, _, _ = GetSpellCooldown('Incarnation: Chosen of Elune')
            local _, fury_cd, _, _ = GetSpellCooldown('Fury of Elune')
            local _, beam_cd, _, _ = GetSpellCooldown('Solar Beam')
            local _, rebirth_cd, _, _ = GetSpellCooldown('Rebirth')
            local _, innervate_cd, _, _ = GetSpellCooldown('Innervate')
            local healer_mp = 0
            if (healer_name) then
                local healer_mana = UnitPower(healer_name, 0)
                local healer_max_mana = UnitPowerMax(healer_name, 0)
                healer_mp = 100 * healer_mana / healer_max_mana
            end
            local solar_emp_duration = env:evaluate_variable('myself.buff.164545') -- solar
            local lunar_empduration = env:evaluate_variable('myself.buff.164547') -- lunar
            local astral_power = UnitPower('player', 8)
            local knows_stellar_flare = GetSpellInfo('Stellar Flare')
            local flare_duration = env:evaluate_variable('unit.target.debuff.Stellar Flare')

            local previous_eclipse = env:evaluate_variable('get_previous_eclipse')
            local lunar_eclipse_duration = env:evaluate_variable('myself.buff.Eclipse (Lunar)')
            local solar_eclipse_duration = env:evaluate_variable('myself.buff.Eclipse (Solar)')
            local alignment_eclipse_duration = env:evaluate_variable('myself.buff.Celestial Alignment')
            local eclipse_charges = env:evaluate_variable('get_eclipse_charges')
            debug_msg(false, '.. counting enemies')
            local enemy_count = get_aoe_count()
            debug_msg(false, 'Enemy aoe count : ' .. enemy_count)

            -- check combat res
            combat_res = false
            if (rebirth_cd == 0 and party) then
                for _, player_name in ipairs(party) do
                    if (combat_res == false) then
                        local distance = env:evaluate_variable('unit.' .. player_name .. '.distance')
                        local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                        if (target_hp == 0 and distance < 20) then
                            combat_res = true
                            print('I should probably res :', player_name)
                        end
                    end
                end
            end
            -- barkskin, soothe
            combat_res = false -- something up with it
            -- Trinket spam
            use_trinkets()
            --rotation
            debug_msg(false, '.. starting moonkin pewpew')
                            RunMacroText('/cast [noform:4] Moonkin Form')
            if (my_hp < renewal_hp and renewal_cd == 0) then
                check_cast('Renewal')
            elseif (my_hp < barksin_hp and barkskin_cd == 0) then
                check_cast('Barkskin')
            elseif (healer_mp ~= 0 and healer_mp < 65 and innervate_cd == 0) then
                RunMacroText('/cast [target=' .. healer_name .. '] Innervate')
            elseif (combat_res) then
                RunMacroText('/cast [target=' .. player_name .. '] Rebirth')
            elseif (check_azerites()) then
                debug_msg(false, '.. Did an Azerite')
            elseif (target_hp > min_dot_hp and sunfire_duration < 1 and eclipse_charges == 0) then
                check_cast('Sunfire')
            elseif (target_hp > min_dot_hp and moonfire_duration < 1 and eclipse_charges == 0) then
                check_cast('Moonfire')
            elseif (knows_stellar_flare and target_hp > min_dot_hp and flare_duration < 1 and eclipse_charges == 0) then
                check_cast('Stellar Flare')
            elseif (alignment_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Celestial Alignment')
            elseif (berserking_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Berserking')
            elseif (incarnation_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Incarnation: Chosen of Elune')
            elseif (solar_emp_duration > 0 and eclipse_charges == 0) then
                check_cast('Wrath')
            elseif (lunar_empduration > 0 and eclipse_charges == 0) then
                check_cast('Lunar Strike')
            elseif (alignment_eclipse_duration > 0) then -- Double Eclipse
                if (fury_cd == 0) then
                    check_cast('Fury Of Elune')
                elseif (enemy_count < 2) then -- Count it as Lunar
                    previous_eclipse = 'Lunar'
                    if (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                        check_cast('Starsurge')
                    else
                        check_cast('Wrath')
                    end
                else -- Count it as Solar
                    previous_eclipse = 'Solar'
                    if (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                        check_cast('Starsurge')
                    elseif (astral_power >= 50) then
                        cast_at_target_position('Starfall', main_tank)
                    else
                        check_cast('Starfire')
                    end
                end
            elseif (lunar_eclipse_duration > 0) then -- Lunar Eclipse
                previous_eclipse = 'Lunar'
                if (fury_cd == 0) then
                    check_cast('Fury Of Elune')
                elseif (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                    check_cast('Starsurge')
                elseif (enemy_count > 2 and astral_power >= 50) then
                    cast_at_target_position('Starfall', main_tank)
                else
                    check_cast('Starfire')
                end
            elseif (solar_eclipse_duration > 0) then -- Solar Eclipse
                previous_eclipse = 'Solar'
                if (fury_cd == 0) then
                    check_cast('Fury Of Elune')
                elseif (enemy_count < 3 and astral_power >= 30 and solar_eclipse_duration > 6) then
                    check_cast('Starsurge')
                elseif (enemy_count > 2 and astral_power >= 50) then
                    cast_at_target_position('Starfall', main_tank)
                else
                    check_cast('Wrath')
                end
            elseif (beam_cd == 0) then -- why not :)
                check_cast('Solar Beam')
            elseif (sunfire_duration < 6 and target_hp > min_dot_hp) then -- pandemic dots
                check_cast('Sunfire')
            elseif (moonfire_duration < 7 and target_hp > min_dot_hp) then
                check_cast('Moonfire')
            elseif (knows_stellar_flare and target_hp > min_dot_hp and flare_duration < 8) then
                check_cast('Stellar Flare')
            elseif (previous_eclipse == 'Solar') then -- Switch to Lunar
                if (eclipse_charges < 2) then
                    eclipse_charges = eclipse_charges + 1
                    check_cast('Wrath')
                else
                    eclipse_charges = 0
                    check_cast('Starfire')
                end
            elseif (previous_eclipse == 'Lunar') then -- Switch to Solar
                if (eclipse_charges < 2) then
                    eclipse_charges = eclipse_charges + 1
                    check_cast('Starfire')
                else
                    eclipse_charges = 0
                    check_cast('Wrath')
                end
            end
            debug_msg(false, '.. done zapping things for this gcd')
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
