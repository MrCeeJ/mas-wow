------------------------------------------------------------------------------------------------------------
---------------                               Demonology                                    ---------------
------------------------------------------------------------------------------------------------------------
function demonology(env)
    debug = false
    debug_rotation = true
    pet_attacking = pet_attacking or false
    local ability = ''
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
    local explosive_potential_duration = env:evaluate_variable('myself.buff.Explosive Potential')
    have_imps = have_imps or false
    local _, dreadstalkers_cd = GetSpellCooldown('Call Dreadstalkers')
    local _, tyrant_cd = GetSpellCooldown('Summon Demonic Tyrant')
    -- local demonic_core_charges, _, _, _, _ = GetSpellCharges('Demonic Core')
    demonic_core_charges = 0
    demonic_core_duration = 9999
    debug_msg(false, '.. Checking buffs')

    function check_buffs()
        for i = 1, 40 do
            local name, _, count, _, _, exp_time, _, _, _, _ = UnitAura('player', i)
            if (name == 'Demonic Core') then -- 264173
                demonic_core_charges = count
                demonic_core_duration = exp_time - GetTime()
                return
            end
        end
    end
    check_buffs()
    debug_msg(false, '.. Loading spells')
    -- Summon Felguard (12)

    -- Implosion (27)
    -- Subjugate Demon (21)

    -- Curse of Weakness

    -- Fel Domination (22)
    -- Ritual of Doom (31)
    -- Soulstone (32)
    -- Curse of Tongues (34)

    function defensives()
        local result = false
        if (my_hp < 40) then
            result = check_cast('Unending Resolve')
            if (result) then
                ability = 'Unending Resolve'
            end
        end

        if (my_hp < 25) then
            result = check_cast('Drain Life')
            if (result) then
                ability = 'Drain Life'
            end
        end

        if (pet_hp < 50) then
            result = check_cast('Health Funnel')
            if (result) then
                ability = 'Health Funnel'
            end
        end
        return result
    end

    function start_attack()
        debug_msg(false, '. send in the pets')
        if (not pet_attacking) then
            RunMacroText('/petattack')
            pet_attacking = true
        end
        return false
    end

    -- need azerite trait
    function implosion()
        debug_msg(false, '. checking Implosion')
        local boom = false
        if (false and explosive_potential_duration == -1 and have_imps) then
            boom = check_cast('Implosion')
        end
        if (boom) then
            ability = 'Implosion'
            have_imps = false
        end
        return boom
    end

    function berserking()
        debug_msg(false, '. checking Berserking')
        local result = check_cast('Berserking')
        if (result) then
            ability = 'Berserking'
        end
        return result
    end

    function grimoire_felguard()
        debug_msg(false, '. checking Grimoire: Felguard')
        local result = check_cast('Grimoire: Felguard')
        if (result) then
            ability = 'Grimoire: Felguard'
        end
        return result
    end

    function summon_vilefiend()
        debug_msg(false, '. checking Summon Vilefiend')
        local result
        if (tyrant_cd < 13 or tyrant_cd > 45) then
            result = check_cast('Summon Vilefiend')
        end
        if (result) then
            ability = 'Summon Vilefiend'
        end
        return result
    end

    function demonic_strengh()
        debug_msg(false, '. checking Demonic Strength')
        local result = check_cast('Demonic Strength')
        if (result) then
            ability = 'Demonic Strength'
        end
        return result
    end

    function call_dreadstalkers()
        debug_msg(false, '. checking Call Dreadstalkers')
        local result = check_cast('Call Dreadstalkers')
        if (result) then
            ability = 'Call Dreadstalkers'
        end
        return result
    end

    function hand_of_gul_dan(shards)
        debug_msg(false, ". checking Hand of Gul'dan")
        local spawn_imps = false
        if (soul_shards >= shards) then
            spawn_imps = check_cast('105174')
        end
        if (spawn_imps) then
            have_imps = true
            ability = "Hand of Gul'dan"
        end
        return spawn_imps
    end

    function demonic_tyrant()
        debug_msg(false, '. checking Demonic Tyrant')
        local result
        if (dreadstalkers_cd > 8) then -- TODO: Do we need some exctra checks here?
            result = check_cast('Summon Demonic Tyrant')
        end
        if (result) then
            ability = 'Demonic Tyrant'
        end
        return result
    end

    function demonbolt()
        debug_msg(false, '. checking Demonbolt')
        local result
        if (demonic_core_charges > 1 or demonic_core_duration < 3) then
            result = check_cast('Demonbolt')
        end
        if (result) then
            ability = 'Demonbolt'
        else
            debug_msg(false, '. no core chages for Demonbolt :(')
        end
        return result
    end

    function power_siphon()
        debug_msg(false, '. checking Power Siphon')
        --TODO: What if we don't have imps, or use our last 2?
        local result = false
        if (have_imps) then
            result = check_cast('Power Siphon')
        end
        if (result) then
            ability = 'Power Siphon'
        end
        return result
    end

    function filler_demonbolt()
        debug_msg(false, '. checking filler Demonbolt')
        local result
        if (demonic_core_duration > 0 and soul_shards < 4 ) then
            result = check_cast('Demonbolt')
        end
        if (result) then
            ability = 'Demonbolt'
        else
            debug_msg(false, '. to many shards for Demonbolt :(')
        end
        return result
    end

    function shadow_bolt()
        debug_msg(false, '. checking Shadow Bolt')
        local result = check_cast('Shadow Bolt')
        if (result) then
            ability = 'Shadow Bolt'
        end
        return result
    end

    function corruption()
        if (target_hp > min_dot_hp and corruption_duration < 4) then
            debug_msg(false, '. checking Corruption')
            return check_cast('Corruption')
        end
        return false
    end
    
    function dps()
        return start_attack() or berserking() or implosion() or check_azerites() or grimoire_felguard() or
            summon_vilefiend() or
            demonic_strengh() or
            call_dreadstalkers() or
            demonic_tyrant() or
            hand_of_gul_dan(4) or
            demonbolt() or
            power_siphon() or
            hand_of_gul_dan(3) or
            filler_demonbolt() or
            shadow_bolt()
    end
    debug_msg(false, '.. Starting rotation')

    local action = handle_interupts('Axe Toss') or defensives() or dps()
    debug_msg(debug_rotation and action, ' used : ' .. tostring(ability))
    return action
end

function prepare_demonology()
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
