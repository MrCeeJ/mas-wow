------------------------------------------------------------------------------------------------------------
---------------                               Demonology                                    ---------------
------------------------------------------------------------------------------------------------------------
function demonology(env)
    debug = true
    debug_msg(false, '.. In demonology Code')
    -- Check for priority targets
    get_priority_target()
    do_boss_mechanic()

    local target_hp = env:evaluate_variable('unit.target.health')
    local enemy_count = get_aoe_count()
    local my_hp = env:evaluate_variable('myself.health')
    local pet_hp = env:evaluate_variable('unit.pet.health')
    local soul_shards = UnitPower('player', 7)

    local corruption_duration = env:evaluate_variable('unit.target.debuff.Corruption')

    -- Health Funnel
    -- Summon Felguard (12)
    -- Call Dreadstalkers (13)
    -- Demonbolt (14)
    -- Implosion (27)
    -- Summon Demonic Tyrant (42)

    -- Subjugate Demon (21)
    -- Command Demon (29)

    -- Create Healthstone
    -- Curse of Weakness
    -- Fear
    -- Curse of Exhasution (12)
    -- Fel Domination (22)
    -- Ritual of Doom (31)
    -- Soulstone (32)
    -- Ritual of Summoning (33)
    -- Curse of Tongues (34)
    -- Demonic Circle (41)
    -- Banish (46)
    -- Create Soulwell (47)
    -- Demonic Gateway (49)





    function defensives()
        local result = false
        if (my_hp < 40) then
            result = check_cast('Unending Resolve')
        end
        if (my_hp < 25) then
            result = check_cast('Drain Life')
        end
        if (pet_hp < 50) then
            result = check_cast("Health Funnel")
        end
        return result
    end

    function start_attack()
        debug_msg(false, '. starting melee')
        RunMacroText('/petattack')
        return false
    end

    function hand_of_gul_dan()
        debug_msg(false, '. checking Hand of Guldan')
        if (soul_shards > 2) then
            debug_msg(false, '. casting Hand of Guldan')
            return check_cast('105174')
        else
            return false
        end
    end

    function shadow_bolt()
        debug_msg(false, '. checking Shadow Bolt')
        return check_cast('Shadow Bolt')
    end

    function corruption()
        if (target_hp > min_dot_hp and corruption_duration < 4) then
            debug_msg(false, '. checking Corruption')
            return check_cast('Corruption')
        end
        return false
    end

    function dps()
        return start_attack() or hand_of_gul_dan() or shadow_bolt()
    end

    return defensives() or dps()
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
