﻿------------------------------------------------------------------------------------------------------------
---------------                         Vengeance                                            ---------------
------------------------------------------------------------------------------------------------------------
function vengeance(env, is_pulling)
    debug_rotation = true
    debug_msg(false, '.. In Vengeance Code')

    get_priority_target()
    do_boss_mechanic()

    local my_hp = env:evaluate_variable('myself.health')
    local fury = UnitPower('player', 17)
    -- local _, _, fragments, _, _, _, _ = AuraUtil.FindAuraByName('Soul Fragments', 'player')
    local spikes_duration = env:evaluate_variable('myself.buff.Demon Spikes')
    local infernal_strike_charges, _, _, infernal_strike_cd, _ = GetSpellCharges('Infernal Strike')
    local _, fel_devastation_cd, _, _ = GetSpellCooldown('Fel Devastation')

    function count_soul_fragments()
        for i = 1, 5 do
            local name, _, count = UnitBuff('player', i)
            if (name == 'Soul Fragments') then
                return count
            end
        end
        return 0
    end
    local fragments = count_soul_fragments()
    local ability = ''

    function defensives()
        debug_msg(false, 'checking Defensives')
        local result = false
        if (my_hp < 50) then
            -- local _, healthstone_cd, _, _ = GetSpellCooldown('Healthstone')
            -- if (healthstone_cd == 0) then
            --     RunMacroText('/p eating Healthstone')
            RunMacroText('/use Healthstone')
        -- end
        end
        if (my_hp < 60) then
            result = check_cast('Metamorphosis')
        end
        if (result == false and my_hp < 95 and spikes_duration == -1) then
            result = check_cast('Demon Spikes')
        end
        return result
    end

    function infernal_strike()
        ability = 'Infernal Strike'
        debug_msg(false, '. checking Infernal Strike')
        if (is_pulling or (infernal_strike_charges == 1 and infernal_strike_cd < 2)) then
            -- Get distance to target, jump to 2 yards short
            p_x, p_y, p_z = GetPositionFromTarget(0.7)
            return cast_at_target_location('Infernal Strike', px, py, pz)
        else
            return false
        end
    end

    function fracture()
        ability = 'Fracture'
        if (fury < 75) then
            return check_cast('Fracture')
        else
            return false
        end
    end

    function spirit_bomb()
        ability = 'Spirit Bomb'
        if (fragments > 3) then
            return check_cast('Spirit Bomb')
        else
            return false
        end
    end
    function fiery_brand()
        ability = 'Fiery Brand'
        debug_msg(false, '. checking Fiery Brand')
        return check_cast('Fiery Brand')
    end

    function fel_devastation()
        ability = 'Fel Devastation'
        debug_msg(false, '. checking Fel Devastation')
        return check_cast('Fel Devastation')
    end

    function elysian_decree()
        ability = 'Elysian Decree'
        debug_msg(false, '. checking Elysian Decree')
        return cast_at_target_position('Elysian Decree', 'target')
    end

    function sigil_of_flame()
        ability = 'Sigil Of Flame'
        debug_msg(false, '. checking Sigil Of Flame')
        return cast_at_target_position('Sigil Of Flame', 'target')
    end

    function sigil_of_misery()
        ability = 'Sigil Of Misery'
        debug_msg(false, '. checking Sigil Of Misery')
        return cast_at_target_position('Sigil Of Misery', 'target')
    end

    function sigil_of_silence()
        ability = 'Sigil Of Silence'
        debug_msg(false, '. checking Sigil Of Silence')
        return cast_at_target_position('Sigil Of Silence', 'target')
    end

    function immolation_aura()
        debug_msg(false, '. checking Immolation Aura')
        if (fury < 90) then
            return check_cast('Immolation Aura')
        else
            return false
        end
    end

    function soul_cleave()
        ability = 'Soul Cleave'
        debug_msg(false, '. checking Soul Cleave :' .. fury)
        if (fury > 30) then
            return check_cast('Soul Cleave')
        else
            return false
        end
    end

    function shear()
        ability = 'Shear'
        debug_msg(false, '. checking Shear')
        return check_cast('Shear')
    end

    function throw_glaive()
        ability = 'Throw Glaive'
        debug_msg(false, '. checking Throw Glaive')
        return check_cast('Throw Glaive')
    end

    -- spectral sight ?
    -- torment

    function dps()
        if (UnitExists('target')) then
            result =
                check_azerites() or infernal_strike() or spirit_bomb() or elysian_decree() or fiery_brand() or
                fel_devastation() or
                fracture() or
                immolation_aura() or
                soul_cleave() or
                sigil_of_flame() or
                sigil_of_misery() or
                sigil_of_silence() or
                shear() or
                throw_glaive()
        else
            result = false
            ability = ' Nothing - no target!'
        end
        debug_msg(debug_rotation and result, '. dps using :' .. tostring(ability))
        return result
    end

    return handle_interupts('Disrupt') or handle_cc('Imprison') or handle_purges('Consume Magic') or handle_purges('Arcane Torrent') or
        defensives() or
        dps()
end

function prepare_vengeance(env)
    return need_to_finish_casting() or does_healer_need_mana(env) or is_anyone_dead(env) or need_to_eat(env)
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
