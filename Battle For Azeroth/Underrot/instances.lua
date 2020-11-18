-- local wmbapi, wowapi = ...

get_boss_mechanics = function()
    print('creating boss mechanic list...')
    local boss_mechanics = {
        -- Waycrest Manor
        ['Sister Malady'] = function(env)
            local override_target = nil
            for b = 1, 3 do
                local target = 'boss' .. b
                for i = 1, 5 do
                    local name, _, _, type, duration, _, _, _, _, spellId = UnitBuff(target, i)
                    if (name == 'Focusing Iris') then --'260805'
                        found = true
                        -- print("Targeting Boss :", b)
                        override_target = target
                    end
                end
            end
            -- if (env:evaluate_variable("myself.debuff.")) then Jump if you have thing
            -- end

            -- Target people with Soul Manipulation to free them
            for i, player_name in ipairs(party) do
                local debuff_duration = env:evaluate_variable('unit.' .. player_name .. '.debuff.Soul Manipulation') --225788
                if (debuff_duration == 0) then
                    print('Mind Control found, need to attack :', player_name)
                    override_target = player_name
                end
            end
            if (override_target ~= nil) then
                RunMacroText('/target ' .. override_target)
            end
            -- Move apart if you have Unstable Runic Mark
        end,
        ['Sister Briar'] = function(env)
            local override_target = nil
            for b = 1, 3 do
                local target = 'boss' .. b
                for i = 1, 5 do
                    local name, _, _, type, duration, _, _, _, _, spellId = UnitBuff(target, i)
                    if (name == 'Focusing Iris') then --"260805"
                        found = true
                        -- print("Targeting Boss :", b)
                        override_target = target
                    end
                end
            end
            -- if (env:evaluate_variable("myself.debuff.")) then Jump if you have thing
            -- end

            -- Target people with Soul Manipulation to free them
            for i, player_name in ipairs(party) do
                local debuff_duration = env:evaluate_variable('unit.' .. player_name .. '.debuff.Soul Manipulation')
                if (debuff_duration == 0) then
                    print('Mind Control found, need to attack :', player_name)
                    override_target = player_name
                end
            end
            if (override_target ~= nil) then
                RunMacroText('/target ' .. override_target)
            end
            -- Move apart if you have Unstable Runic Mark
        end,
        ['Sister Solena'] = function(env)
            local override_target = nil
            for b = 1, 3 do
                local target = 'boss' .. b
                for i = 1, 5 do
                    local name, _, _, type, duration, _, _, _, _, spellId = UnitBuff(target, i)
                    if (name == 'Focusing Iris') then --"260805"
                        found = true
                        -- print("Targeting Boss :", b)
                        override_target = target
                    end
                end
            end
            -- if (env:evaluate_variable("myself.debuff.")) then Jump if you have thing
            -- end

            -- Target people with Soul Manipulation to free them
            for i, player_name in ipairs(party) do
                local debuff_duration = env:evaluate_variable('unit.' .. player_name .. '.debuff.Soul Manipulation')
                if (debuff_duration == 0) then
                    print('Mind Control found, need to attack :', player_name)
                    override_target = player_name
                end
            end
            if (override_target ~= nil) then
                RunMacroText('/target ' .. override_target)
            end
            -- Move apart if you have Unstable Runic Mark
        end,
        ['Lady Waycrest'] = function(env)
            -- spread
            -- move out of disease residue
        end,
        ['Gorak Tul'] = function(env)
            -- positions
            -- tank  -455.9, -339.3, 152.4
            -- healer - -466.7, -337.3, 152.1
            ---459.8, -330.9, 152.1
            ---458.3, -352.7, 152.1
            ---466.9, -346.1, 152.1
        end,
        ['Soulbound Goliath'] = function(env)
            RunMacroText('/target Soul Thorns')
        end,
        ['Raal the Gluttonous'] = function(env)
        end,
        -- Tol Dagor
        ['The Sand Queen'] = function(env)
        end,
        ['Jes Howlis'] = function(env)
        end,
        ['Knight Captain Valyri'] = function(env)
        end,
        ['Overseer Korgus'] = function(env)
        end,
        -- Freehold
        ["Skycap'n Kragg"] = function(env)
        end,
        ['Captain Raoul'] = function(env)
        end,
        ['Captain Eudora'] = function(env)
        end,
        ['Captain Jolly'] = function(env)
        end,
        ['Trothak'] = function(env)
        end,
        ['Harlan Sweete'] = function(env)
        end,
        -- Underrot
        ['Elder Leaxa'] = function(env)
        end,
        ['Cragmaw the Infested'] = function(env)
        end,
        ['Sporecaller Zancha'] = function(env)
        end,
        ['Unbound Abomination'] = function(env)
            local hp = UnitHealth('boss1')
            if (hp < 30) then
                RunMacroText('/tar Blood Visage')
            end
        end,
        -- Temple of Sethralis
        ['Adderis'] = function(env)
        end,
        ['Aspix'] = function(env)
        end,
        ['Merektha'] = function(env)
        end,
        ['Galvazzt'] = function(env)
        end,
        ['Avatar of Sethraliss'] = function(env)
        end,
        -- Motherlode
        ['Coin-Operated Crowd Pummeler'] = function(env)
        end,
        ['Azerokk'] = function(env)
        end,
        ['Rixxa Fluxflame'] = function(env)
        end,
        ['Mogul Razdunk'] = function(env)
            RunMacroText('/tar Venture Co Skyscorcher')
        end,
        --Uldir
        ['Taloc'] = function(env)
            -- local boss_immune = 100
            -- if (UnitExists('boss1')) then
            --     boss_immune = (env:evaluate_variable('unit.boss1.buff.Powered Down') > -1)
            -- end
            boss_hp = env:evaluate_variable('unit.boss1.health')
            RunMacroText('/tar Taloc')
            if (boss_hp > 35) then
                RunMacroText('/tar Coalesced Blood')
            end
            if (player_class == "MAGE") then
                RunMacroText('/tar Volatile Droplet')
            end
            move_distance = 4
            -- or towards healer if out of range
            -- to / from boss depending on distance?
            move_direction = 'back_left'
        end,
        -- Bonus
        ['Headless Horseman'] = function(env)
            -- number of dudes > 2 go to AoE mode
            local count = get_aoe_count(15)
            if (boss_mode == nil) then
                boss_mode = 'Save_CDs'
                RunMacroText('/p  Saving Cooldowns')
            elseif (count > 2 and boss_mode ~= 'AoE') then
                if (aoe_timer_start == nil) then
                    aoe_timer_start = game_time
                    RunMacroText('/p  Staring timer')
                else
                    if (player_class == 'PALADIN') then
                        if (game_time > aoe_timer_start + 3) then
                            RunMacroText('/p  Engaging AoE mode')
                            boss_mode = 'AoE'
                        end
                    else
                        if (game_time > aoe_timer_start + 9) then
                            RunMacroText('/p  Engaging AoE mode')
                            boss_mode = 'AoE'
                        end
                    end
                end
            elseif (count < 2 and boss_mode == 'AoE') then
                RunMacroText('/p  Returning to nomal')
                boss_mode = 'Normal'
            end
        end
    }
    return boss_mechanics
end

get_bad_spells = function(env)
    print('creating known bad spell list...')
    local bad_spells = {
        -- Atal' Dazar
        ['255558'] = 'Tainted Blood',
        ['255620'] = 'Festering Eruption (Reanimated Honor Guard)',
        ['257483'] = 'Pile of Bones (Rezan)',
        ['255371'] = 'Terrifying Visage (Rezan)',
        ['258986'] = 'Stink Bomb (Shadowblade Razi)',
        ['277072'] = 'Corrupted Gold (Corrupted Gold)',
        -- The Underrot
        ['265542'] = 'Rotten Bile (Fetid Maggot)',
        ['265540'] = 'Rotten Bile (Fetid Maggot)',
        ['261498'] = 'Creeping Rot (Elder Leaxa)',
        ['265687'] = 'Noxious Poison (Venomous Lasher)',
        ['269838'] = 'Vile Expulsion (Unbound Abomination)',
        ['278789'] = 'Wave of Decay',
        -- Tol Dagor
        -- Waycrest Manor
        ['263905'] = 'Marking Cleave (Heartsbane Runeweaver)',
        ['264531'] = 'Shrapnel Trap (Maddened Survivalist)',
        ['264476'] = 'Tracking Explosive (Crazed Marksman)',
        ['271174'] = 'Retch (Pallid Gorger)',
        ['264923'] = 'Tenderize (Raal the Gluttonous)',
        ['265757'] = 'Splinter Spike (Matron Bryndle)',
        ['264150'] = 'Shatter (Thornguard)',
        ['265372'] = 'Shadow Cleave (Enthralled Guard)',
        ['265352'] = 'Toad Blight (Blight Toad)',
        ['288922'] = 'Call Meteor (Aman)',
        ['288951'] = 'Burning (Burninator Mark V)',
        ['288716'] = 'Fire Fall (Conflagros)',
        -- Freehold
        ['257273'] = 'Vile Bombardment',
        ['258673'] = 'Azerite Grenade (Irontide Crackshot)',
        ['256106'] = "Azerite Powder Shot (Skycap'n Kragg)",
        ['258773'] = "Charrrrrge (Skycap'n Kragg)",
        ['258779'] = 'Sea Spout (Irontide Oarsman)',
        ['272374'] = 'Whirlpool of Blades (Captain Jolly)',
        ['267523'] = 'Cutting Surge (Captain Jolly)',
        ['256594'] = 'Barrel Smash (Captain Raoul)',
        ['257310'] = 'Cannon Barrage (Harlan Sweete)',
        ['257315'] = 'Black Powder Bomb (Harlan Sweete)',
        ['272397'] = 'Whirlpool of Blades',
        ['276061'] = 'Boulder Throw (Irontide Crusher)',
        ['258199'] = 'Ground Shatter (Irontide Crusher)',
        ['257902'] = 'Shell Bounce (Ludwig Von Tortollan)',
        ['258352'] = 'Grapeshot (Captain Eudora)',
        -- Motherlode
        ['256137'] = 'Timed Detonation (Azerite Footbomb)',
        ['268365'] = 'Mining Charge',
        ['271583'] = 'Black Powder Special',
        ['263105'] = 'Blowtorch (Feckless Assistant)',
        ['269092'] = 'Artillery Barrage (Ordnance Specialist)',
        ['262377'] = 'Seek and Destroy (Crawler Mine)',
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
