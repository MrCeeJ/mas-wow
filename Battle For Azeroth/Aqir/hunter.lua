------------------------------------------------------------------------------------------------------------
---------------                                Marksmanship                                      ---------------
------------------------------------------------------------------------------------------------------------
function marksmanship(env)
    debug = true
    debug_msg(false, '.. In Marksmanship Code')
    -- Check for priority targets
    get_priority_target()
    do_boss_mechanic()

    local target_hp = env:evaluate_variable('unit.target.health')
    local enemy_count = get_aoe_count()
    local my_hp = env:evaluate_variable('myself.health')
    local pet_hp = env:evaluate_variable('unit.pet.health')
    local focus = UnitPower('player', 2)
    local blood_fury_cd = GetSpellCooldown('Blood Fury')
    local aimed_shot_charges, _, _, aimed_shot_cd, _ = GetSpellCharges('Aimed Shot')
    -- Bursting Shot (12)
    -- Concussive Shot (13)
    -- Arcane Shot
    -- Disengage
    -- Feign Death
    -- Freezing Trap
    -- Hunter's Mark

    function defensives()
        local result = false
        if (my_hp < 60) then
            result = check_cast('Aspect of the Turtle')
        end
        if (my_hp < 25) then
            result = check_cast('Exhilaration')
        end
        return result
    end

    function start_attack()
        debug_msg(false, '. sending in pet')
        RunMacroText('/petattack')
        return false
    end

    function blood_fury()
        debug_msg(false, '. checking Blood Fury')
        if (blood_fury_cd == 0) then
            debug_msg(false, '. casting Blood Fury')
            return check_cast('Blood Fury')
        else
            return false
        end
    end

    function aimed_shot()
        debug_msg(false, '. checking Aimed Shot')
        if (aimed_shot_charges > 0 and focus > 34) then
            debug_msg(false, '. casting Aimed Shot')
            return check_cast('Aimed Shot')
        else
            return false
        end
    end

    function arcane_shot()
        debug_msg(false, '. checking Arcane Shot')
        if (focus > 39) then
            debug_msg(false, '. casting Arcane Shot')
            return check_cast('Arcane Shot')
        else
            return false
        end
    end

    function steady_shot()
        debug_msg(false, '. casting Steady Shot')
        return check_cast('Steady Shot')
    end

    function dps()
        return start_attack() or blood_fury() or aimed_shot() or arcane_shot() or steady_shot()
    end
--handle_interupts('Counter Shot') or
    return  defensives() or dps()
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
