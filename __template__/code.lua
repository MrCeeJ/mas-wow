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
        ["get_healer_name"] = function(env)
            local healer_name = "Ceejpriest"
            return healer_name
        end,
        ["get_tank_name"] = function(env)
            local tank_name = "Ceejpaladin"
            return tank_name
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
                print(".. and welcome to :", me, " playing spec :", env:evaluate_variable("myself.spec"))
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
                    -- Our own / generic
                    [6788] = "Weakened Soul",
                    [25771] = "Forbearance",
                    [187464] = "Shadow Mend",
                    [87024] = "Cauterized",
                    [225080] = "Reincarnation",
                    [1604] = "Dazed",
                    -- Undispellable
                    
                    -- Dispellable
                   
                }
            end
            return known_debuffs
        end,
        ["get_curses"] = function(env)
            if (curses == nil) then
                print("creating known curse list...")
                curses = {
                }
            end
            return curses
        end,
        ["get_magics"] = function(env)
            if (magics == nil) then
                print("creating known magics list...")
                magics = {
                   
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
                   
                }
            end
            return poisons
        end,
        ["get_tremors"] = function(env)
            if (tremors == nil) then
                print("creating known tremors list...")
                tremors = {
                }
            end
            return tremors
        end
    },
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
        end,
        murmor_positions = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "PALADIN" then
                env:execute_action("move", {-157.9, -497.3, 15.8})
            elseif player_class == "PRIEST" then
                env:execute_action("move", {-157.9, -476.1, 15.8})
            elseif player_class == "DRUID" then
                env:execute_action("move", {-156.6, -451.4, 17.1})
            elseif player_class == "SHAMAN" then
                env:execute_action("move", {-178.0, -474.9, 18.2})
            elseif player_class == "MAGE" then
                env:execute_action("move", {-135.7, -478.8, 18.2})
            end
        end,
        test_flamestrike = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "MAGE" then
                local main_tank = "ceejpaladin"
                local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(main_tank)
                local pos = {tank_x, tank_y, tank_z}
                local spell = "Flamestrike"
                local args = {["spell"] = spell, ["position"] = pos, ["devoaton"] = 2}
                env:execute_action("cast_ground", args)
            end
        end
    },
    -- Define rotation
    rotations = {
        combat = function(env, is_pulling)
            -- Set up static data
            -- event_frame = env:evaluate_variable("get_singleton_event_frame")
            known_debuffs = env:evaluate_variable("get_known_debuffs")
            known_buffs = env:evaluate_variable("get_known_buffs")
            curses = env:evaluate_variable("get_curses")
            magics = env:evaluate_variable("get_magics")
            diseases = env:evaluate_variable("get_diseases")
            poisons = env:evaluate_variable("get_poisons")
            tremors = env:evaluate_variable("get_tremors")
            party = env:evaluate_variable("get_party")
            main_tank = env:evaluate_variable("get_tank_name")

            eecc = 0
            function get_enemy_count()
                return 0
            end

            function cast_at_target_position(spell, target)
                local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(target)
                print("Target position :[", tank_x, ",", tank_y, ",", tank_z, "]")
                local args = {tank_x, tank_y, tank_z}

                env:execute_action("cast_ground", {["spell"] = spell, ["position"] = args})
                print("Flaming!")
            end

            function thow_more_dots(spell, debuff)
                local more_dots = false
                local min_dot_hp = 1000
                for name, hp in pairs(enemies) do
                    --   print(name, " needs a dot [" .. n .. "]")
                    if (more_dots == false and hp > min_dot_hp) then
                        local dot_duration = env:evaluate_variable("unit.target.debuff." .. debuff)
                        if (dot_duration < 1) then
                            more_dots = true
                            n, r = UnitName(name)
                            print(name, " needs a dot [" .. n .. "]")
                        -- RunMacroText("/cast [" .. name .. "] " .. spell)
                        end
                    end
                end
                return more_dots
            end

            function tremor()
                local _, tremor_cd, _, _ = GetSpellCooldown("Tremor Totem")
                local dispelling = false
                if (dispell_cd == 0 and tremors ~= nil) then
                    for i, player_name in ipairs(party) do
                        for id, name in pairs(tremors) do
                            if (name) then
                                local debuff_duration = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                if (debuff_duration > 0) then
                                    RunMacroText("/s Unleashing the totem to free " .. player_name .. " of " .. name)
                                    dispelling = true
                                end
                            end
                        end
                    end
                end
                if (dispelling) then
                    RunMacroText("/cast Tremor Totem") -- might not need player
                end
                return dispelling
            end

            function dispell(spell, debuff_1, debuff_2, debuff_3)
                local _, dispell_cd, _, _ = GetSpellCooldown(spell)
                local dispelling = false
                if (dispell_cd == 0) then
                    for i, player_name in ipairs(party) do
                        if (debuff_1 ~= nil) then
                            for id, name in pairs(debuff_1) do
                                if (name and dispelling == false) then
                                    local debuff_duration = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                    if (debuff_duration > 0) then
                                        RunMacroText("/s Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                        if (debuff_2 ~= nil) then
                            for id, name in pairs(debuff_2) do
                                if (name and dispelling == false) then
                                    local debuff_duration = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                    if (debuff_duration > 0) then
                                        RunMacroText("/s Dispelling " .. player_name .. " of " .. name)
                                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                                        dispelling = true
                                    end
                                end
                            end
                        end
                        if (debuff_3 ~= nil) then
                            for id, name in pairs(debuff_3) do
                                if name and (dispelling == false) then
                                    local debuff_duration = env:evaluate_variable("unit." .. player_name .. ".debuff." .. id)
                                    if (debuff_duration > 0) then
                                        RunMacroText("/s Dispelling " .. player_name .. " of " .. name)
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

            function cast(spell, target)
                if (target == nil) then
                    if (UnitExists("target") == nil) then
                        target = "target"
                    else
                        print("oops, no target")
                        return faslse
                    end
                end
                -- check spell exists or return false
                local result = env:execute_action("cast", spell)
                -- if (result ~= true) then
                --     local x, y, z = wmbapi.ObjectPosition(target)
                --     env:execute_action("move", {x, y, z})
                -- end
                return result
            end

            function check_for_new_debuffs()
                -- Check for new debuffs
                for _, player_name in ipairs(party) do
                    for i = 1, 5 do
                        local name, _, _, type, duration, _, _, _, _, spellId = UnitDebuff(player_name, i)
                        if (name) then
                            local debuff_present = known_debuffs[spellId]
                            if (debuff_present == nil) then
                                known_debuffs[spellId] = name
                                if (type) then
                                    RunMacroText("/p New debuff found - Name :" .. name .. " id :" .. spellId .. " type: " .. type .. " duration :" .. duration)
                                else
                                    RunMacroText("/p New debuff found - Name :" .. name .. " id :" .. spellId)
                                end
                            end
                        end
                    end
                end
            end

            function check_for_new_buffs()
                -- Check for new buffs
                for _, player_name in ipairs(party) do
                    for i = 1, 10 do
                        local name, _, _, type, duration, _, _, _, _, spellId = UnitBuff(player_name, i)
                        if (name) then
                            local buff_present = known_duffs[spellId]
                            if (buff_present == nil) then
                                known_buffs[spellId] = name
                                RunMacroText("/p New buff found - Name :" .. name .. " id :" .. spellId)
                            end
                        end
                    end
                end
            end

            local _, global_cd, _, _ = GetSpellCooldown("61304")
            local player_class = env:evaluate_variable("myself.class")
            local min_dot_hp = 10

            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            if (global_cd == 0) then
                if player_class == "PALADIN" then -- and player_spec = 66 (prot)
                    -- ** PALADIN ** --
                    eecc = env:evaluate_variable("npcs.attackable.range_8") -- temporay debugging

                    -- A fix for no target spam
                    RunMacroText("/cleartarget [dead][noexists]")
                    if (UnitExists("target") == false) then
                        RunMacroText("/targetenemy [nodead][exists]")
                      --  env:execute_action("target_nearest_enemy")
                    else
                        local dispelling = dispell("Cleanse Toxins", diseases, posions)
                        if (dispelling == false) then
                            local _, hoj_cd = GetSpellCooldown("Hammer of Justice")
                            local _, lotp_cd = GetSpellCooldown("Light Of The Protector")
                            local _, ardent_cd = GetSpellCooldown("Ardent Defender")
                            local _, hands_cd = GetSpellCooldown("Lay on Hands")
                            local _, guardian_cd = GetSpellCooldown("Guardian Of Ancient Kings")
                            local life = env:evaluate_variable("myself.health")

                            -- defensives
                            if (hands_cd == 0 and life < 10) then
                                RunMacroText("/cast [@player] Lay on Hands")
                            elseif (guardian_cd == 0 and life < 40) then
                                RunMacroText("/cast Guardian Of Ancient Kings")
                            elseif (ardent_cd == 0 and life < 60) then
                                RunMacroText("/cast Ardent Defender")
                            elseif (lotp_cd == 0 and life < 70) then
                                RunMacroText("/cast Light Of The Protector")
                            else
                                print("Attackable range 8 :", eecc, " enemy_count:", get_enemy_count()) -- temporay debugging
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
                                if (life < 100 and shield_duration == -1 and shield_charges > 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
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
                    end
                elseif player_class == "PRIEST" then -- and player_spec = 256 (disc)
                    -- ** PRIEST ** --
                    if (UnitExists("target")) then
                        local healing = false
                        local _, penance_cd, _, _ = GetSpellCooldown("Penance")
                        local rapture_duration = env:evaluate_variable("myself.buff.Rapture")

                        -- log out any exiting new buffs and debuffs
                        check_for_new_debuffs(env)
                        -- check_for_new_buffs(env)

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
                                -- Never slack on Schism or Solace
                                local _, schism_cd, _, _ = GetSpellCooldown("Schism")
                                local _, solace_cd, _, _ = GetSpellCooldown("Power Word: Solace")
                                local _, fiend_cd, _, _ = GetSpellCooldown("Shadowfiend")
                                if (schism_cd == 0) then
                                    --cast("Schism")
                                    RunMacroText("/cast Schism")
                                elseif (fiend_cd == 0) then
                                    --RunMacroText("/cast Shadowfiend")
                                    RunMacroText("/cast Shadowfiend")
                                elseif (solace_cd == 0) then
                                    --RunMacroText("/cast Shadowfiend")
                                    RunMacroText("/cast Power Word: Solace")
                                end

                                -- If 3 or more people have taken damage and don't have Atonement cast Radiance (currently seems to double cast, same as druid empowerment)
                                local radiance_charges, _, _, radiance_cd_duration, _ = GetSpellCharges("Power Word: Radiance")
                                if (radiance_charges > 0) then
                                    local sinners = 0
                                    for _, player_name in ipairs(party) do
                                        local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                        local atonement_duration = env:evaluate_variable("unit." .. player_name .. ".buff.atonement")
                                        if (target_hp > 0 and target_hp < 90 and atonement_duration < 3) then
                                            sinners = sinners + 1
                                        end
                                    end
                                    if (sinners > 2) then
                                        healing = true
                                        RunMacroText("/cast Power Word: Radiance")
                                    end
                                end
                                -- ** Loop party members before deciding heal **
                                if (healing == false) then
                                    -- If people have less than 40% hp, panic
                                    health_check = 40
                                    for _, player_name in ipairs(party) do
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
                                for _, player_name in ipairs(party) do
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
                                for _, player_name in ipairs(party) do
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

                                -- Do Damage
                                if (healing == false) then
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
                    else
                        RunMacroText("/assist " .. main_tank)
                    end
                elseif player_class == "DRUID" then -- and player_spec = 102 (balance)
                    -- ** DRUID ** --
                    local dispelling = dispell("Remove Corruption", curses, poisons)

                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local target_hp = env:evaluate_variable("unit.target.health")
                            local moonfire_duration = env:evaluate_variable("unit.target.debuff.Moonfire")
                            local sunfire_duration = env:evaluate_variable("unit.target.debuff.Sunfire")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, alignment_cd, _, _ = GetSpellCooldown("Celestial Alignment")
                            local _, incarnation_cd, _, _ = GetSpellCooldown("Incarnation: Chosen of Elune")
                            local solar_emp_duration = env:evaluate_variable("myself.buff.164545") -- solar
                            local lunar_empduration = env:evaluate_variable("myself.buff.164547") -- lunar
                            local lunar_power = UnitPower("player", 8)
                            --Gets the count of the flying missiles.
                            --count = GetMissileCount()
                            --Gets the info of a specific missile.
                            --spellId, spellVisualId, x, y, z, sourceObject, sourceX, sourceY, sourceZ, targetObject, targetX, targetY, targetZ = GetMissileWithIndex(index)
                            if (target_hp > min_dot_hp and sunfire_duration == -1) then
                                RunMacroText("/cast Sunfire")
                            elseif (target_hp > min_dot_hp and moonfire_duration == -1) then
                                RunMacroText("/cast Moonfire")
                            elseif (alignment_cd == 0) then
                                RunMacroText("/cast Celestial Alignment")
                            elseif (berserking_cd == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (incarnation_cd == 0) then
                                RunMacroText("/cast Incarnation: Chosen of Elune")
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
                elseif player_class == "MAGE" then -- and player_spec = 63 (fire)
                    -- ** MAGE ** --
                    local dispelling = dispell("Remove Curse", curses) or tremor()

                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local hotstreak_duration = env:evaluate_variable("myself.buff.48108")
                            local heating_up_duration = env:evaluate_variable("myself.buff.48107")
                            local combustion_duration = env:evaluate_variable("myself.buff.Combustion")
                            local enemy_count = get_enemy_count()
                            print("Attackable range 8 :", eecc, " enemy_count:", get_enemy_count())

                            local _, fireblast_cd, _, _ = GetSpellCooldown("Fire Blast")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, combustion_cd, _, _ = GetSpellCooldown("Combustion")

                            if (berserking_cd == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (combustion_cd == 0) then
                                RunMacroText("/cast Combustion")
                            elseif (hotstreak_duration > 0) then
                                if (enemy_count > 5) then
                                    cast_at_target_position("Flamestrke", main_tank)
                                else
                                    RunMacroText("/cast Pyroblast")
                                end
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
                            RunMacroText("/assist " .. main_tank) -- perhaps an oops
                        end
                    end
                elseif player_class == "SHAMAN" then -- and player_spec = 262 (elemental)
                    -- ** SHAMAN ** --
                    local dispelling = dispell("Cleanse Spirit", curses)
                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local target_hp = env:evaluate_variable("unit.target.health")
                            local _, flame_shock_cd, _, _ = GetSpellCooldown("188389")
                            local _, earth_elemental_cd, _, _ = GetSpellCooldown("Earth Elemental")
                            local _, fire_elemental_cd, _, _ = GetSpellCooldown("Fire Elemental")
                            local flame_shock_duration = env:evaluate_variable("unit.target.debuff.188389")
                            local maelstrom = UnitPower("player", 11)
                            local lb_charges, _, _, lb_cooldownDuration, _ = GetSpellCharges("Lava Burst")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, guidance_cd, _, _ = GetSpellCooldown("Ancestral Guidance")
                            local _, bloodlust_cd, _, _ = GetSpellCooldown("Bloodlust")
                            -- TODO:
                            -- Check for rebuffing Earth Shield
                            -- Check for defensive Astral Shift
                            -- Check for defensive Thunderstorm
                            -- Check Aoe Chain Lightning
                            -- Check Aoe Earthquake
                            -- Check AoE Capacitor Totem
                            -- Check Tremor Totem (Fear, Charm, Sleep)
                            -- Check Interrupts (Wind Shear)
                            -- Check Dispells (Purge - Magic)
                            if (earth_elemental_cd == 0) then
                                RunMacroText("/cast Earth Elemental")
                            elseif (fire_elemental_cd == 0) then
                                RunMacroText("/cast Fire Elemental")
                            elseif (berserking_cd == 0) then
                                RunMacroText("/cast Berserking")
                            elseif (target_hp > min_dot_hp and flame_shock_duration == -1 and flame_shock_cd == 0) then
                                RunMacroText("/cast Flame Shock")
                            elseif (maelstrom ~= nil and maelstrom >= 90) then
                                RunMacroText("/cast Earth Shock")
                            elseif (lb_charges > 0) then
                                RunMacroText("/cast Lava Burst")
                            elseif (bloodlust_cd == 0) then
                                RunMacroText("/cast Bloodlust") -- probably shouldn't use on CD :/
                            elseif (guidance_cd == 0) then
                                RunMacroText("/cast Ancestral Guidance") -- probably shouldn't use on CD :/
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
            -- ** Constants ** --
            party = env:evaluate_variable("get_party")
            in_combat = env:evaluate_variable("myself.is_in_combat")
            healer_name = env:evaluate_variable("get_healer_name")
            tank_name = env:evaluate_variable("get_tank_name")
            food_name = "Conjured Mana Strudel" -- Mage foods
            food_buff = "167152" -- Replenishment
            
            -- Support Functions - return true if there is work to do
            function release_on_wipe()
                local wipe = true
                for _, player_name in ipairs(party) do
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    if (target_hp > 0) then
                        wipe = false
                    end
                end
                if (wipe) then
                    --release (might need to pause to let others catchup)
                    env:execute_action("release_spirit")
                end
            end

            function check_hybrid(env, res_spell, self_heal)
                --return does_healer_need_mana(env) or need_to_eat(env) or is_anyone_dead(env)
                --need_self_heal(env, self_heal)
                return anyone_need_resing(env, res_spell) or still_resing(env, res_spell) or need_to_eat(env) or does_healer_need_mana(env)
                --or need_mage_food(env)
            end
            function anyone_need_resing(env, spell)
                local reviving = false
                for _, player_name in ipairs(party) do
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    local distance = env:evaluate_variable("unit." .. player_name .. ".distance")
                    if (target_hp == 0 and reviving == false and distance <= 40) then
                        reviving = true
                        RunMacroText("/target " .. player_name)
                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                    -- print("Can't start, " .. player_name .. " still needs resing")
                    end
                end
                if (reviving) then
                end
                return reviving
            end

            function still_resing(env, spell)
                local casting = UnitCastingInfo("player")
                local target = UnitName("target")
                local still_resing = false
                if (casting and target) then -- If we are busy casting, we might not be ready
                    local target_hp = env:evaluate_variable("unit." .. target .. ".health")
                    if (casting == spell and target_hp ~= 0) then
                        print("Aborting uncecessary :", spell, " on target :", target)
                        RunMacroText("/stopcasting")
                        still_resing = true
                        print("Can't start, still need casting res")
                    end
                end
                return still_resing
            end

            function is_anyone_dead(env)
                local dead = false
                for _, player_name in ipairs(party) do
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    if (target_hp == 0) then
                        dead = true
                        print("Can't start, " .. player_name .. " still dead")
                    end
                end
                return dead
            end

            function anyone_need_buffing(env, buff, spell)
                local needs_buff = false
                for _, player_name in ipairs(party) do
                    local buff_duration = env:evaluate_variable("unit." .. player_name .. ".buff." .. buff)
                    local distance = env:evaluate_variable("unit." .. player_name .. ".distance")
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    if (target_hp > 0 and needs_buff == false and buff_duration == -1 and distance < 20) then
                        needs_buff = true
                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                        print("Can't start, " .. player_name .. " still needs buff")
                    end
                end
                return needs_buff
            end

            function do_i_need_buffing(env, spell)
                local needs_buff = false
                local buff_duration = env:evaluate_variable("myself.buff." .. spell)
                local _, buff_cd, _, _ = GetSpellCooldown(spell)
                if (buff_cd == 0 and buff_duration == -1) then
                    needs_buff = true
                    RunMacroText("/cast " .. spell)
                    print("Can't start, I needs a buff")
                end
                return needs_buff
            end

            function tank_needs_buff(env, spell, charges)
                local needs_buff = false
                -- local name, _, count, type, duration, _, _, _, _, spellId = UnitBuff(tank_name, 1, "PLAYER" ) --, "CANCELABLE"
                -- print("You have ".. count .. " charges of " .. name)
                local buff_duration = env:evaluate_variable("unit." .. tank_name .. ".buff." .. spell)
                local distance = env:evaluate_variable("unit." .. tank_name .. ".distance")
                local target_hp = env:evaluate_variable("unit." .. tank_name .. ".health")
                if (target_hp > 0 and buff_duration == -1 and distance < 20) then
                    needs_buff = true
                    RunMacroText("/cast [@" .. tank_name .. "]" .. spell)
                    print("Can't start, tank needs a buff")
                end
                return needs_buff
            end

            function does_healer_need_mana(env)
                local needs_mana = false
                local healer_mana = UnitPower(healer_name, 0)
                local healer_max_mana = UnitPowerMax(healer_name, 0)
                local target_hp = env:evaluate_variable("unit." .. healer_name .. ".health")
                if (target_hp > 0 and healer_max_mana > 0) then
                    local healer_mp = 100 * healer_mana / healer_max_mana
                    if (healer_mp < 80) then
                        needs_mana = true
                    -- print("Can't start, healer needs mana")
                    end
                end
                return needs_mana
            end

            function am_i_dead(env)
                local dead = env:evaluate_variable("myself.life") == 2
                if (dead) then
                    -- Check for mass release
                    AcceptResurrect()
                end
                return dead
            end

            function am_in_combat(env)
                return env:evaluate_variable("myself.is_in_combat")
            end

            function need_self_heal(env, spell)
                local hp = env:evaluate_variable("myself.health")
                local healing = false
                if (hp < 90) then
                    healing = true
                    RunMacroText("/cast [@player] " .. spell)
                    print("Can't start, I need a heal")
                end
                return healing
            end

            function need_to_eat(env)
                local mana = UnitPower("player", 0)
                local max_mana = UnitPowerMax("player", 0)
                local mp = 100 * mana / max_mana
                local thirsty = false
                if (max_mana > 0) then
                    if (mp < 90) then
                        thirsty = true
                        local is_drinking = env:evaluate_variable("myself.buff." .. food_buff)
                        if (is_drinking == -1) then
                            RunMacroText("/use " .. food_name)
                        end
                    end
                end
                return thirsty
            end

            --TODO:
            function need_mage_food(env, food)
                return false
            end


            -- ** General Preparation Code ** --
            release_on_wipe()
            -- Nothing to do if you are dead except accept a res
            if (am_i_dead(env)) then
                return true
            end

            -- Skip preparations if you are in combat
            if (am_in_combat(env)) then
                return false
            end
            -- ** Class Specific Preparation Code ** --
            local player_class = env:evaluate_variable("myself.class")

            if player_class == "PRIEST" then
                -- ** PRIEST ** --
                local res_spell = "Mass Resurrection"
                local buff = "21562"
                local buff_spell = "Power Word: Fortitude"
                local self_heal = "Shadow Mend"
                if (check_hybrid(env, res_spell, self_heal) or anyone_need_buffing(env, buff, buff_spell)) then
                    return true
                end

            elseif player_class == "PALADIN" then
                -- ** PALADIN ** --
                local res_spell = "Redemption"
                local self_heal = "Flash Of Light"
                if (check_hybrid(env, res_spell, self_heal)) then
                    return true
                end

            elseif player_class == "MAGE" then
                -- ** MAGE ** --
                local buff_spell = "Arcane Intellect"
                local buff = "1459"
                local self_buff = "Blazing Barrier"
                if (do_i_need_buffing(env, self_buff) or does_healer_need_mana(env) or is_anyone_dead(env) or anyone_need_buffing(env, buff, buff_spell)) then
                    return true
                end

            elseif player_class == "DRUID" then
                -- ** DRUID ** --
                local res_spell = "Revive"
                local self_heal = "Regrowth"
                if (check_hybrid(env, res_spell, self_heal)) then
                    return true
                end
                RunMacroText("/cast [noform:4] Moonkin Form")

            elseif player_class == "SHAMAN" then
                -- ** SHAMAN ** --
                local res_spell = "Ancestral Spirit"
                local self_heal = "Healing Surge"
                local tank_buff = "Earth Shield"
                local charges = 10
                if (check_hybrid(env, res_spell, self_heal) or tank_needs_buff(env, tank_buff, charges)) then
                    return true
                end
            end
            -- All done, lets go!
            return false
        end
    }
}
