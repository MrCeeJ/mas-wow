------------------------------------------------------------------------------------------------------------
---------------                         Vengeance                                            ---------------
------------------------------------------------------------------------------------------------------------
function vengeance(env)
    debug_msg(false, '.. In Vengeance Code')
    -- Check for priority targets
    get_priority_target()
    do_boss_mechanic()

    function defensives()
        return false
    end

    function dps()
        return true
    end

    return handle_interupts('Disrupt') or handle_purges('Arcane Torrent') or handle_purges('Consume Magic') or
        defensives() or
        dps()
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
