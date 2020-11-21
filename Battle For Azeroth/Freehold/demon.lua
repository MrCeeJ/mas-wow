------------------------------------------------------------------------------------------------------------
---------------                         Vengeance                                            ---------------
------------------------------------------------------------------------------------------------------------
function vengeance(env, is_pulling)
    debug_rotation = true
    debug_msg(false, '.. In Vengeance Code')

    get_priority_target()
    do_boss_mechanic()

    local my_hp = env:evaluate_variable('myself.health')
    local fury = UnitPower('player', 18)
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

    function defensives()
        debug_msg(debug_rotation, 'checking Defensives')
        local result = false
        if (my_hp < 60) then
            result = check_cast('Metamorphosis')
        end
        if (result == false and my_hp < 95 and spikes_duration == -1) then
            result = check_cast('Demon Spikes')
        end
        return result
    end

    function infernal_strike()
        debug_msg(debug_rotation, '. checking Infernal Strike')
        if (is_pulling or (infernal_strike_charges == 1 and infernal_strike_cd < 2)) then
            return cast_at_target_position('Infernal Strike', 'player')
        else
            return false
        end
    end

    function fracture()
        if (fury < 75) then
            return check_cast('Fracture')
        else
            return false
        end
    end

    function spirit_bomb()
        if (fragments > 3) then
            return check_cast('Spirit Bomb')
        else
            return false
        end
    end
    function fiery_brand()
        debug_msg(debug_rotation, '. checking Fiery Brand')
        return check_cast('Fiery Brand')
    end

    function fel_devastation()
        debug_msg(debug_rotation, '. checking Fel Devastation')
        return check_cast('Fel Devastation')
    end

    function sigil_of_flame()
        debug_msg(debug_rotation, '. checking Sigil Of Flame')
        return cast_at_target_position('Sigil Of Flame', 'target')
    end

    function immolation_aura()
        debug_msg(debug_rotation, '. checking Immolation Aura')
        if (fury < 90) then
            return check_cast('Immolation Aura')
        else
            return false
        end
    end

    function soul_cleave()
        debug_msg(debug_rotation, '. checking Soul Cleave' )
        if (fury > 50) then
            return check_cast('Soul Cleave')
        else
            return false
        end
    end

    function shear()
        debug_msg(debug_rotation, '. checking Shear')
        return check_cast('Shear')
    end

    -- Throw Glaive (19)
    -- spectral sight
    -- torment
    -- Sigil of Misery (21)
    -- Sigil of Silence (39)

    function dps()
        return check_azerites() or infernal_strike() or spirit_bomb() or fiery_brand() or fel_devastation() or
            fracture() or
            sigil_of_flame() or
            immolation_aura() or
            soul_cleave() or
            shear()

        -- 'Infernal Strike' -- Leap if about to get 2nd charge
        -- 'Fiery Brand' -- unless saved
        -- Spirit Bomb if souls > 3

        -- 'Fel Devastation' -- AoE, 50 fury
        -- Fracture if Fury <76 and souls < 4
        -- 'Shear' -- if Fury < 90  and souls < 4
        -- 'Immolation Aura' if Fury < 80 -- generated over 6 seconds, might be better to use it more i.e cap at 95

        -- 'Soul Cleave' -- -30, -2 souls -to avoid capping Fury if you are at or above 50 with no souls ou

        -- 'Sigil of Flame' -- AoE
        -- 'Throw Glaive'
    end
    --handle_interupts('Disrupt') or (29)
    return handle_purges('Consume Magic') or handle_purges('Arcane Torrent') or defensives() or dps()
end
return {
    variables = {},
    actions = {},
    rotations = {}
}
