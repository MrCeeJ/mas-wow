-- local wmbapi, wowapi = ...
------------------------------------------------------------------------------------------------------------
---------------                                     Disc                                  ---------------
------------------------------------------------------------------------------------------------------------
function discipline(env)
    local debug_priest = false
    debug_msg(debug_priest, 'Priest code')
    get_priority_target()
    do_boss_mechanic()
    if (UnitExists('target')) then
        debug_msg(debug_priest, '.. have target')

        local healing = false
        local _, penance_cd, _, _ = GetSpellCooldown('Penance')
        local rapture_duration = env:evaluate_variable('myself.buff.Rapture')

        -- Dispell everyone
        debug_msg(debug_priest, '.. checking dispells')
        local dispelling = handle_new_debuffs_mpdc('Purify', false, 'Purify', false)
        debug_msg(debug_priest, '.. dispelling :' .. tostring(dispelling))
        debug_msg(debug_priest, '.. checking purges')
        local purging = handle_purges('Dispel Magic')
        if (dispelling == false and purging == false) then
            debug_msg(debug_priest, '.. not dispelling')
            -- Check for Desperate Prayer
            local health_check = 60
            local my_hp = env:evaluate_variable('myself.health')
            local _, desperate_cd, _, _ = GetSpellCooldown('Desperate Prayer')

            if (my_hp < health_check and desperate_cd == 0) then
                healing = true
                RunMacroText('/cast [@player] Desperate Prayer')
            else
                -- Never slack on Schism or Solace
                local _, schism_cd, _, _ = GetSpellCooldown('Schism')
                local _, solace_cd, _, _ = GetSpellCooldown('Power Word: Solace')
                local _, fiend_cd, _, _ = GetSpellCooldown('Shadowfiend')
                -- Trinket spam
                use_trinkets()
                if (schism_cd == 0 and not moving) then
                    check_cast('Schism')
                elseif (fiend_cd == 0 and boss_mode ~= 'Save_CDs') then
                    check_cast('Shadowfiend')
                elseif (solace_cd == 0) then
                    check_cast('Power Word: Solace')
                end
                debug_msg(debug_priest, 'Sorting on HP')
                -- check HP
                -- order_by_hp = function(player_1, player_2)
                --     local p1_hp = env:evaluate_variable("unit." .. player_1 .. ".health")
                --     local p2_hp = env:evaluate_variable("unit." .. player_2 .. ".health")
                --     return p1 < p2
                -- end
                table.sort(
                    party,
                    function(a, b)
                        return env:evaluate_variable('unit.' .. a .. '.health') <
                            env:evaluate_variable('unit.' .. b .. '.health')
                    end
                )

                debug_msg(debug_priest, 'Sorting finished')
                debug_msg(debug_priest, '.. group healing')
                -- If 3 or more people have taken damage and don't have Atonement cast Radiance (currently seems to double cast, same as druid empowerment)
                local radiance_charges, _, _, radiance_cd_duration, _ = GetSpellCharges('Power Word: Radiance')
                if (radiance_charges > 0 and radiance_cd_duration < 18 and not moving) then
                    local sinners = 0
                    for _, player_name in ipairs(party) do
                        local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                        local atonement_duration = env:evaluate_variable('unit.' .. player_name .. '.buff.atonement')
                        if (target_hp > 0 and target_hp < 90 and atonement_duration < 3) then
                            sinners = sinners + 1
                        end
                    end
                    if (sinners > 2) then
                        healing = true
                        check_cast('Power Word: Radiance')
                    end
                end
                if (healing == false) then
                    -- If people have less than 40% hp, panic
                    health_check = 40
                    for _, player_name in ipairs(party) do
                        local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                        if (target_hp > 0 and target_hp < health_check) then
                            local weakened_soul_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.debuff.6788')
                            local _, pain_suppression_cd, _, _ = GetSpellCooldown('Pain Suppression')
                            local _, rapture_cd, _, _ = GetSpellCooldown('Rapture')
                            local pain_suppression_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.buff.Pain Supression')

                            if (rapture_duration > 0 or pain_suppression_duration > 0) then
                                -- happy days, already on it
                            elseif (rapture_cd == 0) then
                                healing = true
                                check_cast('Rapture')
                            elseif (rapture_duration == -1 and pain_suppression_cd == 0) then -- Chuck them a super shield
                                healing = true
                                RunMacroText('/cast [target=' .. player_name .. '] Pain Suppression')
                            end
                        end
                    end
                end
                debug_msg(debug_priest, '.. over 40% healing')
                -- If people have 40-70% hp, help them out
                health_check = 70
                for _, player_name in ipairs(party) do
                    if (healing == false) then
                        local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                        if (target_hp > 0 and target_hp < health_check) then
                            local weakened_soul_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.debuff.6788')
                            local shield_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.buff.Power Word: Shield')
                            if (shield_duration == -1 and (weakened_soul_duration == -1 or rapture_duration > 0)) then
                                -- Chuck them a shield
                                healing = true
                                RunMacroText('/cast [target=' .. player_name .. '] Power Word: Shield')
                            else
                                if (penance_cd == 0) then
                                    -- They have had a shield, can we top them off with Penance?
                                    healing = true
                                    RunMacroText('/cast [target=' .. player_name .. '] Penance')
                                elseif (not moving) then
                                    -- They have had a shield, and they are still below 80, give them a mend
                                    healing = true
                                    RunMacroText('/cast [target=' .. player_name .. ']Shadow Mend')
                                end
                            end
                        end
                    end
                end
                debug_msg(debug_priest, '.. over 70% healing')

                -- If people have over 70% hp, just use Atonement
                health_check = 100
                for _, player_name in ipairs(party) do
                    if (healing == false) then
                        local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                        if (target_hp > 0 and target_hp < health_check) then
                            local atonement_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.buff.Atonement')
                            if (atonement_duration > 0) then
                                -- Do nothing, they are have atonement
                            else
                                -- Chuck them a shield, they will be fine (If you have weakened soul you also have atonement, so always use a shieled)
                                healing = true
                                RunMacroText('/cast [target=' .. player_name .. '] Power Word: Shield')
                            end
                        end
                    end
                end
                debug_msg(debug_priest, '.. priest go pewpew')
                -- Do Damage
                if (healing == false) then
                    debug_msg(debug_priest, '.. checking cds')
                    local swpain_duration = env:evaluate_variable('unit.target.debuff.589') -- TODO: Check all in combat targets
                    local purge_duration = env:evaluate_variable('unit.target.debuff.204213')
                    local target_health = env:evaluate_variable('unit.target.health')
                    debug_msg(debug_priest, '.. target hp :'.. tostring(target_health))

                    local _, schism_cd, _, _ = GetSpellCooldown('Schism')
                    local _, solace_cd, _, _ = GetSpellCooldown('Power Word: Solace')
                    local _, fiend_cd, _, _ = GetSpellCooldown('Shadowfiend')
                    local _, death_cd, _, _ = GetSpellCooldown('Shadow Word: Death')
                    local _, mind_blast_cd, _, _ = GetSpellCooldown('Mind Blast')
                    if (purge_duration > swpain_duration) then
                        swpain_duration = purge_duration
                    end

                    local min_swd_hp = 40
                    debug_msg(debug_priest, '.. casting')

                    if (target_health > min_dot_hp and swpain_duration == -1) then
                        debug_msg(debug_priest, '.. dot them up')
                        check_cast('Shadow Word: Pain')
                    elseif (schism_cd == 0 and not moving) then
                        check_cast('Schism')
                    elseif (check_azerites()) then
                    elseif (fiend_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Shadowfiend')
                    elseif (solace_cd == 0) then
                        check_cast('Power Word: Solace')
                    elseif (boss_mode == 'AoE') then
                        check_cast('Holy Nova')
                    elseif (target_health < min_swd_hp and my_hp > 20 and death_cd == 0) then
                        check_cast('Shadow Word: Death')
                    elseif (mind_blast_cd == 0) then
                        check_cast('Mind Blast')
                    elseif (penance_cd == 0) then
                        check_cast('Penance')
                    elseif (not moving) then
                        check_cast('Smite')
                    end
                    debug_msg(debug_priest, ".. finished priest casting code")
                end
            end
        end
    else
        debug_msg(debug_priest, ".. don't have target")
        if(main_tank) then
            RunMacroText('/assist ' .. main_tank)
        end
    end
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
