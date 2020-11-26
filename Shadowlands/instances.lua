get_boss_mechanics = function()
    print('creating boss mechanic list...')
    local boss_mechanics = {
        -- The Necrotic Wake
        ['Blightbone'] = function(env)
            RunMacroText('/tar Carrion Worm')
        end,
        ['Amarth'] = function(env)
            RunMacroText('/tar Reanimated')
        end
        -- Plaguefall
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
        -- The Necrotic Wake
        ['320596'] = 'Heaving Retch', --  "Heaving Retch (Blightbone)";
        ['324323'] = 'Gruesome Cleave', -- "Gruesome Cleave (Skeletal Marauder)";
        ['324391'] = 'Grave Spikes', -- "Grave Spikes (Skeletal Monstrosity)";
        ['321253'] = 'Final Harvest', -- "Final Harvest (Amarth)";
        -- Plaguefall
        ['328012'] = 'Binding Fungus', -- applicationOnly = true
        ['328019'] = 'Plague Bore (Plagueborer)',
        ['327233'] = 'Belch Plague (Plaguebelcher)',
        ['326242'] = 'Slime Wave (Globgrog)', -- applicationOnly = true
        ['328501'] = 'Plague Bomb (Rigged Plagueborer)',
        ['320519'] = 'Jagged Spines (Blighted Spinebreaker)',
        ['318949'] = 'Festering Belch (Blighted Spinebreaker)', -- tankSound = 0
        ['328986'] = 'Violent Detonation (Unstable Canister)',
        ['329217'] = 'Slime Lunge (Doctor Ickus)',
        ['330026'] = 'Slime Lunge (Doctor Ickus)',
        ['323572'] = 'Rolling Plague (Plagueborer)',
        ['322475'] = 'Plague Crash (Margrave Stradama)',
        -- Uldir
        ['270288'] = 'Blood Storm'
    }
    return bad_spells
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
