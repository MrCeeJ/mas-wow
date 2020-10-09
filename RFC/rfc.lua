return {
    -- Define rotation
    rotations = {
        combat = function(env, is_pulling)
            local _, global_cd_duration, _, _ = GetSpellCooldown("61304")
            local main_tank = "Ceejpaladin"
            local UnitClassName = env:evaluate_variable("myself.class") --  UnitClass("player")
            local enemeies = env:evaluate_variable("npcs.all.is_attacking_me")
            local min_dot_hp = 10
            --env:evaluate_variable("npcs.attackable.range_10")>=2  -- more than 2 targets in 10 yards

            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            if (global_cd_duration == 0) then
                -- ** PALADIN ** --
                if UnitClassName == "PALADIN" then
                    local current_health = UnitHealth("player")
                    local max_health = UnitHealthMax("player")
                    local _, hoj_cd = GetSpellCooldown("Hammer of Justice")
                    local life = current_health / max_health
                    -- A fix for no target spam
                    if (UnitExists("target") == false) then
                        RunMacroText("/targetenemy [noexists][dead]")
                    end
                    -- cleanse
                    --RunMacroText("/cast Cleanse Toxins")

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
                -- ** PRIEST ** --
                if UnitClassName == "PRIEST" then
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

                    -- Heal yourself
                    if (hp < emergency_health and has_weakened_soul == -1) then
                        healing = true
                        RunMacroText("/cast [@player] Power Word: Shield")
                    elseif (hp < good_health) then
                        healing = true
                        RunMacroText("/cast [@player] Flash Heal")
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
                                -- print(target_health, " greater than ", min_dot_hp, " casting SW:P")
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
                -- ** DRUID ** --
                if UnitClassName == "DRUID" then
                    local lunar_power = UnitPower("player", 8)
                    if (UnitExists("target")) then
                        --Get buff Ids
                        -- for i = 1, 40 do
                        --     local name, _, count, type, duration, etime, source, isStealable, _, spellID = UnitBuff("player", i)
                        --     if name then
                        --          Winds of Wisdom, Fortitude, Attonement, Bezerking, PWS
                        --         if (spellID ~= 326419 and spellID ~= 21562 and spellID ~= 194384 and spellID ~= 26297) then
                        --             print("Name :", name, " id :", spellID, " duration :", duration, "has heating up :", has_heating_up, " has hot streak :", has_hotstreak)
                        --         end
                        --     end
                        -- end

                        local target_hp = env:evaluate_variable("unit.target.health")
                        local has_moonfire = env:evaluate_variable("unit.target.debuff.Moonfire")
                        local knows_sunfire = IsSpellKnown(93402, false) --  not 164815
                        local has_sunfire = env:evaluate_variable("unit.target.debuff.164815")
                        local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                        local has_solar_emp = env:evaluate_variable("myself.buff.164545") -- solar
                        local has_lunar_emp = env:evaluate_variable("myself.buff.164547") -- lunar

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
                -- ** MAGE ** --
                if UnitClassName == "FROSTMAGE" then
                    if (UnitExists("target")) then
                        local target_is_frozen = nil --UnitAura("target", "Frozen")
                        -- local tank_name = "ceejpaladin-Doomhammer"
                        -- RunMacroText("/assist " .. tank_name)

                        local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                        if (berserking_cd_duration == 0) then
                            RunMacroText("/cast Berserking")
                        elseif (target_is_frozen ~= nil) then
                            RunMacroText("/cast Ice Lance")
                        else
                            RunMacroText("/cast Frostbolt")
                        end
                    else
                        RunMacroText("/assist " .. main_tank)
                    end
                end
                if UnitClassName == "MAGE" then
                    if (UnitExists("target")) then
                        local has_hotstreak = env:evaluate_variable("myself.buff.48108") --195283  48108
                        local has_heating_up = env:evaluate_variable("myself.buff.48107") -- Check for Heating Up when lvl 18
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
                -- ** SHAMAN ** --
                if UnitClassName == "SHAMAN" then
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
            local in_combat = env:evaluate_variable("myself.is_in_combat") -- UnitAffectingCombat("player")
            local needs_more_time = false
            local healer_name = "Ceejpriest"
            if (in_combat) then
                needs_more_time = false
            else
                local healer_mana = UnitPower(healer_name, 0)
                local healer_max_mana = UnitPowerMax(healer_name, 0)
                -- print("Healer Mana :", healer_mana, "/", healer_max_mana)
                local healer_mp = 100 * healer_mana / healer_max_mana
                if (healer_mp < 90) then
                    needs_more_time = true
                end
                local UnitClassName = env:evaluate_variable("myself.class") --  UnitClass("player")
                if UnitClassName == "PRIEST" then
                    -- ** PRIEST ** --
                    -- local mp = env:evaluate_variable("myself.mana")
                    local mana = UnitPower("player", 0)
                    local max_mana = UnitPowerMax("player", 0)
                    local mp = 100 * mana / max_mana

                    -- local is_drinking = env:evaluate_variable("myself.buff.159") -- Refreshing Srping Water?
                    local has_fortitude = env:evaluate_variable("myself.buff.21562") 

                    if (mp < 90) then
                        needs_more_time = true
                        -- Drink
                        local is_drinking = env:evaluate_variable("myself.buff.43518") -- 43518 Conjured Mana Pie
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
                elseif UnitClassName == "PALADIN" then
                    -- ** PALADIN ** --
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Flash Of Light")
                    end
                elseif UnitClassName == "MAGE" then
                    -- ** MAGE ** --
                    RunMacroText("/cast [nopet][@pet, dead] Summon Water Elemental")
                elseif UnitClassName == "DRUID" then
                    -- ** DRUID ** --
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Regrowth")
                    else
                        RunMacroText("/cast [noform:4] Moonkin Form")
                    end
                elseif UnitClassName == "SHAMAN" then
                    -- ** SHAMAN ** --
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
