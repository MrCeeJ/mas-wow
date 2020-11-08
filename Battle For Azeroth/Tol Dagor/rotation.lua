_G.getRotations = {}

combat_rotation = function(env, _)
    debug = false
    debug_spells = false
    debug_frame = false
    debug_frame_setup = false
    in_steamvaults = false
    boss_mode = boss_mode or nil
    game_time = tonumber(GetTime())
    safe_position = safe_position or 1
    fire_timer = fire_timer or 0
    moving = moving or false
    aoe_timer_start = aoe_timer_start or nil
    player_class = player_class or env:evaluate_variable('myself.class')
    boss_mechanics = boss_mechanics or env:evaluate_variable('get_boss_mechanics')

    debug_msg = function(override, message)
        if (debug or override) then
            print('debug: ', tostring(message))
        end
    end
    debug_msg(false, 'Begining combat init')
    -- Set up static data
    known_spells = {
        ['81297'] = 'Consecration',
        ['204301'] = 'Blessed Hammer',
        ['275779'] = 'Judgment',
        ['31935'] = "Avenger's Shield",
        ['53600'] = 'Shield Of The Righteous',
        ['17501'] = 'Cannon Fire',
        ['585'] = 'Smite',
        ['589'] = 'SW :P',
        ['214621'] = 'Schism',
        ['129250'] = 'Solace',
        ['47666'] = 'Penance'
    }
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

    if (debug or debug_frame_setup) then
        print('Setting up frame ..')
    end
    event_frame = env:evaluate_variable('get_fire_event_frame')

    if (debug or debug_frame_setup) then
        print('Configuring event handler ..')
    end
    if (in_steamvaults) then
        event_frame:SetScript(
            'OnEvent',
            function(self, event)
                -- pass a variable number of arguments
                self:OnEvent(event, CombatLogGetCurrentEventInfo())
            end
        )
    end
    if (debug or debug_frame_setup) then
        print('.. registering event handler ..')
    end
    -----------------------------------------------------------
    ----------------------- Event Frame -----------------------
    -----------------------------------------------------------
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
        if (subevent == 'SPELL_DAMAGE') then --or subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_APPLIED_DOSE" or subevent == "SPELL_AURA_REFRESH") then
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
                -- print("Spell fonud :", spell_id)
                local spell_present = known_spells[spell_id]
                if (spell_present == nil) then
                    known_spells[spell_id] = spell_name
                --  RunMacroText("/p New spell found - Name :" .. spell_name .. " id :" .. spell_id)
                end
                if (bad_spells[spell_id]) then
                    if (fire_timer < GetTime()) then
                        fire_timer = GetTime() + 2 -- turn off alerts for 2 seconds
                        print('You are stading in the fire, you should probably move.')
                        standing_in_fire = true
                        -- print(".. calling move function.")
                        if (moving) then
                            print('.. hurry up!')
                        else
                            move_to_next_safe_location()
                        end
                    end
                end
            end
        end
    end

    debug_msg(debug or debug_frame_setup, 'finished with event handler ..')

    debug_spell = function(override, message)
        if (debug_spells or override) then
            print(message)
        end
    end
    debug_msg(false, 'Data loaded, defining functions')

    -----------------------------------------------------------
    ------------------------ Targeting ------------------------
    -----------------------------------------------------------
    function get_priority_target()
        -- RunMacroText("/target Head Of The Horseman")
        -- RunMacroText("/target Pumpkin Fiend")
        -- RunMacroText("/target Pulsing ")
        -- RunMacroText("/target Reanimation Totem")
        RunMacroText('/target Thumpknuckle')
    end

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
                        local debuff_duration = env:evaluate_variable('unit.' .. player_name .. '.debuff.' .. id)
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

    function dispell(spell, debuff_1, debuff_2, debuff_3)
        local _, dispell_cd, _, _ = GetSpellCooldown(spell)
        local dispelling = false
        if (dispell_cd == 0) then
            for i, player_name in ipairs(party) do
                if (debuff_1 ~= nil) then
                    for id, name in pairs(debuff_1) do
                        if (name and dispelling == false) then
                            local debuff_duration = env:evaluate_variable('unit.' .. player_name .. '.debuff.' .. id)
                            if (debuff_duration > 0) then
                                if (debug) then
                                    RunMacroText('/s Dispelling ' .. player_name .. ' of ' .. name)
                                end
                                RunMacroText('/cast [target=' .. player_name .. ']' .. spell)
                                dispelling = true
                            end
                        end
                    end
                end
                if (debuff_2 ~= nil) then
                    for id, name in pairs(debuff_2) do
                        if (name and dispelling == false) then
                            local debuff_duration = env:evaluate_variable('unit.' .. player_name .. '.debuff.' .. id)
                            if (debuff_duration > 0) then
                                if (debug) then
                                    RunMacroText('/s Dispelling ' .. player_name .. ' of ' .. name)
                                end
                                RunMacroText('/cast [target=' .. player_name .. ']' .. spell)
                                dispelling = true
                            end
                        end
                    end
                end
                if (debuff_3 ~= nil) then
                    for id, name in pairs(debuff_3) do
                        if name and (dispelling == false) then
                            local debuff_duration = env:evaluate_variable('unit.' .. player_name .. '.debuff.' .. id)
                            if (debuff_duration > 0) then
                                if (debug) then
                                    RunMacroText('/s Dispelling ' .. player_name .. ' of ' .. name)
                                end
                                RunMacroText('/cast [target=' .. player_name .. ']' .. spell)
                                dispelling = true
                            end
                        end
                    end
                end
            end
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
                                    '/p Debuff found - Name :' .. name .. ' id :' .. spellId .. ' type: ' .. type
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
                debug_msg(false, '.. distance ' .. name .. ' target distance :' .. distance .. ' max range' .. maxRange)
                if (distance <= maxRange) then
                    if (notInterruptible == false) then
                        local end_time = endTimeMS / 1000
                        local delay = end_time - game_time
                        -- print("t :",game_time",   e_t :", end_time ",    d :", delay)
                        -- debug_msg(true, "Interuptable spell found :" .. name .. " finishing in :" .. delay .. " (" .. endTimeMS .. " - " ..game_time .. ")")
                        if (game_time + 1.5 > end_time) then
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
            for i = 1, 5 do
                local name, _, _, _, type, _, _, _, stealable = UnitAura(unit, i, 'HELPFUL')
                if (name) then
                    if (type == 'MAGIC' and (spell == 'Dispel Magic' or spell == 'Purge')) then
                        check_cast(spell)
                        return true
                    elseif (type == 'ENRAGE' and spell == 'Soothe') then
                        check_cast(spell)
                        return true
                    elseif (stealable and spell == 'Spellsteal') then
                        check_cast(spell)
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
    local _, global_cd, _, _ = GetSpellCooldown('61304')
    local min_dot_hp = 10

    -- check_position_and_move_during_fight()
    -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
    debug_msg(false, 'Taking a look at my feet ...')

    if (moving == true) then
        print('... I appear to be standing in some fire')
        move_to_next_safe_location()
    end

    if (global_cd == 0) then
        debug_msg(false, '.. ready to act')
        if player_class == 'PALADIN' then -- and player_spec = 66 (prot)
            ------------------------------------------------------------------------------------------------------------
            ---------------                                     Paladin                                  ---------------
            ------------------------------------------------------------------------------------------------------------
            debug_msg(false, 'In paladin, no gcd')
            get_npc_info()
            --  eecc = env:evaluate_variable("npcs.attackable.range_8") -- temporay debugging

            -- A fix for no target spam
            RunMacroText('/cleartarget [dead][noexists]')
            get_priority_target()
            do_boss_mechanic()
            if (UnitExists('target') == false) then
                debug_msg(false, '.. no target, fixing')
                --  env:execute_action("target_nearest_enemy")
                RunMacroText('/targetenemy [nodead][exists]')
            else
                debug_msg(false, '.. Checking for dispels')
                local dispelling = handle_new_debuffs_mpdc(nil, 'Cleanse Toxins', 'Cleanse Toxins', nil)
                debug_msg(false, '..  Finished checking for dispels')
                debug_msg(false, ' .. dispell result :' .. tostring(dispelling))

                local kicking = handle_interupts('Rebuke')
                debug_msg(false, ' .. interrupt result :' .. tostring(kicking))

                if (dispelling == false and kicking == false) then
                    debug_msg(false, '.. fetching cooldowns')
                    local _, hoj_cd = GetSpellCooldown('Hammer of Justice')
                    local _, lotp_cd = GetSpellCooldown('Light Of The Protector')
                    local _, ardent_cd = GetSpellCooldown('Ardent Defender')
                    local _, hands_cd = GetSpellCooldown('Lay on Hands')
                    local _, guardian_cd = GetSpellCooldown('Guardian Of Ancient Kings')
                    local _, divine_protection_cd = GetSpellCooldown('Divine Protection')
                    local _, avenging_wrath_cd = GetSpellCooldown('Avenging Wrath')
                    local shining_light_duration = env:evaluate_variable('myself.buff.327510') -- shining light (182104 is for building stacks)

                    local life = env:evaluate_variable('myself.health')
                    local holy_power = UnitPower('player', 9)
                    -- Trinket spam
                    RunMacroText('/use 13')
                    RunMacroText('/use 14')
                    debug_msg(false, '.. checking defensives')
                    -- defensives
                    if (hands_cd == 0 and life < 10) then
                        RunMacroText('/cast [@player] Lay on Hands')
                    elseif (guardian_cd == 0 and life < 40) then
                        check_cast('Guardian Of Ancient Kings')
                    elseif (ardent_cd == 0 and life < 60) then
                        -- elseif (lotp_cd == 0 and life < 70) then
                        --     check_cast("Light Of The Protector")
                        check_cast('Ardent Defender')
                    elseif (divine_protection_cd == 0 and life < 80) then
                        check_cast('Divine Protection')
                    elseif (life < 70 and holy_power >= 3) then
                        RunMacroText('/cast [@player] Word of Glory')
                    elseif (life < 90 and shining_light_duration > 0) then
                        RunMacroText('/cast [@player] Word of Glory')
                    else
                        --    print("Attackable range 8 :", eecc, " enemy_count:", get_enemy_count()) -- temporay debugging
                        debug_msg(false, '.. loading dps cooldowns')

                        -- tank rotation
                        local _, avengers_shield_cd = GetSpellCooldown("Avenger's Shield")
                        local _, hammer_cd = GetSpellCooldown('Blessed Hammer')
                        local _, judgment_cd = GetSpellCooldown('Judgment')
                        -- local _, crusader_strike_cd = GetSpellCooldown("Crusader Strike")
                        local _, consecration_cd = GetSpellCooldown('Consecration')
                        local consecration_duration = env:evaluate_variable('myself.buff.Consecration')
                        -- local shield_charges, shield_max_harges, shield_cooldown_start, shield_cooldown_duration, _ = GetSpellCharges("Shield of the Righteous")
                        local shield_duration = env:evaluate_variable('myself.buff.132403') -- 132403 for dmg reduction effect, 53600 for spell

                        debug_msg(false, '.. performing roation')

                        -- Use shield if we have taken damage and don't have it up
                        if
                            (life < 100 and shield_duration == -1 and holy_power > 2 and
                                env:evaluate_variable('npcs.attackable.range_8') >= 1)
                         then
                            check_cast('Shield of the Righteous')
                        elseif (holy_power == 5) then
                            check_cast('Shield of the Righteous')
                        elseif (avenging_wrath_cd == 0 and boss_mode ~= 'Save_CDs') then
                            check_cast('Avenging Wrath')
                        elseif (avengers_shield_cd == 0) then
                            check_cast("Avenger's Shield")
                        elseif
                            (consecration_duration == -1 and consecration_cd == 0 and
                                env:evaluate_variable('npcs.attackable.range_8') >= 1)
                         then
                            check_cast('Consecration')
                        elseif (hammer_cd == 0) then
                            check_cast('Blessed Hammer')
                        elseif (judgment_cd == 0) then
                            check_cast('Judgment')
                        elseif (consecration_cd == 0 and env:evaluate_variable('npcs.attackable.range_8') >= 1) then
                            check_cast('Consecration')
                        elseif (hoj_cd == 0) then
                            check_cast('Hammer of Justice')
                        end
                        debug_msg(false, '.. finished paladin code')
                    end
                end
            end
        elseif player_class == 'PRIEST' then -- and player_spec = 256 (disc)
            debug_msg(false, 'Priest code')
            ------------------------------------------------------------------------------------------------------------
            -----------------------------------------------      Priest     --------------------------------------------
            ------------------------------------------------------------------------------------------------------------
            get_priority_target()
            do_boss_mechanic()
            if (UnitExists('target')) then
                debug_msg(false, '.. have target')

                local healing = false
                local _, penance_cd, _, _ = GetSpellCooldown('Penance')
                local rapture_duration = env:evaluate_variable('myself.buff.Rapture')

                -- Dispell everyone
                debug_msg(false, '.. checking dispells')
                local dispelling = handle_new_debuffs_mpdc('Purify', false, 'Purify', false)
                debug_msg(false, '.. dispelling :' .. tostring(dispelling))
                debug_msg(false, '.. checking purges')
                local purging = handle_purges('Dispel Magic')
                if (dispelling == false and purging == false) then
                    debug_msg(false, '.. not dispelling')
                    -- Check for Desperate Prayer
                    local health_check = 60
                    local my_hp = env:evaluate_variable('myself.health')
                    local _, desperate_cd, _, _ = GetSpellCooldown('Desperate Prayer')

                    if (my_hp < health_check and desperate_cd == 0) then
                        healing = true
                        RunMacroText('/cast [@player] Desperate Prayer')
                    else
                        -- Never slack on Schism or Solace
                        local _, schism_cd, _, _ = GetSpellCooldown('Schism')
                        local _, solace_cd, _, _ = GetSpellCooldown('Power Word: Solace')
                        local _, fiend_cd, _, _ = GetSpellCooldown('Shadowfiend')
                        -- Trinket spam
                        RunMacroText('/use 13')
                        RunMacroText('/use 14')
                        if (schism_cd == 0 and not moving) then
                            --cast("Schism")
                            check_cast('Schism')
                        elseif (fiend_cd == 0 and boss_mode ~= 'Save_CDs') then
                            check_cast('Shadowfiend')
                        elseif (solace_cd == 0) then
                            check_cast('Power Word: Solace')
                        end
                        debug_msg(false, 'Sorting on HP')
                        -- check HP
                        -- order_by_hp = function(player_1, player_2)
                        --     local p1_hp = env:evaluate_variable("unit." .. player_1 .. ".health")
                        --     local p2_hp = env:evaluate_variable("unit." .. player_2 .. ".health")
                        --     return p1 < p2
                        -- end
                        table.sort(
                            party,
                            function(a, b)
                                return env:evaluate_variable('unit.' .. a .. '.health') <
                                    env:evaluate_variable('unit.' .. b .. '.health')
                            end
                        )

                        debug_msg(false, 'Sorting finished')
                        debug_msg(false, '.. group healing')
                        -- If 3 or more people have taken damage and don't have Atonement cast Radiance (currently seems to double cast, same as druid empowerment)
                        local radiance_charges, _, _, radiance_cd_duration, _ = GetSpellCharges('Power Word: Radiance')
                        if (radiance_charges > 0 and radiance_cd_duration < 18 and not moving) then
                            local sinners = 0
                            for _, player_name in ipairs(party) do
                                local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                                local atonement_duration =
                                    env:evaluate_variable('unit.' .. player_name .. '.buff.atonement')
                                if (target_hp > 0 and target_hp < 90 and atonement_duration < 3) then
                                    sinners = sinners + 1
                                end
                            end
                            if (sinners > 2) then
                                healing = true
                                check_cast('Power Word: Radiance')
                            end
                        end
                        if (healing == false) then
                            -- If people have less than 40% hp, panic
                            health_check = 40
                            for _, player_name in ipairs(party) do
                                local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                                if (target_hp > 0 and target_hp < health_check) then
                                    local weakened_soul_duration =
                                        env:evaluate_variable('unit.' .. player_name .. '.debuff.6788')
                                    local _, pain_suppression_cd, _, _ = GetSpellCooldown('Pain Suppression')
                                    local _, rapture_cd, _, _ = GetSpellCooldown('Rapture')
                                    local pain_suppression_duration =
                                        env:evaluate_variable('unit.' .. player_name .. '.buff.Pain Supression')

                                    if (rapture_duration > 0 or pain_suppression_duration > 0) then
                                        -- happy days, already on it
                                    elseif (rapture_cd == 0) then
                                        healing = true
                                        check_cast('Rapture')
                                    elseif (rapture_duration == -1 and pain_suppression_cd == 0) then -- Chuck them a super shield
                                        healing = true
                                        RunMacroText('/cast [target=' .. player_name .. '] Pain Suppression')
                                    end
                                end
                            end
                        end
                        debug_msg(false, '.. over 40% healing')
                        -- If people have 40-70% hp, help them out
                        health_check = 70
                        for _, player_name in ipairs(party) do
                            if (healing == false) then
                                local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                                if (target_hp > 0 and target_hp < health_check) then
                                    local weakened_soul_duration =
                                        env:evaluate_variable('unit.' .. player_name .. '.debuff.6788')
                                    local shield_duration =
                                        env:evaluate_variable('unit.' .. player_name .. '.buff.Power Word: Shield')
                                    if
                                        (shield_duration == -1 and
                                            (weakened_soul_duration == -1 or rapture_duration > 0))
                                     then
                                        -- Chuck them a shield
                                        healing = true
                                        RunMacroText('/cast [target=' .. player_name .. '] Power Word: Shield')
                                    else
                                        if (penance_cd == 0) then
                                            -- They have had a shield, can we top them off with Penance?
                                            healing = true
                                            RunMacroText('/cast [target=' .. player_name .. '] Penance')
                                        elseif (not moving) then
                                            -- They have had a shield, and they are still below 80, give them a mend
                                            healing = true
                                            RunMacroText('/cast [target=' .. player_name .. ']Shadow Mend')
                                        end
                                    end
                                end
                            end
                        end
                        debug_msg(false, '.. over 70% healing')

                        -- If people have over 70% hp, just use Atonement
                        health_check = 100
                        for _, player_name in ipairs(party) do
                            if (healing == false) then
                                local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                                if (target_hp > 0 and target_hp < health_check) then
                                    local atonement_duration =
                                        env:evaluate_variable('unit.' .. player_name .. '.buff.Atonement')
                                    if (atonement_duration > 0) then
                                        -- Do nothing, they are have atonement
                                    else
                                        -- Chuck them a shield, they will be fine (If you have weakened soul you also have atonement, so always use a shieled)
                                        healing = true
                                        RunMacroText('/cast [target=' .. player_name .. '] Power Word: Shield')
                                    end
                                end
                            end
                        end
                        debug_msg(false, '.. priest go pewpew')
                        -- Do Damage
                        if (healing == false) then
                            local swpain_duration = env:evaluate_variable('unit.target.debuff.589') -- TODO: Check all in combat targets
                            local purge_duration = env:evaluate_variable('unit.target.debuff.204213')
                            local target_health = env:evaluate_variable('unit.target.health')
                            local _, schism_cd, _, _ = GetSpellCooldown('Schism')
                            local _, solace_cd, _, _ = GetSpellCooldown('Power Word: Solace')
                            local _, fiend_cd, _, _ = GetSpellCooldown('Shadowfiend')
                            local _, death_cd, _, _ = GetSpellCooldown('Shadow Word: Death')
                            local _, mind_blast_cd, _, _ = GetSpellCooldown('Mind Blast')
                            if (purge_duration > swpain_duration) then
                                swpain_duration = purge_duration
                            end

                            local min_swd_hp = 40

                            if (target_health > min_dot_hp and swpain_duration == -1) then
                                check_cast('Shadow Word: Pain')
                            elseif (schism_cd == 0 and not moving) then
                                check_cast('Schism')
                            elseif (fiend_cd == 0 and boss_mode ~= 'Save_CDs') then
                                check_cast('Shadowfiend')
                            elseif (solace_cd == 0) then
                                check_cast('Power Word: Solace')
                            elseif (boss_mode == 'AoE') then
                                check_cast('Holy Nova')
                            elseif (target_health < min_swd_hp and my_hp > 20 and death_cd == 0) then
                                check_cast('Shadow Word: Death')
                            elseif (mind_blast_cd == 0) then
                                check_cast('Mind Blast')
                            elseif (penance_cd == 0) then
                                check_cast('Penance')
                            elseif (not moving) then
                                check_cast('Smite')
                            end
                        end
                    end
                end
            else
                debug_msg(false, ".. don't have target")
                RunMacroText('/assist ' .. main_tank)
            end
        elseif player_class == 'DRUID' then -- and player_spec = 102 (balance)
            ------------------------------------------------------------------------------------------------------------
            ---------------                                      Druid                                   ---------------
            ------------------------------------------------------------------------------------------------------------
            debug_msg(false, '.. checking dispels')
            local dispelling = handle_new_debuffs_mpdc(false, 'Remove Corruption', false, 'Remove Corruption')
            debug_msg(false, '.. checking purges')
            local purging = handle_purges('Soothe')
            -- Check for priority targets
            get_priority_target()
            do_boss_mechanic()
            if (dispelling == false and purging == false) then
                if (UnitExists('target')) then
                    -- Check for renewal
                    local my_hp = env:evaluate_variable('myself.health')
                    local _, renewal_cd, _, _ = GetSpellCooldown('Renewal')
                    local renewal_hp = 70
                    local _, barkskin_cd, _, _ = GetSpellCooldown('Barkskin')
                    local barksin_hp = 50
                    local enemy_count = get_aoe_count()

                    local target_hp = env:evaluate_variable('unit.target.health')
                    local moonfire_duration = env:evaluate_variable('unit.target.debuff.Moonfire')
                    local sunfire_duration = env:evaluate_variable('unit.target.debuff.Sunfire')
                    local _, berserking_cd, _, _ = GetSpellCooldown('Berserking')
                    local _, alignment_cd, _, _ = GetSpellCooldown('Celestial Alignment') --39
                    local _, incarnation_cd, _, _ = GetSpellCooldown('Incarnation: Chosen of Elune')
                    local _, fury_cd, _, _ = GetSpellCooldown('Fury of Elune')
                    local _, beam_cd, _, _ = GetSpellCooldown('Solar Beam')
                    local _, rebirth_cd, _, _ = GetSpellCooldown('Rebirth')
                    local _, innervate_cd, _, _ = GetSpellCooldown('Innervate')
                    local healer_mana = UnitPower(healer_name, 0)
                    local healer_max_mana = UnitPowerMax(healer_name, 0)
                    local healer_mp = 100 * healer_mana / healer_max_mana
                    local solar_emp_duration = env:evaluate_variable('myself.buff.164545') -- solar
                    local lunar_empduration = env:evaluate_variable('myself.buff.164547') -- lunar
                    local astral_power = UnitPower('player', 8)
                    local knows_stellar_flare = GetSpellInfo('Stellar Flare')
                    local flare_duration = env:evaluate_variable('unit.target.debuff.Stellar Flare')

                    previous_eclipse = env:evaluate_variable('get_previous_eclipse')
                    local lunar_eclipse_duration = env:evaluate_variable('myself.buff.Eclipse (Lunar)')
                    local solar_eclipse_duration = env:evaluate_variable('myself.buff.Eclipse (Solar)')
                    local alignment_eclipse_duration = env:evaluate_variable('myself.buff.Celestial Alignment')
                    local eclipse_charges = env:evaluate_variable('get_eclipse_charges')
                    debug_msg(false, '.. counting enemies')
                    local enemy_count = get_aoe_count()
                    debug_msg(false, 'Enemy aoe count : ' .. enemy_count)

                    -- check combat res
                    combat_res = false
                    if (rebirth_cd == 0 and party) then
                        for _, player_name in ipairs(party) do
                            if (combat_res == false) then
                                local distance = env:evaluate_variable('unit.' .. player_name .. '.distance')
                                local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                                if (target_hp == 0 and distance < 20) then
                                    combat_res = true
                                    print('I should probably res :', player_name)
                                end
                            end
                        end
                    end
                    -- barkskin, soothe
                    combat_res = false -- something up with it
                    -- Trinket spam
                    RunMacroText('/use 13')
                    RunMacroText('/use 14')
                    --rotation
                    debug_msg(false, '.. starting moonkin pewpew')
                    if (my_hp < renewal_hp and renewal_cd == 0) then
                        check_cast('Renewal')
                    elseif (my_hp < barksin_hp and barkskin_cd == 0) then
                        check_cast('Barkskin')
                    elseif (healer_mp ~= 0 and healer_mp < 65 and innervate_cd == 0) then
                        RunMacroText('/cast [target=' .. healer_name .. '] Innervate')
                    elseif (combat_res) then
                        RunMacroText('/cast [target=' .. player_name .. '] Rebirth')
                    elseif (target_hp > min_dot_hp and sunfire_duration < 1 and eclipse_charges == 0) then
                        check_cast('Sunfire')
                    elseif (target_hp > min_dot_hp and moonfire_duration < 1 and eclipse_charges == 0) then
                        check_cast('Moonfire')
                    elseif
                        (knows_stellar_flare and target_hp > min_dot_hp and flare_duration < 1 and eclipse_charges == 0)
                     then
                        check_cast('Stellar Flare')
                    elseif (alignment_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Celestial Alignment')
                    elseif (berserking_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Berserking')
                    elseif (incarnation_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Incarnation: Chosen of Elune')
                    elseif (solar_emp_duration > 0 and eclipse_charges == 0) then
                        check_cast('Wrath')
                    elseif (lunar_empduration > 0 and eclipse_charges == 0) then
                        check_cast('Lunar Strike')
                    elseif (alignment_eclipse_duration > 0) then -- Double Eclipse
                        if (fury_cd == 0) then
                            check_cast('Fury Of Elune')
                        elseif (enemy_count < 2) then -- Count it as Lunar
                            previous_eclipse = 'Lunar'
                            if (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                                check_cast('Starsurge')
                            else
                                check_cast('Wrath')
                            end
                        else -- Count it as Solar
                            previous_eclipse = 'Solar'
                            if (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                                check_cast('Starsurge')
                            elseif (astral_power >= 50) then
                                cast_at_target_position('Starfall', main_tank)
                            else
                                check_cast('Starfire')
                            end
                        end
                    elseif (lunar_eclipse_duration > 0) then -- Lunar Eclipse
                        previous_eclipse = 'Lunar'
                        if (fury_cd == 0) then
                            check_cast('Fury Of Elune')
                        elseif (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                            check_cast('Starsurge')
                        elseif (enemy_count > 2 and astral_power >= 50) then
                            cast_at_target_position('Starfall', main_tank)
                        else
                            check_cast('Starfire')
                        end
                    elseif (solar_eclipse_duration > 0) then -- Solar Eclipse
                        previous_eclipse = 'Solar'
                        if (fury_cd == 0) then
                            check_cast('Fury Of Elune')
                        elseif (enemy_count < 3 and astral_power >= 30 and solar_eclipse_duration > 6) then
                            check_cast('Starsurge')
                        elseif (enemy_count > 2 and astral_power >= 50) then
                            cast_at_target_position('Starfall', main_tank)
                        else
                            check_cast('Wrath')
                        end
                    elseif (beam_cd == 0) then -- why not :)
                        check_cast('Solar Beam')
                    elseif (sunfire_duration < 6 and target_hp > min_dot_hp) then -- pandemic dots
                        check_cast('Sunfire')
                    elseif (moonfire_duration < 7 and target_hp > min_dot_hp) then
                        check_cast('Moonfire')
                    elseif (knows_stellar_flare and target_hp > min_dot_hp and flare_duration < 8) then
                        check_cast('Stellar Flare')
                    elseif (previous_eclipse == 'Solar') then -- Switch to Lunar
                        if (eclipse_charges < 2) then
                            eclipse_charges = eclipse_charges + 1
                            check_cast('Wrath')
                        else
                            eclipse_charges = 0
                            check_cast('Starfire')
                        end
                    elseif (previous_eclipse == 'Lunar') then -- Switch to Solar
                        if (eclipse_charges < 2) then
                            eclipse_charges = eclipse_charges + 1
                            check_cast('Starfire')
                        else
                            eclipse_charges = 0
                            check_cast('Wrath')
                        end
                    end
                    debug_msg(false, '.. done zapping things for this gcd')
                else
                    RunMacroText('/assist ' .. main_tank)
                end
            end
        elseif player_class == 'MAGE' then -- and player_spec = 63 (fire)
            ------------------------------------------------------------------------------------------------------------
            ---------------                                      Mage                                    ---------------
            ------------------------------------------------------------------------------------------------------------
            if (debug) then
                print('.. Mage Code checking curses')
            end
            local dispelling = handle_new_debuffs_mpdc(false, false, false, 'Remove Curse')
            local kicking = handle_interupts('Counterspell')
            debug_msg(false, '.. checking purges')
            local purging = handle_purges('Spellsteal')
            -- Check for priority targets
            get_priority_target()
            do_boss_mechanic()
            if (debug) then
                print('.. done with curses')
            end
            if (dispelling == false and kicking == false and purging == false) then
                if (UnitExists('target')) then
                    debug_msg(false, '.. dps rotation setup')

                    local my_hp = env:evaluate_variable('myself.health')
                    local _, invis_cd, _, _ = GetSpellCooldown('Invisibility')
                    local invis_hp = 60
                    local _, iceblock_cd, _, _ = GetSpellCooldown('Iceblock')
                    local iceblock_duration = env:evaluate_variable('myself.buff.Iceblock')
                    local iceblock_hp = 20

                    local hotstreak_duration = env:evaluate_variable('myself.buff.48108')
                    local heating_up_duration = env:evaluate_variable('myself.buff.48107')
                    local combustion_duration = env:evaluate_variable('myself.buff.Combustion')
                    local power_duration = env:evaluate_variable('myself.buff.Rune of Power')
                    debug_msg(false, '.. counting enemies')
                    local enemy_count = get_aoe_count()
                    debug_msg(false, 'Enemy aoe count : ' .. enemy_count)
                    local fireblast_charges, _, _, fireblast_cd_duration, _ = GetSpellCharges('Fire Blast')
                    local _, fireblast_cd, _, _ = GetSpellCooldown('Fire Blast')
                    local _, berserking_cd, _, _ = GetSpellCooldown('Berserking')
                    local _, combustion_cd, _, _ = GetSpellCooldown('Combustion')
                    local _, meteor_cd, _, _ = GetSpellCooldown('Meteor')

                    local _, rune_cd, _, _ = GetSpellCooldown('Rune Of Power')

                    local phoenix_charges, _, _, phoenix_cd_duration, _ = GetSpellCharges('Phoenix Flames')
                    -- Trinket spam
                    RunMacroText('/use 13')
                    RunMacroText('/use 14')

                    if (my_hp < invis_hp and invis_cd == 0) then
                        check_cast('Invisibility')
                    elseif (my_hp < iceblock_hp and iceblock_cd == 0) then
                        check_cast('Ice block')
                    elseif (berserking_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Berserking')
                    elseif (combustion_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Combustion')
                    elseif (rune_cd == 0 and power_duration == -1) then
                        check_cast('Rune of Power')
                    elseif (meteor_cd == 0) then
                        cast_at_target_position('Meteor', main_tank)
                    elseif (hotstreak_duration > 0) then
                        if (enemy_count > 2) then
                            cast_at_target_position('Flamestrike', main_tank)
                        else
                            check_cast('Pyroblast')
                        end
                    elseif (fireblast_charges > 0 and heating_up_duration > 0) then
                        check_cast('Fire Blast')
                    else
                        if (combustion_duration > 0) then
                            if (phoenix_charges > 0 and heating_up_duration > 0) then
                                check_cast('Phoenix Flames')
                            else
                                check_cast('Scorch')
                            end
                        elseif (enemy_count > 5 and ring_of_frost_cd == 0) then
                            cast_at_target_position('Ring of Frost', main_tank)
                        elseif (power_duration == 0 and phoenix_charges == 1 and phoenix_cd_duration < combustion_cd) then
                            check_cast('Phoenix Flames')
                        elseif (boss_mode == 'AoE' and phoenix_charges > 0) then
                            check_cast('Phoenix Flames')
                        elseif (boss_mode == 'AoE') then
                            cast_at_target_position('Flamestrike', main_tank)
                        else -- check 2nd phoenix
                            check_cast('Fireball')
                        end
                    end
                else
                    RunMacroText('/assist ' .. main_tank) -- perhaps an oops
                end
            end
        elseif player_class == 'SHAMAN' then -- and player_spec = 262 (elemental)
            ------------------------------------------------------------------------------------------------------------
            ---------------                                      Shaman                                   ---------------
            ------------------------------------------------------------------------------------------------------------
            -- Check for priority targets
            get_priority_target()
            do_boss_mechanic()
            local dispelling = dispell('Cleanse Spirit', curses) --or tremor()
            local dispelling = handle_new_debuffs_mpdc(false, false, false, 'Cleanse Spirit')
            local kicking = handle_interupts('Wind Shear')
            if (dispelling == false and kicking == false) then
                if (UnitExists('target')) then
                    local target_hp = env:evaluate_variable('unit.target.health')
                    local _, flame_shock_cd, _, _ = GetSpellCooldown('188389')
                    local _, earth_elemental_cd, _, _ = GetSpellCooldown('Earth Elemental')
                    local _, fire_elemental_cd, _, _ = GetSpellCooldown('Fire Elemental')
                    local _, storm_elemental_cd, _, _ = GetSpellCooldown('Storm Elemental')
                    local flame_shock_duration = env:evaluate_variable('unit.target.debuff.188389')
                    local maelstrom = UnitPower('player', 11)
                    local lb_charges, _, _, lb_cooldownDuration, _ = GetSpellCharges('Lava Burst')
                    local _, berserking_cd, _, _ = GetSpellCooldown('Berserking')
                    local _, ancestral_guidance_cd, _, _ = GetSpellCooldown('Ancestral Guidance')
                    local _, bloodlust_cd, _, _ = GetSpellCooldown('Bloodlust')
                    local _, ascendance_cd, _, _ = GetSpellCooldown('Ascendance')

                    local _, healing_stream_cd, _, _ = GetSpellCooldown('Healing Stream Totem')
                    local tank_hp = env:evaluate_variable('unit.' .. main_tank .. '.health')
                    local tank_distance = env:evaluate_variable('unit.' .. main_tank .. '.distance')

                    local lightning_shield_duration = env:evaluate_variable('myself.buff.Lightning Shield')
                    debug_msg(false, '.. counting enemies')
                    local enemy_count = get_aoe_count()
                    debug_msg(false, 'Enemy aoe count : ' .. enemy_count)
                    local my_hp = env:evaluate_variable('myself.health')
                    local _, astral_shift_cd, _, _ = GetSpellCooldown('Astral Shift')
                    local astral_shift_hp = 70

                    -- TODO:
                    -- Check for rebuffing Earth Shield
                    -- Check for defensive Tremor Totem (47)
                    -- Check for defensive Thunderstorm (49)
                    -- Check AoE Capacitor Totem ?
                    -- Check Tremor Totem (Fear, Charm, Sleep)

                    --multidot flameshock
                    -- Check Av HP for Ancestral Guidance healing
                    local total_hp = 0
                    local players = 0
                    for _, player_name in ipairs(party) do
                        local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
                        total_hp = total_hp + target_hp
                        if (target_hp > 0) then
                            players = players + 1
                        end
                    end
                    av_hp = total_hp / players
                    -- Trinket spam
                    RunMacroText('/use 13')
                    RunMacroText('/use 14')

                    if (my_hp < astral_shift_hp and astral_shift_cd == 0) then
                        check_cast('Astral Shift')
                    elseif (healing_stream_cd == 0 and av_hp < 95) then
                        check_cast('Healing Stream Totem')
                    elseif (ancestral_guidance_cd == 0 and av_hp < 80) then
                        check_cast('Ancestral Guidance')
                    elseif (lightning_shield_duration == -1) then
                        check_cast('Lightning Shield')
                    elseif (earth_elemental_cd == 0 and tank_hp < 40) then
                        check_cast('Earth Elemental')
                    elseif (storm_elemental_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Storm Elemental')
                    elseif (fire_elemental_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Fire Elemental')
                    elseif (berserking_cd == 0 and boss_mode ~= 'Save_CDs') then
                        check_cast('Berserking')
                    elseif (target_hp > min_dot_hp and flame_shock_duration < 1 and flame_shock_cd == 0) then
                        check_cast('Flame Shock')
                    elseif (ascendance_cd == 0) then
                        check_cast('Ascendance')
                    elseif (enemy_count > 2 and maelstrom >= 60 and tank_distance < 40) then
                        cast_at_target_position('Earthquake', main_tank)
                    elseif (maelstrom ~= nil and maelstrom >= 60) then
                        check_cast('Earth Shock')
                    elseif (lb_cooldownDuration == 0 or lb_charges > 0) then
                        check_cast('Lava Burst')
                    elseif (bloodlust_cd == 0) then
                        check_cast('Bloodlust') -- probably shouldn't use on CD :/
                    elseif (enemy_count > 2) then
                        check_cast('Chain Lightning')
                    else
                        check_cast('Lightning Bolt')
                    end
                else
                    RunMacroText('/assist ' .. main_tank)
                end
            end
        end
    elseif (debug) then
        print('Nothing to do, gcd:', global_cd, ' moving out of fire :', moving)
    end
end

_G.getRotations.combat_rotation = combat_rotation