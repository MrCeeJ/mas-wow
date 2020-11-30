-----------------------------------------------------------
            ----------------------- Event Frame -----------------------
            -----------------------------------------------------------
            debug_msg(debug_frame_setup, 'Configuring event handler ..')
            function event_frame:OnEvent(event, ...)
                local _,
                    subevent,
                    _,
                    sourceGUID,
                    sourceName,
                    sourceFlags,
                    sourceRaidFlags,
                    destGUID,
                    destName,
                    destFlags,
                    destRaidFlags = ...
                local spellID, spellName, spellSchool
                local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
                local playerGUID = UnitGUID('player')
                local me, _ = UnitName('player') --and destName == me

                if
                    (destGUID == playerGUID or destName == me) and
                        (subevent == 'SPELL_DAMAGE' or --) then
                            subevent == 'SPELL_AURA_APPLIED' or
                            subevent == 'SPELL_AURA_APPLIED_DOSE' or
                            subevent == 'SPELL_AURA_REFRESH')
                 then
                    spellID, spellName = select(12, ...)
                    local spell_id = tostring(spellID)
                    local spell_name = tostring(spellName)
                    if (spellID > 0) then
                        if (bad_spells[spell_id] or bad_spells[spell_name]) then
                            debug_msg(debug_movement, 'Standing in Fire!! :' .. spell_name)
                            -- print log event?
                            debug_msg(debug_movement, 'dest Name :' .. tostring(destName))
                            debug_msg(debug_movement, 'dest GUID :' .. tostring(destGUID))
                            RunMacroText('/p um, looks like a :' .. spell_name .. ', lets move!')
                            standing_in_fire = true
                            fire_x, fire_y, fire_z = wmbapi.ObjectPosition('player')
                        end
                    end
                end
            end



            
    -- function count_pets()
    --     --[[ https://wago.io/H18rRiAm7 Braer's Pet Tracker
    --     aura_env.demonTypes = {
    --     ['imp'] = { 196273, 196274, 104317, 196271, 279910 },
    --     ['dreadstalker'] = { 193331, 193332 },
    --     ['darkglare'] = { 205180 },
    --     ['vilefiend'] = { 264119 },
    --     ['tyrant'] = { 265187 },
    --     ['bonus'] = { 267987, 267992, 267991, 267988, 267989, 268001, 267995, 267994, 267996, 235037, 60478, 267986 },
    --     ['grimoire'] = { 111898, 000000, 111896, 000000, 111897, 000000, 111895, 000000, 111859, 000000 },
    --     ['cooldown'] = { 60478, 000000, 1122, 000000},
    --     ['pet'] = { 112870 }
    -- --}
    -- --aura_env.demons = {
    --     -- temporary pets
    --     [196273] = { lifespan = 22, units = {} }, --wild imp 1: improved dreadstalkers
    --     [196274] = { lifespan = 22, units = {} },--wild imp 2: improved dreadstalkers
    --     [104317] = { lifespan = 22, units = {} },--wild imp 1-3: hog
    --     [196271] = { lifespan = 22, units = {} },--wild imp: impending doom
    --     [279910] = { lifespan = 22, units = {} },--wild imp: inner demons
    --     [193331] = { lifespan = 12, units = {} },--dreadstalker1
    --     [193332] = { lifespan = 12, units = {} },--dreadstalker2
    --     [205180] = { lifespan = 12, units = {} },--darkglare
    --      [264119] = { lifespan = 15, units = {} },--vilefiend\
    --      [265187] = { lifespan = 15, units = {} },--demonic tyrant
    --      [267992] = { lifespan = 12, units = {} },--bilescourge: inner/nether   
    --      [267987] = { lifespan = 12, units = {} },--illidari satyr: inner/nether
    --      [267991] = { lifespan = 12, units = {} },--void terror: inner/nether
    --      [267989] = { lifespan = 12, units = {} },--eyes of gul'dan: inner/nether
    --      [267988] = { lifespan = 12, units = {} },--vicious hellhound: inner/nether
    --      [268001] = { lifespan = 15, units = {} },--ur'zul: inner/nether
    --      [267995] = { lifespan = 15, units = {} },--wrathguard: inner/nether
    --      [267994] = { lifespan = 15, units = {} },--shivarra: inner/nether
    --      [267996] = { lifespan = 15, units = {} },--darkhound: inner/nether
    --      [235037] = { lifespan = 15, units = {} },--brittle guardian: inner/nether
    --      [267986] = { lifespan = 15, units = {} },--prince malchezaar: inner/nether
    --      [60478] = { lifespan = 25, units = {} },--doomguard
    --      [000000] = { lifespan = 25, units = {} },--terrorguard NYI?
    --      [1122] = { lifespan = 25, units = {} },--infernal
    --      [000000] = { lifespan = 25, units = {} },--abyssal NYI?
    --      [111859] = { lifespan = 25, units = {} },--g:imp
    --      [000000] = { lifespan = 25, units = {} },--g:fel imp NYI?
    --      [111895] = { lifespan = 25, units = {} },--g:voidwalker
    --      [000000] = { lifespan = 25, units = {} },--g:voidlord NYI?
    --      [111897] = { lifespan = 25, units = {} },--g:felhunter
    --      [000000] = { lifespan = 25, units = {} },--g:observer NYI?
    --      [111896] = { lifespan = 25, units = {} },--g:succubus
    --      [000000] = { lifespan = 25, units = {} },--g:shivarra NYI?
    --      [111898] = { lifespan = 25, units = {} },--g:felguard
    --      [000000] = { lifespan = 25, units = {} },--g:wrathguard NYI?
    --       -- perma pets
    --       -- [112870] = { healthRatio = 0.5, lifespan = 100000, units = {} }
    --     }
    --     -- assign to globals
    --     WA_BRAER_LOCK_PET = 0
    --     WA_BRAER_LOCK_CD = 0
    --     WA_BRAER_LOCK_GRIM = 0
    --     nWA_BRAER_LOCK_IMP = 0\nWA_BRAER_LOCK_DREAD = 0\nWA_BRAER_LOCK_DARK = 0\nWA_BRAER_LOCK_VILE = 0\nWA_BRAER_LOCK_TYRANT = 0\nWA_BRAER_LOCK_BONUS = 0\nWA_BRAER_LOCK_TOTAL = 0\n\nWA_BRAER_IMP_CASTS = 5
    --     aura_env.pguid = UnitGUID(\"player\")
    --     aura_env.count = 0
    --     aura_env.tyrActive = false
    --     aura_env.tyrRemaining = 0
    --     aura_env.AddDemon = function(spellID,destGUID)
    --     iSpellID = spellID
    --     -- if iSpellID == 279910 and not UnitAffectingCombat(\"player\") theniSpellID = 279999\n    end\n    
                    
    --     if aura_env.demons[iSpellID] then
    --         aura_env.demons[iSpellID].units[destGUID] = {}
    --         detail = aura_env.demons[iSpellID].units[destGUID]
    --         detail.dob = GetTime()
    --         -- print(\"Added demon \",iSpellID,\" as \",destGUID)
    --         for _,dID in ipairs(aura_env.demonTypes['imp']) do
    --             if iSpellID == dID then
    --                 detail.energy = 500
    --                 if aura_env.tyrActive then
    --                     detail.dob = detail.dob + (aura_env.tyrRemaining)
    --                     -- print(\"Added \",aura_env.tyrRemaining,\" seconds to imp's time\")
    --                     end
    --                 end
    --             end
    --             -- print(\"added\",iSpellID)
    --         end
    --     end
    --     aura_env.RemoveDemon = function(dID, destGUID)
    --         if dID == 265187 then
    --             aura_env.tyrActive = false
    --             aura_env.tyrRemaining = 0
    --         end
    --         for type, demon in pairs(aura_env.demons) do
    --             for id,_ in pairs(demon.units) do
    --                 if id == destGUID then
    --                     demon.units[destGUID] = nil
    --                     -- print(\"removed\",destGUID)
    --                 end
    --             end
    --         end
    --     end
        
    --     aura_env.implodeImps = function()
    --         for _, demon in ipairs(aura_env.demonTypes['imp']) do
    --             for id,unit in pairs(aura_env.demons[demon].units) do
    --                 aura_env.demons[demon].units[id] = nil
    --             end
    --         end
    --     end
        
    --     aura_env.CountDemonsPerType = function(dtype)
    --         local count = 0
    --         for i, demon in ipairs(aura_env.demonTypes[dtype]) do
    --             for k,v in pairs(aura_env.demons[demon].units) do
    --                 count = count + 1
    --             end
    --         end
    --         return count
    --     end
    --     aura_env.refreshDemons = function()
    --         dTypes = { 'dreadstalker', 'vilefiend', 'bonus', 'grimoire' }
    --         for _, dtype in ipairs(dTypes) do 
    --             for _, demon in ipairs(aura_env.demonTypes[dtype]) do
    --                 for _,detail in pairs(aura_env.demons[demon].units) do
    --                      detail.dob = detail.dob + 15.00
    --                     end
    --                 end
    --             end
    --         end
    --         --]]
    -- end