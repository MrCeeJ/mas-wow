return {
    -- Define custom variables.
    variables = {
        ["battle.is_long_enough"] = function(env)
            -- You can use [setting.xxx] syntax to access the current value of a custom setting in terms of a variable.
            local battle_timeout = env:evaluate_variable("setting.battle_timeout")
            if (battle_timeout) then
                local battle_duration = env:evaluate_variable("battleground.duration")
                return battle_duration and battle_duration > battle_timeout or false
            else
                return false
            end
        end,
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
                    [6788] = "Weakened Soul",
                    [187464] = "Shadow Mend",
                    [30615] = "Fear",
                    [3242] = "Ravage",
                    --Unavoidable
                    [93691] = "Desecration", -- On the floor
                    [93581] = "Pain and Suffering", -- Channeled boss ability
                    [93423] = "Asphyxiate", -- Channeled boss ability
                    [93697] = "Conjour Poisonous Mixture", -- undispellable poison
                    [7057] = "Haunting Spirits", -- undispellable curse
                    [7054] = "Forsaken Ability",
                    -- undispellable curse
                    [91677] = "Pustulent Spit",
                    -- ignore
                    [15497] = "Frost Bolt", -- magic
                    [12611] = "Cone Of Cold",
                    -- [7139] = "Fell Stomp",

                    -- Removable
                    [23224] = "Veil Of Shadows", -- curse
                    [91677] = "Pustulent Spit" -- poison
                }
            end
            return known_debuffs
        end,
        ["get_curses"] = function(env)
            if (curses == nil) then
                print("creating known curse list...")
                curses = {
                    [23224] = "Veil Of Shadows"
                }
            end
            return curses
        end,
        ["get_magics"] = function(env)
            if (magics == nil) then
                print("creating known magics list...")
                magics = {
                    [93956] = "Cursed Veil"
                }
            end
            return magics
        end,
        ["get_diseases"] = function(env)
            if (diseases == nil) then
                print("creating known diseases list...")
                diseases = {}
            end
            return diseases
        end,
        ["get_poisons"] = function(env)
            if (poisons == nil) then
                print("creating known poisons list...")
                poisons = {
                    [91677] = "Pustulent Spit"
                }
            end
            return diseases
        end,        
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
                        if (debuff_1) then
                            for id, name in pairs(debuff_1) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/p Dispelling Whoop Whoop!")
                                        RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                        if (debuff_2) then
                            for id, name in pairs(debuff_2) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                        if (debuff_3) then
                            for id, name in pairs(debuff_3) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
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
            local player_class = env:evaluate_variable("myself.class") --  UnitClass("player")
            local min_dot_hp = 10
            --env:evaluate_variable("npcs.attackable.range_10")>=2  -- more than 2 targets in 10 yards

            --get all targets
            -- if not in LoS, move to tank

            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            if (global_cd_duration == 0) then
                -- local enemies = env:evaluate_variable("npcs.all.is_attacking_me")
                -- print ("Enemies attacking :", player_class, " : ", enemies)
                -- Check for Toxic Coagulant 93617
                local player_coagulating = env:evaluate_variable("myself.debuff.93617") -- Toxic Coagulant
                if (player_coagulating > 0) then
                    print("I should probably move")
                end

                -- ** PALADIN ** --
                if player_class == "PALADIN" then
                    local current_health = UnitHealth("player")
                    local max_health = UnitHealthMax("player")
                    local _, hoj_cd = GetSpellCooldown("Hammer of Justice")
                    local life = current_health / max_health
                    -- A fix for no target spam
                    if (UnitExists("target") == false) then
                        RunMacroText("/targetenemy [noexists][dead]")
                    end

                    -- Sort everyone out twice
                    local dispell = "Cleanse Toxins"
                    local _, dispell_cd_duration, _, _ = GetSpellCooldown(dispell)
                    local party_members = GetHomePartyInfo()
                    local dispelling = false
                    if (party_members ~= nil and dispell_cd_duration == 0) then
                        for i, player_name in ipairs(party_members) do
                            for id, name in pairs(diseases) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                                        dispelling = true
                                    end
                                end
                            end
                            for id, name in pairs(poisons) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                                        dispelling = true
                                    end
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
                -- ** PRIEST ** --
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
                    local _, purify_cd_duration, _, _ = GetSpellCooldown("Purify")
                    local _, fiend_cd_duration, _, _ = GetSpellCooldown("Shadowfiend")
                    local party_members = GetHomePartyInfo()

                    -- Check for new debuffs
                    for i, player_name in ipairs(party_members) do
                        for b = 1, 5 do
                            local name, _, count, type, duration, etime, source, isStealable, _, spellId = UnitDebuff(player_name, b, "CANCELABLE")
                            if (name) then
                                local debuf_present = known_debuffs[spellId]
                                if (debuf_present == nil) then
                                    RunMacroText("/p New debuff found from :" .. source .. " Name :" .. name .. " id :" .. spellId .. " duration :" .. duration)
                                    known_debuffs[spellId] = name
                                -- table.insert(known_debuffs, spellId = name)
                                end
                            end
                        end
                    end
                    dispell("Purify", magics, diseases)
                    -- Sort everyone out twice
                    -- local dispell = "Purify"
                    -- local _, dispell_cd_duration, _, _ = GetSpellCooldown(dispell)
                    -- local dispelling = false
                    -- if (party_members ~= nil and dispell_cd_duration == 0) then
                    --     for i, player_name in ipairs(party_members) do
                    --         for id, name in pairs(magics) do
                    --             local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                    --             if (dispelling == false) then
                    --                 if (needs_dispell > 0) then
                    --                     RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                    --                     RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                    --                     dispelling = true
                    --                 end
                    --             end
                    --         end
                    --         for id, name in pairs(diseases) do
                    --             local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                    --             if (dispelling == false) then
                    --                 if (needs_dispell > 0) then
                    --                     RunMacroText("/p Dispelling " .. player_name .. " of " .. name)
                    --                     RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                    --                     dispelling = true
                    --                 end
                    --             end
                    --         end
                    --     end
                    -- end

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
                                -- print(target_health, " greater than ", min_dot_hp, " casting SW:P")
                                RunMacroText("/cast Shadow Word: Pain")
                            elseif (fiend_cd_duration == 0) then
                                RunMacroText("/cast Shadowfiend")
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
                if player_class == "DRUID" then
                    local lunar_power = UnitPower("player", 8)

                    -- Sort everyone out twice
                    local dispell = "Remove Corruption"
                    local _, dispell_cd_duration, _, _ = GetSpellCooldown(dispell)
                    local party_members = GetHomePartyInfo()
                    local dispelling = false
                    if (party_members ~= nil and dispell_cd_duration == 0) then
                        for i, player_name in ipairs(party_members) do
                            for id, name in pairs(curses) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/p Dispelling " .. player_name .. " of  curse: " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                                        dispelling = true
                                    end
                                end
                            end
                            for id, name in pairs(poisons) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/p Dispelling " .. player_name .. " of poison  " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                    end
                    if (dispelling == false) then
                        if (UnitExists("target")) then
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
                end
                -- ** MAGE ** --
                if player_class == "MAGE" then
                    -- Sort everyone out
                    local dispell = "Remove Curse"
                    local _, dispell_cd_duration, _, _ = GetSpellCooldown(dispell)
                    local party_members = GetHomePartyInfo()
                    local dispelling = false
                    if (party_members ~= nil and dispell_cd_duration == 0) then
                        for i, player_name in ipairs(party_members) do
                            for id, name in pairs(curses) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                    end
                    if (dispelling == false) then
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
                end
                -- ** SHAMAN ** --
                if player_class == "SHAMAN" then
                    -- Sort everyone out
                    local dispell = "Cleanse Spirit"
                    local _, dispell_cd_duration, _, _ = GetSpellCooldown(dispell)
                    local party_members = GetHomePartyInfo()
                    local dispelling = false
                    if (party_members ~= nil and dispell_cd_duration == 0) then
                        for i, player_name in ipairs(party_members) do
                            for id, name in pairs(curses) do
                                local needs_dispell = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (dispelling == false) then
                                    if (needs_dispell > 0) then
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. dispell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                    end
                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local target_hp = env:evaluate_variable("unit.target.health")
                            local _, flame_shock_cd_duration, _, _ = GetSpellCooldown("188389")
                            local has_flame_shock = env:evaluate_variable("unit.target.debuff.188389")
                            local maelstrom = UnitPower("player", 11)
                            local lb_charges, _, _, lb_cooldownDuration, _ = GetSpellCharges("Lava Burst")
                            local _, berserking_cd_duration, _, _ = GetSpellCooldown("Berserking")
                            if (berserking_cd_duration == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (target_hp > min_dot_hp and has_flame_shock == -1 and flame_shock_cd_duration == 0) then
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
            local in_combat = env:evaluate_variable("myself.is_in_combat") -- UnitAffectingCombat("player")
            local needs_more_time = false
            local healer_name = "Ceejpriest"
            local tank_name = "Ceejpaladin"
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
                local player_class = env:evaluate_variable("myself.class") --  UnitClass("player")
                if player_class == "PRIEST" then
                    -- ** PRIEST ** --
                    -- local mp = env:evaluate_variable("myself.mana")
                    local mana = UnitPower("player", 0)
                    local max_mana = UnitPowerMax("player", 0)
                    local mp = 100 * mana / max_mana

                    -- local is_drinking = env:evaluate_variable("myself.buff.159") -- Refreshing Srping Water?
                    local has_fortitude = env:evaluate_variable("myself.buff.21562")

                    if (mp < 90) then
                        -- print("Priest needs more mana :", mp, "is drinking :", is_drinking)
                        needs_more_time = true
                        -- Drink
                        local is_drinking = env:evaluate_variable("myself.buff.167152") -- 43518 Conjured Mana Pie 167152 Replenishmet
                        if (is_drinking == -1) then
                            RunMacroText("/use Conjured Mana Pie")
                        end
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
                    local has_earth_shield = env:evaluate_variable("unit." .. tank_name .. ".buff.Earth Shield")
                    if (has_earth_shield == -1 ) then
                        needs_more_time = true
                        RunMacroText("/cast [@" .. tank_name .."]Earth Shield")
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
