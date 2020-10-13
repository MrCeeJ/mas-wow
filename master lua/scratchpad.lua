action.duration < 3
interact({"id":64250,"range":5})


--env:execute_action("mail", {["recipient"] = mailname,["subject"] = subject1,["body"] = "",["item"] = item1});

-- for name, hp in pairs(enemies) do
-- end
--get all targets
--env:evaluate_variable("npcs.attackable.range_10")>=2  -- more than 2 targets in 10 yards
-- if not in LoS, move to tank

-- local enemies = env:evaluate_variable("npcs.all.is_attacking_me")
-- print ("Enemies attacking :", player_class, " : ", enemies)

                        -- RunMacroText("/targetenemy [nodead][exists]")

-- "/use Piccolo of the Flaming Fire"


function get_enemy_count()
    --env:execute_action("move", {-157.9, -497.3, 15.8}) --this works fine
    local count
    local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(main_tank)
    --print("Tank at position :[", tank_x, ",", tank_y, ",", tank_z, "]") -- this also works fine
    local position = {tank_x, tank_y, tank_z}

    -- Which of these methods should I use?
    -- local position = {tank_x,tank_y,tank_z} -- Flamestrike code
    local position = "{" .. tank_x .. "," .. tank_y .. "," .. tank_z .. "}"

    -- local position = "[" .. tank_x .. "," .. tank_y .. "," .. tank_z .. "]"
    -- local position = ""..tank_x..","..tank_y..","..tank_z..""
    -- local position = ""..tank_x..".center_"..tank_y..".center_"..tank_z..""
    --            --print(env.myself:get_distance({2604.52,-543.39,89}));

    local enemies = env:evaluate_variable("npcs.attackable.range_8.center_" .. position) -- Find everyone within 8 yards of tank
    if (enemies == nil) then
        count = 0
    else
        -- print(enemies)
        count = tonumber(enemies)
    end
    --  env.npcs.attackable.center(position)
    -- if(env.myself:get_distance({2604.52,-543.39,89}) >10) then
    -- print("Env calc :", env.npcs.center(position));
    -- end
    return count
end

function get_enemies()
    enemies = {}
    for i = 1, 20 do
        local unit = "nameplate" .. i
        if (env:evaluate_variable("unit." .. unit)) then
            if (UnitAffectingCombat(unit)) then
                local unit_health = UnitHealth(unit)
                if (unit_health) then
                    enemies[unit] = unit_health
                end
            end
        end
    end
    return enemies
end

function is_alive_and_in_range(target, spell)
    local castable = false
    if (spell == nil) then
        range = 40
    else
        range = 40 -- get spel range
    end
    return castable
end
