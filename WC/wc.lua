return {
    -- This file has two hard coded values, the tank name and healer name, please insert them if you want to use the script.


    -- Define custom variables.
    variables = {
        ["get_singleton_event_frame"] = function(env)
            if (event_frame == null) then
                print("creating frame...")
                event_frame = CreateFrame("Frame", "event_frame", UIParent)
                event_frame:RegisterEvent("UNIT_COMBAT")
                event_frame:SetScript("OnEvent", print)
            end
            return event_frame
        end
    },
    -- Define rotation
    rotations = {
        combat = function(env, is_pulling)
            --local event_frame = env:evaluate_variable("get_singleton_event_frame") -- a singleton of the combat log to identify actions if needed
            local _, global_cd_duration, _, _ = GetSpellCooldown("61304")
            local main_tank = "" -- ** Insert your Tank name here **
            local player_class = env:evaluate_variable("myself.class")
            local min_dot_hp = 10
            --env:evaluate_variable("npcs.attackable.range_10")>=2  -- more than 2 targets in 10 yards

            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            if (global_cd_duration == 0) then
                -- ** PALADIN (PROT)** --
                if player_class == "PALADIN" then
                    local current_health = UnitHealth("player")
                    local max_health = UnitHealthMax("player")
                    local _, hoj_cd = GetSpellCooldown("Hammer of Justice")
                    local life = current_health / max_health
                    -- A fix for no target spam
                    if (UnitExists("target") == false) then
                        RunMacroText("/targetenemy [noexists][dead]")
                    end

                    -- Wake everyone up
                    local _, cleanse_cd_duration, _, _ = GetSpellCooldown("Cleanse Toxins")
                    local party_members = GetHomePartyInfo()
                    if (party_members ~= nil and cleanse_cd_duration == 0) then
                        local cleansing = false
                        for i, player_name in ipairs(party_members) do
                            local target_poisoned = env:evaluate_variable("unit." .. player_name .. ".debuff.7947") --Localised Toxin
                            if (cleansing == false) then
                                if (target_poisoned > 0) then
                                    RunMacroText("/cast [target=" .. player_name .. "] Cleanse Toxins")
                                    cleansing = true
                                end
                            end
                        end
                    end
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
                        local has_consecration = env:evaluate_variable("myself.buff.Consecration")
                        local shield_charges, shield_max_harges, shield_cooldown_start, shield_cooldown_duration, _ = GetSpellCharges("Shield of the Righteous")
                        local has_shield = env:evaluate_variable("myself.buff.132403") -- 132403 for dmg reduction effect

                        -- Use shield if we have taken damage and don't have it up
                        if (life < 1 and has_shield == -1 and shield_charges > 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
                            RunMacroText("/cast Shield of the Righteous")
                        elseif (avengers_shield_cd == 0) then
                            RunMacroText("/cast Avenger's Shield")
                        elseif (has_consecration == -1 and consecration_cd == 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
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
                -- ** PRIEST (DISC) ** --
                if player_class == "PRIEST" then
                    local emergency_health = 50
                    local ok_health = 75
                    local good_health = 80
                    local party_size = 1
                    RunMacroText("/assist " .. main_tank)
                    -- Do Healing
                    local healing = false
                    local current_health = UnitHealth("player")
                    local max_health = UnitHealthMax("player")
                    local life = tonumber(current_health) / tonumber(max_health)
                    local hp = env:evaluate_variable("myself.health")
                    local has_weakened_soul = env:evaluate_variable("myself.debuff.6788")
                    local start, penance_cd_duration, enabled, modRate = GetSpellCooldown("Penance")
                    local _, desperate_cd_duration, _, _ = GetSpellCooldown("Desperate Prayer")
                    local _, purify_cd_duration, _, _ = GetSpellCooldown("Desperate Prayer")

                    for i = 1, 40 do
                        local name, _, count, type, duration, etime, source, isStealable, _, spellID = UnitDebuff("player", i)
                        if name then
                            -- Winds of Wisdom (326419), Fortitude (21562), Attonement(194384), Bezerking, PWS(26297), Masochism(193065), Replensihment(167152)
                            if (spellID ~= 326419 and spellID ~= 21562 and spellID ~= 194384 and spellID ~= 26297 and spellID ~= 193065 and spellID ~= 167152 ) then
                            --    print("Name :", name, " id :", spellID, " duration :", duration) -- Print out debuffs for adding dispells
                            end
                        end
                    end

                    -- Wake everyone up
                    local _, purify_cd_duration, _, _ = GetSpellCooldown("Purify")
                    local party_members = GetHomePartyInfo()
                    if (party_members ~= nil and purify_cd_duration == 0) then
                        local purifying = false
                        for i, player_name in ipairs(party_members) do
                            local target_poisoned = env:evaluate_variable("unit." .. player_name .. ".debuff.8040") --Druid's Slumber
                            local target_nightmare = env:evaluate_variable("unit." .. player_name .. ".debuff.7967") --Nightmare
                            if (purifying == false) then
                                if (target_poisoned > 0 or target_nightmare > 0) then
                                    RunMacroText("/cast [target=" .. player_name .. "] Purify")
                                    purifying = true
                                end
                            end
                        end
                    end

                    -- Heal yourself
                    if (hp < emergency_health and has_weakened_soul == -1) then
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
                                    local has_weakened_soul = env:evaluate_variable("unit." .. player_name .. ".debuff.6788")
                                    if (target_hp > 0 and target_hp < emergency_health and has_weakened_soul == -1) then
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
                                    local has_weakened_soul = env:evaluate_variable("unit." .. player_name .. ".debuff.6788")
                                    if (target_hp > 0 and target_hp < good_health and penance_cd_duration == 0) then
                                        -- print(i, player_name, target_hp, "Receiving Penance")
                                        healing = true
                                        RunMacroText("/cast [target=" .. player_name .. "] Penance")
                                    elseif (target_hp > 0 and target_hp < good_health and has_weakened_soul == -1 and player_name == main_tank) then
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
                            local has_swpain = env:evaluate_variable("unit.target.debuff.589") -- TODO: Check all in combat targets
                            local target_health = env:evaluate_variable("unit.target.health")
                            local _, schism_cd_duration, _, _ = GetSpellCooldown("Schism")

                            -- print("target health: " .. target_health)
                            if (target_health > min_dot_hp and has_swpain == -1) then
                                RunMacroText("/cast Shadow Word: Pain")
                            elseif (schism_cd_duration == 0) then
                                RunMacroText("/cast Schism")
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
                -- ** DRUID (BALANCE) ** --
                if player_class == "DRUID" then
                    local lunar_power = UnitPower("player", 8)

                    -- Wake everyone up
                    local _, remove_cd_duration, _, _ = GetSpellCooldown("Remove Corruption")
                    local party_members = GetHomePartyInfo()
                    if (party_members ~= nil and remove_cd_duration == 0) then
                        local removing = false
                        for i, player_name in ipairs(party_members) do
                            local target_poisoned = env:evaluate_variable("unit." .. player_name .. ".debuff.7947") --Localised Toxin
                            if (removing == false) then
                                if (target_poisoned > 0) then
                                    RunMacroText("/cast [target=" .. player_name .. "] Remove Corruption")
                                    removing = true
                                end
                            end
                        end
                    end

                    if (UnitExists("target")) then
                        local target_hp = env:evaluate_variable("unit.target.health")
                        local has_moonfire = env:evaluate_variable("unit.target.debuff.Moonfire")
                        local knows_sunfire = IsSpellKnown(93402, false) --  not 164815
                        local has_sunfire = env:evaluate_variable("unit.target.debuff.164815")
                        local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                        local has_solar_emp = env:evaluate_variable("myself.buff.164545") -- Solar Empowerment
                        local has_lunar_emp = env:evaluate_variable("myself.buff.164547") -- Lunar Empowerment

                        if (berserking_cd_duration == 0) then
                            RunMacroText("/cast Berserking")
                        elseif (target_hp > min_dot_hp and has_moonfire == -1) then
                            RunMacroText("/cast Moonfire")
                        elseif (knows_sunfire == true and target_hp > min_dot_hp and has_sunfire == -1) then
                            RunMacroText("/cast Sunfire")
                        elseif (has_solar_emp ~= -1) then -- will recast as buff isn't removed until spell lands
                            RunMacroText("/cast Solar Wrath")
                        elseif (lunar_power >= 40) then
                            RunMacroText("/cast Starsurge")
                        elseif (has_lunar_emp ~= -1) then -- will recast as buff isn't removed until spell lands
                            RunMacroText("/cast Lunar Strike")
                        else
                            RunMacroText("/cast Solar Wrath")
                        end
                    else
                        RunMacroText("/assist " .. main_tank)
                    end
                end
                -- ** MAGE (FIRE)** --
                if player_class == "MAGE" then
                    if (UnitExists("target")) then
                        local has_hotstreak = env:evaluate_variable("myself.buff.48108") -- not 195283 but 48108
                        local has_heating_up = env:evaluate_variable("myself.buff.48107")
                        local _, fireblast_cd_duration, _, _ = GetSpellCooldown("Fire Blast")
                        local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")

                        if (berserking_cd_duration == 0) then
                            RunMacroText("/cast Berserking")
                        elseif (has_hotstreak > 0) then
                            RunMacroText("/cast Pyroblast")
                        elseif (fireblast_cd_duration == 0 and has_heating_up > 0) then
                            RunMacroText("/cast Fire Blast")
                        else
                            RunMacroText("/cast Fireball")
                        end
                    else
                        RunMacroText("/assist " .. main_tank)
                    end
                end
                -- ** SHAMAN (ELEMENTAL)** --
                if player_class == "SHAMAN" then
                    if (UnitExists("target")) then
                        local target_hp = env:evaluate_variable("unit.target.health")
                        local _, flame_shock_cd_duration, _, _ = GetSpellCooldown("188389")
                        local has_flame_shock = env:evaluate_variable("unit.target.debuff.188389")
                        local maelstrom = UnitPower("player", 11)
                        local lb_charges, maxCharges, lb_cooldownStart, lb_cooldownDuration, lb_chargeModRate = GetSpellCharges("Lava Burst")
                        local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                        if (berserking_cd_duration == 0) then
                            RunMacroText("/cast Berserking")
                        elseif (target_hp > min_dot_hp and has_flame_shock == -1 and flame_shock_cd_duration == 0) then
                            RunMacroText("/cast Flame Shock")
                        elseif (maelstrom ~= nil and maelstrom >= 90) then
                            RunMacroText("/cast Earth Shock")
                        elseif (IsSpellKnown(51505, false) and lb_charges > 0 and lb_cooldownDuration == 0) then --"Lava Burst"
                            RunMacroText("/cast Lava Burst")
                        else
                            RunMacroText("/cast Lightning Bolt")
                        end
                    else
                        RunMacroText("/assist " .. main_tank)
                    end
                end
            end
        end,
        prepare = function(env)
            -- called to check and run the preparation roation, such as summoning and buffing
            -- return true if preparations are still ongoing
            local in_combat = env:evaluate_variable("myself.is_in_combat")
            local needs_more_time = false
            local healer_name = "" -- ** Insert your healer name here **
            if (in_combat) then
                needs_more_time = false
            else
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
                    local has_fortitude = env:evaluate_variable("myself.buff.21562")

                    if (mp < 90) then
                        needs_more_time = true
                        --Get buff Ids
                        for i = 1, 40 do
                            local name, _, count, type, duration, etime, source, isStealable, _, spellID = UnitBuff("player", i)
                            if name then
                                -- Winds of Wisdom, Fortitude, Attonement, Bezerking, PWS
                                if (spellID ~= 326419 and spellID ~= 21562 and spellID ~= 194384 and spellID ~= 26297) then
                                    print("Name :", name, " id :", spellID, " duration :", duration)
                                end
                            end
                        end

                        -- Drink
                        local is_drinking = env:evaluate_variable("myself.buff.Refreshment") -- 43518 Conjured Mana Pie
                        if (is_drinking == -1) then
                            RunMacroText("/use Conjured Mana Pie")
                        end
                        print("Priest needs more mana :", mp, "is drinking :", is_drinking)
                    elseif (has_fortitude == -1) then
                        needs_more_time = true
                        RunMacroText("/cast Power Word: Fortitude")
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
                    local has_barrier = env:evaluate_variable("myself.buff.235313")
                    local _, barrier_cd_duration, _, _ = GetSpellCooldown("Blazing Barrier")
                    if (barrier_cd_duration == 0 and has_barrier == -1) then
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
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Healing Surge")
                    end
                end
            end
            return needs_more_time
        end
    }
}
