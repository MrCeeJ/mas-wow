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
            -- role = UnitGroupRolesAssigned(unit);
            -- local tank_unit
            -- if (role == "TANK") then --String - TANK, HEALER, DAMAGER, NONE
            --     tank_unit = unit
            -- end

            local tank_name = 'Ceejdemon'
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
            if player_class == 'PALADIN' or player_class == 'DEMONHUNTER' then
                MoveForwardStart()
            elseif player_class == 'PRIEST' then
                RunMacroText('/dance')
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
            if player_class == 'PALADIN' or player_class == 'DEMONHUNTER' then
                MoveForwardStop()
            elseif player_class == 'PRIEST' then
                RunMacroText('/cheer')
            elseif player_class == 'DRUID' then
                MoveBackwardStop()
            elseif player_class == 'SHAMAN' then
                StrafeLeftStop()
            elseif player_class == 'MAGE' then
                StrafeRightStop()
            end
        end,
        -- Necrotic Wake
        narzudah_positions = function(env)
            debug_msg(true, 'boss positions ho!')
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' or player_class == 'DEMONHUNTER' then
                env:execute_action('move', {-3487.2, -3600.5, 6617.8})
            elseif player_class == 'PRIEST' then
                env:execute_action('move', {-3496.0, -3607.0, 6617.9})
            elseif player_class == 'DRUID' then
                env:execute_action('move', {-3491.5, -3588.4, 6617.8})
            elseif player_class == 'WARLOCK' then
                env:execute_action('move', {-3482.9, -3607.8, 6617.9})
            elseif player_class == 'MAGE' then
                env:execute_action('move', {-3475.0, -3613.9, 6617.9})
            end
        end,
        winged_companion_positions = function(env)
            local player_class = env:evaluate_variable('myself.class')
            debug_msg(true, 'my class is :' .. player_class)
            if player_class == 'PALADIN' or player_class == 'DEMONHUNTER' then
                env:execute_action('move', {-3339.1, -3416.4, 6632.8})
            elseif player_class == 'PRIEST' then
                debug_msg(true, 'moving to priest waypoint')
                env:execute_action('move', {-3332.4, -3430.9, 6632.9})
            elseif player_class == 'DRUID' then
                env:execute_action('move', {-3303.6, -3423.9, 6633.0})
            elseif player_class == 'WARLOCK' then
                env:execute_action('move', {-3302.6, -3424.5, 6633.2})
            elseif player_class == 'MAGE' then
                env:execute_action('move', {-3285.6, -3420.0, 6632.9})
            end
        end,
        pull_stitchflesh = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'PALADIN' then
                print('Pulling Lady Waycrest')
                RunMacroText('/tar Lady Waycrest')
                RunMacroText('/cast Judgment')
            elseif player_class == 'DEMONHUNTER' then
                print('Pulling Lady Waycrest')
                RunMacroText('/tar Lady Waycrest')
                RunMacroText('/cast Throw Glaive')
            end
        end,
        stichflesh_positions = function(env)
            local player_class = env:evaluate_variable('myself.class')
            debug_msg(true, 'my class is :' .. player_class)
            if player_class == 'PALADIN' or player_class == 'DEMONHUNTER' then
                env:execute_action('move', {-3202, -3386.4, 6770.2})
            else
                debug_msg(true, 'moving to team waypoint')
                env:execute_action('move', {-3190.0, -3360.1, 6770.2})
            end
        end,
        aleez_positions = function(env)
            local player_class = env:evaluate_variable('myself.class')
            debug_msg(true, 'my class is :' .. player_class)
            if player_class == 'PALADIN' or player_class == 'DEMONHUNTER' then
                env:execute_action('move', {-2211.7, 5667.8, 4179.5})
            elseif player_class == 'PRIEST' then
                debug_msg(true, 'moving to priest waypoint')
                env:execute_action('move', {-2225.1, 5678.3, 4179.9})
            elseif player_class == 'DRUID' then
                env:execute_action('move', {-2221.5, 5661.3, 4180.0})
            elseif player_class == 'WARLOCK' then
                env:execute_action('move', {-2199.5, 5661.6, 4179.9})
            elseif player_class == 'MAGE' then
                env:execute_action('move', {-2201.1, 5688.8, 4179.9})
            end
        end,
        mage_food = function(env)
            local player_class = env:evaluate_variable('myself.class')
            if player_class == 'MAGE' then
                env:execute_action('cast', 'Conjure Refreshment')
            end
        end
    },
    -- Define rotation
    rotations = {
        --------------------------------------------------------------------------------------------------------------------
        ---------------                                          Combat                                      ---------------
        --------------------------------------------------------------------------------------------------------------------
        combat = function(env, is_pulling)
            debug = false
            debug_spells = false
            debug_frame = false
            debug_frame_setup = false

            enable_event_frame = enable_event_frame or true
            boss_mode = boss_mode or nil
            game_time = tonumber(GetTime())
            gcd_moved_time = gcd_moved_time or game_time
            gcd_moved = gcd_moved or false
            check_move_destination = check_move_destination or false
            safe_position = safe_position or 1
            fire_timer = fire_timer or 0
            moving = moving or false
            strafe_end_time = strafe_end_time or nil
            aoe_timer_start = aoe_timer_start or nil
            player_class = player_class or env:evaluate_variable('myself.class')
            boss_mechanics = boss_mechanics or get_boss_mechanics()
            enemies = enemies or {}

            debug_msg(false, 'Init combat variables')
            curses = env:evaluate_variable('get_curses')
            magics = env:evaluate_variable('get_magics')
            diseases = env:evaluate_variable('get_diseases')
            poisons = env:evaluate_variable('get_poisons')
            tremors = env:evaluate_variable('get_tremors')
            party = env:evaluate_variable('get_party')
            main_tank = env:evaluate_variable('get_tank_name')
            healer_name = env:evaluate_variable('get_healer_name')
            bad_spells = bad_spells or get_bad_spells()
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
                local _,
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
                local spellID, spellName
                local playerGUID = UnitGUID('player')
                local me, _ = UnitName('player') --and destName == me

                if
                    (destGUID == playerGUID or destName == me) and
                        (subevent == 'SPELL_DAMAGE' or --) then
                            subevent == 'SPELL_AURA_APPLIED' or
                            subevent == 'SPELL_AURA_APPLIED_DOSE' or
                            subevent == 'SPELL_AURA_REFRESH')
                 then
                    spellID, spellName = select(12, ...)
                    local spell_id = tostring(spellID)
                    local spell_name = tostring(spellName)
                    if (spellID > 0) then
                        if (bad_spells[spell_id] or bad_spells[spell_name]) then
                            debug_msg(debug_movement, 'Standing in Fire!! :' .. spell_name)
                            -- print log event?
                            debug_msg(debug_movement, 'dest Name :' .. tostring(destName))
                            debug_msg(debug_movement, 'dest GUID :' .. tostring(destGUID))
                            RunMacroText('/p um, looks like a :' .. spell_name .. ', lets move!')
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

            function get_aoe_count(range)
                range = range or 8
                if (UnitExists(main_tank)) then
                    local distance = env:evaluate_variable('unit.main_tank.distance')
                    if (distance < 30) then
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

            function cast_at_target_location(spell, t_x, t_y, t_z)
                if (t_x == nil or t_y == nil or t_z == nil) then
                    t_x, t_y, t_z = wmbapi.ObjectPosition('player')
                end
                debug_msg(false, 'Target position :[' .. t_x .. ',' .. t_x .. ',' .. t_z .. ']')
                local pos = {t_x, t_y, t_z}
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
                if (tremor_cd == 0 and dispell_cd == 0 and tremors ~= nil) then
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
                -- if spell is a name this checks you know it, but not if spell is an ID
                local name, _, _, _, _, _, spellId = GetSpellInfo(spell)
                local result = false
                local message
                if (debug_spells) then
                    print('Spell Id :', spellId, ' name :', name)
                end
                if (name == nil) then
                    message = "Warning, cast aborted as you don't know the spell :" .. spell
                else
                    debug_msg(debug_spells, 'Casting spell: ' .. spell .. ', name: ' .. name .. ', id: ' .. spellId)
                    local _, spell_cd, enabled = GetSpellCooldown(spellId)
                    if (debug_spells) then
                        print('Spell CD :', spell_cd, ' enabled :', enabled)
                    end
                    if (enabled == 0) then
                        message = 'Warning, cast aborted as spell is already active :' .. spell0
                    else
                        if (spell_cd ~= 0) then
                            message = 'Warning, cast aborted as spell is currently on cooldown :' .. spell
                        else
                            face = env:execute_action('face_target')
                            result = env:execute_action('cast', spellId)
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
                            return env:execute_action('cast', spellId)
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

            function handle_interupts(spell)
                debug_interupts = true
                local _, kick_cd, _, _ = GetSpellCooldown(spell)
                debug_msg(debug_interupts, '.. checking ' .. spell .. ' cd :' .. kick_cd)

                local spell_name, rank, icon, castTime, minRange, maxRange, spell_spellId = GetSpellInfo(spell)
                debug_msg(debug_interupts, '.. range of ' .. spell .. ' is :' .. maxRange)

                if (kick_cd == 0 and UnitExists('target')) then
                    -- local casting = UnitCastingInfo("target")
                    debug_msg(faldebug_interuptsse, '.. checking target spell')

                    local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId =
                        UnitCastingInfo('target')
                    if (name and spellId and endTimeMS) then
                        debug_msg(debug_interupts, '.. checking target range')
                        local distance = env:evaluate_variable('unit.target.distance')
                        debug_msg(
                            debug_interupts,
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
                                        debug_msg(debug_interupts, '.. ' .. spell .. ' used to squish :' .. name)
                                    end
                                    return true
                                end
                            end
                        end
                    else
                        debug_msg(debug_interupts, '.. Nothing to interrupt')
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
                                return check_cast(spell)
                            elseif (type == 'MAGIC' and spell == 'Purge') then
                                return check_cast(spell)
                            elseif (type == 'MAGIC' and spell == 'Arcane Torrent') then
                                return check_cast(spell)
                            elseif (type == 'MAGIC' and spell == 'Consume Magic') then
                                return check_cast(spell)
                            elseif (type == 'ENRAGE' and spell == 'Soothe') then
                                return check_cast(spell)
                            elseif (type == 'MAGIC' and stealable and spell == 'Spellsteal') then
                                RunMacroText('/p Stealing stuffs!')
                                return check_cast(spell)
                            end
                        end
                    end
                end
                return false
            end
            -----------------------------------------------------------------------
            ---------------------------    Positional Code    ---------------------
            -----------------------------------------------------------------------
            function move_in_direction(angle, time)
                RunMacroText('/p moving in direction :' .. tostring(angle) .. ' for ' .. tostring(distance) .. ' yards')
                local time = game_time
                move_stop_time = game_time + time
            end

            function check_spread(spread)
                local min_distance = 9999
                local nearest_player = nil
                for _, player_name in ipairs(party) do
                    local distance = env:evaluate_variable('unit.' .. player_name .. '.distance')
                    if (distance < min_distance) then
                        nearest_player = player_name
                        min_distance = distance
                    end
                end
                if (min_distance < spread) then
                    -- move away from player
                    local p_x, p_y, p_z = wmbapi.ObjectPosition('player')
                    local t_x, t_y, t_z = wmbapi.ObjectPosition(nearest_player)
                    local angle = GetAnglesBetweenPositions(t_x, t_y, t_z, p_x, p_y, p_z)
                    local dist = spread - min_distance
                    local time = dist / 5
                    move_in_direction(angle, time)
                end
            end

            debug_movement = true
            debug_fire = false
            standing_in_fire = standing_in_fire or false
            fire_x = fire_x or nil
            fire_y = fire_y or nil
            fire_z = fire_z or nil
            move_distance = move_distance or 5
            move_direction = move_direction or 5

            move_fuctions =
                move_fuctions or
                {
                    [1] = function()
                        MoveForwardStart()
                    end,
                    [2] = function()
                        MoveForwardStart()
                        StrafeRightStart()
                    end,
                    [3] = function()
                        debug_msg(debug_movement, 'Starting to move right')

                        StrafeRightStart()
                    end,
                    [4] = function()
                        MoveBackwardStart()
                        StrafeRightStart()
                    end,
                    [5] = function()
                        MoveBackwardStart()
                    end,
                    [6] = function()
                        MoveBackwardStart()
                        StrafeLeftStart()
                    end,
                    [7] = function()
                        debug_msg(debug_movement, 'Starting to move left')
                        StrafeLeftStart()
                    end,
                    [8] = function()
                        MoveForwardStart()
                        StrafeLeftStart()
                    end
                }
            stop_fuctions =
                stop_fuctions or
                {
                    [1] = function()
                        MoveForwardStop()
                    end,
                    [2] = function()
                        MoveForwardStop()
                        StrafeRightStop()
                    end,
                    [3] = function()
                        StrafeRightStop()
                    end,
                    [4] = function()
                        MoveBackwardStop()
                        StrafeRightStop()
                    end,
                    [5] = function()
                        MoveBackwardStop()
                    end,
                    [6] = function()
                        MoveBackwardStop()
                        StrafeLeftStop()
                    end,
                    [7] = function()
                        StrafeLeftStop()
                    end,
                    [8] = function()
                        MoveForwardStop()
                        StrafeLeftStop()
                    end
                }

            function start_moving()
                debug_msg(debug_movement, 'Starting to move')
                move_fuctions[move_direction]()
            end

            function stop_moving()
                debug_msg(debug_movement, 'Stopping movement')
                MoveForwardStop()
                MoveBackwardStop()
                StrafeRightStop()
                StrafeLeftStop()
                -- stop_fuctions[move_direction]()
            end

            function check_fire()
                debug_msg(debug_fire, 'Checking for fire..')
                -- local _, _, _, _, endTimeMS, _, _, _, _ = UnitCastingInfo('player') -- keeps moving if triggered?
                if (standing_in_fire and not endTimeMS) then
                    debug_msg(debug_movement, 'Creating fire move action')

                    movement_action = function()
                        local px, py, pz = wmbapi.ObjectPosition('player')
                        local distance = GetDistanceBetweenPositions(px, py, pz, fire_x, fire_y, fire_z)
                        debug_msg(debug_movement, 'Fire is :' .. tostring(distance) .. ' away!')
                        if (distance < move_distance) then
                            start_moving()
                        else
                            stop_moving()
                            debug_msg(debug_movement, 'Made it ' .. tostring(move_distance) .. ' yards away. Stopping.')
                            standing_in_fire = false
                            debug_msg(debug_movement, '... removing fire move action')
                            movement_action = nil
                        end
                    end
                else
                    debug_msg(debug_fire, '.. no fire or busy casting')
                end
            end

            function check_move()
                if (movement_action) then
                    movement_action()
                    return true
                end
                return false
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
                    protection(env, is_pulling)
                elseif player_class == 'PRIEST' then -- and player_spec = 256 (disc)
                    discipline(env, is_pulling)
                elseif player_class == 'DRUID' then -- and player_spec = 102 (balance)
                    balance(env, is_pulling)
                elseif player_class == 'MAGE' then -- and player_spec = 63 (fire)
                    fire(env, is_pulling)
                elseif player_class == 'SHAMAN' then -- and player_spec = 262 (elemental)
                    elemental(env, is_pulling)
                elseif player_class == 'WARRIOR' then -- and player_spec = 71 (arms) (fury 72)
                    arms(env, is_pulling)
                elseif player_class == 'DEMONHUNTER' then -- and player_spec = 581 Veng
                    vengeance(env, is_pulling)
                elseif player_class == 'HUNTER' then -- and player_spec =
                    marksmanship(env, is_pulling)
                elseif player_class == 'MONK' then -- and player_spec =
                    mistweaver(env, is_pulling)
                elseif player_class == 'WARLOCK' then -- and player_spec = 266 Demon
                    demonology(env, is_pulling)
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
            started = started or get_start_message()
            party = env:evaluate_variable('get_party')
            in_combat = env:evaluate_variable('myself.is_in_combat')
            healer_name = env:evaluate_variable('get_healer_name')
            tank_name = env:evaluate_variable('get_tank_name')
            -- Mage food
            food_name = 'Conjured Mana Bun'
            -- food_name = 'Conjured Mana Pudding'
            -- food_name = "Conjured Mana Cake"
            -- food_name = "Conjured Mana Strudel"
            -- food_name = "Conjured Mana Pie"
            food_buff = '167152' -- Replenishment
            debug = true
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

            function need_self_heal(spell)
                local hp = env:evaluate_variable('myself.health')
                local healing = false
                if (hp < 60) then
                    healing = true
                    RunMacroText('/cast [@player] ' .. spell)
                    debug_msg(false, "Can't start, I need a heal")
                end
                return healing
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
                if (need_self_heal(heal_spell) or check_hybrid(env, res_spell, heal_spell)) then
                    return true
                end
                RunMacroText('/cast [outdoors,noform:3, nomounted] Travel Form')
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
            elseif player_class == 'DEMONHUNTER' then -- and player_spec =
                return prepare_vengeance(env)
            elseif player_class == 'WARLOCK' then -- and player_spec =
                return prepare_demonology(env)
            end
            -- All done, lets go!
            return false
        end
    }
}
