------------------------------------------------------------------------------------------------------------
---------------                                 Mistweaver                                      ---------------
------------------------------------------------------------------------------------------------------------
function mistweaver(env)
    debug_rotation = true
    debug_msg(false, '.. In Mistweaver Code')

    get_priority_target()
    do_boss_mechanic()

    local my_hp = env:evaluate_variable('myself.health')

    table.sort(
        party,
        function(a, b)
            return env:evaluate_variable('unit.' .. a .. '.health') < env:evaluate_variable('unit.' .. b .. '.health')
        end
    )

    function defensives()
        debug_msg(debug_rotation, 'checking Defensives')
        local result = false
        if (my_hp < 90) then
            result = check_cast('Expel Harm')
        end
        if (result == false and my_hp < 95 and spikes_duration == -1) then
            result = check_cast('Demon Spikes')
        end
        return result
    end

    function emergency_heal()
    end

    function group_heal()
    end

    function normal_heal()
    end

    function light_heal()
    end

    function dps()
    end

    return defensives() or emergency_heal() or group_heal() or normal_heal() or light_heal() or dps()
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
