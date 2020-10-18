--[[
	action.duration < 3
	interact({"id":64250,"range":5})
	underBots2
]]
--env:execute_action("mail", {["recipient"] = mailname,["subject"] = subject1,["body"] = "",["item"] = item1});
--[[
MiniBot.WoW.Cli.exe inject -u"mrceej@gmail.com" -p "underBots2" -g "D:\Games\World of Warcraft\_retail_\Wow.exe" -l -s "5"
]]
-- for name, hp in pairs(enemies) do
-- end
--get all targets
--env:evaluate_variable("npcs.attackable.range_10")>=2  -- more than 2 targets in 10 yards
-- if not in LoS, move to tank

-- local enemies = env:evaluate_variable("npcs.all.is_attacking_me")
-- print ("Enemies attacking :", player_class, " : ", enemies)

-- RunMacroText("/targetenemy [nodead][exists]")

-- "/use Piccolo of the Flaming Fire"

                            --Gets the count of the flying missiles.
                            --count = GetMissileCount()
                            --Gets the info of a specific missile.
                            --spellId, spellVisualId, x, y, z, sourceObject, sourceX, sourceY, sourceZ, targetObject, targetX, targetY, targetZ = GetMissileWithIndex(index)

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

local debug_debuffs = true
if (debug_debuffs) then
	if (UnitExists("player")) then
		local aura_count = GetAuraCount("player")
		print(">>>>" .. UnitName("player") .. "<<<<")
		for i = 1, aura_count do
			print(GetAuraWithIndex(i, true))
		end
	end
end
actions = {
	["get_singleton_event_frame"] = function(env)
		if (event_frame == nil) then
			print("creating frame...")
			event_frame = CreateFrame("Frame", "event_frame", UIParent)
			event_frame:RegisterEvent("UNIT_COMBAT")
			event_frame:SetScript("OnEvent", print)
		end
		return event_frame
	end
}
function check_position_and_move_during_fight(poistion, target)
	position = {185.0, 968.1, 190.8}
	if (env:evaluate_variable("myself.distance." .. position) > 5) then
		env:execute_action("move", position)
	end
end

function cast(spell, target)
	-- local target_name = GetUnitName("target")

	-- ," at target :", target
	if (debug_spells) then
		print(".. .. Casting :", spell)
	end
	check_cast(spell)
	-- if (target == nil) then
	--     if (UnitExists("target") == nil) then
	--         target = "target"
	--     else
	--         print("oops, no target")
	--         return faslse
	--     end
	-- end
	-- -- check spell exists or return false
	-- local result = env:execute_action("cast", spell)
	-- -- if (result ~= true) then
	-- --     local x, y, z = wmbapi.ObjectPosition(target)
	-- --     env:execute_action("move", {x, y, z})
	-- -- end
	-- return result
end

function get_enemy_count()
	local count
	local tank_x, tank_y, tank_z = wmbapi.ObjectPosition(main_tank)
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

---------------------------------------------------------------------------------------------------------------
----                  A cycle of reference learning for hunters and cannot be used directly                ----
---------------------------------------------------------------------------------------------------------------
function Split(szFullString, szSeparator) --分割字符串 1.完整字符串 2.分隔符
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
		if not nFindLastIndex then
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
			break
		end
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)
		nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

function PickUp(aDis)
	local Ptr
	repeat
		if GetFreePackNum() <= 3 then
			if PickUpIng() then
				ExeLua("CloseLoot()")
				Sleep(500)
			end
			return true
		end
		if PickUpIng() then
			Sleep(300)
		end
		if PickUpOne() then
			Sleep(300)
		end
		Ptr = GetLootPtr(aDis)
		Print(Ptr)
		if Ptr ~= 0 then
			OpenCTM()
			SetTarget(PtrToGuid(Ptr))
			SetFace(GetFaceByTarget())
			InteractTarget(Ptr)
			Sleep(1500)
		else
			return true
		end
		Sleep(300)
	until false
end

function CallPet(aPetIdx)
	local PetID = 883
	if not aPetIdx then
		aPetIdx = 1
	end
	if aPetIdx == 1 then
		PetID = 883
	else
		PetID = tonumber("8324" .. aPetIdx)
	end
	repeat
		if (ExeLua('UnitHealthMax("pet")') ~= "0") and (ExeLua('UnitHealth("pet")') ~= "0") then
			return true
		else
			CastSpell(PetID)
			Print("开始召唤")
			Sleep(1500)
		end
		if (ExeLua('UnitHealthMax("pet")') == "0") or (ExeLua('UnitHealth("pet")') == "0") then
			CastSpell("982") --复活BB
			Print("开始复活")
			Sleep(1500)
		end
		Sleep(100)
	until false
end

--【脚本式过滤器的写法-得到自己创建的怪列表】
function FilterList_MyCreateUnit(List)
	local MyGuid = PtrToGuid(GetPlayerBase())
	local PtrCreateGuid
	for i = #List, 1, -1 do --倒循环 不然移除元素时会出问题 比如10个成员的表 第2个发现不需要要删除 删除以后第3个元素就会成为第2个元素 循环因为第2个走过就会走第3个元素 原来的第3个元素变为第2个的就会跳过不检查
		PtrCreateGuid = GetPtrCreatedBy(List[i]) --6代亿精灵改了这里
		if PtrCreateGuid ~= MyGuid then --Ptr的创建者不是我
			table.remove(List, i)
		--不是我创建的Ptr就移除
		end
	end
	return List --返回进行移除部分对象的表
end

function GetItemIDFromLink(bag, slot) --返回包中一格位上物品的ID号1.第几个背包 2.包中第几格
	if select("#", ExeLua("GetContainerItemLink(" .. bag .. ", " .. slot .. ")")) == 0 then
		return "0"
	end
	local _, _, ID = ExeLua("string.find(GetContainerItemLink(" .. bag .. ", " .. slot .. "), 'Hitem:(%d+):')")
	return ID
end

function GetItemQuality(bag, slot) --返回包中一格位上物品的ID号1.第几个背包 2.包中第几格
	if select("#", ExeLua("GetContainerItemLink(" .. bag .. ", " .. slot .. ")")) == 0 then
		return "-1"
	end
	local _, _, Quality = ExeLua("GetItemInfo(GetContainerItemLink(" .. bag .. ", " .. slot .. "))")
	return Quality
end

function GetNameByLink(Link) --从Link中取出物品的名字
	local B1 = string.find(Link, "(%[)")
	local E1 = string.find(Link, "(%])")
	return string.sub(Link, B1, E1)
end

function UseItemByID(F_ID) --右键包里一个物品
	local bag, slot, bagNum
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotID = GetItemIDFromLink(bag, slot)
				if alotID == tostring(F_ID) then
					ExeLua("UseContainerItem(" .. bag .. ", " .. slot .. ")")
					Print("使用物品")
					break
				end
			end
		end
	end
end

function SellItemByID(aSellIDList) --售卖指定ID号的物品 1.物品ID字符串用,分隔
	if ExeLua("MerchantFrameCloseButton:IsVisible()") ~= "true" then --检测商人窗口是否已经打开
		return
	end
	local bag, slot, bagNum
	local a = Split(aSellIDList, ",")
	local x = 1
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotID = GetItemIDFromLink(bag, slot)
				if alotID ~= "0" then
					for x = 1, #a do
						if alotID == a[x] then
							ExeLua("UseContainerItem(" .. bag .. ", " .. slot .. ")")
							Sleep(100)
						end
					end
				end
			end
		end
	end
end

function DeleteItemByID(aDeleteIDList) --丢掉指定ID号的物品 1.物品ID字符串用,分隔
	local bag, slot, bagNum
	local a = Split(aDeleteIDList, ",")
	local x = 1
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotID = GetItemIDFromLink(bag, slot)
				if alotID ~= "0" then
					for x = 1, #a do
						if alotID == a[x] then
							ExeLua("PickupContainerItem(" .. bag .. ", " .. slot .. ")")
							ExeLua("DeleteCursorItem()")
							Sleep(100)
						end
					end
				end
			end
		end
	end
end

function SellItemByQuality(aSellQualityList) --售卖指定品质的物品 1.物品品质字符串用,分隔 0灰色 1白色 2绿色 3蓝色 4紫色 6橙色 Sell items of specified quality 1. For item quality strings, separate 0 gray 1 white 2 green 3 blue 4 purple 6 orange
	if ExeLua("MerchantFrameCloseButton:IsVisible()") ~= "true" then --检测商人窗口是否已经打开 -Detect whether the merchant window has been opened
		return
	end
	local bag, slot, bagNum
	local a = Split(aSellQualityList, ",")
	local x = 1
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotQuality = GetItemQuality(bag, slot)
				if alotQuality ~= "-1" then
					for x = 1, #a do
						if alotQuality == a[x] then
							ExeLua("UseContainerItem(" .. bag .. ", " .. slot .. ")")
							Sleep(100)
						end
					end
				end
			end
		end
	end
end

function DeleteItemByQuality(aDeleteQualityList) --丢掉指定品质的物品 1.物品品质字符串用,分隔
	local bag, slot, bagNum
	local a = Split(aDeleteQualityList, ",")
	local x = 1
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotQuality = GetItemQuality(bag, slot)
				if alotQuality ~= "-1" then
					for x = 1, #a do
						if alotQuality == a[x] then
							ExeLua("PickupContainerItem(" .. bag .. ", " .. slot .. ")")
							ExeLua("DeleteCursorItem()")
							Sleep(100)
						end
					end
				end
			end
		end
	end
end

function SellItemByKeepID(aSellKeepIDList) --除保留ID以外其他售卖   1.物品品质字符串用,分隔 --Selling other than the reserved ID 1. For item quality string, separate
	local bag, slot, bagNum
	local a = Split(aSellKeepIDList, ",")
	local x = 1
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotID = GetItemIDFromLink(bag, slot)
				if alotID ~= "0" then
					for x = 1, #a do
						if alotID == a[x] then
						--	goto NotSell;
						end
					end
					ExeLua("UseContainerItem(" .. bag .. ", " .. slot .. ")")
					Sleep(100)
				--	::NotSell::
				end
			end
		end
	end
end

function DeleteItemByKeepID(aDeleteKeepIDList) --除保留ID以外其他删除  1.物品品质字符串用,分隔
	local bag, slot, bagNum
	local a = Split(aDeleteKeepIDList, ",")
	local x = 1
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotID = GetItemIDFromLink(bag, slot)
				if alotID ~= "0" then
					for x = 1, #a do
						if alotID == a[x] then
						--		goto NotDelete;
						end
					end
					ExeLua("PickupContainerItem(" .. bag .. ", " .. slot .. ")")
					ExeLua("DeleteCursorItem()")
					Sleep(100)
				--		::NotDelete::
				end
			end
		end
	end
end

function SendMailItem(RecvMailName, aSendItemList, CODMoney) --邮寄物品 1.收件人角色名 2.要邮寄物品的ID号字符串用,分隔  3.如果是付费邮寄那就收多少G写0或不写表示普通邮寄
	local bag, slot, bagNum, n
	local x = 1
	local a = Split(aSendItemList, ",")
	local n = 0
	if #a <= 0 then
		return
	end
	if RecvMailName == "" then
		return
	end
	ExeLua("MailFrameTab_OnClick(OpenMailFrame,2)")
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotID = GetItemIDFromLink(bag, slot)
				if alotID ~= "0" then
					for x = 1, #a do
						if alotID == a[x] then
							ExeLua("UseContainerItem(" .. bag .. ", " .. slot .. ")")
							Sleep(100)
							n = n + 1
							if n == 12 then
								n = 0
								ExeLua('SendMailNameEditBox:SetText("' .. RecvMailName .. '")')
								ExeLua('SendMailSubjectEditBox:SetText("好东东哦")')
								if (CODMoney) and (CODMoney > 0) then
									ExeLua("SendMailCODButton:Click()")
									ExeLua('SendMailMoneyGold:SetText("' .. CODMoney .. '")')
								end
								ExeLua("SendMailFrame_SendMail()")
								SendMailOkButton()
								Print("发送成功")
								Sleep(1000)
							end
						end
					end
				end
			end
		end
	end
	if n > 0 then --最后一次不满的邮寄走这里
		ExeLua('SendMailNameEditBox:SetText("' .. RecvMailName .. '")')
		ExeLua('SendMailSubjectEditBox:SetText("好东东哦")')
		if (CODMoney) and (CODMoney > 0) then
			ExeLua("SendMailCODButton:Click()")
			ExeLua('SendMailMoneyGold:SetText("' .. CODMoney .. '")')
		end
		ExeLua("SendMailFrame_SendMail()")
		SendMailOkButton()
		Print("最后一次发送成功")
	end
end

function SendMailItemByQuality(RecvMailName, aQualityList, CODMoney) --邮寄物品 1.收件人角色名 2.要邮寄物品的品质字符串用,分隔 3.如果是付费邮寄那就收多少G写0或不写表示普通邮寄
	local bag, slot, bagNum, n
	local x = 1
	local a = Split(aSendItemList, ",")
	local n = 0
	if #a <= 0 then
		return
	end
	if RecvMailName == "" then
		return
	end
	ExeLua("MailFrameTab_OnClick(OpenMailFrame,2)")
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local aQuality = GetItemQuality(bag, slot)
				for x = 1, #a do
					if aQuality == a[x] then
						ExeLua("UseContainerItem(" .. bag .. ", " .. slot .. ")")
						Sleep(100)
						n = n + 1
						if n == 12 then
							n = 0
							ExeLua('SendMailNameEditBox:SetText("' .. RecvMailName .. '")')
							ExeLua('SendMailSubjectEditBox:SetText("好东东哦")')
							if (CODMoney) and (CODMoney > 0) then
								ExeLua("SendMailCODButton:Click()")
								ExeLua('SendMailMoneyGold:SetText("' .. CODMoney .. '")')
							end
							ExeLua("SendMailFrame_SendMail()")
							SendMailOkButton()
							Print("发送成功")
							Sleep(1000)
						end
					end
				end
			end
		end
	end
	if n > 0 then --最后一次不满的邮寄走这里
		ExeLua('SendMailNameEditBox:SetText("' .. RecvMailName .. '")')
		ExeLua('SendMailSubjectEditBox:SetText("好东东哦")')
		if (CODMoney) and (CODMoney > 0) then
			ExeLua("SendMailCODButton:Click()")
			ExeLua('SendMailMoneyGold:SetText("' .. CODMoney .. '")')
		end
		ExeLua("SendMailFrame_SendMail()")
		SendMailOkButton()
		Print("最后一次发送成功")
		Sleep(1000)
	end
end

function SendMailMoney(RecvMailName, LastMoney, DMoney) --邮寄G币 1.收件人角色名 2.要剩余的G数 3.达到多少G时开始邮寄 - Mailing G coins 1. Recipient role name 2. The number of G to be left 3. Start mailing when it reaches the number of G
	if RecvMailName == "" then
		return
	end
	local SendMoney = GetMoney() - LastMoney --身上的G减去要保留的G等于要U的G --The G on the body minus the G to keep is equal to the G to U
	if SendMoney >= DMoney then --要U的G达到了指定数量时开始U -Start U when the G of U reaches the specified number
		ExeLua("MailFrameTab_OnClick(OpenMailFrame,2)")
		ExeLua('SendMailNameEditBox:SetText("' .. RecvMailName .. '")')
		ExeLua('SendMailSubjectEditBox:SetText("jj")')
		ExeLua("SetSendMailMoney(" .. SendMoney .. "0000)") --单位铜 --Unit copper
		ExeLua("SendMailFrame_SendMail()")
		SendMailOkButton()
		ExeLua("CloseMail()")
	end
end

function IsCasting(Unit) --单位是否在读条 --Whether the unit is reading
	if select("#", ExeLua('UnitCastingInfo("' .. Unit .. '")')) > 0 then
		return true
	else
		return false
	end
end

function IsChanneling(Unit) --单位是否在反读条 --Whether the unit is reading the bar in reverse
	if select("#", ExeLua('UnitChannelInfo("' .. Unit .. '")')) > 0 then
		return true
	else
		return false
	end
end

function OutPet() --解散BB
	while ExeLua('UnitHealth("pet")') ~= "0" do
		if not IsCasting("player") then
			CastSpell(2641)
		end
		Sleep(1000)
	end
	ExeLua("SpellStopCasting()") --停止施法
end

function CastSpellBuffExists(SpellID, BuffID, SpellUnit, BuffUnit) --放技能放到BUFF存在
	while BuffExists(BuffID, BuffUnit) ~= 1 do
		CastSpell(SpellID, SpellUnit)
		if Sleep(500) then
			return true
		end
	end
end

function InMount() --上坐骑  推荐用AutoInMount()
	Print("开始上坐骑")
	if ExeLua("MountJournalSummonRandomFavoriteButton") == "nil" then
		Print("第一次上坐骑")
		ExeLua("CollectionsMicroButton:Click()")
		Sleep(100)
		ExeLua("CollectionsMicroButton:Click()")
	end
	while ExeLua("IsMounted()") ~= "true" do
		Print("按Shift+P对你想使用的坐骑右键设置为偏好")
		if not IsCasting("player") then
			ExeLua("MountJournalSummonRandomFavoriteButton:Click()")
		--ExeLua("CallCompanion(\'MOUNT\',"..tostring(Idx)..")");
		end
		Sleep(1000)
	end
end

function DPS_BuffExists(SpellID, BuffID) --当BuffID触发时释放SpellID技能
	local Result = false
	if BuffExists(BuffID) == 1 then
		if CastSpell(SpellID) then
			Result = true
		end
	end
	return Result
end

function GetUnitF_HP(Unit) --得到指定单位的血量百分比(小数) --Get the percentage of blood volume in the specified unit (decimal)
	local HP = tonumber(ExeLua('UnitHealth("' .. Unit .. '")'))
	if HP ~= 0 then
		local MaxHP = tonumber(ExeLua('UnitHealthMax("' .. Unit .. '")'))
		return HP / MaxHP
	else
		return 0
	end
end

function GetUnitF_MP(Unit) --得到指定单位的蓝量百分比(小数) -Get the percentage of blue volume in the specified unit (decimal)
	local MP = tonumber(ExeLua('UnitMana("' .. Unit .. '")'))
	if MP ~= 0 then
		local MaxMP = tonumber(ExeLua('UnitManaMax("' .. Unit .. '")'))
		return MP / MaxMP
	else
		return 0
	end
end

function GetUnitF_XP(Unit) --得到指定单位的经验百分比(小数) --Get the experience percentage (decimal) of the specified unit
	local XP = tonumber(ExeLua('UnitXP("' .. Unit .. '")'))
	if XP ~= 0 then
		local MaxXP = tonumber(ExeLua('UnitXPMax("' .. Unit .. '")'))
		return XP / MaxXP
	else
		return 0
	end
end

function GetUnitF_PP(Unit, PType) --得到指定单位的各种能量百分比(小数) --Get various energy percentages (decimals) in the specified unit
	--[[
if GetUnitF_PP('player',9) >= 0.5 then  --PType 【QS:9 恶魔SS:15 毁灭SS:7 鸟德:8 武僧:15 其它职业自己试1-15】
  Print('QS的能量大于等于50%')
end;
SPELL_POWER_MANA 0 法力
SPELL_POWER_RAGE 1 怒气
SPELL_POWER_FOCUS 2 集中
SPELL_POWER_ENERGY 3 能量
SPELL_POWER_RUNES 5 符文
SPELL_POWER_RUNIC_POWER 6 符文能量
SPELL_POWER_SOUL_SHARDS 7 灵魂碎片
SPELL_POWER_ECLIPSE 8 日月蚀-------已经是nil了
SPELL_POWER_HOLY_POWER 9 圣能
ALTERNATE_POWER_INDEX 10 　　SPELL_POWER_ALTERNATE_POWER 10 
SPELL_POWER_MAELSTROM 11 增强萨满 旋涡值
SPELL_POWER_LIGHT_FORCE 12 真气-------已经是nil了
SPELL_POWER_SHADOW_ORBS 13 暗影宝珠-------已经是nil了
SPELL_POWER_BURNING_EMBERS 14 爆燃灰烬-------已经是nil了
SPELL_POWER_DEMONIC_FURY 15 恶魔之怒-------已经是nil了
]]
	local PP = tonumber(ExeLua("UnitPower('" .. Unit .. "'," .. PType .. ")"))
	Print(PP)
	if PP ~= 0 then
		local MaxPP = tonumber(ExeLua("UnitPowerMax('" .. Unit .. "'," .. PType .. ")"))
		Print(MaxPP)
		return PP / MaxPP
	else
		return 0
	end
end

function WaitingPlayerHP(F_HP) --等等回血 1.玩家血量百分比
	while GetUnitF_HP("player") < F_HP do
		Sleep(500)
	end
end

function GetFreePackNum()
	local bag, slot, bagNum
	local Result = 0
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				local alotID = GetItemIDFromLink(bag, slot)
				if alotID == "0" then
					Result = Result + 1
				end
			end
		end
	end
	return Result
end

function GetMaxPackNum()
	local bag, slot, bagNum
	local Result = 0
	for bag = 0, 4 do
		bagNum = tonumber(ExeLua("GetContainerNumSlots(" .. bag .. ")"))
		if bagNum > 0 then
			for slot = 1, bagNum do
				Result = Result + 1
			end
		end
	end
	return Result
end

function IsLM(Unit)
	if not Unit then
		Unit = "player"
	end
	--中立熊猫人Neutral 联盟Alliance  部落Horde
	if ExeLua('UnitFactionGroup("' .. Unit .. '")') == "Alliance" then
		return true
	else
		return false
	end
end

function DPS_Exit(target, DPSf_HP) --DPS目标时的退出条件
	local NowTarget = GetTarget()
	if NowTarget == "00000000000000000000000000000000" then
		return true
	end --目标无 --No goal
	if target ~= NowTarget then
		return true
	end --目标切换了 --Target switched
	if GetUnitF_HP("target") <= DPSf_HP then
		return true
	end --目标血量打到规定值了 --The target HP reached the specified value
	return false
end

function DPSTarget_20LR(target, DPSF_HP)
	repeat
		if DPS_Exit(target, DPSF_HP) then
			break
		end
		SetFace(GetFaceByTarget())
		--if IsCasting('player') then Print('---1--'); goto RepeatLast end	--在读条中
		if BuffExists(13163, "player") == 0 then
			CastSpell(13163)
			Print("灵猴守护") --Guardian of the Monkey
		--         Líng hóu shǒuhù
		--   4/5000
		--  goto RepeatLast
		end ---灵猴守护
		if DeBuffExists(1978, "target") == 0 then
			CastSpell(1978)
			Print("毒蛇钉刺")
		--	  goto RepeatLast
		end ---毒蛇钉刺存在debuff		 Viper Sting exists debuff
		--CallPet(PetIndex);
		--CastMacro('/petattack');--bb攻击
		if CastSpell(2973) then --猛禽一击 Raptor Strike
			--          Měngqín yī jī
			--       4/5000
			Print("猛禽一击")
		elseif CastSpell(3044) then --奥术射击 Arcane Shot
			Print("奥术射击")
		end
		--	::RepeatLast::
		Sleep(500)
	until false
end

function DPSTarget_DH(target, DPSF_HP) --浩劫
	local TX, TY, TZ
	local Ptr
	repeat
		if DPS_Exit(target, DPSF_HP) then
			break
		end
		SetFace(GetFaceByTarget())
		if IsCasting("player") then
		--	goto RepeatLast
		end --在读条中
		if HasAOE() then --检测手上有AOE技能 或用ExeLua('IsCurrentSpell(189110)') == 'true'要用冷却ID
			Ptr = GuidToPtr(target)
			TX, TY, TZ = GetPtrXYZ(Ptr)
			if (TX ~= 0) and (TY ~= 0) and (TZ ~= 0) then
				CastAOE(TX, TY, TZ)
				Print("地狱火撞击-释放") --Hellfire Crash-Release
			end
		elseif CastSpell(195072, 189110) then --技能ID,冷却ID --Skill ID, Cooldown ID
			Print("地狱火撞击-抓取") --Hellfire Crash-Grab
		elseif CastSpell(162794, 228477) then --技能ID,冷却ID
			Print("灵魂裂劈") --Soul Cleave
		elseif CastSpell(198013, 178740) then --技能ID,冷却ID
			Print("献祭光环") --Sacrifice aura
		elseif CastSpell(203782) then --技能ID和冷却ID一样时只要写一个就行了 --If the skill ID is the same as the cooldown ID, just write one.
			Print("裂魂") --Soul Split
		end
		--	::RepeatLast::
		Sleep(500)
	until false
end

function DPSFilter(DPSFun, DPSF_HP, ObjType, extent, x, y, z, TargetIs, IDStr)
	Print("开始打怪")
	repeat
		local NowTarget = PtrToGuid(GetPtrFromFilter(ObjType, extent, x, y, z, DPSF_HP, 3, TargetIs, IDStr))
		Print("选种怪" .. NowTarget) --Selection Monster
		SetTarget(NowTarget)
		Sleep(1000)
		DPSFun(NowTarget, DPSF_HP)
	until NowTarget == "00000000000000000000000000000000"
	Print("打怪结束") --End of Daguai
end
