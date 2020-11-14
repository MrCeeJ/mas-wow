local wmbapi, wowapi = ...
return {
    -- Define custom variables.
    variables = {
        ['get_fire_event_frame'] = function(env)
            if (event_frame == nil) then
                if (debug or debug_frame_setup) then
                    print('Setting up frame ..')
                end                
                event_frame = CreateFrame('Frame', 'event_frame', UIParent) --
                event_frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
            end
            return event_frame
        end,
        -- ['moving'] = gcd_moved or false,
        ['get_healer_name'] = function(env)
            local healer_name = 'Ceejpriest'
            return healer_name
        end,
        ['get_tank_name'] = function(env)
            local tank_name = 'Ceejpaladin'
            return tank_name
        end,
        ['get_party'] = function(env)
            if (party == nil) then
                print('creating party...')
                party = {}
                party_info = GetHomePartyInfo()
                if (party_info ~= nil) then
                    for id, name in pairs(party_info) do
                        -- local isTank, isHeal, isDPS = UnitGroupRolesAssigned(Unit) -- uses bliz unit id not name
                        if (true) then
                            print('Welcome to you :', name)
                        elseif (isTank) then
                            print('Welcome to the tank :', name)
                        elseif (isDPS) then
                            print('Welcome to the deeps :', name)
                        elseif (isHeal) then
                            print('Finally, a healer! :', name)
                        end
                        table.insert(party, name)
                    end
                end
                local me, _ = UnitName('player')
                print('.. and welcome to :', me, ' playing spec :', env:evaluate_variable('myself.spec'))
                table.insert(party, me)
            end
            return party
        end,
        ['get_known_buffs'] = function(env)
            if (known_buffs == nil) then
                print('creating known buff list...')
                known_buffs = {
                    [326419] = 'Winds of Wisdom',
                    [21562] = 'Fortitude',
                    [194384] = 'Attonement',
                    [26297] = 'Power Word: Shield',
                    [193065] = 'Masochism',
                    [167152] = 'Replensihment'
                }
            end
            return known_buffs
        end,
        ['get_known_debuffs'] = function(env)
            if (known_debuffs == nil) then
                print('creating known debuff list...')
                known_debuffs = {
                    -- Our own / generic
                    [6788] = 'Weakened Soul',
                    [25771] = 'Forbearance',
                    [187464] = 'Shadow Mend',
                    [87024] = 'Cauterized',
                    [87023] = 'Cauterize',
                    [225080] = 'Reincarnation',
                    [57724] = 'Sated',
                    [1604] = 'Dazed'
                }
            end
            return known_debuffs
        end,
        ['get_ignore_magic'] = function(env)
            if (ignore_magic == nil) then
                print('creating ingore magics list...')
                ignore_magic = {
                    [15497] = 'Forst Bolt'
                }
            end
            return ignore_magic
        end,
        ['get_bad_spells'] = function(env)
            if (bad_spells == nil) then
                print('creating known bad spell list...')
                bad_spells = {
                    ['2120'] = 'Flame Strike',
                    ['205470'] = 'Flame Patch',
                    -- Atal' Dazar
                    ['255558'] = 'Tainted Blood',
                    ['255620'] = 'Festering Eruption (Reanimated Honor Guard)',
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
                }
            end
            return bad_spells
        end,
        ['get_safe_locations'] = function(env)
            if (safe_locations == nil) then
                print('creating known safe location list...')
                safe_locations = {
                    {90.0, -326.1, -7.9},
                    {58.5, -323.1, -7.9},
                    {91.3, -306.5, -7.9},
                    {59.3, -303.4, -7.9}
                }
            end
            return safe_locations
        end,
        ['get_priority_targets'] = function(env)
            if (priorities == nil) then
                print('creating known priority targets list...')
                priorities = {
                    'Naga Distiller'
                }
            end
            return priorities
        end,
        ['get_previous_eclipse'] = function(env)
            if (previous_eclipse == nil) then
                previous_eclipse = 'Lunar'
            end
            return previous_eclipse
        end,
        ['get_eclipse_charges'] = function(env)
            if (eclipse_charges == nil) then
                eclipse_charges = 0
            end
            return eclipse_charges
        end,
        ['get_boss_mechanics'] = function(env)
            if (boss_mechanics == nil) then
                print('creating boss mechanic list...')
                boss_mechanics = {
                    -- Waycrest Manor
                    ['Sister Malady'] = function(env)
                        local found = false
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
                            local debuff_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.debuff.Soul Manipulation') --225788
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
                        local found = false
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
                            local debuff_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.debuff.Soul Manipulation')
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
                        local found = false
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
                            local debuff_duration =
                                env:evaluate_variable('unit.' .. player_name .. '.debuff.Soul Manipulation')
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
        end
    },
    --Custom Actions
    actions = {
        aoe = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                local _, consecration_cd = GetSpellCooldown('Consecration')
                if (consecration_cd == 0) then
                    check_cast('Consecration')
                end
            elseif player_class == 'PRIEST' then
                check_cast('Holy Nova')
            elseif player_class == 'DRUID' then
                local astral_power = UnitPower('player', 8)
                if (astral_power >= 50) then
                    RunMacroText('/cast [@player]Starfall')
                end
            elseif player_class == 'MAGE' then
                local _, blast_wave_cd = GetSpellCooldown('Consecration')
                if (blast_wave_cd == 0) then
                    check_cast('Blast Wave')
                else
                    RunMacroText('/cast [@player]Flame Strike')
                end
            elseif player_class == 'SHAMAN' then
                local _, totem_cd = GetSpellCooldown('Capacitor Totem')
                local _, thunderstorm_cd = GetSpellCooldown('Thunderstorm')
                if (totem_cd == 0) then
                    RunMacroText('/cast [@player]Capacitor Totem')
                elseif (thunderstorm_cd == 0) then
                    check_cast('Thunderstorm')
                end
            end
            return false
        end,
        start_scatter = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                MoveForwardStart() 
            elseif player_class == 'PRIEST' then                
                RunMacroText("/dance")
            elseif player_class == 'DRUID' then
                MoveBackwardStart() 
            elseif player_class == 'SHAMAN' then
                StrafeLeftStart()
            elseif player_class == 'MAGE' then
                StrafeRightStart()
            end
        end,
        stop_scatter = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                MoveForwardStop() 
            elseif player_class == 'PRIEST' then       
                RunMacroText("/cheer")         
            elseif player_class == 'DRUID' then
                MoveBackwardStop() 
            elseif player_class == 'SHAMAN' then
                StrafeLeftStop()
            elseif player_class == 'MAGE' then
                StrafeRightStop()
            end
        end,
        -- Tol
        overseer_korgus_positions = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                env:execute_action('move', {99.5, -2676.1, 78.1})
            elseif player_class == 'PRIEST' then
                env:execute_action('move', {123.1, -2671.7, 74.9})
            elseif player_class == 'DRUID' then
                env:execute_action('move', {119.0, -2682.9, 74.4})
            elseif player_class == 'SHAMAN' then
                env:execute_action('move', {105.7, -2667.0, 75.0})
            elseif player_class == 'MAGE' then
                env:execute_action('move', {107.8, -2682.8, 75.0})
            end
        end,
        -- Waycrest Manor
        heartsbane_triad_positions = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                env:execute_action('move', {-562.9, -153.0, 235.2})
            elseif player_class == 'PRIEST' then
                env:execute_action('move', {-555.9, -169.3, 235.2})
            elseif player_class == 'DRUID' then
                env:execute_action('move', {-556.1, -161.8, 235.2})
            elseif player_class == 'SHAMAN' then
                env:execute_action('move', {-551.8, -154.5, 235.2})
            elseif player_class == 'MAGE' then
                env:execute_action('move', {-564.1, -166.9, 235.2})
            end
        end,
        lady_waycrest_positions = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                env:execute_action('move', {-548.0, -262.4, 185.3})
            elseif player_class == 'PRIEST' then
                env:execute_action('move', {-562.1, -267.3, 185.3})
            elseif player_class == 'DRUID' then
                env:execute_action('move', {-556.0, -272.0, 185.3})
            elseif player_class == 'SHAMAN' then
                env:execute_action('move', {-562.2, -257.5, 185.3})
            elseif player_class == 'MAGE' then
                env:execute_action('move', {-554.8, -249.4, 185.3})
            end
        end,
        pull_lord_waycrest = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                print('Pulling Lady Waycrest')
                RunMacroText('/tar Lady Waycrest')
                RunMacroText('/cast Judgment')
            -- RunMacroText('/cast [@player]Flame Strike')
            -- RunMacroText('/cast [target=' .. player_name .. ']' .. spell)
            end
        end,
        raal_the_gluttonous_positions = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                env:execute_action('move', {-494.3, -341.1, 236.5})
            elseif player_class == 'PRIEST' then
                env:execute_action('move', {-497.4, -337.0, 235.6})
            elseif player_class == 'DRUID' then
                env:execute_action('move', {-486.2, -340.3, 235.7})
            elseif player_class == 'SHAMAN' then
                env:execute_action('move', {-501.6, -338.5, 235.6})
            elseif player_class == 'MAGE' then
                env:execute_action('move', {-491.3, -338.0, 235.6})
            end
        end,
        get_vol_kaal_totem_positions = function(env)
            return {
                {-591.2, 2292.4, 710.0},
                {-636.2, 2316.1, 710.0},
                {-636.0, 2269.2, 710.0}
            }
        end,
        mage_food = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'MAGE' then
                env:execute_action('cast', 'Conjure Refreshment')
            end
        end,
        engage_boss_mode = function(env)
            local waypoint = 17
            print('Switching to boss waypoint :', waypoint)
            env:execute_action('set_next_waypoint', waypoint)
        end,
        fight_boss = function(env, boss_name)
            if (boss_name) then
                RunMacroText('/target ' .. boss_name)
                local hp = UnitHealth('target')
                local boss_dead = UnitIsDead('target')
            else
                print('Warning, no boss specified!')
            end
        end,
        choose_wm_route = function(env)
            local bottom_left = 282408
            local bottom_right = 282409
            local top_right = 282766
            local top_right = 282768
        end,
        group_up = function(env)
            party_info = GetHomePartyInfo()
            if (party_info ~= nil) then
                local grouped = true
                for id, name in pairs(party_info) do
                end
            end
        end
    },
    -- Define rotation
    rotations = {
        -- combat = _G.getRotations.combat_rotation,
        -- combat = function(env, is_pulling) end,
        --------------------------------------------------------------------------------------------------------------------
        ---------------                                          Combat                                      ---------------
        --------------------------------------------------------------------------------------------------------------------
        combat = function(env, is_pulling)
            debug = false
            debug_spells = false
            debug_frame = false
            debug_movement = false
            debug_frame_setup = false

            enable_event_frame = enable_event_frame or true
            boss_mode = boss_mode or nil
            game_time = tonumber(GetTime())
            gcd_moved_time = gcd_moved_time or game_time
            gcd_moved = gcd_moved or false
            check_move_destination = check_move_destination or false
            -- wmbapi.SetSystemVar("moving", gcd_moved)
            safe_position = safe_position or 1
            fire_timer = fire_timer or 0
            moving = moving or false
            strafe_end_time = strafe_end_time or nil
            aoe_timer_start = aoe_timer_start or nil
            player_class = player_class or env:evaluate_variable('myself.class')
            boss_mechanics = boss_mechanics or env:evaluate_variable('get_boss_mechanics')
            enemies = enemies or {}

            -- Fire Movement Code
            standing_in_fire = standing_in_fire or false
            fire_x = fire_x or nil
            fire_y = fire_y or nil
            fire_z = fire_z or nil

            debug_msg(false, 'Init combat variables')
            known_buffs = env:evaluate_variable('get_known_buffs')
            known_debuffs = env:evaluate_variable('get_known_debuffs')
            curses = env:evaluate_variable('get_curses')
            magics = env:evaluate_variable('get_magics')
            ignore_magic = env:evaluate_variable('get_ignore_magic')
            diseases = env:evaluate_variable('get_diseases')
            poisons = env:evaluate_variable('get_poisons')
            tremors = env:evaluate_variable('get_tremors')
            party = env:evaluate_variable('get_party')
            main_tank = env:evaluate_variable('get_tank_name')
            healer_name = env:evaluate_variable('get_healer_name')
            bad_spells = bad_spells or env:evaluate_variable('get_bad_spells')
            safe_locations = env:evaluate_variable('get_safe_locations')            
            event_frame = env:evaluate_variable('get_fire_event_frame')

            debug_msg(debug_frame_setup, '.. registering event handler ..')
            if (enable_event_frame) then
                enable_event_frame = false
                event_frame:SetScript(
                    'OnEvent',
                    function(self, event)
                        -- pass a variable number of arguments
                        self:OnEvent(event, CombatLogGetCurrentEventInfo())
                    end
                )
            end            
            -----------------------------------------------------------
            ----------------------- Event Frame -----------------------
            -----------------------------------------------------------
            debug_msg(debug_frame_setup, 'Configuring event handler ..')
            function event_frame:OnEvent(event, ...)
                local timestamp,
                    subevent,
                    _,
                    sourceGUID,
                    sourceName,
                    sourceFlags,
                    sourceRaidFlags,
                    destGUID,
                    destName,
                    destFlags,
                    destRaidFlags = ...
                local spellID, spellName, spellSchool
                local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
                if (subevent == 'SPELL_DAMAGE' --) then
                    or subevent == 'SPELL_AURA_APPLIED' or
                        subevent == 'SPELL_AURA_APPLIED_DOSE' or
                        subevent == 'SPELL_AURA_REFRESH') then
                    spellID,
                        spellName,
                        spellSchool,
                        amount,
                        overkill,
                        school,
                        resisted,
                        blocked,
                        absorbed,
                        critical,
                        glancing,
                        crushing,
                        isOffHand = select(12, ...)
                    local spell_id = tostring(spellID)
                    local spell_name = tostring(spellName)
                    if (spellID > 0) then
                        if (bad_spells[spell_id]) then
                            debug_msg(debug_movement, 'Standing in Fire!! :'..spell_name)
                            RunMacroText("/p um, looks like a :"..spell_name..", lets move!")
                            standing_in_fire = true
                            fire_x, fire_y, fire_z = wmbapi.ObjectPosition('player')
                        end
                    end
                end
            end

            debug_msg(debug or debug_frame_setup, 'finished with event handler ..')

            debug_msg(false, 'Data loaded, defining functions')

            -----------------------------------------------------------
            ------------------------ Targeting ------------------------
            -----------------------------------------------------------

            function do_boss_mechanic()
                local unit_name = UnitName('boss1') or nil
                if (unit_name ~= nil) then
                    debug_msg(false, 'Boss Found! :' .. unit_name)
                    boss_fight = true
                else
                    boss_fight = false
                end

                if (boss_fight) then
                    local action = boss_mechanics[unit_name]
                    if (action ~= nil) then
                        debug_msg(false, 'Doing boss action for :' .. unit_name)
                        action(env)
                    else
                        debug_msg(true, 'Unable to find boss actions for  :' .. unit_name)
                    end
                end
            end

            function get_npc_info()
                enemies = {}
                local prevous_found = true
                for i = 1, 20 do
                    local unit = 'nameplate' .. i
                    if (previous_found and env:evaluate_variable('unit.' .. unit)) then
                        if (UnitAffectingCombat(unit)) then
                            local unit_health = UnitHealth(unit) or 0
                            if (unit_health) then
                                local unit_name = UnitName(unit) or '<unknown>'
                                if (unit_name) then
                                    print('Encountering unit :', unit_name, ' on ', unit_health, '% hp')
                                else
                                    print('Encountering unit, unable to determine name ', unit_health, '% hp')
                                end
                            end
                        end
                    else
                        prevous_found = false
                    end
                end
            end

            function get_aoe_count(range)
                local range = range or 8
                if (UnitExists(main_tank)) then
                    -- TODO: add in range check for tank, or use self
                    local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(main_tank)
                    local x = math.floor(tank_x + 0.5)
                    local y = math.floor(tank_y + 0.5)
                    local z = math.floor(tank_z + 0.5)
                    local args = 'npcs.attackable.range_' .. range .. '.center_' .. x .. ',' .. y .. ',' .. z
                    local enemies = env:evaluate_variable(args)
                    if (enemies) then
                        return enemies
                    end
                end
                return 0
            end

            function cast_at_target_position(spell, target)
                local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(target)
                if (tank_x == nil) then
                    tank_x, tank_y, tank_z = wmbapi.ObjectPosition('player')
                end
                debug_msg(false, 'Target position :[' .. tank_x .. ',' .. tank_x .. ',' .. tank_z .. ']')
                local pos = {tank_x, tank_y, tank_z}
                local args = {['spell'] = spell, ['position'] = pos}
                env:execute_action('cast_ground', args)
            end

            function thow_more_dots(spell, debuff)
                local more_dots = false
                local min_dot_hp = 1000
                for name, hp in pairs(enemies) do
                    --   print(name, " needs a dot [" .. n .. "]")
                    if (more_dots == false and hp > min_dot_hp) then
                        local dot_duration = env:evaluate_variable('unit.target.debuff.' .. debuff)
                        if (dot_duration < 1) then
                            more_dots = true
                            n, r = UnitName(name)
                            print(name, ' needs a dot [' .. n .. ']')
                        -- RunMacroText("/cast [" .. name .. "] " .. spell)
                        end
                    end
                end
                return more_dots
            end

            function tremor()
                local _, tremor_cd, _, _ = GetSpellCooldown('Tremor Totem')
                local dispelling = false
                if (dispell_cd == 0 and tremors ~= nil) then
                    for i, player_name in ipairs(party) do
                        for id, name in pairs(tremors) do
                            if (name) then
                                local debuff_duration =
                                    env:evaluate_variable('unit.' .. player_name .. '.debuff.' .. id)
                                if (debuff_duration > 0) then
                                    RunMacroText('/s Unleashing the totem to free ' .. player_name .. ' of ' .. name)
                                    dispelling = true
                                end
                            end
                        end
                    end
                end
                if (dispelling) then
                    check_cast('Tremor Totem') -- might not need player
                end
                return dispelling
            end
            -----------------------------------------------------------
            -------------------    Spell Casting    -------------------
            -----------------------------------------------------------
            function check_cast(spell)
                --name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spellId or "spellName"[, "spellRank"])
                --start, duration, enabled, modRate = GetSpellCooldown("spellName" or spellID or slotID, "bookType")
                if (debug_spells) then
                    print('Attempting to cast :', spell)
                end
                local name, _, _, _, _, _, spellId = GetSpellInfo(spell)
                local result = false
                local message = ''
                if (debug_spells) then
                    print('Spell Id :', spellId, ' name :', name)
                end
                if (name == nil) then
                    message = "Warning, cast aborted as you don't know the spell :" .. spell
                else
                    if (debug_spells) then
                        message = 'Casting spell: ' .. spell .. ' with name: ' .. name .. ' and id: ' .. spellId
                    end
                    local _, spell_cd, enabled = GetSpellCooldown(spellId)
                    if (debug_spells) then
                        print('Spell CD :', spell_cd, ' enabled :', enabled)
                    end
                    if (enabled == 0) then
                        message = 'Warning, cast aborted as spell is already active :' .. spell
                    else
                        if (spell_cd ~= 0) then
                            message = 'Warning, cast aborted as spell is currently on cooldown :' .. spell
                        else
                            face = env:execute_action('face_target') -- posible move fix?
                            result = env:execute_action('cast', spellId) --cast_target
                            if (debug_spells) then
                                print('Facing result :', face)
                            end
                            if (debug_spells) then
                                print('Spell cast :', spellId)
                            end
                            if (result) then
                                message = 'Spell cast succesfuly: ' .. spell
                            else
                                message = 'Spell attempt failed: ' .. spell
                                if (debug_spells) then
                                    print('Spell failed :')
                                    print('Target Distance :')
                                    print('Target LoS :')
                                end
                            end
                        end
                    end
                end
                debug_msg(false, message)
                return result
            end

            function check_azerites()
                debug_msg(false, '.. checking azerites')
                local concentrated_flame = 295373
                local focused_azerite_beam = 295258
                local spells = {concentrated_flame, focused_azerite_beam}
                for _, spell in ipairs(spells) do
                    debug_msg(false, '.. checking :' .. tostring(spell))
                    if (IsSpellKnown(spell)) then
                        local name, _, _, _, _, _, spellId = GetSpellInfo(spell)
                        local _, spell_cd, enabled = GetSpellCooldown(spellId)
                        if (debug_spells) then
                            print('Spell CD :', spell_cd, ' enabled :', enabled)
                        end
                        if (enabled and spell_cd == 0) then
                            debug_msg(false, '.. using azerite')
                            result = env:execute_action('cast', spellId)
                            if (result) then
                                return true
                            end
                        end
                    end
                end
                return false
            end

            function use_trinkets()
                for i = 13, 14 do
                    local itemID = GetInventoryItemID('player', i) -- 13 for trinket1, 14 for trinket2
                    local start, duration, enable = GetItemCooldown(itemID)
                    if (enable == 1 and duration == 0) then
                        RunMacroText('/use ' .. i)
                    end
                end
            end

            function handle_new_debuffs_mpdc(magic, poison, disease, curse)
                --     -- Check for new debuffs
                debug_dispells = false
                debug_msg(false, 'In handle_new_debuffs_mpdc')
                if (UnitExists('target') == false) then
                    debug_msg(false, 'No targets, probably unable to act')
                else
                    for _, player_name in ipairs(party) do
                        debug_msg(debug_dispells, 'Checking player :' .. player_name)
                        for i = 1, 5 do
                            local name, _, _, type, duration, _, _, _, _, spellId = UnitDebuff(player_name, i)
                            if (name) then
                                debug_msg(false, 'Debuff found :' .. name)
                                local id = tonumber(spellId)
                                local debuff_present = known_debuffs[id]
                                if (type) then
                                    if (type == 'Magic' and magic) then
                                        local _, cd, _, _ = GetSpellCooldown(magic)
                                        if (cd == 0) then
                                            local ignore = false
                                            -- for id, name in pairs(ignore_magic) do
                                            --     if (spellId == id) then
                                            --         ignore = true
                                            --         print("Ignoring debuff :", name)
                                            --     end
                                            -- end
                                            if (ignore == false) then
                                                debug_msg(false, 'Using ' .. magic .. ' to dispel :' .. name)
                                                RunMacroText('/cast [target=' .. player_name .. ']' .. magic)
                                                return true
                                            end
                                        else
                                            debug_msg(false, magic .. ' is on cd, ignoring ' .. name)
                                        end
                                    elseif (type == 'Poison' and poison) then
                                        local _, cd, _, _ = GetSpellCooldown(poison)
                                        if (cd == 0) then
                                            local ignore = false
                                            if (ignore == false) then
                                                debug_msg(false, 'Using ' .. poison .. ' to dispel :' .. name)
                                                RunMacroText('/cast [target=' .. player_name .. ']' .. poison)
                                                return true
                                            end
                                        else
                                            debug_msg(false, poison .. ' is on cd, ignoring ' .. name)
                                        end
                                    elseif (type == 'Disease' and disease) then
                                        local _, cd, _, _ = GetSpellCooldown(disease)
                                        if (cd == 0) then
                                            local ignore = false
                                            if (ignore == false) then
                                                debug_msg(false, 'Using ' .. disease .. ' to dispel :' .. name)
                                                RunMacroText('/cast [target=' .. player_name .. ']' .. disease)
                                                return true
                                            end
                                        else
                                            debug_msg(false, disease .. ' is on cd, ignoring ' .. name)
                                        end
                                    elseif (type == 'Curse' and curse) then
                                        local _, cd, _, _ = GetSpellCooldown(curse)
                                        if (cd == 0) then
                                            local ignore = false
                                            if (ignore == false) then
                                                debug_msg(false, 'Using ' .. curse .. ' to dispel :' .. name)
                                                RunMacroText('/cast [target=' .. player_name .. ']' .. curse)
                                                return true
                                            end
                                        else
                                            debug_msg(false, curse .. ' is on cd, ignoring ' .. name)
                                        end
                                    end
                                    if (debuff_present == false) then
                                        RunMacroText(
                                            '/p Debuff found - Name :' ..
                                                name .. ' id :' .. spellId .. ' type: ' .. type
                                        )
                                    end
                                elseif (debuff_present == false) then
                                    RunMacroText('/p New debuff found - Name :' .. name .. ' id :' .. spellId)
                                end
                            else
                                debug_msg(debug_dispells, 'No debuffs found :(' .. i .. ' /5)')
                            end
                        end
                        debug_msg(debug_dispells, 'No debuffs found on player :' .. player_name)
                    end
                end
                debug_msg(debug_dispells, 'Done checking, returning false.')
                return false
            end

            function handle_interupts(spell)
                local _, kick_cd, _, _ = GetSpellCooldown(spell)
                debug_msg(false, '.. checking ' .. spell .. ' cd :' .. kick_cd)

                local spell_name, rank, icon, castTime, minRange, maxRange, spell_spellId = GetSpellInfo(spell)
                debug_msg(false, '.. range of' .. spell .. ' is :' .. maxRange)

                if (kick_cd == 0 and UnitExists('target')) then
                    -- local casting = UnitCastingInfo("target")
                    debug_msg(false, '.. checking target spell')

                    local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId =
                        UnitCastingInfo('target')
                    if (name and spellId and endTimeMS) then
                        debug_msg(false, '.. checking target range')
                        local distance = env:evaluate_variable('unit.target.distance')
                        debug_msg(
                            false,
                            '.. distance ' .. name .. ' target distance :' .. distance .. ' max range' .. maxRange
                        )
                        if (distance <= maxRange) then
                            if (notInterruptible == false) then
                                local end_time = endTimeMS / 1000
                                local delay = end_time - game_time
                                local _, global_cd, _, _ = GetSpellCooldown('61304')
                                -- print("t :",game_time",   e_t :", end_time ",    d :", delay)
                                -- debug_msg(true, "Interuptable spell found :" .. name .. " finishing in :" .. delay .. " (" .. endTimeMS .. " - " ..game_time .. ")")
                                if (game_time + global_cd > end_time) then
                                    check_cast(spell)
                                    if (spell and name) then
                                        debug_msg(true, '.. ' .. spell .. ' used to squish :' .. name)
                                    end
                                    return true
                                end
                            end
                        end
                    end
                end
                return false
            end

            function handle_purges(spell)
                local _, purge_cd, _, _ = GetSpellCooldown(spell)
                local unit = 'target'
                if (purge_cd == 0) then
                    for i = 1, 40 do
                        local name, _, _, _, type, _, _, _, stealable = UnitAura(unit, i) -- CANCELABLE ?
                        if (name) then
                            if (type == 'MAGIC' and spell == 'Dispel Magic') then
                                check_cast(spell)
                                return true
                            elseif (type == 'MAGIC' and spell == 'Purge') then
                                check_cast(spell)
                                return true
                            elseif (type == 'ENRAGE' and spell == 'Soothe') then
                                check_cast(spell)
                                return true
                            elseif (type == 'MAGIC' and stealable and spell == 'Spellsteal') then
                                check_cast(spell)
                                RunMacroText('/p Stealing stuffs!')
                                return true
                            end
                        end
                    end
                end
                return false
            end
            -----------------------------------------------------------------------
            ---------------------------    Positional Code    ---------------------
            -----------------------------------------------------------------------
            function check_fire()
                --205470 Flame Patch - 2120
                local move_distance = 5
                debug_msg(debug_movement, 'Checking for fire..')
                local name, _, _, _, endTimeMS, _, _, _, _ = UnitCastingInfo('player')
                if (standing_in_fire and not endTimeMS) then
                    local px, py, pz = wmbapi.ObjectPosition('player')
                    local distance = GetDistanceBetweenPositions(px, py, pz, fire_x, fire_y, fire_z)
                    debug_msg(debug_movement, 'Fire is :' .. tostring(distance) .. ' away!')
                    if (distance < move_distance) then
                        StrafeLeftStart()
                    else
                        debug_msg(debug_movement, 'Made it '.. tostring(move_distance)..' yards away. Stopping.')
                        StrafeLeftStop()
                        standing_in_fire = false
                    end
                else
                    debug_msg(debug_movement, '.. no fire or busy casting')
                end
                -- if (standing_in_fire and UnitExists('target')) then
                --     debug_msg(debug_movement, 'Moving out of Stuffs!')
                --     local px, py, pz = wmbapi.ObjectPosition('player')
                --     local tx, ty, tz = wmbapi.ObjectPosition('target')
                --     local h, v = GetAnglesBetweenPositions(px, py, pz, tx, ty, tz)
                --     debug_msg(debug_movement, 'Angle is :' .. tostring(h))
                --     local distance = 1
                --     local nx, ny, nz = GetPositionFromPosition(px, py, pz, distance, h + math.pi * 1.5) -- 5 yards to the left
                --     check_move_destination = {nx, ny, nz}
                --     standing_in_fire = false
                -- end
                -- return false
            end

            function check_move()
                -- if (check_move_destination and not endTimeMS) then
                --     local dest =
                --         check_move_destination[1] ..
                --         ',' .. check_move_destination[2] .. ',' .. check_move_destination[3]
                --     local distance = env:evaluate_variable('myself.distance.' .. dest)
                --     if (distance < 1) then
                --         check_move_destination = nil
                --     else
                --         local step_size = 0.1
                --         if (game_time - gcd_moved_time > step_size) then
                --             gcd_moved = true
                --             gcd_moved_time = game_time
                --             local x, y, z = wmbapi.ObjectPosition('player')
                --             debug_msg(debug_movement, "I'm at :[" .. x .. ' ' .. y .. ' ' .. z .. ']')
                --             -- print("I'm at :[".. x.. ' '.. y.. ' '.. z.. ']')
                --             local d_x = 0.7
                --             local d_y = 0.35
                --             local x2 = x + d_x
                --             local y2 = y + d_y
                --             -- wmbapi.MoveTo(x + d_x, y + d_y, z)
                --             local pos = {}
                --             pos[1] = x2
                --             pos[2] = y2
                --             pos[3] = z
                --             debug_msg(debug_movement, 'Moving to :[' .. x2 .. ' ' .. y2 .. ' ' .. z .. ']')
                --             env:execute_action('face_target') -- posible move fix?
                --             env:execute_action('move', check_move_destination)

                --         end
                --     end
                -- end
                return false
            end

            function move_away_from()
            end

            function move_to_next_safe_location()
                if (moving) then
                    -- print("Already moving, target is position :", safe_position)
                    -- local x = math.floor(safe_destination[1] + 0.5)
                    -- local y = math.floor(safe_destination[2] + 0.5)
                    -- local z = math.floor(safe_destination[3] + 0.5)
                    local x = safe_destination[1]
                    local y = safe_destination[2]
                    local z = safe_destination[3]
                    local dest = x .. ',' .. y .. ',' .. z

                    -- print(".. heading to :[", tostring(dest), "]")

                    local distance = env:evaluate_variable('myself.distance.' .. dest)

                    print('Already moving, distance to saftey :', tostring(distance))
                    if (distance < 5) then
                        moving = false
                        print('We made it, next safe position :', safe_position)
                    else
                        print('We should already be moving')
                        -- wmbapi.MoveTo(x,y,z)
                        env:execute_action('terminate_path')
                        env:execute_action('move', safe_destination)
                    end
                else
                    -- print(".. leaving move function.")
                    moving = true
                    print('Run away! heading to safe position:', safe_position)
                    -- get furthest?
                    safe_destination = safe_locations[safe_position]
                    local x = safe_destination[1]
                    local y = safe_destination[2]
                    local z = safe_destination[3]
                    -- wmbapi.MoveTo(x,y,z)
                    env:execute_action('terminate_path')
                    env:execute_action('move', safe_destination)
                    safe_position = safe_position + 1
                    if (safe_position > table.getn(safe_locations)) then
                        safe_position = 1
                        print('Used all the safe positions, round again!:')
                    end
                end
            end

            function check_position_and_move_during_fight(poistion, target)
                position = {185.0, 968.1, 190.8}
                if (env:evaluate_variable('myself.distance.' .. position) > 5) then
                    env:execute_action('move', position)
                end
            end

            -------------------------------------------------------------------------------------------------------------------------------------------------------------------
            -------------------------------------------------------------------       General Combat Code    ------------------------------------------------------------------
            -------------------------------------------------------------------------------------------------------------------------------------------------------------------
             _, global_cd, _, _ = GetSpellCooldown('61304')
             min_dot_hp = 10

            -- check_position_and_move_during_fight()
            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            debug_msg(false, 'Taking a look at my feet ...')

            if (moving == true) then
                print('... I appear to be standing in some fire')
                move_to_next_safe_location()
            end

            if (global_cd == 0) then
                debug_msg(false, '.. ready to act')
                gcd_moved = false

                if player_class == 'PALADIN' then
                    protection(env)
                elseif player_class == 'PRIEST' then -- and player_spec = 256 (disc)
                    discipline(env)
                elseif player_class == 'DRUID' then -- and player_spec = 102 (balance)
                    balance(env)
                elseif player_class == 'MAGE' then -- and player_spec = 63 (fire)
                    fire(env)
                elseif player_class == 'SHAMAN' then -- and player_spec = 262 (elemental)
                   elemental(env)
                end
            
            else
                if (debug) then
                    print('Nothing to do, gcd:', global_cd, ' moving out of fire :', moving)
                end
                return check_fire() or check_move()
            end
        end,
        prepare = function(env)
            ------------------------------------------------------------------------------------------------------------
            ---------------                               Preparation Setup                              ---------------
            ------------------------------------------------------------------------------------------------------------
            -- debug_msg = function(override, message)
            --     if (debug or override) then
            --         print('debug: ', tostring(message))
            --     end
            -- end
            -- debug_msg = utils["debug_msg"]

            if (false) then
                return false
            end
            started = started or get_start()
            party = env:evaluate_variable('get_party')
            in_combat = env:evaluate_variable('myself.is_in_combat')
            healer_name = env:evaluate_variable('get_healer_name')
            tank_name = env:evaluate_variable('get_tank_name')
            -- Mage food
            food_name = 'Conjured Mana Pudding'
            -- food_name = "Conjured Mana Cake"
            -- food_name = "Conjured Mana Strudel"
            -- food_name = "Conjured Mana Pie"
            food_buff = '167152' -- Replenishment
            debug = false
            debug_spells = false
            -- Support Functions - return true if there is work to do
            function release_on_wipe()
                local wipe = true
                for _, player_name in ipairs(party) do
                    local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                    if (target_hp > 0) then
                        wipe = false
                    end
                end
                if (wipe) then
                    local waypoint = 1
                    print('Releasing and resetting waypoint to :', waypoint)
                    -- env:execute_action("set_waypoint", waypoint)
                    env:execute_action('set_next_waypoint', waypoint)
                    env:execute_action('release_spirit')
                end
            end

            function check_hybrid(env, res_spell, heal_spell)
                --return does_healer_need_mana(env) or need_to_eat(env) or is_anyone_dead(env)
                return anyone_need_resing(env, res_spell) or still_resing(env, res_spell) or need_to_eat(env) or
                    check_heal(env, heal_spell) or
                    does_healer_need_mana(env)
                --or need_mage_food(env)
            end

            function check_heal(env, spell)
                local hp = 50
                local name = nil
                for _, player_name in ipairs(party) do
                    local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                    local distance = env:evaluate_variable('unit.' .. player_name .. '.distance')
                    if (target_hp > 0 and target_hp < hp and distance <= 30) then
                        hp = target_hp
                        name = player_name
                    end
                end
                if (name and spell) then
                    RunMacroText('/sit')
                    RunMacroText('/cast [target=' .. name .. ']' .. spell)
                    return true
                end
                return false
            end

            function anyone_need_resing(env, spell)
                local reviving = false
                for _, player_name in ipairs(party) do
                    local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                    local distance = env:evaluate_variable('unit.' .. player_name .. '.distance')
                    if (target_hp == 0 and reviving == false and distance <= 40) then
                        reviving = true
                        RunMacroText('/target ' .. player_name)
                        RunMacroText('/cast [target=' .. player_name .. ']' .. spell)
                        debug_msg(false, "Can't start, " .. player_name .. ' still needs resing')
                    end
                end
                return reviving
            end

            function still_resing(env, spell)
                local casting = UnitCastingInfo('player')
                local target = UnitName('target')
                local still_resing = false
                if (casting and target) then -- If we are busy casting, we might not be ready
                    local target_hp = env:evaluate_variable('unit.' .. target .. '.health')
                    if (casting == spell and target_hp ~= 0) then
                        print('Aborting uncecessary :', spell, ' on target :', target)
                        RunMacroText('/stopcasting')
                        still_resing = true
                        debug_msg(false, "Can't start, still need casting res")
                    end
                end
                return still_resing
            end

            function is_anyone_dead(env)
                local dead = false
                for _, player_name in ipairs(party) do
                    local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                    if (target_hp == 0) then
                        dead = true
                        debug_msg(false, "Can't start, " .. player_name .. ' still dead')
                    end
                end
                return dead
            end

            function anyone_need_party_buff(env, buff, spell)
                local needs_buff = false
                for _, player_name in ipairs(party) do
                    local buff_duration = env:evaluate_variable('unit.' .. player_name .. '.buff.' .. buff)
                    local distance = env:evaluate_variable('unit.' .. player_name .. '.distance')
                    local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                    if (target_hp > 0 and needs_buff == false and buff_duration == -1 and distance < 20) then
                        needs_buff = true
                        RunMacroText('/cast ' .. spell)
                        debug_msg(false, "Can't start, " .. player_name .. ' still needs buff')
                    end
                end
                return needs_buff
            end

            function anyone_need_individual_buff(env, buff, spell)
                local needs_buff = false
                for _, player_name in ipairs(party) do
                    local buff_duration = env:evaluate_variable('unit.' .. player_name .. '.buff.' .. buff)
                    local distance = env:evaluate_variable('unit.' .. player_name .. '.distance')
                    local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                    if (target_hp > 0 and needs_buff == false and buff_duration == -1 and distance < 30) then
                        needs_buff = true
                        RunMacroText('/cast [target=' .. player_name .. ']' .. spell)
                        debug_msg(false, "Can't start, " .. player_name .. ' still needs buff')
                    end
                end
                return needs_buff
            end

            function do_i_need_buffing(env, spell)
                local needs_buff = false
                local buff_duration = env:evaluate_variable('myself.buff.' .. spell)
                local _, buff_cd, _, _ = GetSpellCooldown(spell)
                if (buff_cd == 0 and buff_duration == -1) then
                    needs_buff = true
                    RunMacroText('/cast ' .. spell)
                    debug_msg(false, "Can't start, I needs a buff")
                end
                return needs_buff
            end

            function tank_needs_buff(env, spell, charges)
                local needs_buff = false
                -- local name, _, count, type, duration, _, _, _, _, spellId = UnitBuff(tank_name, 1, "PLAYER" ) --, "CANCELABLE"
                -- print("You have ".. count .. " charges of " .. name)
                local buff_duration = env:evaluate_variable('unit.' .. tank_name .. '.buff.' .. spell)
                local distance = env:evaluate_variable('unit.' .. tank_name .. '.distance')
                local target_hp = env:evaluate_variable('unit.' .. tank_name .. '.health')
                if (target_hp > 0 and buff_duration == -1 and distance < 20) then
                    needs_buff = true
                    RunMacroText('/cast [@' .. tank_name .. ']' .. spell)
                    debug_msg(false, "Can't start, tank needs a buff")
                end
                return needs_buff
            end

            function does_healer_need_mana(env)
                local needs_mana = false
                local healer_mana = UnitPower(healer_name, 0)
                local healer_max_mana = UnitPowerMax(healer_name, 0)
                local target_hp = env:evaluate_variable('unit.' .. healer_name .. '.health')
                if (target_hp > 0 and healer_max_mana > 0) then
                    local healer_mp = 100 * healer_mana / healer_max_mana
                    if (healer_mp < 80) then
                        needs_mana = true
                    -- print("Can't start, healer needs mana")
                    end
                end
                return needs_mana
            end

            function am_i_dead()
                local dead = env:evaluate_variable('myself.life') == 2
                if (dead) then
                    -- Check for mass release
                    AcceptResurrect()
                end
                return dead
            end

            function am_in_combat()
                return env:evaluate_variable('myself.is_in_combat')
            end

            function need_self_heal(env, spell)
                local hp = env:evaluate_variable('myself.health')
                local healing = false
                if (hp < 90) then
                    healing = true
                    RunMacroText('/cast [@player] ' .. spell)
                    debug_msg(false, "Can't start, I need a heal")
                end
                return healing
            end

            function need_to_eat(env)
                local hp = env:evaluate_variable('myself.health')
                local hungry = false
                local mana = UnitPower('player', 0)
                local max_mana = UnitPowerMax('player', 0)
                local mp = 100 * mana / max_mana
                local thirsty = false
                if (hp < 90) then
                    hungry = true
                    local is_drinking = env:evaluate_variable('myself.buff.' .. food_buff)
                    if (is_drinking == -1) then
                        RunMacroText('/use ' .. food_name)
                        debug_msg(false, "Can't start, need to drink")
                    end
                elseif (max_mana > 0) then
                    if (mp < 90) then
                        thirsty = true
                        local is_drinking = env:evaluate_variable('myself.buff.' .. food_buff)
                        if (is_drinking == -1) then
                            RunMacroText('/use ' .. food_name)
                            debug_msg(false, "Can't start, need to eat")
                        end
                    end
                end
                return thirsty or hungry
            end

            --TODO:
            function need_mage_food(env, food)
                -- food_name
                return false
            end
            ------------------------------------------------------------------------------------------------------------
            ---------------                                Preparation Code                              ---------------
            ------------------------------------------------------------------------------------------------------------
            release_on_wipe()
            -- Nothing to do if you are dead except accept a res
            if (am_i_dead()) then
                return true
            end

            -- Skip preparations if you are in combat
            if (am_in_combat()) then
                return false
            end
            -- ** Class Specific Preparation Code ** --
            local player_class = env:evaluate_variable('myself.class')

            if player_class == 'PRIEST' then
                -- ** PRIEST ** --
                local res_spell = 'Mass Resurrection' -- 37
                -- local res_spell = "Resurrection"
                local party_buff = '21562'
                local party_spell = 'Power Word: Fortitude'
                -- local individual_spell = "Levitate"or anyone_need_individual_buff(env, individual_buff, individual_spell)
                -- local individual_buff = "Levitate"
                local heal_spell = 'Shadow Mend'
                if (check_hybrid(env, res_spell, heal_spell) or anyone_need_party_buff(env, party_buff, party_spell)) then
                    return true
                end
            elseif player_class == 'PALADIN' then
                -- ** PALADIN ** --
                local res_spell = 'Redemption'
                local heal_spell = 'Flash Of Light'
                if (check_hybrid(env, res_spell, heal_spell)) then
                    return true
                end
            elseif player_class == 'MAGE' then
                -- ** MAGE ** --
                local party_spell = 'Arcane Intellect'
                local party_buff = '1459'
                -- local individual_spell = "Slow Fall"
                -- local individual_buff = "Slow Fall" --or anyone_need_individual_buff(env, individual_buff, individual_spell
                local self_buff = 'Blazing Barrier'
                if
                    (do_i_need_buffing(env, self_buff) or does_healer_need_mana(env) or is_anyone_dead(env) or
                        anyone_need_party_buff(env, party_buff, party_spell) or
                        need_to_eat(env))
                 then
                    return true
                end
            elseif player_class == 'DRUID' then
                -- ** DRUID ** --
                local res_spell = 'Revive'
                local heal_spell = 'Regrowth'
                if (check_hybrid(env, res_spell, heal_spell)) then
                    return true
                end
                RunMacroText('/cast [noform:4] Moonkin Form')
            elseif player_class == 'SHAMAN' then
                -- ** SHAMAN ** --
                local res_spell = 'Ancestral Spirit'
                local heal_spell = 'Healing Surge'
                local tank_buff = 'Earth Shield'
                -- local individual_spell = "Water Walking" or anyone_need_individual_buff(env, individual_buff, individual_spell)
                -- local individual_buff = "Water Walking"
                local charges = 10
                if
                    (check_heal(env, heal_spell) or check_hybrid(env, res_spell, heal_spell) or
                        tank_needs_buff(env, tank_buff, charges))
                 then
                    return true
                end
            end
            -- All done, lets go!
            return false
        end
    }
}
