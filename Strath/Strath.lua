return {
    -- Define custom variables.
    variables = {
        ["get_singleton_event_frame"] = function(env)
            if (event_frame == nil) then
                print("creating frame...")
                event_frame = CreateFrame("Frame", "event_frame", UIParent)
                event_frame:RegisterEvent("UNIT_COMBAT")
                event_frame:SetScript("OnEvent", print)
            end
            return event_frame
        end,
        ["get_known_buffs"] = function(env)
            if (known_buffs == nil) then
                print("creating known buff list...")
                known_buffs = {
                    ["326419"] = "Winds of Wisdom",
                    ["21562"] = "Fortitude",
                    ["194384"] = "Attonement",
                    ["26297"] = "Power Word: Shield",
                    ["193065"] = "Masochism",
                    ["167152"] = "Replensihment"
                }
            end
            return known_buffs
        end,
        ["get_known_debuffs"] = function(env)
            if (known_debuffs == nil) then
                print("creating known debuff list...")
                known_debuffs = {
                    -- Undispellable
                    [1604] = "Dazed",
                    [13444] = "Sunder Armor",
                    [13730] = "Demoralizing Shout",
                    [6788] = "Weakened Soul",
                    [187464] = "Shadow Mend",
                    --Unavoidable
                    --Ignore
                    [9672] = "Frostbolt",
                    -- Dispellable
                    [16458] = "Ghoul Plague",
                    [16143] = "Cadaver Worms",
                    [7068] = "Vale of Shadows",
                    [16336] = "Haunting Phantoms",
                    [5137] = "Call of the Grave",
                    [16333] = "Dibilitating Touch"
                }
            end
            return known_debuffs
        end,
        ["get_curses"] = function(env)
            if (curses == nil) then
                print("creating known curse list...")
                curses = {
                    [7068] = "Vale of Shadow",
                    [16336] = "Haunting Phantoms",
                    [5137] = "Call of the Grave"
                }
            end
            return curses
        end,
        ["get_magics"] = function(env)
            if (magics == nil) then
                print("creating known magics list...")
                magics = {
                    [16333] = "Dibilitating Touch"
                }
            end
            return magics
        end,
        ["get_diseases"] = function(env)
            if (diseases == nil) then
                print("creating known diseases list...")
                diseases = {
                    [16458] = "Ghoul Plague",
                    [16143] = "Cadaver Worms"
                }
            end
            return diseases
        end,
        ["get_poisons"] = function(env)
            if (poisons == nil) then
                print("creating known poisons list...")
                poisons = {}
            end
            return poisons
        end
    },
    -- Define rotation
    rotations = {
        combat = function(env, is_pulling)
            -- Set up static data
            --event_frame = env:evaluate_variable("get_singleton_event_frame")
            known_debuffs = env:evaluate_variable("get_known_debuffs")
            known_buffs = env:evaluate_variable("get_known_buffs")
            curses = env:evaluate_variable("get_curses")
            magics = env:evaluate_variable("get_magics")
            diseases = env:evaluate_variable("get_diseases")
            poisons = env:evaluate_variable("get_poisons")

            function dispell(spell, debuff_1, debuff_2, debuff_3)
                local _, dispell_cd_duration, _, _ = GetSpellCooldown(spell)
                local party_members = GetHomePartyInfo()
                local dispelling = false
                if (party_members ~= nil and dispell_cd_duration == 0) then
                    for i, player_name in ipairs(party_members) do
                        if (debuff_1 ~= nil) then
                            for id, name in pairs(debuff_1) do
                                if (dispelling == false) then
                                    local debuff_duration = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                    if (debuff_duration > 0) then
                                        RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                        if (debuff_2 ~= nil) then
                            for id, name in pairs(debuff_2) do
                                if (dispelling == false) then
                                    local debuff_duration = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                    if (debuff_duration > 0) then
                                        RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                        if (debuff_3 ~= nil) then
                            for id, name in pairs(debuff_3) do
                                if (dispelling == false) then
                                    local debuff_duration = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                    if (debuff_duration > 0) then
                                        RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                    end
                end
                return dispelling
            end

            local _, global_cd_duration, _, _ = GetSpellCooldown("61304")
            local main_tank = "Ceejpaladin"
            local player_class = env:evaluate_variable("myself.class")
            local min_dot_hp = 10
            --env:evaluate_variable("npcs.attackable.range_10")>=2  -- more than 2 targets in 10 yards

            --get all targets
            -- if not in LoS, move to tank

            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            if (global_cd_duration == 0) then
                -- local enemies = env:evaluate_variable("npcs.all.is_attacking_me")
                -- print ("Enemies attacking :", player_class, " : ", enemies)
                -- Check for Toxic Coagulant 93617
                -- local player_coagulating = env:evaluate_variable("myself.debuff.93617") -- Toxic Coagulant
                -- if (player_coagulating > 0) then
                --     print("I should probably move")
                -- end

                -- ** PALADIN ** --
                if player_class == "PALADIN" then
                    local current_health = UnitHealth("player")
                    local max_health = UnitHealthMax("player")
                    local _, hoj_cd = GetSpellCooldown("Hammer of Justice")
                    local life = current_health / max_health
                    -- A fix for no target spam
                    RunMacroText("/cleartarget [dead][noharm]")
                    if (UnitExists("target") == false) then
                        RunMacroText("/targetenemy [noexists][noharm]")
                    end

                    -- Sort everyone out 
                    local dispelling = dispell("Cleanse Toxins", diseases, posions)
                   
                    -- defensives
                    if (hoj_cd == 0 and life < 0.4) then
                        RunMacroText("/cast Hammer of Justice")
                    else
                        -- tank rotation
                        local _, avengers_shield_cd = GetSpellCooldown("Avenger's Shield")
                        local _, hammer_of_the_rightrous_cd = GetSpellCooldown("Hammer of the Righteous")
                        local _, judgment_cd = GetSpellCooldown("Judgment")
                        local _, crusader_strike_cd = GetSpellCooldown("Crusader Strike")
                        local _, consecration_cd = GetSpellCooldown("Consecration")
                        local consecration_duration = env:evaluate_variable("myself.buff.Consecration")
                        local shield_charges, shield_max_harges, shield_cooldown_start, shield_cooldown_duration, _ = GetSpellCharges("Shield of the Righteous")
                        local shield_duration = env:evaluate_variable("myself.buff.132403") -- 132403 for dmg reduction effect

                        -- Use shield if we have taken damage and don't have it up
                        if (life < 1 and shield_duration == -1 and shield_charges > 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
                            RunMacroText("/cast Shield of the Righteous")
                        elseif (avengers_shield_cd == 0) then
                            RunMacroText("/cast Avenger's Shield")
                        elseif (consecration_duration == -1 and consecration_cd == 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
                            RunMacroText("/cast Consecration")
                        elseif (hammer_of_the_rightrous_cd == 0) then
                            RunMacroText("/cast Hammer of the Righteous")
                        elseif (judgment_cd == 0) then
                            RunMacroText("/cast Judgment")
                        elseif (crusader_strike_cd == 0) then
                            RunMacroText("/cast Crusader Strike")
                        elseif (consecration_cd == 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
                            RunMacroText("/cast Consecration")
                        elseif (hoj_cd == 0) then
                            RunMacroText("/cast Hammer of Justice")
                        end
                    end
                end
                -- ** PRIEST ** --
                if player_class == "PRIEST" then
                    local emergency_health = 50
                    local ok_health = 75
                    local good_health = 80
                    local fiend_mp = 80
                    -- Check target
                    if (UnitExists("target") == false) then
                        RunMacroText("/assist " .. main_tank)
                    end
                    -- Do Healing
                    local healing = false
                    local current_health = UnitHealth("player")
                    local max_health = UnitHealthMax("player")
                    local life = tonumber(current_health) / tonumber(max_health)
                    local hp = env:evaluate_variable("myself.health")
                    local weakened_soul_duration = env:evaluate_variable("myself.debuff.6788")

                    local start, penance_cd_duration, enabled, modRate = GetSpellCooldown("Penance")
                    local _, desperate_cd_duration, _, _ = GetSpellCooldown("Desperate Prayer")
                    local _, purify_cd_duration, _, _ = GetSpellCooldown("Purify")
                    local _, fiend_cd_duration, _, _ = GetSpellCooldown("Shadowfiend")
                    local party_members = GetHomePartyInfo()

                    -- Check for new debuffs
                    for i, player_name in ipairs(party_members) do
                        for b = 1, 5 do
                            local name, _, count, type, duration, etime, source, isStealable, _, spellId = UnitDebuff(player_name, b) --, "CANCELABLE"
                            if (name) then
                                local debuf_present = known_debuffs[spellId]
                                if (debuf_present == nil) then
                                    RunMacroText("/p New debuff found from :" .. source .. " Name :" .. name .. " id :" .. spellId .. " duration :" .. duration)
                                    known_debuffs[spellId] = name
                                end
                            end
                        end
                    end
                    -- Sort everyone out
                    dispell("Purify", magics, diseases)           

                    -- Heal yourself
                    if (hp < emergency_health and weakened_soul_duration == -1) then
                        healing = true
                        RunMacroText("/cast [@player] Power Word: Shield")
                    elseif (hp < emergency_health and desperate_cd_duration == 0) then
                        healing = true
                        RunMacroText("/cast [@player] Desperate Prayer")
                    elseif (hp < good_health) then
                        healing = true
                        RunMacroText("/cast [@player] Flash Heal") -- Note: Flash Heal also casts Shadow Mend if you are disc.
                    else
                        -- Heal the party
                        local party_members = GetHomePartyInfo()
                        if (party_members ~= nil) then
                            -- emergency healing
                            for i, player_name in ipairs(party_members) do
                                local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                -- print(i, player_name, target_hp, "Checking for healing already done? :", healing)
                                if (healing == false) then
                                    local weakened_soul_duration = env:evaluate_variable("unit." .. player_name .. ".debuff.6788")
                                    if (target_hp > 0 and target_hp < emergency_health and weakened_soul_duration == -1) then
                                        -- print(i, player_name, target_hp, "Receiving shield")
                                        healing = true
                                        RunMacroText("/cast [target=" .. player_name .. "] Power Word: Shield")
                                    elseif (target_hp > 0 and target_hp < emergency_health and penance_cd_duration == 0) then
                                        -- print(i, player_name, target_hp, "Receiving Penance")
                                        healing = true
                                        RunMacroText("/cast [target=" .. player_name .. "] Penance")
                                    elseif (target_hp > 0 and target_hp < emergency_health) then
                                        healing = true
                                        RunMacroText("/cast [target=" .. player_name .. "] Flash Heal")
                                    -- print(i, player_name, target_hp, "Receiving Flash Heal")
                                    end
                                end
                            end
                            -- top everyone else off
                            for i, player_name in ipairs(party_members) do
                                local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                -- print(i, player_name, target_hp, "Checking for healing already done? :", healing)
                                if (healing == false) then
                                    local weakened_soul_duration = env:evaluate_variable("unit." .. player_name .. ".debuff.6788")
                                    if (target_hp > 0 and target_hp < good_health and penance_cd_duration == 0) then
                                        -- print(i, player_name, target_hp, "Receiving Penance")
                                        healing = true
                                        RunMacroText("/cast [target=" .. player_name .. "] Penance")
                                    elseif (target_hp > 0 and target_hp < good_health and weakened_soul_duration == -1 and player_name == main_tank) then
                                        -- print(i, player_name, target_hp, "Receiving shield")
                                        healing = true
                                        RunMacroText("/cast [target=" .. player_name .. "] Power Word: Shield")
                                    elseif (target_hp > 0 and target_hp < ok_health) then
                                        healing = true
                                        RunMacroText("/cast [target=" .. player_name .. "] Flash Heal")
                                    -- print(i, player_name, target_hp, "Receiving Flash Heal")
                                    end
                                end
                            end
                        end
                    end
                    -- Do Damage
                    if (healing == false) then
                        if (UnitExists("target")) then -- check LOS and Move?
                            local swpain_duration = env:evaluate_variable("unit.target.debuff.589") -- TODO: Check all in combat targets
                            local target_health = env:evaluate_variable("unit.target.health")
                            local _, schism_cd_duration, _, _ = GetSpellCooldown("Schism")
                            local _, solace_cd_duration, _, _ = GetSpellCooldown("Power Word: Solace")
                            local mana = UnitPower("player", 0)
                            local max_mana = UnitPowerMax("player", 0)
                            local mp = 100 * mana / max_mana

                            if (target_health > min_dot_hp and swpain_duration == -1) then
                                RunMacroText("/cast Shadow Word: Pain")
                            elseif (fiend_cd_duration == 0 and mp < fiend_mp) then
                                RunMacroText("/cast Shadowfiend")
                            elseif (schism_cd_duration == 0) then
                                RunMacroText("/cast Schism")
                            elseif (solace_cd_duration == 0) then
                                RunMacroText("/cast Power Word: Solace")
                            elseif (penance_cd_duration == 0) then
                                RunMacroText("/cast Penance") -- ID 47540
                            else
                                RunMacroText("/cast Smite")
                            end
                        else
                            RunMacroText("/assist " .. main_tank)
                        end
                    end
                end
                -- ** DRUID ** --
                if player_class == "DRUID" then
                    local lunar_power = UnitPower("player", 8)

                    -- -- Sort everyone out 
                    local dispelling = dispell("Remove Corruption", curses, poisons)
                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local target_hp = env:evaluate_variable("unit.target.health")
                            local moonfire_duration = env:evaluate_variable("unit.target.debuff.Moonfire")
                            local knows_sunfire = IsSpellKnown(93402, false) --  not 164815
                            local sunfire_duration = env:evaluate_variable("unit.target.debuff.164815")
                            local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                            local solar_emp_duration = env:evaluate_variable("myself.buff.164545") -- solar
                            local lunar_empduration = env:evaluate_variable("myself.buff.164547") -- lunar

                            if (berserking_cd_duration == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (target_hp > min_dot_hp and moonfire_duration == -1) then
                                RunMacroText("/cast Moonfire")
                            elseif (knows_sunfire == true and target_hp > min_dot_hp and sunfire_duration == -1) then
                                RunMacroText("/cast Sunfire")
                            elseif (solar_emp_duration ~= -1) then -- will recast as buff isn't removed until spell lands
                                RunMacroText("/cast Solar Wrath")
                            elseif (lunar_power >= 40) then
                                RunMacroText("/cast Starsurge")
                            elseif (lunar_empduration ~= -1) then -- will recast as buff isn't removed until spell lands
                                RunMacroText("/cast Lunar Strike")
                            else
                                RunMacroText("/cast Solar Wrath")
                            end
                        else
                            RunMacroText("/assist " .. main_tank)
                        end
                    end
                end
                -- ** MAGE ** --
                if player_class == "MAGE" then
                    -- Sort everyone out
                    local dispelling = dispell("Remove Curse", curses)
                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local hotstreak_duration = env:evaluate_variable("myself.buff.48108")
                            local heating_up_duration = env:evaluate_variable("myself.buff.48107")
                            local combustion_duration = env:evaluate_variable("myself.buff.Combustion")

                            local _, fireblast_cd_duration, _, _ = GetSpellCooldown("Fire Blast")
                            local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                            local _, combustion_cd_duration, _, _ = GetSpellCooldown("Combustion")

                            if (berserking_cd_duration == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (combustion_cd_duration == 0) then
                                RunMacroText("/cast Combustion")
                            elseif (hotstreak_duration > 0) then
                                RunMacroText("/cast Pyroblast")
                            elseif (fireblast_cd_duration == 0 and heating_up_duration > 0) then
                                RunMacroText("/cast Fire Blast")
                            else
                                if (combustion_duration > 0) then
                                    RunMacroText("/cast Scorch")
                                else
                                    RunMacroText("/cast Fireball")
                                end
                            end
                        else
                            RunMacroText("/assist " .. main_tank)
                        end
                    end
                end
                -- ** SHAMAN ** --
                if player_class == "SHAMAN" then
                    -- Sort everyone out
                    local dispelling = dispell("Cleanse Spirit", curses)
                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local target_hp = env:evaluate_variable("unit.target.health")
                            local _, flame_shock_cd_duration, _, _ = GetSpellCooldown("188389")
                            local flame_shock_duration = env:evaluate_variable("unit.target.debuff.188389")
                            local maelstrom = UnitPower("player", 11)
                            local lb_charges, _, _, lb_cooldownDuration, _ = GetSpellCharges("Lava Burst")
                            local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                            if (berserking_cd_duration == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (target_hp > min_dot_hp and flame_shock_duration == -1 and flame_shock_cd_duration == 0) then
                                RunMacroText("/cast Flame Shock")
                            elseif (maelstrom ~= nil and maelstrom >= 90) then
                                RunMacroText("/cast Earth Shock")
                            elseif (lb_charges > 0) then --"Lava Burst" not 51505
                                RunMacroText("/cast Lava Burst")
                            else
                                RunMacroText("/cast Lightning Bolt")
                            end
                        else
                            RunMacroText("/assist " .. main_tank)
                        end
                    end
                end
            end
        end,
        prepare = function(env)
            res_party = function(env, spell)
                local party_members = GetHomePartyInfo()
                local reviving = false
                for i, player_name in ipairs(party_members) do
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    if (target_hp == 0 and reviving == false) then
                        reviving = true
                        needs_more_time = true
                        RunMacroText("/target " .. player_name)
                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                    end
                end
                return reviving
            end

            local in_combat = env:evaluate_variable("myself.is_in_combat") -- UnitAffectingCombat("player")
            local needs_more_time = false
            local healer_name = "Ceejpriest"
            local tank_name = "Ceejpaladin"

            if (env:evaluate_variable("myself.life") == 2) then
                -- print("I seem to be dead")
                AcceptResurrect()
            end

            if (in_combat) then
                needs_more_time = false -- If we are in combat, no need to worry about preparations
            else
                local spell = UnitCastingInfo("player")
                if (spell ~= null) then -- If we are busy casting, we are clearly not ready
                    local target = UnitName("target")
                    local target_hp = env:evaluate_variable("unit." .. target .. ".health")
                    if (spell == "Resurrection" and target_hp ~= 0) then
                        print("Aborting uncecessary :", spell, " on target :", target)
                        RunMacroText("/stopcasting")
                    else
                        return true
                    end
                end

                local healer_mana = UnitPower(healer_name, 0)
                local healer_max_mana = UnitPowerMax(healer_name, 0)
                local healer_mp = 100 * healer_mana / healer_max_mana
                if (healer_mp < 90) then
                    needs_more_time = true
                end
                local player_class = env:evaluate_variable("myself.class")
                if player_class == "PRIEST" then
                    -- ** PRIEST ** --
                    local mana = UnitPower("player", 0)
                    local max_mana = UnitPowerMax("player", 0)
                    local mp = 100 * mana / max_mana
                    local fortitude_duration = env:evaluate_variable("myself.buff.21562")

                    if (mp < 90) then
                        -- print("Priest needs more mana :", mp, "is drinking :", is_drinking)
                        needs_more_time = true
                        -- Drink
                        local is_drinking = env:evaluate_variable("myself.buff.167152") -- Replenishmet
                        if (is_drinking == -1) then
                            RunMacroText("/use Conjured Mana Pie") -- warn if no food found?
                        end
                    else
                        needs_more_time = res_party(env, "Resurrection")
                        if (reviving == false and fortitude_duration == -1) then
                            needs_more_time = true
                            RunMacroText("/cast Power Word: Fortitude")
                        end
                    end
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Flash Heal")
                    end
                elseif player_class == "PALADIN" then
                    -- ** PALADIN ** --
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Flash Of Light")
                    end
                elseif player_class == "MAGE" then
                    -- ** MAGE ** --
                    -- RunMacroText("/cast [nopet][@pet, dead] Summon Water Elemental")
                    local barrier_duration = env:evaluate_variable("myself.buff.235313")
                    local _, barrier_cd_duration, _, _ = GetSpellCooldown("Blazing Barrier")
                    if (barrier_cd_duration == 0 and barrier_duration == -1) then
                        RunMacroText("/cast Blazing Barrier")
                    end
                elseif player_class == "DRUID" then
                    -- ** DRUID ** --
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Regrowth")
                    else
                        RunMacroText("/cast [noform:4] Moonkin Form")
                    end
                elseif player_class == "SHAMAN" then
                    -- ** SHAMAN ** --
                    local earth_shield_duration = env:evaluate_variable("unit." .. tank_name .. ".buff.Earth Shield")
                    if (earth_shield_duration == -1) then
                        needs_more_time = true
                        RunMacroText("/cast [@" .. tank_name .. "]Earth Shield")
                    end

                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Healing Surge")
                    end
                end
            end
            -- called to check and run the preparation roation, such as summoning and buffing
            -- return true if preparations are still ongoing
            return needs_more_time
        end
    }
}
