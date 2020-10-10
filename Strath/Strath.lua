return {
    --Custom Actions
    actions = {
        aoe = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "PALADIN" then
                local _, consecration_cd = GetSpellCooldown("Consecration")
                if (consecration_cd == 0) then
                    RunMacroText("/cast Consecration")
                end
            elseif player_class == "PRIEST" then
                RunMacroText("/cast Holy Nova")
            elseif player_class == "DRUID" then
                local lunar_power = UnitPower("player", 8)
                if (lunar_power >= 50) then
                    RunMacroText("/cast [@player]Starfall")
                end
            elseif player_class == "MAGE" then
                local _, blast_wave_cd = GetSpellCooldown("Consecration")
                if (blast_wave_cd == 0) then
                    RunMacroText("/cast Blast Wave")
                else
                    RunMacroText("/cast [@player]Flame Strike")
                end
            elseif player_class == "SHAMAN" then
                local _, totem_cd = GetSpellCooldown("Capacitor Totem")
                local _, thunderstorm_cd = GetSpellCooldown("Thunderstorm")
                if (totem_cd == 0) then
                    RunMacroText("/cast [@player]Capacitor Totem")
                elseif (thunderstorm_cd == 0) then
                    RunMacroText("/cast Thunderstorm")
                end
            end
            return false
        end
    },
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
        ["get_healer_name"] = function(env)
            return "Ceejpriest"
        end,
        ["get_tank_name"] = function(env)
            return "Ceejpaladin"
        end,
        ["get_party"] = function(env)
            if (party == nil) then
                print("creating party...")
                party = {}
                party_info = GetHomePartyInfo()
                for id, name in pairs(party_info) do
                    print("Welcome to :", name)
                    table.insert(party, name)
                end
                local me, _ = UnitName("player")
                print(".. and welcome to :", me)
                table.insert(party, me)
            end
            return party
        end,
        ["get_known_buffs"] = function(env)
            if (known_buffs == nil) then
                print("creating known buff list...")
                known_buffs = {
                    [326419] = "Winds of Wisdom",
                    [21562] = "Fortitude",
                    [194384] = "Attonement",
                    [26297] = "Power Word: Shield",
                    [193065] = "Masochism",
                    [167152] = "Replensihment"
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
                    [17455] = "Bone Smelt",
                    [13730] = "Demoralizing Shout",
                    [9080] = "Hamstring",
                    [13737] = "Mortal Strike",
                    [16244] = "Demo Shout",
                    [6253] = "Backhand",
                    [6713] = "Disarm",
                    [15655] = "Shield Slam",
                    [6788] = "Weakened Soul",
                    [187464] = "Shadow Mend",
                    [87024] = "Cauterized",
                    [225080] = "Reincarnation",
                    --Unavoidable
                    --Ignore
                    [9672] = "Frostbolt",
                    [15043] = "Frostbolt",
                    [6136] = "Chilled",
                    [17145] = "Blastwave",
                    [17165] = "Mind Flay",
                    [122832] = "Unrelenting Anguish",
                    -- Dispellable
                    [16458] = "Ghoul Plague",
                    [16143] = "Cadaver Worms",
                    [7068] = "Vale of Shadows",
                    [16336] = "Haunting Phantoms",
                    [5137] = "Call of the Grave",
                    [16333] = "Dibilitating Touch",
                    [15654] = "Shadow Word: Pain",
                    [13323] = "Polymorph",
                    [33975] = "Pyroblast",
                    [15063] = "Frost Nova",
                    [15732] = "Immolate",
                    [66290] = "Sleep",
                    [16798] = "Enchanting Lulaby",
                    [12741] = "Curse of Weakness",
                    [13704] = "Psychic Scream",
                    [17141] = "Holy Fire",
                    [13338] = "Curse of Tongues",
                    [7713] = "Wailing Dead"
                }
            end
            return known_debuffs
        end,
        ["get_curses"] = function(env)
            if (curses == nil) then
                print("creating known curse list...")
                curses = {
                    [7068] = "Vale of Shadows",
                    [16336] = "Haunting Phantoms",
                    [5137] = "Call of the Grave",
                    [7713] = "Wailing Dead",
                    [12741] = "Curse of Weakness",
                    [13338] = "Curse of Tongues"
                }
            end
            return curses
        end,
        ["get_magics"] = function(env)
            if (magics == nil) then
                print("creating known magics list...")
                magics = {
                    [16333] = "Dibilitating Touch",
                    [15654] = "Shadow Word: Pain",
                    [13323] = "Polymorph",
                    [15732] = "Immolate",
                    [17141] = "Holy Fire",
                    [15063] = "Frost Nova",
                    [66290] = "Sleep",
                    [13704] = "Psychic Scream"
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
            party = env:evaluate_variable("get_party")

            function dispell(spell, debuff_1, debuff_2, debuff_3)
                local _, dispell_cd, _, _ = GetSpellCooldown(spell)
                local dispelling = false
                if (dispell_cd == 0) then
                    for i, player_name in ipairs(party) do
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
            function check_for_new_debuffs(env)
                -- Check for new debuffs
                for i, player_name in ipairs(party) do
                    for b = 1, 5 do
                        local name, _, _, type, duration, _, _, _, _, spellId = UnitDebuff(player_name, b) --, "CANCELABLE"
                        if (name) then
                            local debuff_present = known_debuffs[spellId]
                            if (debuff_present == nil) then
                                RunMacroText("/p New debuff found - Name :" .. name .. " type: " .. type .. " id :" .. spellId .. " duration :" .. duration)
                                known_debuffs[spellId] = name
                            end
                        end
                    end
                end
            end

            function cannons(env)
                -- 176215 ammo
                -- 176217 ammo
            end

            local _, global_cd, _, _ = GetSpellCooldown("61304")
            local main_tank = "Ceejpaladin"
            local player_class = env:evaluate_variable("myself.class")
            local min_dot_hp = 10
            --env:evaluate_variable("npcs.attackable.range_10")>=2  -- more than 2 targets in 10 yards

            --get all targets
            -- if not in LoS, move to tank

            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            if (global_cd == 0) then
                -- local enemies = env:evaluate_variable("npcs.all.is_attacking_me")
                -- print ("Enemies attacking :", player_class, " : ", enemies)

                -- ** PALADIN ** --
                if player_class == "PALADIN" then
                    local current_health = UnitHealth("player")
                    local max_health = UnitHealthMax("player")
                    local _, hoj_cd = GetSpellCooldown("Hammer of Justice")
                    local life = current_health / max_health
                    -- A fix for no target spam
                    RunMacroText("/cleartarget [dead][noharm][noexists]")
                    if (UnitExists("target") == false) then
                        RunMacroText("/targetenemy [nodead][exists]")
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
                    -- Do Healing
                    local healing = false
                    local _, penance_cd, _, _ = GetSpellCooldown("Penance")
                    local rapture_duration = env:evaluate_variable("myself.buff.Rapture")

                    -- log out any exiting new debuffs
                    check_for_new_debuffs(env)

                    -- Dispell everyone
                    local dispelling = dispell("Purify", magics, diseases)

                    if (dispelling == false) then
                        -- Check for Desperate Prayer
                        local health_check = 60
                        local my_hp = env:evaluate_variable("myself.health")
                        local _, desperate_cd, _, _ = GetSpellCooldown("Desperate Prayer")
                        if (my_hp < health_check and desperate_cd == 0) then
                            healing = true
                            RunMacroText("/cast [@player] Desperate Prayer")
                        else
                            -- If people have less than 40% hp, panic
                            health_check = 40
                            for i, player_name in ipairs(party) do
                                if (healing == false) then
                                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                    if (target_hp > 0 and target_hp < health_check) then
                                        local weakened_soul_duration = env:evaluate_variable("unit." .. player_name .. ".debuff.6788")
                                        local _, pain_suppression_cd, _, _ = GetSpellCooldown("Pain Suppression")
                                        local _, rapture_cd, _, _ = GetSpellCooldown("Rapture")
                                        local pain_suppression_duration = env:evaluate_variable("unit." .. player_name .. ".buff.Pain Supression")

                                        if (rapture_duration > 0 or pain_suppression_duration > 0) then
                                            -- happy days, already on it
                                        elseif (rapture_cd == 0) then
                                            healing = true
                                            RunMacroText("/cast Rapture")
                                        elseif (rapture_duration == -1 and pain_suppression_cd == 0) then -- Chuck them a super shield
                                            healing = true
                                            RunMacroText("/cast [target=" .. player_name .. "] Pain Suppression")
                                        end
                                    end
                                end
                            end

                            -- If people have 40-70% hp, help them out
                            health_check = 70
                            for i, player_name in ipairs(party) do
                                if (healing == false) then
                                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                    if (target_hp > 0 and target_hp < health_check) then
                                        local weakened_soul_duration = env:evaluate_variable("unit." .. player_name .. ".debuff.6788")
                                        local shield_duration = env:evaluate_variable("unit." .. player_name .. ".buff.Power Word: Shield")
                                        if (shield_duration == -1 and (weakened_soul_duration == -1 or rapture_duration > 0)) then
                                            -- Chuck them a shield
                                            healing = true
                                            RunMacroText("/cast [target=" .. player_name .. "] Power Word: Shield")
                                        else
                                            if (penance_cd == 0) then
                                                -- They have had a shield, can we top them off with Penance?
                                                healing = true
                                                RunMacroText("/cast [target=" .. player_name .. "] Penance")
                                            else
                                                -- They have had a shield, and they are still below 80, give them a mend
                                                healing = true
                                                RunMacroText("/cast [target=" .. player_name .. "]Shadow Mend")
                                            end
                                        end
                                    end
                                end
                            end

                            -- If people have over 70% hp, just use Atonement
                            health_check = 100
                            for i, player_name in ipairs(party) do
                                if (healing == false) then
                                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                    if (target_hp > 0 and target_hp < health_check) then
                                        local atonement_duration = env:evaluate_variable("unit." .. player_name .. ".buff.Atonement")
                                        if (atonement_duration > 0) then
                                            -- Do nothing, they are have atonement
                                        else
                                            -- Chuck them a shield, they will be fine (If you have weakened soul you also have atonement, so always use a shieled)
                                            healing = true
                                            RunMacroText("/cast [target=" .. player_name .. "] Power Word: Shield")
                                        end
                                    end
                                end
                            end
                        end
                        -- Do Damage
                        if (healing == false) then
                            -- Check target
                            if (UnitExists("target") == false) then
                                RunMacroText("/assist " .. main_tank)
                            else
                                -- Need to check LOS and possibly Move?
                                local swpain_duration = env:evaluate_variable("unit.target.debuff.589") -- TODO: Check all in combat targets
                                local target_health = env:evaluate_variable("unit.target.health")
                                local _, schism_cd, _, _ = GetSpellCooldown("Schism")
                                local _, solace_cd, _, _ = GetSpellCooldown("Power Word: Solace")
                                local _, fiend_cd, _, _ = GetSpellCooldown("Shadowfiend")

                                if (target_health > min_dot_hp and swpain_duration == -1) then
                                    RunMacroText("/cast Shadow Word: Pain")
                                elseif (schism_cd == 0) then
                                    RunMacroText("/cast Schism")
                                elseif (fiend_cd == 0) then
                                    RunMacroText("/cast Shadowfiend")
                                elseif (solace_cd == 0) then
                                    RunMacroText("/cast Power Word: Solace")
                                elseif (penance_cd == 0) then
                                    RunMacroText("/cast Penance")
                                else
                                    RunMacroText("/cast Smite")
                                end
                            end
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
                            local sunfire_duration = env:evaluate_variable("unit.target.debuff.Sunfire")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, alignment_cd, _, _ = GetSpellCooldown("Celestial Alignment")
                            local solar_emp_duration = env:evaluate_variable("myself.buff.164545") -- solar
                            local lunar_empduration = env:evaluate_variable("myself.buff.164547") -- lunar

                            if (alignment_cd == 0) then
                                RunMacroText("/cast Celestial Alignment")
                            elseif (berserking_cd == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (target_hp > min_dot_hp and moonfire_duration == -1) then
                                RunMacroText("/cast Moonfire")
                            elseif (target_hp > min_dot_hp and sunfire_duration == -1) then
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

                            local _, fireblast_cd, _, _ = GetSpellCooldown("Fire Blast")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, combustion_cd, _, _ = GetSpellCooldown("Combustion")

                            if (berserking_cd == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (combustion_cd == 0) then
                                RunMacroText("/cast Combustion")
                            elseif (hotstreak_duration > 0) then
                                RunMacroText("/cast Pyroblast")
                            elseif (fireblast_cd == 0 and heating_up_duration > 0) then
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
                            local _, flame_shock_cd, _, _ = GetSpellCooldown("188389")
                            local _, earth_elemental_cd, _, _ = GetSpellCooldown("Earth Elemental")
                            local flame_shock_duration = env:evaluate_variable("unit.target.debuff.188389")
                            local maelstrom = UnitPower("player", 11)
                            local lb_charges, _, _, lb_cooldownDuration, _ = GetSpellCharges("Lava Burst")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")

                            -- Check Earth Shield
                            if (earth_elemental_cd == 0) then
                                RunMacroText("/cast Earth Elemental")
                            elseif (berserking_cd == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (target_hp > min_dot_hp and flame_shock_duration == -1 and flame_shock_cd == 0) then
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
            local party = env:evaluate_variable("get_party")
            local in_combat = env:evaluate_variable("myself.is_in_combat")
            local healer_name = env:evaluate_variable("get_healer_name")
            local tank_name  = env:evaluate_variable("get_tank_name")

            -- Support Functions
            res_party = function(env, spell)
                local reviving = false
                for player_name in pairs(party) do
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    local distance = env:evaluate_variable("unit." .. player_name .. ".distance")
                    if (target_hp == 0 and reviving == false and distance <= 40) then
                        reviving = true
                        needs_more_time = true
                        if (spell) then
                            RunMacroText("/target " .. player_name)
                            RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                        end
                    end
                end
                return reviving
            end
            check_res = function(env, spell)
                local casting = UnitCastingInfo("player")
                local target = UnitName("target")
                if (casting ~= nil and target ~= nil) then -- If we are busy casting, we are clearly not ready
                    local target_hp = env:evaluate_variable("unit." .. target .. ".health")
                    if (casting == spell and target_hp ~= 0) then
                        print("Aborting uncecessary :", spell, " on target :", target)
                        RunMacroText("/stopcasting")
                        return false
                    else
                        return true
                    end
                end
            end
            is_anyone_dead = function(env)
                local dead = false
                for player_name in pairs(party) do
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    if (target_hp == 0) then
                        dead = true
                    end
                end
                return dead
            end
            is_everyone_buffed = function(env, spell)
                local buffed = true
                for player_name in pairs(party) do
                    local buff_duration = env:evaluate_variable("unit." .. player_name .. ".buff."..spell)
                    if (buff_duration == 0) then
                        buffed = false
                    end
                end
                return dead
            end
            does_healer_have_mana = function(env)
                local has_mana = true
                local healer_mana = UnitPower(healer_name, 0)
                local healer_max_mana = UnitPowerMax(healer_name, 0)
                local healer_mp = 100 * healer_mana / healer_max_mana
                if (healer_mp < 90) then
                    has_mana = false
                end
                return has_mana
            end
            
            -- Preparation Code
            local needs_more_time = false


            if (env:evaluate_variable("myself.life") == 2) then
                -- print("I seem to be dead")
                AcceptResurrect()
                return true            
            end

            if (in_combat) then
                needs_more_time = false -- If we are in combat, no need to worry about preparations
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
                    if (check_res(env, "Resurrection")) then
                        return true
                    end

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
                    if (check_res(env, "Redemption")) then
                        return true
                    end
                    needs_more_time = res_party(env, "Redemption")
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90 and needs_more_time ~= false) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Flash Of Light")
                    end
                elseif player_class == "MAGE" then
                    -- ** MAGE ** --

                    if (is_anyone_dead(env)) then
                        return true
                    end
                    -- RunMacroText("/cast [nopet][@pet, dead] Summon Water Elemental")
                    local barrier_duration = env:evaluate_variable("myself.buff.235313")
                    local _, barrier_cd, _, _ = GetSpellCooldown("Blazing Barrier")

                    if (barrier_cd == 0 and barrier_duration == -1) then
                        RunMacroText("/cast Blazing Barrier")
                    end
                elseif player_class == "DRUID" then
                    -- ** DRUID ** --
                    if (check_res(env, "Revive")) then
                        return true
                    end
                    needs_more_time = res_party(env, "Revive")
                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90 and needs_more_time ~= false) then
                        needs_more_time = true
                        RunMacroText("/cast [@Player]Regrowth")
                    else
                        RunMacroText("/cast [noform:4] Moonkin Form")
                    end
                elseif player_class == "SHAMAN" then
                    -- ** SHAMAN ** --
                    if (check_res(env, "Ancestral Spirit")) then
                        return true
                    end
                    needs_more_time = res_party(env, "Ancestral Spirit")
                    local earth_shield_duration = env:evaluate_variable("unit." .. tank_name .. ".buff.Earth Shield")
                    local distance = env:evaluate_variable("unit." .. tank_name .. ".distance")
                    local target_hp = env:evaluate_variable("unit." .. tank_name .. ".health") -- todo: sight
                    if (earth_shield_duration == -1 and target_hp > 0 and distance < 20 and needs_more_time ~= false) then
                        needs_more_time = true
                        RunMacroText("/cast [@" .. tank_name .. "]Earth Shield")
                    end

                    local hp = env:evaluate_variable("myself.health")
                    if (hp < 90 and needs_more_time ~= false) then
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
