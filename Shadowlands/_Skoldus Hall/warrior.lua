------------------------------------------------------------------------------------------------------------
---------------                                    Arms                                      ---------------
------------------------------------------------------------------------------------------------------------
function arms(env)
    debug_msg(false, '.. In arms Code')
    -- Check for priority targets
    get_priority_target()
    do_boss_mechanic()

    local target_hp = env:evaluate_variable('unit.target.health')
    local target_distance = env:evaluate_variable('unit.target.distance')
    local enemy_count = get_aoe_count()
    local my_hp = env:evaluate_variable('myself.health')
    local rage = UnitPower('player', 1)

    local _, die_by_sword_cd, _, _ = GetSpellCooldown('Die by the Sword')
    local _, charge_cd, _, _ = GetSpellCooldown('Charge')
    local _, execute_cd, _, _ = GetSpellCooldown('Execute')
    local _, victory_rush_cd, _, _ = GetSpellCooldown('Victory Rush')
    local victory_rush_duration = env:evaluate_variable('myself.buff.Victory Rush') -- Check
    local _, sweeping_strikes_cd, _, _ = GetSpellCooldown('Sweeping Strikes')
    local _, colossus_smash_cd, _, _ = GetSpellCooldown('Colossus Smash')
    local _, mortal_strike_cd, _, _ = GetSpellCooldown('Mortal Strike')
    local _, overpower_cd, _, _ = GetSpellCooldown('Overpower')
    -- Overpower (12)
    -- colossus smash (19)
    -- sweeping_strikes_cd (22)
    -- Blade Storm (38)
    -- heroic throw (24)

    -- ignore pain (17)
    -- Die by the Sword (23)

    -- heroic leap (33)
    -- intervene (43)
    -- intimidating shout(34)
    -- battle shout (39)
    -- shattering throw (41)

    -- rallying cry (46)
    -- spell reflection (47)
    -- hamstring
    -- piercing howl
    -- shield block
    -- shield slam
    -- will of the forsaken
    -- beserker rage(29)
    -- challenging shout (54)
    --taunt

    function defensives()
        local result = false
        if (my_hp < 60) then
        -- result = check_cast('Metamorphosis')
        end
        if (result == false and my_hp < 95) then
        -- result = check_cast('Demon Spikes')
        end
        return result
    end

    function start_attack()
        debug_msg(false, '. starting melee')
        RunMacroText('/startattack')
        return false
    end

    function charge()
        debug_msg(false, '. checking charge')
        if (target_distance > 8 and target_distance < 25 and charge_cd == 0) then
            debug_msg(false, '. casting charge')
            return check_cast('Charge')
        else
            return false
        end
    end

    function execute()
        debug_msg(false, '. checking Execute')
        if (execute_cd == 0 and target_hp < 20 and rage > 20) then
            return check_cast('Execute')
        else
            return false
        end
    end
    function victory_rush()
        debug_msg(false, '. checking Victory Rush')
        if (victory_rush_cd == 0 and victory_rush_duration > 0) then
            return check_cast('Victory Rush')
        else
            return false
        end
    end
    function whirlwind()
        debug_msg(false, '. checking Whirlwind')
        if (enemy_count > 2 == 0 and rage > 30) then
            return check_cast('Whirlwind')
        else
            return false
        end
    end

    function mortal_strike()
        debug_msg(false, '. checking Mortal Strike')
        if (mortal_strike_cd == 0 and rage > 30) then
            return check_cast('Mortal Strike')
        else
            return false
        end
    end
    function slam()
        debug_msg(false, '. checking Slam')
        if (rage > 20) then
            return check_cast('Slam')
        else
            return false
        end
    end

    function dps()
        return start_attack() or charge() or execute() or victory_rush() or whirlwind() or mortal_strike() or slam()
    end

    return handle_interupts('Pummel') or defensives() or dps()
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
