------------------------------------------------------------------------------------------------------------
---------------                                     Elemental                                  ---------------
------------------------------------------------------------------------------------------------------------
function elemental(env)
    -- Check for priority targets
    use_heroism = false
    get_priority_target()
    do_boss_mechanic()
    local dispelling = handle_new_debuffs_mpdc(false, false, false, 'Cleanse Spirit')
    local kicking = handle_interupts('Wind Shear')
    local purging = handle_purges('Purge')
    if (dispelling == false and kicking == false and purging == false) then
        if (UnitExists('target')) then
            local target_hp = env:evaluate_variable('unit.target.health')
            local _, flame_shock_cd, _, _ = GetSpellCooldown('188389')
            local _, earth_elemental_cd, _, _ = GetSpellCooldown('Earth Elemental')
            local _, fire_elemental_cd, _, _ = GetSpellCooldown('Fire Elemental')
            local _, storm_elemental_cd, _, _ = GetSpellCooldown('Storm Elemental')
            local flame_shock_duration = env:evaluate_variable('unit.target.debuff.188389')
            local maelstrom = UnitPower('player', 11)
            local lb_charges, _, _, lb_cooldownDuration, _ = GetSpellCharges('Lava Burst')
            local _, berserking_cd, _, _ = GetSpellCooldown('Berserking')
            local _, ancestral_guidance_cd, _, _ = GetSpellCooldown('Ancestral Guidance')
            local _, bloodlust_cd, _, _ = GetSpellCooldown('Bloodlust')
            local _, ascendance_cd, _, _ = GetSpellCooldown('Ascendance')

            local _, healing_stream_cd, _, _ = GetSpellCooldown('Healing Stream Totem')
            local tank_hp = env:evaluate_variable('unit.' .. main_tank .. '.health')
            local tank_distance = env:evaluate_variable('unit.' .. main_tank .. '.distance')

            local lightning_shield_duration = env:evaluate_variable('myself.buff.Lightning Shield')
            debug_msg(false, '.. counting enemies')
            local enemy_count = get_aoe_count()
            debug_msg(false, 'Enemy aoe count : ' .. enemy_count)
            local my_hp = env:evaluate_variable('myself.health')
            local _, astral_shift_cd, _, _ = GetSpellCooldown('Astral Shift')
            local astral_shift_hp = 70

            -- TODO:
            -- Check for rebuffing Earth Shield
            -- Check for defensive Tremor Totem (47)
            -- Check for defensive Thunderstorm (49)
            -- Check AoE Capacitor Totem ?
            -- Check Tremor Totem (Fear, Charm, Sleep)

            --multidot flameshock
            -- Check Av HP for Ancestral Guidance healing
            local total_hp = 0
            local players = 0
            for _, player_name in ipairs(party) do
                local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                total_hp = total_hp + target_hp
                if (target_hp > 0) then
                    players = players + 1
                end
            end
            av_hp = total_hp / players
            use_trinkets()

            if (my_hp < astral_shift_hp and astral_shift_cd == 0) then
                check_cast('Astral Shift')
            elseif (healing_stream_cd == 0 and av_hp < 95) then
                check_cast('Healing Stream Totem')
            elseif (ancestral_guidance_cd == 0 and av_hp < 80) then
                check_cast('Ancestral Guidance')
            elseif (lightning_shield_duration == -1) then
                check_cast('Lightning Shield')
            elseif (check_azerites()) then
            elseif (earth_elemental_cd == 0 and tank_hp < 40) then
                check_cast('Earth Elemental')
            elseif (storm_elemental_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Storm Elemental')
            elseif (fire_elemental_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Fire Elemental')
            elseif (berserking_cd == 0 and boss_mode ~= 'Save_CDs') then
                check_cast('Berserking')
            elseif (target_hp > min_dot_hp and flame_shock_duration < 1 and flame_shock_cd == 0) then
                check_cast('Flame Shock')
            elseif (ascendance_cd == 0) then
                check_cast('Ascendance')
            elseif (enemy_count > 2 and maelstrom >= 60 and tank_distance < 40) then
                cast_at_target_position('Earthquake', main_tank)
            elseif (maelstrom ~= nil and maelstrom >= 60) then
                check_cast('Earth Shock')
            elseif (lb_cooldownDuration == 0 or lb_charges > 0) then
                check_cast('Lava Burst')
            elseif (use_heroism and bloodlust_cd == 0) then
                check_cast('Bloodlust')
            elseif (enemy_count > 2) then
                check_cast('Chain Lightning')
            else
                check_cast('Lightning Bolt')
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
