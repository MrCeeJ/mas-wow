return {
    -- Define custom variables.
    variables = {
        ["get_fire_event_frame"] = function(env)
            if (event_frame == nil) then
                print("creating frame of fire...")
                event_frame = CreateFrame("Frame", "event_frame", UIParent) --
                event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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
                if (party_info ~= nil) then
                    for id, name in pairs(party_info) do
                        print("Welcome to :", name)
                        table.insert(party, name)
                    end
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
                    [87023] = "Cauterize",
                    [225080] = "Reincarnation",
                    [1604] = "Dazed",
                    -- Undispellable

                    -- Dispellable
                    -- Blood Furnace
                    [6726] = "Silence",
                    [13338] = "Curse of Tongues",
                    [30937] = "Mark of Shadow",
                    [34969] = "Poison",
                    [30917] = "Poison Bolt",
                    --Steamvault
                    [38660] = "Fear",
                    [31481] = "Lung Burst",
                    [31718] = "Enveloping Winds",
                    -- Shadow Labs
                    [14032] = "Shadow Word: Pain",
                    [32863] = "Seed of Corruption",
                    [51514] = "Hex",
                    [9574] = "Flame Buffet",
                    [33502] = "Brain Wash",
                    [17165] = "Mind Flay",
                    [33487] = "Addle Humanoid",
                    [30615] = "Fear",
                    -- Slave Pens
                    [35760] = "Decayed Strength",
                    [32192] = "Frost Nova",
                    [34984] = "Psychic Horror",
                    [17883] = "Immolate",
                    [32173] = "Engtangling Roots",
                    [36872] = "Deadly Poison",
                    [34780] = "Engtangling Roots",
                    [34780] = "Poison Bolt Volley",
                    [164815] = "Sunfire",
                    [164815] = "Sunfire",
                    [33787] = "Cripple"
                    -- [19134] = "Firghtening Shout",
                    -- [29544] = "Firghtening Shout",
                }
            end
            return known_debuffs
        end,
        ["get_curses"] = function(env)
            if (curses == nil) then
                print("creating known curse list...")
                curses = {
                    [13338] = "Curse of Tongues",
                    [51514] = "Hex"
                }
            end
            return curses
        end,
        ["get_magics"] = function(env)
            if (magics == nil) then
                print("creating known magics list...")
                magics = {
                    -- Blood Furnace
                    [6726] = "Silence",
                    [32197] = "Corruption",
                    [30937] = "Mark of Shadow",
                    -- Steamvault
                    [38660] = "Fear",
                    -- [31481] = "Lung Burst", -- not prio over stun
                    [31718] = "Enveloping Winds",
                    -- Shadow Labs
                    [14032] = "Shadow Word: Pain",
                    [32863] = "Seed of Corruption",
                    [9574] = "Flame Buffet",
                    [33487] = "Addle Humanoid",
                    -- Ramparts
                    [30615] = "Fear",
                    -- Slave Pens
                    [32192] = "Frost Nova",
                    [34984] = "Psychic Horror",
                    [17883] = "Immolate",
                    [32173] = "Engtangling Roots",
                    [164815] = "Sunfire",
                    [33787] = "Cripple"
                }
            end
            return magics
        end,
        ["get_diseases"] = function(env)
            if (diseases == nil) then
                print("creating known diseases list...")
                diseases = {
                    -- Slave Pens
                    [35760] = "Decayed Strength"
                }
            end
            return diseases
        end,
        ["get_poisons"] = function(env)
            if (poisons == nil) then
                print("creating known poisons list...")
                poisons = {
                    -- Blood Furnace
                    [34969] = "Poison",
                    [30917] = "Poison Bolt",
                    -- Slave Pens
                    [36872] = "Deadly Poison",
                    [34780] = "Poison Bolt Volley"
                }
            end
            return poisons
        end,
        ["get_tremors"] = function(env)
            if (tremors == nil) then
                print("creating known tremors list...")
                tremors = {
                    -- Steamvault
                    [38660] = "Fear"
                }
            end
            return tremors
        end,
        ["get_bad_spells"] = function(env)
            if (bad_spells == nil) then
                print("creating known bad spell list...")
                bad_spells = {
                    ["25033"] = "Lightning Cloud ", --Hydromancer Thespia - Steam Vaults
                    ["33617"] = "Rain of Fire", --Grandmaster Vorpil - Shadow Labyrinth
                    ["39363"] = "Rain of Fire", --Grandmaster Vorpil - Shadow Labyrinth Heroic
                    ["24050"] = "Spirit Burst", -- Sethekk Spirit - Sethekk Halls
                    ["30508"] = "Dark Spin", -- Grand Warlock Nethekurse - Shattered Halls
                    ["11990"] = "Rain of Fire", -- Shadowmoon Darkcaster - Shattered Halls
                    ["30979"] = "Flames", --Shattered Halls
                    ["32251"] = "Consumption", -- (Grand Warlock Nethekurse - Shattered Halls
                    ["35057"] = "Netherbomb", -- (Mechanar Tinkerer - Mechanar
                    ["32302"] = "Focus Fire", -- (Shirrak the Dead Watcher - Auchenai Crypts
                    ["38382"] = "Focus Fire", -- (Shirrak the Dead Watcher - Auchenai Crypts - Heroic
                    ["38925"] = "Netherbomb", -- Mechanar Tinkerer - Mechanar Heroic)";
                    ["36583"] = "Charged Fist", -- Tempest-Forge Destroyer - Mechanar)";
                    ["35312"] = "Raging Flames", -- Nethermancer Sepethrea - Mechanar)";
                    ["35283"] = "Inferno", -- Nethermancer Sepethrea - Mechanar)";
                    ["36121"] = "Consumption", -- Zereketh the Unbound - Arcatraz)";
                    ["36717"] = "Energy Discharge", -- Destroyed Sentinel - Arcatraz)";
                    ["38829"] = "Energy Discharge", -- Destroyed Sentinel - Arcatraz Heroic)";
                    ["36175"] = "Whirlwind", -- Dalliah the Doomsayer - Arcatraz)";
                    ["35767"] = "Felfire", -- Wrath-Scryer Soccothrates - Arcatraz
                    ["34358"] = "Vial of Poison", -- Sunseeker Chemist - Botanica)";
                    ["39127"] = "Vial of Poison", -- Sunseeker Chemist - Botanica Heroic)";
                    ["34642"] = "Death and Decay", -- Sunseeker Gene-Splicer - Botanica)";
                    ["39347"] = "Death and Decay", -- Sunseeker Gene-Splicer - Botanica Heroic)";
                    ["34660"] = "Hellfire", -- Thorngrin the Tender - Botanica)";
                    ["39132"] = "Hellfire" -- Thorngrin the Tender - Botanica Heroic
                }
            end
            return bad_spells
        end,
        ["get_safe_locations"] = function(env)
            if (safe_locations == nil) then
                print("creating known safe location list...")
                safe_locations = {
                    {90.0, -326.1, -7.9},
                    {58.5, -323.1, -7.9},
                    {91.3, -306.5, -7.9},
                    {59.3, -303.4, -7.9}
                }
            end
            return safe_locations
        end,
        ["get_priority_targets"] = function(env)
            if (priorities == nil) then
                print("creating known priority targets list...")
                priorities = {
                    "Naga Distiller"
                }
            end
            return priorities
        end,
        ["get_previous_eclipse"] = function(env)
            if (previous_eclipse == nil) then
                previous_eclipse = "Lunar"
            end
            return previous_eclipse
        end,
        ["get_eclipse_charges"] = function(env)
            if (eclipse_charges == nil) then
                eclipse_charges = 0
            end
            return eclipse_charges
        end
    },
    --Custom Actions
    actions = {
        aoe = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "PALADIN" then
                local _, consecration_cd = GetSpellCooldown("Consecration")
                if (consecration_cd == 0) then
                    check_cast("Consecration")
                end
            elseif player_class == "PRIEST" then
                check_cast("Holy Nova")
            elseif player_class == "DRUID" then
                local astral_power = UnitPower("player", 8)
                if (astral_power >= 50) then
                    RunMacroText("/cast [@player]Starfall")
                end
            elseif player_class == "MAGE" then
                local _, blast_wave_cd = GetSpellCooldown("Consecration")
                if (blast_wave_cd == 0) then
                    check_cast("Blast Wave")
                else
                    RunMacroText("/cast [@player]Flame Strike")
                end
            elseif player_class == "SHAMAN" then
                local _, totem_cd = GetSpellCooldown("Capacitor Totem")
                local _, thunderstorm_cd = GetSpellCooldown("Thunderstorm")
                if (totem_cd == 0) then
                    RunMacroText("/cast [@player]Capacitor Totem")
                elseif (thunderstorm_cd == 0) then
                    check_cast("Thunderstorm")
                end
            end
            return false
        end,
        murmor_positions = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "PALADIN" then
                env:execute_action("move", {60.3, -312.0, -7.9})
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
        thespia_positions = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "PALADIN" then
                env:execute_action("move", {-157.9, -497.3, 15.8})
            elseif player_class == "PRIEST" then
                env:execute_action("move", {53.5, -314.5, -7.9})
            elseif player_class == "DRUID" then
                env:execute_action("move", {57.5, -300.0, -8.0})
            elseif player_class == "SHAMAN" then
                env:execute_action("move", {55.7, -325.0, -7.9})
            elseif player_class == "MAGE" then
                env:execute_action("move", {53.5, -314.5, -7.9})
            end
        end,
        quagmire_positions = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "PALADIN" then
                env:execute_action("move", {-149.2, -735.5, 37.9})
            elseif player_class == "PRIEST" then
                env:execute_action("move", {-140.9, -744.4, 37.9})
            elseif player_class == "DRUID" then
                env:execute_action("move", {-152.8, -756.9, 37.9})
            elseif player_class == "SHAMAN" then
                env:execute_action("move", {-146.0, -751.2, 37.9})
            elseif player_class == "MAGE" then
                env:execute_action("move", {-135.2, -733.5, 37.9})
            end
        end,
        mage_food = function(env)
            local player_class = env:evaluate_variable("myself.class")
            if player_class == "MAGE" then
                env:execute_action("cast", "Conjure Refreshment")
            end
        end
    },
    -- Define rotation
    rotations = {
        --------------------------------------------------------------------------------------------------------------------
        ---------------                                          Combat                                      ---------------
        --------------------------------------------------------------------------------------------------------------------
        combat = function(env, is_pulling)
            debug = false
            debug_spells = false
            debug_frame = true
            debug_frame_setup = false
            in_steamvaults = false

            debug_msg = function(override, message)
                if (debug or override) then
                    print("debug: ", tostring(message))
                end
            end
            debug_msg(false, "Begining combat init")
            -- Set up static data
            known_debuffs = env:evaluate_variable("get_known_debuffs")
            known_spells = {
                ["81297"] = "Consecration",
                ["204301"] = "Blessed Hammer",
                ["275779"] = "Judgment",
                ["31935"] = "Avenger's Shield",
                ["53600"] = "Shield Of The Righteous",
                ["17501"] = "Cannon Fire",
                ["585"] = "Smite",
                ["589"] = "SW :P",
                ["214621"] = "Schism",
                ["129250"] = "Solace",
                ["47666"] = "Penance"
            }
            known_buffs = env:evaluate_variable("get_known_buffs")
            curses = env:evaluate_variable("get_curses")
            magics = env:evaluate_variable("get_magics")
            diseases = env:evaluate_variable("get_diseases")
            poisons = env:evaluate_variable("get_poisons")
            tremors = env:evaluate_variable("get_tremors")
            party = env:evaluate_variable("get_party")
            main_tank = env:evaluate_variable("get_tank_name")
            bad_spells = env:evaluate_variable("get_bad_spells")
            safe_locations = env:evaluate_variable("get_safe_locations")
            if (safe_position == nil) then
                safe_position = 1
            end
            if (fire_timer == nil) then
                fire_timer = 0
            end

            if (moving == nil) then
                moving = false
            end

            if (debug or debug_frame_setup) then
                print("Setting up frame ..")
            end
            event_frame = env:evaluate_variable("get_fire_event_frame")

            if (debug_frame_setup) then
                print("Configuring event handler ..")
            end
            if (in_steamvaults) then
                event_frame:SetScript(
                    "OnEvent",
                    function(self, event)
                        -- pass a variable number of arguments
                        self:OnEvent(event, CombatLogGetCurrentEventInfo())
                    end
                )
            end
            if (debug_frame_setup) then
                print(".. registering event handler ..")
            end
            -----------------------------------------------------------
            ----------------------- Event Frame -----------------------
            -----------------------------------------------------------
            function event_frame:OnEvent(event, ...)
                local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
                local spellId, spellName, spellSchool
                local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
                if (subevent == "SPELL_DAMAGE") then --or subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_APPLIED_DOSE" or subevent == "SPELL_AURA_REFRESH") then
                    spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
                    local spell_id = tostring(spellID)
                    local spell_name = tostring(spellName)
                    if (spellID > 0) then
                        -- print("Spell fonud :", spell_id)
                        local spell_present = known_spells[spell_id]
                        if (spell_present == nil) then
                            known_spells[spell_id] = spell_name
                        --  RunMacroText("/p New spell found - Name :" .. spell_name .. " id :" .. spell_id)
                        end
                        if (bad_spells[spell_id]) then
                            if (fire_timer < GetTime()) then
                                fire_timer = GetTime() + 2
                                print("You are stading in the fire, you should probably move.")
                                standing_in_fire = true
                                -- print(".. calling move function.")
                                if (moving) then
                                    print(".. hurry up!")
                                else
                                    move_to_next_safe_location()
                                end
                            end
                        end
                    end
                end
            end

            debug_msg(debug_frame_setup, "finished with event handler ..")

            debug_spell = function(override, message)
                if (debug_spells or override) then
                    print(message)
                end
            end
            debug_msg(false, "Data loaded, defining functions")

            -----------------------------------------------------------
            ------------------------ Targeting ------------------------
            -----------------------------------------------------------

            function get_npc_info()
                --  count = GetNpcCount([center | x, y, z][, range][, rangeOption])
                --npc = GetNpcWithIndex(index)
                local count = GetNpcCount()
                print("There ", " NPCs")
                if (count > 0) then
                    for i = 1, count do
                        print(" NPC: ", GetNpcWithIndex(i))
                    end
                end
            end

            function get_aoe_count()
                if (UnitExists(main_tank)) then
                    local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(main_tank)
                    local x = math.floor(tank_x + 0.5)
                    local y = math.floor(tank_y + 0.5)
                    local z = math.floor(tank_z + 0.5)
                    local args = "npcs.attackable.range_8.center_" .. x .. "," .. y .. "," .. z
                    local enemies = env:evaluate_variable(args)
                    if (enemies) then
                        return enemies
                    end
                end
                return 0
            end

            function cast_at_target_position(spell, target)
                local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(target)
                debug_msg(false, "Target position :[" .. tank_x .. "," .. tank_x .. "," .. tank_z .. "]")
                local pos = {tank_x, tank_y, tank_z}
                local args = {["spell"] = spell, ["position"] = pos}
                env:execute_action("cast_ground", args)
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
                    check_cast("Tremor Totem") -- might not need player
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
                                        if (debug) then
                                            RunMacroText("/s Dispelling " .. player_name .. " of " .. name)
                                        end
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
                                        if (debug) then
                                            RunMacroText("/s Dispelling " .. player_name .. " of " .. name)
                                        end
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
                                        if (debug) then
                                            RunMacroText("/s Dispelling " .. player_name .. " of " .. name)
                                        end
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
            -----------------------------------------------------------
            -------------------    Spell Casting    -------------------
            -----------------------------------------------------------
            function check_cast(spell)
                --name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spellId or "spellName"[, "spellRank"])
                --start, duration, enabled, modRate = GetSpellCooldown("spellName" or spellID or slotID, "bookType")
                if (debug_spells) then
                    print("Attempting to cast :", spell)
                end
                local name, _, _, _, _, _, spellId = GetSpellInfo(spell)
                local result = false
                local message = ""
                if (debug_spells) then
                    print("Spell Id :", spellId, " name :", name)
                end
                if (name == nil) then
                    message = "Warning, cast aborted as you don't know the spell :" .. spell
                else
                    if (debug_spells) then
                        message = "Casting spell: " .. spell .. " with name: " .. name .. " and id: " .. spellId
                    end
                    local _, spell_cd, enabled = GetSpellCooldown(spellId)
                    if (debug_spells) then
                        print("Spell CD :", spell_cd, " enabled :", enabled)
                    end
                    if (enabled == 0) then
                        message = "Warning, cast aborted as spell is already active :" .. spell
                    else
                        if (spell_cd ~= 0) then
                            message = "Warning, cast aborted as spell is currently on cooldown :" .. spell
                        else
                            face = env:execute_action("face_target") -- posible move fix?
                            result = env:execute_action("cast", spellId) --cast_target
                            if (debug_spells) then
                                print("Facing result :", dXW)
                            end
                            if (debug_spells) then
                                print("Spell cast :", spellId)
                            end
                            if (result) then
                                message = "Spell cast succesfuly: " .. spell
                            else
                                message = "Spell attempt failed: " .. spell
                                if (debug_spells) then
                                    print("Spell failed :")
                                    print("Target Distance :")
                                    print("Target LoS :")
                                end
                            end
                        end
                    end
                end
                if (debug) then
                    print(message)
                end
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
                        if (spellId) then
                            local buff_present = known_duffs[spellId]
                            if (buff_present == nil) then
                                known_buffs[spellId] = name
                                RunMacroText("/p New buff found - Name :" .. name .. " id :" .. spellId)
                            end
                        end
                    end
                end
            end

            -----------------------------------------------------------------------
            ---------------------------    Positional Code    ---------------------
            -----------------------------------------------------------------------
            function move_to_next_safe_location()
                if (moving) then
                    -- print("Already moving, target is position :", safe_position)
                    -- local x = math.floor(safe_destination[1] + 0.5)
                    -- local y = math.floor(safe_destination[2] + 0.5)
                    -- local z = math.floor(safe_destination[3] + 0.5)
                    local x = safe_destination[1]
                    local y = safe_destination[2]
                    local z = safe_destination[3]
                    local dest = x .. "," .. y .. "," .. z

                    -- print(".. heading to :[", tostring(dest), "]")

                    local distance = env:evaluate_variable("myself.distance." .. dest)

                    print("Already moving, distance to saftey :", tostring(distance))
                    if (distance < 5) then
                        moving = false
                        print("We made it, next safe position :", safe_position)
                    else
                        print("We should already be moving")
                        -- wmbapi.MoveTo(x,y,z)
                        env:execute_action("terminate_path")
                        env:execute_action("move", safe_destination)
                    end
                else
                    -- print(".. leaving move function.")
                    moving = true
                    print("Run away! heading to safe position:", safe_position)
                    -- get furthest?
                    safe_destination = safe_locations[safe_position]
                    local x = safe_destination[1]
                    local y = safe_destination[2]
                    local z = safe_destination[3]
                    -- wmbapi.MoveTo(x,y,z)
                    env:execute_action("terminate_path")
                    env:execute_action("move", safe_destination)
                    safe_position = safe_position + 1
                    if (safe_position > table.getn(safe_locations)) then
                        safe_position = 1
                        print("Used all the safe positions, round again!:")
                    end
                end
            end

            function check_position_and_move_during_fight(poistion, target)
                position = {185.0, 968.1, 190.8}
                if (env:evaluate_variable("myself.distance." .. position) > 5) then
                    env:execute_action("move", position)
                end
            end

            -------------------------------------------------------------------------------------------------------------------------------------------------------------------
            -------------------------------------------------------------------       General Combat Code    ------------------------------------------------------------------
            -------------------------------------------------------------------------------------------------------------------------------------------------------------------
            local _, global_cd, _, _ = GetSpellCooldown("61304")
            local player_class = env:evaluate_variable("myself.class")
            local min_dot_hp = 10

            -- check_position_and_move_during_fight()
            -- NOTE: Off gcd abilities won't be used until the next free gcd, but they won't trigger gcd so the next ability will happen at the same time
            debug_msg(false, "Taking a look at my feet ...")

            if (moving == true) then
                print("... I appear to be standing in some fire")
                move_to_next_safe_location()
            end

            if (global_cd == 0) then
                debug_msg(false, ".. ready to act")
                if player_class == "PALADIN" then -- and player_spec = 66 (prot)
                    ------------------------------------------------------------------------------------------------------------
                    ---------------                                     Paladin                                  ---------------
                    ------------------------------------------------------------------------------------------------------------
                    if (debug) then
                        print("In paladin, no gcd")
                    end
                    --  eecc = env:evaluate_variable("npcs.attackable.range_8") -- temporay debugging

                    -- A fix for no target spam
                    RunMacroText("/cleartarget [dead][noexists]")
                    if (UnitExists("target") == false) then
                        if (debug) then
                            print(".. no target, fixing")
                        end
                        --  env:execute_action("target_nearest_enemy")
                        RunMacroText("/targetenemy [nodead][exists]")
                    else
                        if (debug) then
                            print(".. Checking for dispels")
                        end
                        local dispelling = dispell("Cleanse Toxins", diseases, posions)
                        if (debug) then
                            print(" .. dispell result :", dispelling)
                        end
                        if (dispelling == false) then
                            if (debug) then
                                print(".. fetching cooldowns")
                            end
                            local _, hoj_cd = GetSpellCooldown("Hammer of Justice")
                            local _, lotp_cd = GetSpellCooldown("Light Of The Protector")
                            -- local _, ardent_cd = GetSpellCooldown("Ardent Defender")
                            local _, hands_cd = GetSpellCooldown("Lay on Hands")
                            -- local _, guardian_cd = GetSpellCooldown("Guardian Of Ancient Kings")
                            local _, divine_protection_cd = GetSpellCooldown("Divine Protection")

                            local life = env:evaluate_variable("myself.health")
                            local holy_power = UnitPower("player", 9)

                            if (debug) then
                                print(".. checking defensives")
                            end
                            -- defensives
                            if (hands_cd == 0 and life < 10) then
                                -- elseif (guardian_cd == 0 and life < 40) then
                                --     check_cast("Guardian Of Ancient Kings")
                                -- elseif (ardent_cd == 0 and life < 60) then
                                --     check_cast("Ardent Defender")
                                -- elseif (lotp_cd == 0 and life < 70) then
                                --     check_cast("Light Of The Protector")
                                RunMacroText("/cast [@player] Lay on Hands")
                            elseif (divine_protection_cd == 0 and life < 80) then
                                check_cast("Divine Protection")
                            elseif (life < 70 and holy_power >= 3) then
                                RunMacroText("/cast [@player] Word of Glory")
                            else
                                --    print("Attackable range 8 :", eecc, " enemy_count:", get_enemy_count()) -- temporay debugging
                                if (debug) then
                                    print(".. loading tank cooldowns")
                                end
                                -- tank rotation
                                local _, avengers_shield_cd = GetSpellCooldown("Avenger's Shield")
                                local _, hammer_cd = GetSpellCooldown("Blessed Hammer")
                                local _, judgment_cd = GetSpellCooldown("Judgment")
                                -- local _, crusader_strike_cd = GetSpellCooldown("Crusader Strike")
                                local _, consecration_cd = GetSpellCooldown("Consecration")
                                local consecration_duration = env:evaluate_variable("myself.buff.Consecration")
                                -- local shield_charges, shield_max_harges, shield_cooldown_start, shield_cooldown_duration, _ = GetSpellCharges("Shield of the Righteous")
                                local shield_duration = env:evaluate_variable("myself.buff.132403") -- 132403 for dmg reduction effect, 53600 for spell
                                if (debug) then
                                    print(".. performing roation")
                                end
                                -- Use shield if we have taken damage and don't have it up
                                if (life < 100 and shield_duration == -1 and holy_power > 2 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
                                    check_cast("Shield of the Righteous")
                                elseif (holy_power == 5) then
                                    check_cast("Shield of the Righteous")
                                elseif (avengers_shield_cd == 0) then
                                    check_cast("Avenger's Shield", "target")

                                    check_cast("Avenger's Shield")
                                elseif (consecration_duration == -1 and consecration_cd == 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
                                    check_cast("Consecration")
                                elseif (hammer_cd == 0) then
                                    check_cast("Blessed Hammer")
                                elseif (judgment_cd == 0) then
                                    check_cast("Judgment")
                                elseif (consecration_cd == 0 and env:evaluate_variable("npcs.attackable.range_8") >= 1) then
                                    check_cast("Consecration")
                                elseif (hoj_cd == 0) then
                                    check_cast("Hammer of Justice")
                                end
                                if (debug) then
                                    print(".. finished paladin code")
                                end
                            end
                        end
                    end
                elseif player_class == "PRIEST" then -- and player_spec = 256 (disc)
                    debug_msg(false, "Priest code")
                    ------------------------------------------------------------------------------------------------------------
                    -----------------------------------------------      Priest     --------------------------------------------
                    ------------------------------------------------------------------------------------------------------------
                    if (UnitExists("target")) then
                        debug_msg(false, ".. have target")

                        local healing = false
                        local _, penance_cd, _, _ = GetSpellCooldown("Penance")
                        local rapture_duration = env:evaluate_variable("myself.buff.Rapture")

                        debug_msg(false, ".. checking debuffs")

                        -- log out any exiting new buffs and debuffs
                        check_for_new_debuffs(env)
                        debug_msg(false, ".. checking buffs")
                        --check_for_new_buffs(env) -- seems crashy
                        debug_msg(false, ".. checking dispells")
                        -- Dispell everyone
                        local dispelling = dispell("Purify", magics, diseases)
                        debug_msg(false, ".. dispelling :" .. tostring(dispelling))
                        if (dispelling == false) then
                            debug_msg(false, ".. not dispelling")
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
                                if (schism_cd == 0 and not moving) then
                                    --cast("Schism")
                                    check_cast("Schism")
                                elseif (fiend_cd == 0) then
                                    --RunMacroText("/cast Shadowfiend")
                                    check_cast("Shadowfiend")
                                elseif (solace_cd == 0) then
                                    --RunMacroText("/cast Shadowfiend")
                                    check_cast("Power Word: Solace")
                                end
                                debug_msg(false, "Sorting on HP")
                                -- check HP
                                -- order_by_hp = function(player_1, player_2)
                                --     local p1_hp = env:evaluate_variable("unit." .. player_1 .. ".health")
                                --     local p2_hp = env:evaluate_variable("unit." .. player_2 .. ".health")
                                --     return p1 < p2
                                -- end
                                table.sort(party, order_by_hp)
                                debug_msg(false, "Sorting finished")
                                debug_msg(false, ".. group healing")
                                -- If 3 or more people have taken damage and don't have Atonement cast Radiance (currently seems to double cast, same as druid empowerment)
                                local radiance_charges, _, _, radiance_cd_duration, _ = GetSpellCharges("Power Word: Radiance")
                                if (radiance_charges > 0 and not moving) then
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
                                        check_cast("Power Word: Radiance")
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
                                                check_cast("Rapture")
                                            elseif (rapture_duration == -1 and pain_suppression_cd == 0) then -- Chuck them a super shield
                                                healing = true
                                                RunMacroText("/cast [target=" .. player_name .. "] Pain Suppression")
                                            end
                                        end
                                    end
                                end
                                debug_msg(false, ".. over 40% healing")
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
                                                elseif (not moving) then
                                                    -- They have had a shield, and they are still below 80, give them a mend
                                                    healing = true
                                                    RunMacroText("/cast [target=" .. player_name .. "]Shadow Mend")
                                                end
                                            end
                                        end
                                    end
                                end
                                debug_msg(false, ".. over 70% healing")

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
                                debug_msg(false, ".. priest go pewpew")
                                -- Do Damage
                                if (healing == false) then
                                    local swpain_duration = env:evaluate_variable("unit.target.debuff.589") -- TODO: Check all in combat targets
                                    local target_health = env:evaluate_variable("unit.target.health")
                                    local _, schism_cd, _, _ = GetSpellCooldown("Schism")
                                    local _, solace_cd, _, _ = GetSpellCooldown("Power Word: Solace")
                                    local _, fiend_cd, _, _ = GetSpellCooldown("Shadowfiend")
                                    local _, death_cd, _, _ = GetSpellCooldown("Shadow Word: Death")
                                    local _, mind_blast_cd, _, _ = GetSpellCooldown("Mind Blast")

                                    local min_swd_hp = 40

                                    if (target_health > min_dot_hp and swpain_duration == -1) then
                                        check_cast("Shadow Word: Pain")
                                    elseif (schism_cd == 0 and not moving) then
                                        check_cast("Schism")
                                    elseif (fiend_cd == 0) then
                                        check_cast("Shadowfiend")
                                    elseif (solace_cd == 0) then
                                        check_cast("Power Word: Solace")
                                    elseif (target_health < min_swd_hp and my_hp > 20 and death_cd == 0) then
                                        check_cast("Shadow Word: Death")
                                    elseif (mind_blast_cd == 0) then
                                        check_cast("Mind Blast")
                                    elseif (penance_cd == 0) then
                                        check_cast("Penance")
                                    elseif (not moving) then
                                        check_cast("Smite")
                                    end
                                end
                            end
                        end
                    else
                        debug_msg(false, ".. don't have target")
                        RunMacroText("/assist " .. main_tank)
                    end
                elseif player_class == "DRUID" then -- and player_spec = 102 (balance)
                    ------------------------------------------------------------------------------------------------------------
                    ---------------                                      Druid                                   ---------------
                    ------------------------------------------------------------------------------------------------------------
                    local dispelling = dispell("Remove Corruption", curses, poisons)
                    -- Check for priority targets
                    RunMacroText("/tar Naga Distiller")
                    RunMacroText("/tar Void Traveler")
                    RunMacroText("/tar Totem")
                    RunMacroText("/tar Ward") -- "Mennu's Healing Ward", "Tainted Stoneskin Totem" Corrupted Nova Totem" "Tainted Earthgrab Totem"
                    RunMacroText("/tar Raging Flames")

                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            -- Check for renewal
                            local my_hp = env:evaluate_variable("myself.health")
                            local _, renewal_cd, _, _ = GetSpellCooldown("Renewal")
                            local renewal_hp = 70
                            local enemy_count = get_aoe_count()

                            local target_hp = env:evaluate_variable("unit.target.health")
                            local moonfire_duration = env:evaluate_variable("unit.target.debuff.Moonfire")
                            local sunfire_duration = env:evaluate_variable("unit.target.debuff.Sunfire")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, alignment_cd, _, _ = GetSpellCooldown("Celestial Alignment") --39
                            local _, incarnation_cd, _, _ = GetSpellCooldown("Incarnation: Chosen of Elune")
                            local _, beam_cd, _, _ = GetSpellCooldown("Solar Beam")
                            local _, rebirth_cd, _, _ = GetSpellCooldown("Rebirth")
                            local solar_emp_duration = env:evaluate_variable("myself.buff.164545") -- solar
                            local lunar_empduration = env:evaluate_variable("myself.buff.164547") -- lunar
                            local astral_power = UnitPower("player", 8)

                            previous_eclipse = env:evaluate_variable("get_previous_eclipse")
                            local lunar_eclipse_duration = env:evaluate_variable("myself.buff.Eclipse (Lunar)")
                            local solar_eclipse_duration = env:evaluate_variable("myself.buff.Eclipse (Solar)")
                            local alignment_eclipse_duration = env:evaluate_variable("myself.buff.Celestial Alignment")
                            local eclipse_charges = env:evaluate_variable("get_eclipse_charges")
                            if (debug) then
                                print(".. counting enemies")
                            end
                            local enemy_count = get_aoe_count()
                            debug_msg(false, "Enemy aoe count : " .. enemy_count)

                            -- check combat res
                            combat_res = false
                            if (rebirth_cd == 0) then
                                for _, player_name in ipairs(party) do
                                    if (combat_res == false) then
                                        local distance = env:evaluate_variable("unit." .. player_name .. ".distance")
                                        local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                        if (target_hp == 0 and distance < 20) then
                                            combat_res = true
                                            print("I should probably res :", player_name)
                                        end
                                    end
                                end
                            end
                            -- barkskin, soothe
                            combat_res = false -- something up with it

                            if (my_hp < renewal_hp and renewal_cd == 0) then
                                check_cast("/cast Renewal")
                            elseif (combat_res) then
                                RunMacroText("/cast [target=" .. player_name .. "] Rebirth")
                            elseif (target_hp > min_dot_hp and sunfire_duration < 1 and eclipse_charges == 0) then
                                check_cast("Sunfire")
                            elseif (target_hp > min_dot_hp and moonfire_duration < 1 and eclipse_charges == 0) then
                                check_cast("Moonfire")
                            elseif (alignment_cd == 0) then
                                check_cast("Celestial Alignment")
                            elseif (berserking_cd == 0) then
                                check_cast("Berserking")
                            elseif (incarnation_cd == 0) then
                                check_cast("Incarnation: Chosen of Elune")
                            elseif (solar_emp_duration > 0 and eclipse_charges == 0) then -- will recast as buff isn't removed until spell lands
                                check_cast("Wrath")
                            elseif (lunar_empduration > 0 and eclipse_charges == 0) then -- will recast as buff isn't removed until spell lands
                                check_cast("Lunar Strike")
                            elseif (alignment_eclipse_duration > 0) then -- Lunar Eclipse
                                if (enemy_count < 2) then
                                    previous_eclipse = "Lunar"
                                    if (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                                        check_cast("Starsurge")
                                    elseif (astral_power >= 50) then
                                        check_cast("Starsurge")
                                    else
                                        check_cast("Wrath")
                                    end
                                else
                                    previous_eclipse = "Solar"
                                    if (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                                        check_cast("Starsurge")
                                    elseif (astral_power >= 50) then
                                        check_cast("Starsurge")
                                    else
                                        check_cast("Starfire")
                                    end
                                end
                            elseif (lunar_eclipse_duration > 0) then -- Lunar Eclipse
                                previous_eclipse = "Lunar"
                                if (enemy_count < 3 and astral_power >= 30 and lunar_eclipse_duration > 6) then
                                    check_cast("Starsurge")
                                elseif (astral_power >= 50) then
                                    cast_at_target_position("Starfall", main_tank)
                                else
                                    check_cast("Starfire")
                                end
                            elseif (solar_eclipse_duration > 0) then -- Solar Eclipse
                                previous_eclipse = "Solar"
                                if (astral_power >= 30 and solar_eclipse_duration > 6) then
                                    check_cast("Starsurge")
                                else
                                    check_cast("Wrath")
                                end
                            elseif (beam_cd == 0) then -- why not :)
                                check_cast("Solar Beam")
                            elseif (sunfire_duration < 6) then -- pandemic dots
                                check_cast("Sunfire")
                            elseif (moonfire_duration < 7) then
                                check_cast("Moonfire")
                            elseif (previous_eclipse == "Solar") then -- Switch to Lunar
                                if (eclipse_charges < 2) then
                                    eclipse_charges = eclipse_charges + 1
                                    check_cast("Wrath")
                                else
                                    eclipse_charges = 0
                                    check_cast("Starfire")
                                end
                            elseif (previous_eclipse == "Lunar") then -- Switch to Solar
                                if (eclipse_charges < 2) then
                                    eclipse_charges = eclipse_charges + 1
                                    check_cast("Starfire")
                                else
                                    eclipse_charges = 0
                                    check_cast("Wrath")
                                end
                            end
                        else
                            RunMacroText("/assist " .. main_tank)
                        end
                    end
                elseif player_class == "MAGE" then -- and player_spec = 63 (fire)
                    ------------------------------------------------------------------------------------------------------------
                    ---------------                                      Mage                                    ---------------
                    ------------------------------------------------------------------------------------------------------------
                    if (debug) then
                        print(".. Mage Code checking curses")
                    end
                    local dispelling = dispell("Remove Curse", curses)
                    -- Check for priority targets
                    RunMacroText("/tar Naga Distiller")
                    RunMacroText("/tar Void Traveler")
                    RunMacroText("/tar Totem")
                    RunMacroText("/tar Raging Flames")
                    if (debug) then
                        print(".. done with curses")
                    end
                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            if (debug) then
                                print(".. dps rotation setup")
                            end
                            local hotstreak_duration = env:evaluate_variable("myself.buff.48108")
                            local heating_up_duration = env:evaluate_variable("myself.buff.48107")
                            local combustion_duration = env:evaluate_variable("myself.buff.Combustion")
                            local power_duration = env:evaluate_variable("myself.buff.Rune of Power")

                            if (debug) then
                                print(".. counting enemies")
                            end
                            local enemy_count = get_aoe_count()
                            debug_msg(false, "Enemy aoe count : " .. enemy_count)
                            local fireblast_charges, _, _, fireblast_cd_duration, _ = GetSpellCharges("Fire Blast")
                            local _, fireblast_cd, _, _ = GetSpellCooldown("Fire Blast")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, combustion_cd, _, _ = GetSpellCooldown("Combustion")
                            local _, rune_cd, _, _ = GetSpellCooldown("Rune Of Power")

                            local phoenix_charges, _, _, phoenix_cd_duration, _ = GetSpellCharges("Phoenix Flames")

                            if (berserking_cd == 0) then
                                check_cast("Berserking")
                            elseif (combustion_cd == 0) then
                                check_cast("Combustion")
                            elseif (rune_cd == 0 and power_duration == -1) then
                                check_cast("Rune of Power")
                            elseif (hotstreak_duration > 0) then
                                if (enemy_count > 2) then
                                    cast_at_target_position("Flamestrike", main_tank)
                                else
                                    check_cast("Pyroblast")
                                end
                            elseif (fireblast_charges > 0 and heating_up_duration > 0) then
                                check_cast("Fire Blast")
                            else
                                if (combustion_duration > 0) then
                                    if (phoenix_charges > 0 and heating_up_duration > 0) then
                                        check_cast("Phoenix Flames")
                                    else
                                        check_cast("Scorch")
                                    end
                                elseif (enemy_count > 5 and ring_of_frost_cd == 0) then
                                    cast_at_target_position("Ring of Frost", main_tank)
                                elseif (power_duration == 0 and phoenix_charges == 1 and phoenix_cd_duration < combustion_cd) then
                                    check_cast("Phoenix Flames")
                                else -- check 2nd phoenix
                                    check_cast("Fireball")
                                end
                            end
                        else
                            RunMacroText("/assist " .. main_tank) -- perhaps an oops
                        end
                    end
                elseif player_class == "SHAMAN" then -- and player_spec = 262 (elemental)
                    ------------------------------------------------------------------------------------------------------------
                    ---------------                                      Shaman                                   ---------------
                    ------------------------------------------------------------------------------------------------------------
                    -- Check for priority targets
                    RunMacroText("/tar Naga Distiller")
                    RunMacroText("/tar Void Traveler")
                    RunMacroText("/tar Totem")
                    RunMacroText("/tar Raging Flames")
                    local dispelling = dispell("Cleanse Spirit", curses) --or tremor()
                    if (dispelling == false) then
                        if (UnitExists("target")) then
                            local target_hp = env:evaluate_variable("unit.target.health")
                            local _, flame_shock_cd, _, _ = GetSpellCooldown("188389")
                            local _, earth_elemental_cd, _, _ = GetSpellCooldown("Earth Elemental")
                            local _, fire_elemental_cd, _, _ = GetSpellCooldown("Fire Elemental")
                            local _, storm_elemental_cd, _, _ = GetSpellCooldown("Storm Elemental")
                            local flame_shock_duration = env:evaluate_variable("unit.target.debuff.188389")
                            local maelstrom = UnitPower("player", 11)
                            local lb_charges, _, _, lb_cooldownDuration, _ = GetSpellCharges("Lava Burst")
                            local _, berserking_cd, _, _ = GetSpellCooldown("Berserking")
                            local _, ancestral_guidance_cd, _, _ = GetSpellCooldown("Ancestral Guidance")
                            local _, bloodlust_cd, _, _ = GetSpellCooldown("Bloodlust")
                            local _, healing_stream_cd, _, _ = GetSpellCooldown("Healing Stream Totem")

                            local lightning_shield_duration = env:evaluate_variable("myself.buff.Lightning Shield")
                            if (debug) then
                                print(".. counting enemies")
                            end
                            local enemy_count = get_aoe_count()
                            debug_msg(false, "Enemy aoe count : " .. enemy_count)
                            -- TODO:
                            -- Check for rebuffing Earth Shield
                            -- Sheck for healing stream

                            -- Check Aoe Earthquake (38)
                            -- Check for defensive Astral Shift (42)
                            -- Check Aoe Chain Lightning (43)
                            -- Check for defensive Tremor Totem (47)

                            -- Check for defensive Thunderstorm (49)

                            -- Check AoE Capacitor Totem ?
                            -- Check Tremor Totem (Fear, Charm, Sleep)
                            -- Check Interrupts (Wind Shear)
                            -- Check Dispells (Purge - Magic)

                            --multidot flameshock
                            -- Check Av HP for Ancestral Guidance healing
                            local total_hp = 0
                            local players = 0
                            for _, player_name in ipairs(party) do
                                local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                                total_hp = total_hp + target_hp
                                if (target_hp > 0) then
                                    players = players + 1
                                end
                            end
                            av_hp = total_hp / players

                            if (healing_stream_cd == 0 and av_hp < 95) then
                                check_cast("Healing Stream Totem")
                            elseif (ancestral_guidance_cd == 0 and av_hp < 80) then
                                check_cast("Ancestral Guidance")
                            elseif (lightning_shield_duration == -1) then
                                check_cast("Lightning Shield")
                            elseif (earth_elemental_cd == 0) then
                                check_cast("Earth Elemental")
                            elseif (storm_elemental_cd == 0) then
                                check_cast("Storm Elemental")
                            elseif (fire_elemental_cd == 0) then
                                check_cast("Fire Elemental")
                            elseif (berserking_cd == 0) then
                                check_cast("Berserking")
                            elseif (target_hp > min_dot_hp and flame_shock_duration < 1 and flame_shock_cd == 0) then
                                check_cast("Flame Shock")
                            elseif (enemy_count > 2 and maelstrom >= 60) then
                                cast_at_target_position("Earthquake", main_tank)
                            elseif (maelstrom ~= nil and maelstrom >= 60) then
                                check_cast("Earth Shock")
                            elseif (lb_cooldownDuration == 0 or lb_charges > 0) then
                                check_cast("Lava Burst")
                            elseif (bloodlust_cd == 0) then
                                check_cast("Bloodlust") -- probably shouldn't use on CD :/
                            elseif (enemy_count > 2) then
                                check_cast("Chain Lightning")
                            else
                                check_cast("Lightning Bolt")
                            end
                        else
                            RunMacroText("/assist " .. main_tank)
                        end
                    end
                end
            elseif (debug) then
                print("Nothing to do, gcd:", global_cd, " moving out of fire :", moving)
            end
        end,
        prepare = function(env)
            ------------------------------------------------------------------------------------------------------------
            ---------------                               Preparation Setup                              ---------------
            ------------------------------------------------------------------------------------------------------------
            debug_msg = function(override, message)
                if (debug or override) then
                    print("debug: ", tostring(message))
                end
            end
            party = env:evaluate_variable("get_party")
            in_combat = env:evaluate_variable("myself.is_in_combat")
            healer_name = env:evaluate_variable("get_healer_name")
            tank_name = env:evaluate_variable("get_tank_name")
            food_name = "Conjured Mana Cake" -- Mage foods

            -- food_name = "Conjured Mana Strudel" -- Mage foods
            --food_name = "Conjured Mana Pie" -- Mage foods
            food_buff = "167152" -- Replenishment
            debug = false
            debug_spells = false
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
                    env:execute_action("set_next_waypoint", 1)
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
                        debug_msg(false, "Can't start, " .. player_name .. " still needs resing")
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
                        debug_msg(false, "Can't start, still need casting res")
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
                        debug_msg(false, "Can't start, " .. player_name .. " still dead")
                    end
                end
                return dead
            end

            function anyone_need_party_buff(env, buff, spell)
                local needs_buff = false
                for _, player_name in ipairs(party) do
                    local buff_duration = env:evaluate_variable("unit." .. player_name .. ".buff." .. buff)
                    local distance = env:evaluate_variable("unit." .. player_name .. ".distance")
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    if (target_hp > 0 and needs_buff == false and buff_duration == -1 and distance < 20) then
                        needs_buff = true
                        RunMacroText("/cast " .. spell)
                        debug_msg(false, "Can't start, " .. player_name .. " still needs buff")
                    end
                end
                return needs_buff
            end

            function anyone_need_individual_buff(env, buff, spell)
                local needs_buff = false
                for _, player_name in ipairs(party) do
                    local buff_duration = env:evaluate_variable("unit." .. player_name .. ".buff." .. buff)
                    local distance = env:evaluate_variable("unit." .. player_name .. ".distance")
                    local target_hp = env:evaluate_variable("unit." .. player_name .. ".health")
                    if (target_hp > 0 and needs_buff == false and buff_duration == -1 and distance < 30) then
                        needs_buff = true
                        RunMacroText("/cast [target=" .. player_name .. "]" .. spell)
                        debug_msg(false, "Can't start, " .. player_name .. " still needs buff")
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
                    debug_msg(false, "Can't start, I needs a buff")
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
                    debug_msg(false, "Can't start, tank needs a buff")
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

            function am_i_dead()
                local dead = env:evaluate_variable("myself.life") == 2
                if (dead) then
                    -- Check for mass release
                    AcceptResurrect()
                end
                return dead
            end

            function am_in_combat()
                return env:evaluate_variable("myself.is_in_combat")
            end

            function need_self_heal(env, spell)
                local hp = env:evaluate_variable("myself.health")
                local healing = false
                if (hp < 90) then
                    healing = true
                    RunMacroText("/cast [@player] " .. spell)
                    debug_msg(false, "Can't start, I need a heal")
                end
                return healing
            end

            function need_to_eat(env)
                local hp = env:evaluate_variable("myself.health")
                local hungry = false
                local mana = UnitPower("player", 0)
                local max_mana = UnitPowerMax("player", 0)
                local mp = 100 * mana / max_mana
                local thirsty = false
                if (hp < 90) then
                    hungry = true
                    local is_drinking = env:evaluate_variable("myself.buff." .. food_buff)
                    if (is_drinking == -1) then
                        RunMacroText("/use " .. food_name)
                    end
                elseif (max_mana > 0) then
                    if (mp < 90) then
                        thirsty = true
                        local is_drinking = env:evaluate_variable("myself.buff." .. food_buff)
                        if (is_drinking == -1) then
                            RunMacroText("/use " .. food_name)
                        end
                    end
                end
                return thirsty or hungry
            end

            --TODO:
            function need_mage_food(env, food)
                return false
            end
            ------------------------------------------------------------------------------------------------------------
            ---------------                                Preparation Code                              ---------------
            ------------------------------------------------------------------------------------------------------------
            release_on_wipe()
            -- Nothing to do if you are dead except accept a res
            if (am_i_dead()) then
                return true
            end

            -- Skip preparations if you are in combat
            if (am_in_combat()) then
                return false
            end
            -- ** Class Specific Preparation Code ** --
            local player_class = env:evaluate_variable("myself.class")

            if player_class == "PRIEST" then
                -- ** PRIEST ** --
                local res_spell = "Mass Resurrection" -- 37
                local res_spell = "Resurrection"
                local party_buff = "21562"
                local party_spell = "Power Word: Fortitude"
                local individual_spell = "Levitate"
                local individual_buff = "Levitate"
                local self_heal = "Shadow Mend"
                if (check_hybrid(env, res_spell, self_heal) or anyone_need_party_buff(env, party_buff, party_spell) or anyone_need_individual_buff(env, individual_buff, individual_spell)) then
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
                local party_spell = "Arcane Intellect"
                local party_buff = "1459"
                -- local individual_spell = "Slow Fall"
                -- local individual_buff = "Slow Fall" --or anyone_need_individual_buff(env, individual_buff, individual_spell
                local self_buff = "Blazing Barrier"
                if (do_i_need_buffing(env, self_buff) or does_healer_need_mana(env) or is_anyone_dead(env) or anyone_need_party_buff(env, party_buff, party_spell)) then
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
                local individual_spell = "Water Walking"
                local individual_buff = "Water Walking"
                local charges = 10
                if (check_hybrid(env, res_spell, self_heal) or tank_needs_buff(env, tank_buff, charges) or anyone_need_individual_buff(env, individual_buff, individual_spell)) then
                    return true
                end
            end
            -- All done, lets go!
            return false
        end
    }
}
