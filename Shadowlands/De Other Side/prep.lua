get_start_message = function()
    if (not start) then
        print('Hi, welcome to the preparation prep!')
    end
    return true
end

function need_to_finish_casting(env)
    local casting = UnitCastingInfo('player')
    if (casting) then
        return true
    else
        return false
    end
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
            debug_msg(false, "Can't start, healer needs mana")
        end
    end
    return needs_mana
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

function need_to_eat(env)
    local hungry = false
    local hp = env:evaluate_variable('myself.health')
    if (hp < 90) then
        hungry = true
        local is_drinking = env:evaluate_variable('myself.buff.' .. food_buff)
        if (is_drinking == -1) then
            RunMacroText('/use ' .. food_name)
            debug_msg(false, "Can't start, need to drink")
        end
    end
    return hungry
end

function need_to_drink(env, min_mana)
    local thirsty = false
    local mana = UnitPower('player', 0)
    local max_mana = UnitPowerMax('player', 0)
    local min_mp = min_mana or 90
    local mp = 100 * mana / max_mana
    if (max_mana > 0) then
        if (mp < min_mp) then
            thirsty = true
            local is_drinking = env:evaluate_variable('myself.buff.' .. food_buff)
            if (is_drinking == -1) then
                RunMacroText('/use ' .. food_name)
                debug_msg(false, "Can't start, need to eat")
            end
        end
    end
    return thirsty
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
