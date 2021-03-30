get_boss_mechanics = function()
    print('creating boss mechanic list...')
    local boss_mechanics = {
        -- Halls of Atonement
        ['Halkias'] = function(env)
            move_direction = 3
        end,
        ['Echelon'] = function(env)
            move_direction = 3
        end,
        ['Inquisitor Sigar'] = function(env)
            move_direction = 3
        end,
        -- The Necrotic Wake
        ['Blightbone'] = function(env)
            RunMacroText('/tar Carrion Worm')
        end,
        ['Amarth'] = function(env)
            RunMacroText('/tar Reanimated')
        end,
        -- Plaguefall
        ['Globgrog'] = function(env)
        end,
        ['Doctor Ickus'] = function(env)
        end,
        ['Domina Venomblade'] = function(env)
        end,
        ['Margrave Stradama'] = function(env)
        end,
        -- Mists of Tirna Schithe
        ['Ingra Malorch'] = function(env)
            -- Avoid cast 323137
            -- interupt 323057
            -- Death shroud - radiance?
            debug_msg(true, 'Targeting Droman')
            move_direction = 3
            RunMacroText('/tar Droman')
        end,
        ["Tred'ova"] = function(env)
            -- mind link break 322648
            -- makred prey, run away 322563
            -- 322450 dps shield then can interupt this
        end,
        -- 7 Spires of Ascension
        ['Oryphrion'] = function(env)
            move_direction = 7
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
        --Theater of Pain
        ['332708'] = 'Ground Smash (Heavin the Breaker)',
        ['317231'] = 'Crushing Slam (Xav the Unfallen)',
        ['320729'] = 'Massive Cleave (Xav the Unfallen)',
        ['317605'] = 'Whirlwind (Nekthara the Mangler)',
        ['321041'] = 'Disgusting Burst (Disgusting Refuse)',
        ['330608'] = 'Vile Eruption (Rancid Gasbag)',
        --["323406"] = "Jagged Gash (Gorechop)",
        ['317367'] = "Necrotic Volley (Kul'tharok)",
        ['331243'] = 'Bone Spikes (Soulforged Bonereaver)',
        ['333294'] = 'Bone Spear (Bone Magus)',
        --["332731"] = "Debilitating Filth",
        --["319567"] = "Grasping Hands (Kul'tharok)",

        -- Spires of Ascension
        ['324662'] = 'Charged Spear (Kin-Tara)',
        ['317626'] = 'Maw-Touched Venom',
        ['323739'] = 'Residual Impact (Forsworn Squad-Leader)',
        ['323792'] = 'Volatile Anima',
        ['339080'] = 'Surging Anima',
        ['324444'] = 'Anima Field',

        -- Halls of Atonement
        -- ['326440'] = 'Sin Quake (Shard of Halkias)',
        ['322945'] = 'Heave Debris (Halkias)',
        -- ['338013'] = 'Anima Fountain (Anima Fountain)',
        -- ['323126'] = 'Telekinetic Collision (Lord Chamberlain)',
        -- spells
        ['323001'] = 'Glass Shards (Halkias)',
        -- ['324044'] = 'Refracted Sinlight (Halkias)',
        ['319703'] = 'Blood Torrent (Echelon)',
        -- ['323853'] = 'Pulse from Beyond (Ghastly Parishioner) -- Area damage version',
        ['326891'] = 'Anguish (Inquisitor Sigar)',

        -- The Necrotic Wake
        ['320596'] = 'Heaving Retch', --  "Heaving Retch (Blightbone)";
        ['324323'] = 'Gruesome Cleave', -- "Gruesome Cleave (Skeletal Marauder)";
        ['324391'] = 'Grave Spikes', -- "Grave Spikes (Skeletal Monstrosity)";
        ['321253'] = 'Final Harvest', -- "Final Harvest (Amarth)";

        -- Plaguefall
        ['319120'] = 'Slime',
        ['328012'] = 'Binding Fungus', -- applicationOnly = true
        ['328019'] = 'Plague Bore (Plagueborer)',
        ['327233'] = 'Belch Plague (Plaguebelcher)',
        ['326242'] = 'Slime Wave (Globgrog)', -- applicationOnly = true
        ['328501'] = 'Plague Bomb (Rigged Plagueborer)',
        -- ['320519'] = 'Jagged Spines (Blighted Spinebreaker)',
        ['318949'] = 'Festering Belch (Blighted Spinebreaker)', -- tankSound = 0
        -- ['328986'] = 'Violent Detonation (Unstable Canister)',
        ['329217'] = 'Slime Lunge (Doctor Ickus)',
        ['330026'] = 'Slime Lunge (Doctor Ickus)',
        ['323572'] = 'Rolling Plague (Plagueborer)',
        ['322475'] = 'Plague Crash (Margrave Stradama)',
        ['Concentrated Plague'] = 'Concentrated Plague',

        -- Mists of Tirna Schithe
        --  ['321968'] = 'Bewildering Pollen (Tirnenn Villager)',
        --  ['323137'] = 'Bewildering Pollen (Droman Oulfarran)',
        ['331748'] = 'Back Kick (Mistveil Guardian)',
        ['321834'] = 'Dodge Ball (Mistcaller)',
        ['321893'] = 'Freezing Burst (Illusionary Vulpin)',
        ['325418'] = 'Acid Spray (Spinemaw Acidgullet)',
        -- ['326022'] = 'Acid Globule (Spinemaw Gorger)',
        -- ['322655'] = "Acid Expulsion (Tred'ova)",
        ['326263'] = "Anima Shedding (Tred'ova)",
        ['323250'] = 'Anima puddle, doh!'
    }
    return bad_spells
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
