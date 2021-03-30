------------------------------------------------------------------------------------------------------------
---------------                           Balance                                             ---------------
------------------------------------------------------------------------------------------------------------
function balance(env)
    debug_rotation = true
    debug_msg(false, '.. In Druid Code')

    get_priority_target()
    do_boss_mechanic()

    local my_hp = env:evaluate_variable('myself.health')
    local always_starfall = false

    function healthstone()
        if (my_hp < 50) then
            -- RunMacroText('/p eating Healthstone')
            RunMacroText('/use Healthstone')
        end
        return false
    end

    function barkskin()
        ability = 'Barkskin'
        if (my_hp < 40) then
            return check_cast('Barkskin')
        else
            return false
        end
    end

    function renewal()
        ability = 'Renewal'
        if (my_hp < 70) then
            return check_cast('Renewal')
        else
            return false
        end
    end

    function regrowth()
        ability = 'Regrowth'
        if (my_hp < 30) then
            return check_cast('Regrowth')
        else
            return false
        end
    end

    function defensives()
        debug_msg(fales, 'checking Defensives')
        return healthstone() or barkskin() or renewal() or regrowth()
    end

    -- Innervate
    -- Rebirth
    function cooldowns()
        use_trinkets()
        return celestial_alignment() or incarnation() or beserking() or fury() or empower_bond()
    end

    function empower_bond()
        ability = 'Empower Bond'
        return check_cast('Empower Bond')
    end

    function celestial_alignment()
        ability = 'Celestial Alignment'
        return check_cast('Celestial Alignment')
    end

    function incarnation()
        ability = 'Incarnation: Chosen of Elune'
        return check_cast('Incarnation: Chosen of Elune')
    end

    function beserking()
        ability = 'Berserking'
        return check_cast('Berserking')
    end

    function fury()
        ability = 'Fury Of Elune'
        return check_cast('Fury Of Elune')
    end

    function convoke()
        local convoke = GetSpellInfo('Convoke the Spirits')
        if (convoke) then
            return check_cast('Convoke the Spirits')
        end
    end

    function starfall()
        debug_msg(false, '. checking for Starfall')
        ability = 'Starfall'
        local starfall_duration = env:evaluate_variable('myself.buff.191034')
        if (starfall_duration < 3) then
            debug_msg(true, '. Need! Starfall')
            local enemies = get_aoe_count(8)
            if (always_starfall or enemies > 2) then
                return cast_at_target_position('Starfall', main_tank)
            end
        end
        return false
    end

    function starsurge()
        ability = 'Starsurge'
        local astral_power = UnitPower('player', 8)
        if (always_starfall and astral_power < 50) then
            return false
        else
            return check_cast('Starsurge')
        end
    end

    function wrath()
        ability = 'Wrath'
        return check_cast('Wrath')
    end

    function starfire()
        ability = 'Starfire'
        return check_cast('Starfire')
    end

    function moonfire()
        ability = 'Moonfire'
        local moonfire_duration = env:evaluate_variable('unit.target.debuff.Moonfire')
        if (moonfire_duration < 2) then
            return check_cast('Moonfire')
        end
        return false
    end

    function sunfire()
        ability = 'Sunfire'
        local sunfire_duration = env:evaluate_variable('unit.target.debuff.Sunfire')
        if (sunfire_duration < 2) then
            return check_cast('Sunfire')
        end
        return false
    end

    function lunar_eclipse()
        return starsurge() or starfire()
    end

    function solar_eclipse()
        return starsurge() or wrath()
    end

    function eclipse()
        local alignment_eclipse_duration = env:evaluate_variable('myself.buff.Celestial Alignment')
        if (alignment_eclipse_duration > 0) then
            local enemies = get_aoe_count(8)
            if (enemies > 1) then
                return lunar_eclipse()
            else
                return solar_eclipse()
            end
        else
            local lunar_eclipse_duration = env:evaluate_variable('myself.buff.Eclipse (Lunar)')
            if (lunar_eclipse_duration > 0) then
                return lunar_eclipse()
            else
                local solar_eclipse_duration = env:evaluate_variable('myself.buff.Eclipse (Solar)')
                if (solar_eclipse_duration > 0) then
                    return solar_eclipse()
                end
            end
        end
        return false
    end

    function build_eclipse()
        local wraths = GetSpellCount('Wrath')
        local starfires = GetSpellCount('Starfire')
        if (wraths > 0) then
            return wrath()
        elseif (starfires > 0) then
            return starfire()
        end
    end

    function filler()
        return build_eclipse()
    end

    function dps()
        if (UnitExists('target')) then
            result = convoke() or starfall() or sunfire() or moonfire() or eclipse() or filler()
        else
            result = false
            ability = ' Nothing - no target!'
        end
        return result
    end

    function dispell()
        return handle_new_debuffs_mpdc(false, 'Remove Corruption', false, 'Remove Corruption')
    end

    function moonkin()
        RunMacroText('/cast [noform:4] Moonkin Form')
        return false
    end

    result =
        moonfire() or moonkin() or handle_interupts('Solar Beam') or handle_purges('Soothe') or dispell() or
        defensives() or
        cooldowns() or
        dps()

    debug_msg(debug_rotation and result, 'Casting :' .. tostring(ability))
    return result
end

function check_soulbond(env)
    local spirits_duration = env:evaluate_variable('myself.buff.326967')
    local lone_duration = env:evaluate_variable('myself.buff.338041')
    local name, _, _, _, _, _, spellId = GetSpellInfo('Kindred Spirits')

    if (spirits_duration == -1 and lone_duration == -1 and name) then
        RunMacroText('/tar Ceejmoonkin')
        RunMacroText('/tar CeejDemon')
        RunMacroText('/tar CeejArcane')
        RunMacroText('/tar CeejWarlock')
        RunMacroText('/cast Kindred Spirits')
        return true
    end
    return false
end

function travel(env)
    RunMacroText('/cast [outdoors,noform:3, nomounted] Travel Form')
    return false
end

function prepare_balance(env)
    local res_spell = 'Revive'
    local heal_spell = 'Regrowth'

    return need_to_finish_casting() or need_self_heal(heal_spell) or need_to_eat(env) or need_to_drink(env, 40) or
        check_soulbond(env) or
        check_hybrid(env, res_spell, heal_spell) or
        does_healer_need_mana(env) or
        is_anyone_dead(env) or
        travel()
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
