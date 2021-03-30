------------------------------------------------------------------------------------------------------------
---------------                         Disc                                            ---------------
------------------------------------------------------------------------------------------------------------
function discipline(env, is_pulling)
    debug_rotation = true
    debug_msg(true, '.. In Disc Code')

    local my_hp = env:evaluate_variable('myself.health')
    local average_hp = my_hp

    table.sort(
        party,
        function(a, b)
            return env:evaluate_variable('unit.' .. a .. '.health') < env:evaluate_variable('unit.' .. b .. '.health')
        end
    )
    -- local spikes_duration = env:evaluate_variable('myself.buff.Demon Spikes')
    -- local infernal_strike_charges, _, _, infernal_strike_cd, _ = GetSpellCharges('Infernal Strike')
    -- local _, fel_devastation_cd, _, _ = GetSpellCooldown('Fel Devastation')

    function defensives()
        debug_msg(false, 'checking Defensives')
        local result = false
        if (my_hp < 40) then
            RunMacroText('/use Healthstone')
        end
        if (my_hp < 50) then
            RunMacroText('/use Phial Of serenity')
        end
        if (my_hp < 60) then
            result = check_cast('Fade')
        end
        if (result == false and my_hp < 95) then
            result = check_cast('Desperate Prayer00.')
        end
        return result
    end

    function barrier()
        ability = 'Barrier'
        debug_barrier = false
        debug_msg(debug_barrier, '. checking Barrier')
        local _, barrier_cd, _, _ = GetSpellCooldown('Power Word: Barrier')
        if (barrier_cd == 0 and average_hp < 40) then
            return cast_at_target_position('Power Word: Barrier', 'player')
        -- local px, py, pz = wmbapi.ObjectPosition('player')
        -- debug_msg(debug_barrier, '. my target :' .. px .. ',' .. py .. ',' .. pz)
        end
        return false
    end

    function radiance()
        local total_hp = 0
        local count = 0
        local attonements = 0
        local injured = 0
        for _, player_name in ipairs(party) do
            local target_hp = env:evaluate_variable('unit.' .. player_name .. '.health')
            local atonement_duration = env:evaluate_variable('unit.' .. player_name .. '.buff.Atonement')
            total_hp = total_hp + target_hp
            count = count + 1
            if (target_hp < 60) then
                injured = injured + 1
            elseif (target_hp < 90 and atonement_duration < 2) then
                injured = injured + 1
            end

            if (atonement_duration > 0) then
                attonements = attonements + 1
            end
        end

        if (injured > 2) then
            return check_cast('Power Word: Radiance')
        end
        if ((total_hp / count) < 70) then
            return check_cast('Power Word: Radiance')
        end

        return false
    end

    function pain_suppression()
        ability = 'Pain Suppression'
        return cast_spell_on_player_above_hp('Pain Suppression', party[1], 40)
    end

    function rapture()
        ability = 'Rapture'
        return cast_spell_on_player_above_hp('Rapture', party[1], 40)
    end

    function power_word_shield()
        debug_msg(debug_rotation, '.. checking pw:s on ' .. party[1])
        ability = 'Power Word: Sheld'
        local weakened_soul_duration = env:evaluate_variable('unit.' .. party[1] .. '.debuff.6788')
        if (weakened_soul_duration == -1) then
            return cast_spell_on_player_above_hp('Power Word: Sheld', party[1], 70)
        else
            return false
        end
    end

    function heal_penance()
        debug_msg(debug_rotation, '.. checking penance on ' .. party[1])
        return cast_spell_on_player_above_hp('Penance', party[1], 50)
    end

    function shadow_mend()
        debug_msg(debug_rotation, '.. checking shadow mend on ' .. party[1])
        ability = 'Shadow Mend'
        return cast_spell_on_player_above_hp('Shadow Mend', party[1], 70)
    end

    function shadow_word_pain()
        ability = 'Shadow Word: Pain'
        local swpain_duration = env:evaluate_variable('unit.target.debuff.589')
        local purge_duration = env:evaluate_variable('unit.target.debuff.204213')
        if (purge_duration > swpain_duration) then
            swpain_duration = purge_duration
        end
        if (swpain_duration < 2) then
            return check_cast('Shadow Word: Pain')
        end
        return false
    end

    function schism()
        ability = 'Schism'
        return check_cast('Schism')
    end

    function smite()
        ability = 'Smite'
        return check_cast('Smite')
    end

    function ascended_boon()
        ability = 'Boon of the Ascended'
        local ascended_duration = env:evaluate_variable('myself.buff.Boon of the Ascended')
        if (ascended_duration == -1) then
            return check_cast('Boon of the Ascended')
        else
            return false
        end
    end

    function ascended_blast()
        ability = 'Ascended Blast'
        local ascended_duration = env:evaluate_variable('myself.buff.Boon of the Ascended')
        if (ascended_duration > 0) then
            return check_cast('Ascended Blast') -- does it need to just be smite?
        else
            return false
        end
    end

    function ascended_explosion()
        ability = 'Ascended Nova'
        local ascended_duration = env:evaluate_variable('myself.buff.Boon of the Ascended')
        if (ascended_duration > 0) then
            return check_cast('Ascended Nova') -- does it need to just be boon?
        else
            return false
        end
    end

    function fiend()
        ability = 'Shadowfiend'
        return check_cast('Shadowfiend')
    end

    function solace()
        debug_msg(debug_rotation, '.. Solace')
        ability = 'Power Word: Solace'
        return check_cast('Power Word: Solace')
    end

    function death()
        debug_msg(debug_rotation, '.. Death')
        ability = 'Shadow Word: Death'
        local target_health = env:evaluate_variable('unit.target.health')
        if (target_health < 40 and my_hp > 20) then
            return check_cast('Shadow Word: Death')
        else
            return false
        end
    end

    function mind_blast()
        debug_msg(debug_rotation, '.. Mind Blast')
        ability = 'Mind Blast'
        return check_cast('Mind Blast')
    end

    function dps_penance()
        ability = 'Penance'
        return check_cast('Penance')
    end

    function dps()
        debug_msg(debug_rotation, '.. dps')
        if (UnitExists('target')) then
            result =
                shadow_word_pain() or schism() or ascended_boon() or ascended_blast() or fiend() or solace() or death() or
                mind_blast() or
                dps_penance() or
                smite()
        else
            result = false
            ability = ' Nothing - no target!'
        end
        debug_msg(debug_rotation and result, '. dps using :' .. tostring(ability))
        return result
    end

    function heal()
        debug_msg(debug_rotation, '.. heal')
        return heal_penance() or shadow_mend() or power_word_shield()
    end

    function group_heal()
        debug_msg(debug_rotation, '.. group heal')
        return barrier() or radiance()
    end

    function emergency_heal()
        debug_msg(debug_rotation, '.. emergency heal')
        return pain_suppression() or rapture()
    end

    return handle_purges('Dispel Magic') or defensives() or emergency_heal() or group_heal() or heal() or dps()
end

function prepare_disc(env)
    debug_msg(true, '.. In Disc prep')

    local res_spell = 'Mass Resurrection' -- 37

    local party_spell = 'Power Word: Fortitude'
    --  -- local individual_spell = "Levitate"or anyone_need_individual_buff(env, individual_buff, individual_spell)
    --  -- local individual_buff = "Levitate"
    local heal_spell = 'Shadow Mend'
    --  if
    --      (need_to_drink(env) or check_hybrid(env, res_spell, heal_spell) or
    --          anyone_need_party_buff(env, party_buff, party_spell))
    --   then
    --      return true
    --  end
    return need_to_finish_casting() or need_to_eat(env) or does_healer_need_mana(env) or is_anyone_dead(env)
end

return {
    variables = {},
    actions = {},
    rotations = {}
}
