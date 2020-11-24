------------------------------------------------------------------------------------------------------------
---------------                                     Fire                                  ---------------
------------------------------------------------------------------------------------------------------------
function fire(env)
    if (debug) then
        print('.. Mage Code checking curses')
    end
    local dispelling = handle_new_debuffs_mpdc(false, false, false, 'Remove Curse')
    local kicking = handle_interupts('Counterspell')
    debug_msg(false, '.. checking purges')
    local purging = handle_purges('Spellsteal')
    -- Check for priority targets
    use_heroism = false
    get_priority_target()
    do_boss_mechanic()
    if (debug) then
        print('.. done with curses')
    end
    if (dispelling == false and kicking == false and purging == false) then
        if (UnitExists('target')) then
            debug_msg(false, '.. dps rotation setup')

            local my_hp = env:evaluate_variable('myself.health')
            local _, invis_cd, _, _ = GetSpellCooldown('Invisibility')
            local invis_hp = 60
            local _, iceblock_cd, _, _ = GetSpellCooldown('Iceblock')
            local iceblock_duration = env:evaluate_variable('myself.buff.Iceblock')
            local iceblock_hp = 20

            local hotstreak_duration = env:evaluate_variable('myself.buff.48108')
            local heating_up_duration = env:evaluate_variable('myself.buff.48107')
            local combustion_duration = env:evaluate_variable('myself.buff.Combustion')
            local power_duration = env:evaluate_variable('myself.buff.Rune of Power')
            debug_msg(false, '.. counting enemies')
            local enemy_count = get_aoe_count()
            debug_msg(false, 'Enemy aoe count : ' .. enemy_count)
            local fireblast_charges, _, _, fireblast_cd_duration, _ = GetSpellCharges('Fire Blast')
            local _, fireblast_cd, _, _ = GetSpellCooldown('Fire Blast')
            local _, berserking_cd, _, _ = GetSpellCooldown('Berserking')
            local _, combustion_cd, _, _ = GetSpellCooldown('Combustion')
            local _, time_warp_cd, _, _ = GetSpellCooldown('Time Warp')
            local _, meteor_cd, _, _ = GetSpellCooldown('Meteor')
            local _, images_cd, _, _ = GetSpellCooldown('Mirror Image')
            local _, rune_cd, _, _ = GetSpellCooldown('Rune Of Power')

            local phoenix_charges, _, _, phoenix_cd_duration, _ = GetSpellCharges('Phoenix Flames')
            -- Trinket spam
            use_trinkets()
            debug_msg(false, '.. start casting')
            if (my_hp < invis_hp and invis_cd == 0) then
                check_cast('Invisibility')
            elseif (my_hp < iceblock_hp and iceblock_cd == 0) then
                check_cast('Ice block')
            elseif (berserking_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Berserking')
            elseif (time_warp_cd == 0 and use_heroism) then
                check_cast('Time Warp')
            elseif (combustion_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Combustion')
            elseif (images_cd == 0 and boss_mode ~= 'Save_CDs') then
                debug_msg(false, '.. start casting images')
                check_cast('Mirror Image')
            elseif (rune_cd == 0 and power_duration == -1) then
                check_cast('Rune of Power')
            elseif (check_azerites()) then
            elseif (meteor_cd == 0) then
                cast_at_target_position('Meteor', main_tank)
            elseif (hotstreak_duration > 0) then
                if (enemy_count > 2) then
                    cast_at_target_position('Flamestrike', main_tank)
                else
                    check_cast('Pyroblast')
                end
            elseif (fireblast_charges > 0 and heating_up_duration > 0) then
                check_cast('Fire Blast')
            else
                if (combustion_duration > 0) then
                    if (phoenix_charges > 0 and heating_up_duration > 0) then
                        check_cast('Phoenix Flames')
                    else
                        check_cast('Scorch')
                    end
                elseif (enemy_count > 5 and ring_of_frost_cd == 0) then
                    cast_at_target_position('Ring of Frost', main_tank)
                elseif (power_duration == 0 and phoenix_charges == 1 and phoenix_cd_duration < combustion_cd) then
                    check_cast('Phoenix Flames')
                elseif (boss_mode == 'AoE' and phoenix_charges > 0) then
                    check_cast('Phoenix Flames')
                elseif (boss_mode == 'AoE') then
                    cast_at_target_position('Flamestrike', main_tank)
                else -- check 2nd phoenix
                    check_cast('Fireball')
                end
            end
        else
            RunMacroText('/assist ' .. main_tank) -- perhaps an oops
        end
    end
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
