get_boss_mechanics = function()
    print('creating boss mechanic list...')
    local boss_mechanics = {
        ['Blightbone'] = function(env)
            RunMacroText('/tar Carrion Worm')
        end,
        ['Amarth'] = function(env)
            RunMacroText('/tar Reanimated')
        end
    }
    return boss_mechanics
end

get_priority_target = function()
    -- Necrotic Wake
    --'Zolramus Gatekeeper'
end


get_bad_spells = function(env)
    print('creating known bad spell list...')
    local bad_spells = {

        ['320596'] = 'Heaving Retch',
        --desc = "Heaving Retch (Blightbone)";
        ['324323'] = 'Gruesome Cleave',
        --desc = "Gruesome Cleave (Skeletal Marauder)";
        ['324391'] = 'Grave Spikes',
        --desc = "Grave Spikes (Skeletal Monstrosity)";
        ['321253'] = 'Final Harvest',
        --desc = "Final Harvest (Amarth)";
        -- Uldir
        ['270288'] = 'Blood Storm'
    }
    return bad_spells
end

return {
    variables = {},
    actions = {         
    },
    rotations = {}
}
