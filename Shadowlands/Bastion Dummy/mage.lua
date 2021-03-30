------------------------------------------------------------------------------------------------------------
---------------                           Fire                                             ---------------
------------------------------------------------------------------------------------------------------------
function fire(env)
    debug_rotation = true
    debug_msg(false, '.. In Mage Code')

    get_priority_target()
    do_boss_mechanic()

    local my_hp = env:evaluate_variable('myself.health')

    function healthstone()
        if (my_hp < 50) then
            RunMacroText('/use Healthstone')
        end
        return false
    end

    function invis()
        ability = 'Invisibility'
        if (my_hp < 60) then
            return check_cast('Invisibility')
        else
            return false
        end
    end

    function ice_block()
        ability = 'Ice Block'
        if (my_hp < 20) then
            return check_cast('Ice Block')
        else
            return false
        end
    end

    function barrier()
        local blazing_barrier_duration = env:evaluate_variable('myself.buff.Blazing Barrier')
        if (blazing_barrier_duration == -1) then
            return check_cast('Blazing Barrier')
        else
            return false
        end
    end

    function cooldowns()
        use_trinkets()
        return check_cast('Berserking') or time_warp() or combustion() or check_cast('Mirror Image') or rune()
    end

    function time_warp()
        ability = 'Time Warp'
        if (UnitExists('boss1')) then
            return check_cast('Time Warp')
        else
            return false
        end
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
        debug_msg(false, '. checking for Meteor')
        ability = 'Meteor'
        return cast_at_target_position('Meteor', main_tank)
    end

    function hot_pyro()
        debug_msg(false, '. checking for Hot Streak Pyroblast')
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
        ability = debug_msg(false, '. checking for Hot Streak Flamestrike')
        local hotstreak_duration = env:evaluate_variable('myself.buff.48108')
        if (hotstreak_duration > 0) then
            return cast_at_target_position('Flamestrike', main_tank)
        else
            return false
        end
    end

    function normal_flamestrike()
        ability = 'Normal - Flamestrike'
        local combustion_duration = env:evaluate_variable('myself.buff.Combustion')
        -- Only hard cast outside combustion
        if (combustion_duration == -1) then
            ability = debug_msg(false, '. checking for Normal Flamestrike')
            return cast_at_target_position('Flamestrike', main_tank)
        else
            return false
        end
    end

    function heating_fire_blast()
        ability = 'Heating Up - Fire Blast'
        debug_msg(false, '. checking for Heating Up Fire Blast')
        local heating_up_duration = env:evaluate_variable('myself.buff.48107')
        if (heating_up_duration > 0) then
            return check_cast('Fire Blast')
        else
            return false
        end
    end

    function heating_phoenix()
        ability = 'Phoenix Flames'
        debug_msg(false, '. checking for Heating Up Phoenix Flames')
        local combustion_duration = env:evaluate_variable('myself.buff.Combustion')
        local heating_up_duration = env:evaluate_variable('myself.buff.48107')
        if (combustion_duration > 0 and heating_up_duration > 0) then
            return check_cast('Phoenix Flames')
        else
            return false
        end
    end
    function ignite_phoenix()
        local THREE_PHOENIX_TRIGGER = 50
        local TWO_PHOENIX_TRIGGER = 100
        local ONE_PHOENIX_TRIGGER = 200
        local ignite_dps = 0
        ability = 'Phoenix Flames'
        local combustion_duration = env:evaluate_variable('myself.buff.Combustion')
        if (combustion_duration == -1) then
            debug_msg(false, '. checking for ignite Phoenix Flames')
            local phoenix_charges, _, _, phoenix_cd_duration, _ = GetSpellCharges('Phoenix Flames')
            for i = 1, 40 do
                local data = {UnitAura('target', i, 'HARMFUL')}
                if (not data) then
                    break
                end
                if (data[1] == 'Ignite') then
                    ignite_dps = data[16]
                    debug_msg(false, 'Ingite Dot : ' .. data[16])
                end
            end
            if
                ((ignite_dps > THREE_PHOENIX_TRIGGER and phoenix_charges == 3) or
                    (ignite_dps > TWO_PHOENIX_TRIGGER and phoenix_charges == 2) or
                    (ignite_dps > ONE_PHOENIX_TRIGGER and phoenix_charges == 1))
             then
                local result = check_cast('Phoenix Flames')
                if (result) then
                    debug_msg(true, 'Casting Ignite at : ' .. ignite_dps)
                end
                return result
            end
        end
        return false
    end

    function spend_phoenix()
        ability = 'Phoenix Flames'
        debug_msg(false, '. checking for wasted Phoenix Flames')
        local power_duration = env:evaluate_variable('myself.buff.Rune of Power')
        local phoenix_charges, _, _, phoenix_cd_duration, _ = GetSpellCharges('Phoenix Flames')
        local _, combustion_cd, _, _ = GetSpellCooldown('Combustion')
        if (phoenix_charges == 3) then
            return check_cast('Phoenix Flames')
        elseif (power_duration > 0 and phoenix_charges == 1 and phoenix_cd_duration < combustion_cd) then
            return check_cast('Phoenix Flames')
        else
            return false
        end
    end

    function fireball()
        ability = 'Fireball'
        return check_cast('Fireball')
    end

    function defensives()
        debug_msg(false, 'checking Defensives')
        return healthstone() or invis() or ice_block() or barrier()
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
        local enemy_count = get_aoe_count(8)
        debug_msg(false, 'Enemy aoe count : ' .. enemy_count)
        if (enemy_count > 2) then
            return hot_flamestrike() or ignite_phoenix() or spend_phoenix()
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
