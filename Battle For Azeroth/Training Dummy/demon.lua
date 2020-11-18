------------------------------------------------------------------------------------------------------------
---------------                         Vengeance                                            ---------------
------------------------------------------------------------------------------------------------------------
function vengeance(env)
    debug_msg(false, '.. In Vengeance Code')
    -- Check for priority targets
    get_priority_target()
    do_boss_mechanic()

    local kicking = handle_interupts('Disrupt')
    if (kicking == false) then
        local purging = handle_purges('Arcane Torrent') -- or handle_purges('Consume Magic')
        if (purging == false) then
            local defensives = false
            if (defensives == false) then
                debug_msg("false", "Dpomg damage")
            end
        end
    end

end
return {
    variables = {},
    actions = {},
    rotations = {}
}
