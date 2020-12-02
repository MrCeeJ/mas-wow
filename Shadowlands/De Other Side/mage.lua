------------------------------------------------------------------------------------------------------------
---------------                           Fire                                             ---------------
------------------------------------------------------------------------------------------------------------
function fire(env)
    debug_rotation = true
    debug_msg(false, '.. In Mage Code')

    get_priority_target()
    do_boss_mechanic()

    local my_hp = env:evaluate_variable('myself.health')

    function defensives()
        debug_msg(fales, 'checking Defensives')
        local result = false
        if (my_hp < 60) then
            result = check_cast('Invisibility')
        end
        if (result == false and my_hp < 20) then
            result = check_cast('Ice Block')
        end
        if (result == false and do_i_need_buffing(env, 'Blazing Barrier')) then
            result = check_cast('Blazing Barrier')
        end
        return result
    end

    function cooldowns()
        use_trinkets()
        return check_cast('Berserking') or check_cast('Time Warp') or combustion() or check_cast('Mirror Image') or
            rune()
    end

    function combustion()
        ability = 'Combustion'
        return check_cast('Combustion')
    end

    function rune()
        local rune_of_power_duration = env:evaluate_variable('myself.buff.Rune of Power')
        local combustion_duration = env:evaluate_variable('myself.buff.Combustion')
        if (rune_of_power_duration > 0 or combustion_duration > 0) then
            return false
        else
            ability = 'Rune of Power'
            return check_cast('Rune of Power')
        end
    end

    function radiant_spark()
        ability = 'Radiant Spark'
        return check_cast('Radiant Spark')
    end

    function meteor()
        debug_msg(fales, '. checking for Meteor')
        ability = 'Meteor'
        return cast_at_target_position('Meteor', main_tank)
    end

    function hot_pyro()
        debug_msg(fales, '. checking for Hot Streak Pyroblast')
        ability = 'Hot Streak - Pyroblast'
        local hotstreak_duration = env:evaluate_variable('myself.buff.48108')
        if (hotstreak_duration > 0) then
            return check_cast('Pyroblast')
        else
            return false
        end
    end

    function hot_flamestrike()
        ability = 'Hot Streak - Flamestrike'
        ability = debug_msg(fales, '. checking for Hot Streak Flamestrike')
        local hotstreak_duration = env:evaluate_variable('myself.buff.48108')
        if (hotstreak_duration > 0) then
            return check_cast('Flamestrike')
        else
            return false
        end
    end

    function heating_fire_blast()
        ability = 'Heating Up - Fire Blast'
        debug_msg(fales, '. checking for Heating Up Fire Blast')
        local heating_up_duration = env:evaluate_variable('myself.buff.48107')
        if (heating_up_duration > 0) then
            return check_cast('Fire Blast')
        else
            return false
        end
    end

    function heating_phoenix()
        ability = 'Phoenix Flames'
        debug_msg(fales, '. checking for Heating Up Phoenix Flames')
        local combustion_duration = env:evaluate_variable('myself.buff.Combustion')
        local heating_up_duration = env:evaluate_variable('myself.buff.48107')
        if (combustion_duration > 0 and heating_up_duration > 0) then
            return check_cast('Phoenix Flames')
        else
            return false
        end
    end

    function spend_phoenix()
        ability = 'Phoenix Flames'
        debug_msg(fales, '. checking for Heating Up Phoenix Flames')
        local power_duration = env:evaluate_variable('myself.buff.Rune of Power')
        local phoenix_charges, _, _, phoenix_cd_duration, _ = GetSpellCharges('Phoenix Flames')
        local _, combustion_cd, _, _ = GetSpellCooldown('Combustion')
        if (power_duration > 0 and phoenix_charges == 1 and phoenix_cd_duration < combustion_cd) then
            return check_cast('Phoenix Flames')
        else
            return false
        end
    end

    function fireball()
        ability = 'Fireball'
        return check_cast('Fireball')
    end

    function dps()
        if (UnitExists('target')) then
            result =
                radiant_spark() or meteor() or hot_pyro() or heating_fire_blast() or heating_phoenix() or
                spend_phoenix() or
                fireball()
        else
            result = false
            ability = ' Nothing - no target!'
        end
        return result
    end

    function aoe()
        local enemy_count = get_aoe_count()
        debug_msg(false, 'Enemy aoe count : ' .. enemy_count)
        if (enemy_count > 3) then
            return hot_flamestrike() or spend_phoenix()
        end
        return false
    end

    result =
        handle_interupts('Counterspell') or handle_purges('Spellsteal') or defensives() or cooldowns() or aoe() or dps()
    debug_msg(debug_rotation and result, 'Casting :' .. tostring(ability))
    return result
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
