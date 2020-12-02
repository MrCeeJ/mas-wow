debug_msg = function(override, message)
    if (debug or override) then
        if (message == previous_message) then
            if (GetTime() - previous_message_time > 1) then
                print('debug: ', tostring(message))
                previous_message_time = GetTime()
                print_dots = true
            else
                if (print_dots) then
                    print('debug: ...')
                    print_dots = false
                end
            end
        else
            print('debug: ', tostring(message))
            previous_message = message
            previous_message_time = GetTime()
            print_dots = true
        end
    end
end

debug_spell = function(override, message)
    if (debug_spells or override) then
        print(message)
    end
end

-----------------------------------------------------------
------------------------ Targeting ------------------------
-----------------------------------------------------------

do_boss_mechanic = function()
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
            use_heroism = true -- can be overridden by the action for specific timings
            action(env)
        else
            use_heroism = true
            debug_msg(true, 'Unable to find boss actions for  :' .. unit_name)
        end
    end
end

-- Not currently used
get_npc_info = function()
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

get_aoe_count = function(range)
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

cast_at_target_position = function(spell, target)
    local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(target)
    if (tank_x == nil) then
        tank_x, tank_y, tank_z = wmbapi.ObjectPosition('target')
    end
    if (tank_x == nil) then
        tank_x, tank_y, tank_z = wmbapi.ObjectPosition('player')
    end
    debug_msg(false, 'Target position :[' .. tank_x .. ',' .. tank_x .. ',' .. tank_z .. ']')
    local pos = {tank_x, tank_y, tank_z}
    local args = {['spell'] = spell, ['position'] = pos}
    return env:execute_action('cast_ground', args)
end

-- ??
thow_more_dots = function(spell, debuff)
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

-- ??
tremor = function()
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

handle_new_debuffs_mpdc = function(magic, poison, disease, curse)
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
                    end
                end
            end
            debug_msg(debug_dispells, 'No debuffs found on player :' .. player_name)
        end
    end
    debug_msg(debug_dispells, 'Done checking, returning false.')
    return false
end

get_priority_target = function()
    -- RunMacroText("/target Head Of The Horseman")
    -- RunMacroText("/target Pumpkin Fiend")
    -- RunMacroText("/target Pulsing ")
    -- RunMacroText("/target Reanimation Totem")
    -- RunMacroText('/target Thumpknuckle')
end

-----------------------------------------------------------
------------------------   Maths   ------------------------
-----------------------------------------------------------
GetPositionFromPosition = function(X, Y, Z, dist, angle)
    return math.cos(angle) * dist + X, math.sin(angle) * dist + Y, math.sin(0) * dist + Z
end
GetAnglesBetweenPositions = function(X1, Y1, Z1, X2, Y2, Z2)
    return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2), math.atan(
        (Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))
    ) % math.pi
end
GetDistanceBetweenPositions = function(X1, Y1, Z1, X2, Y2, Z2)
    return math.sqrt(math.pow(X2 - X1, 2) + math.pow(Y2 - Y1, 2) + math.pow(Z2 - Z1, 2))
end

GetPositionInfrontOfTarget = function(dist)
    local target_x, target_y, target_z = wmbapi.ObjectPosition('target')
    local player_x, player_y, player_z = wmbapi.ObjectPosition('player')
    local distance = GetDistanceBetweenPositions(target_x, target_y, target_z, player_x, player_y, player_z)
    local ratio = tonumber(dist) / distance
end

GetPositionFromTarget = function(dist)
    local target_x, target_y, target_z = wmbapi.ObjectPosition('target')
    local player_x, player_y, player_z = wmbapi.ObjectPosition('player')
    local angle = GetAnglesBetweenPositions(target_x, target_y, target_z, player_x, player_y, player_z)
    return GetPositionFromPosition(target_x, target_y, target_z, dist, angle)
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
