-- Dav's Gui - The Vampire Legends Hub (Matcha Version) - CU PLAYER ESP OPTIMIZAT
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 1. GET WEBHOOK FROM PASTEBIN
local webhook_url = httpget("https://pastebin.com/raw/RnDJ6pfB")
if webhook_url == "" then
    print("Could not load webhook!")
    return
end

-- 2. GET IDS FROM PASTEBIN
local whitelist_content = httpget("https://pastebin.com/raw/6uksLa4N")
local isAllowed = false

if whitelist_content ~= "" then
    for id in whitelist_content:gmatch("%d+") do
        if tonumber(id) == player.UserId then
            isAllowed = true
            break
        end
    end
end

-- 3. FUNCTION TO SEND TO DISCORD
local function sendLog(title, description, color)
    local embed = {{
        title = title,
        description = description,
        color = color or 16711680,
        footer = { text = "Matcha • " .. os.date("%H:%M:%S") }
    }}
    httppost(webhook_url, HttpService:JSONEncode({embeds = embed}))
end

-- 4. COLLECT INFO (WITH CHECKS)
local executorName, executorVersion = identifyexecutor()
local gameName = getgamename() or "N/A"
local ping = GetPingValue() or 0
local memory = gcinfo() or 0

-- 5. BUILD MESSAGE
local statusText = isAllowed and "Authorized" or "Denied"
local color = isAllowed and 65280 or 16711680

local description = string.format([[
**Player**
Name: %s
Display: %s
ID: `%d`

**Executor**
Name: %s
Version: %s
Ping: %d ms
Memory: %s KB

**Game**
Name: %s
Place ID: `%s`
Job ID: `%s`

**Whitelist**
Status: %s
Verified ID: `%d`

**Time**
%s
]],
    player.Name,
    player.DisplayName or player.Name,
    player.UserId,
    executorName or "N/A",
    executorVersion or "N/A",
    ping,
    memory,
    gameName,
    tostring(game.PlaceId or "N/A"),
    tostring(game.JobId or "N/A"),
    statusText,
    player.UserId,
    os.date("%Y-%m-%d %H:%M:%S")
)

-- 6. SEND TO DISCORD
sendLog(
    isAllowed and "Executed - Authorized" or "Not Whitelisted - Access Denied",
    description,
    color
)

-- 7. STOP IF NOT WHITELISTED
if not isAllowed then
    error("nigger ur not whitelisted")
    return
end

print("a nigger executed")

-- ===== START GUI =====
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui

local win = Lib:CreateWindow({
    title    = "Dav's Gui",
    subtitle = "The Vampire Legends Hub",
    size     = Vector2.new(720, 560),
    menuKey  = "P",
})

-- ===== LOCALIZE EVERYTHING =====
local WorldToScreen = WorldToScreen
local Drawing_new = Drawing.new
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local Color3_fromRGB = Color3.fromRGB
local math_floor = math.floor
local table_concat = table.concat
local pairs = pairs
local ipairs = ipairs
local task_wait = task.wait
local task_spawn = task.spawn
local tick = tick

local P = game:GetService("Players")
local W = game:GetService("Workspace")
local R = game:GetService("RunService")
local LP = P.LocalPlayer
local MY_NAME = LP.Name

-- ===== OPTIONS =====
local Options = {
    EnablePlayerESP = true, MaxDist = 2500,
    ShowSpecies = true, ShowRealName = true, ShowPlayerName = true,
    ShowDistance = true, ShowItems = true,
    EnableToolsESP = true, EnableCureESP = true, ToolsMaxDist = 5000,
    EnablePlantESP = true, PlantMaxDist = 2500,
    ShowPlantName = true, ShowPlantDist = true,
    ShowWolfsbane = true, ShowVampite = true, ShowSenia = true,
    ShowMooncap = true, ShowNightshade = true, ShowAerpine = true,
    ShowYarrow = true, ShowArcanith = true, ShowDerrida = true,
    ShowSanguinia = true, ShowPerennia = true,
    IWOSNotifier = true, CureNotifier = true,
    StaffNotifier = true, NotifDuration = 5,
    UpdateRate = 30,
}

-- ===== DICTIONARIES =====
local N = {["The Hybrid"]="Klaus Mikaelson",["Loyal Sister"]="Rebekah Mikaelson",["Noble Brother"]="Elijah Mikaelson",["Lost Sister"]="Freya Mikaelson",["sis"]="Freya Mikaelson",["The Miracle"]="Hope Mikaelson",["The Imposter"]="Katherine Pierce",["The Ripper"]="Stefan Salvatore",["The Sarcastic"]="Damon Salvatore",["Town Witch"]="Bonnie Bennett",["Attic Witch"]="Davina Claire",["The Muse"]="Cleo Sowande",["Ancient Witch"]="Qetsiyah",["The King"]="Marcel Gerard",["The Trickster"]="Silas",["The Phoenix"]="Landon Kirby",["The Headmaster"]="Alaric Saltzman",["The Hunter"]="Jeremy Gilbert",["The Mentor"]="Alexia Branson",["The Control Freak"]="Caroline Forbes",["Original Witch"]="Esther Mikaelson",["The Sociopath"]="Malachi Kai Parker",["The Doppelganger"]="Elena Gilbert",["Alpha Wolf"]="Jackson Kenner",["Quarterback"]="Tyler Lockwood",["Crescent Queen"]="Hayley Marshall-Kenner",["First Bloodwitch"]="Valerie Tulle",["The Anchor"]="Amara",["The Friend"]="Matt Donovan",["The Therapist"]="Camille O'Connor",["The Sheriff"]="Liz Forbes",["The Guardian"]="Jenna Sommers",["The Mayor"]="Carol Lockwood",["The Fairy"]="Wade Rivers",["Silent Bloodwitch"]="Beau",["The Nerd"]="Milton MG Greasley",["The Dragon"]="Kaleb Hawkins",["The Charmer"]="Damon Salvatore",["Siphoner Witch"]="Josie Saltzman",["Siphoner Twin"]="Lizzie Saltzman",["Dark Siphoner"]="Dark Josie",["Viking Warrior"]="Mikael Mikaelson",["Deranged Brother"]="Kol Mikaelson",["Outcast Brother"]="Finn Mikaelson",["The Lover"]="Sage",["The Selfish"]="Isobel Flemming",["Troubled Girl"]="Vicki Donovan",["The Loyal"]="Joshua Josh Rosza",["The Runaway"]="Rose",["The Fierce Protector"]="Pearl Zhu",["Adoptive Mother"]="Lily Salvatore",["The Rebellious"]="Annabelle Zhu",["The Traveler"]="Nadia Petrova",["The Firstborn"]="Lucien Castle",["The Assassin"]="Aya Al-Rashid",["The Unhinged"]="Aurora De Martel",["The Leader"]="Tristan De Martel",["The Merciless"]="Sebastian The Merciless",["The Obsessed"]="Roman",["Coven Ancestor"]="Genevieve",["Ritual Leader"]="Bastianna Natale",["Fortune Teller"]="Agnes",["Regent"]="Josephine LaRue",["Voodoo King"]="Papa Tunde",["Ancestral Guardian"]="Vincent Griffith",["The Doctor"]="Josette Jo Parker",["Lost Twin"]="Olivia Parker",["Protective Twin"]="Luke Parker",["Popular Girl"]="Alyssa Chang",["The Sacrifice"]="Monique Deveraux",["Quarter Witch"]="Sophie Deveraux",["Cousin"]="Lucy Bennett",["Grandmother"]="Sheila Bennett",["Absent Mother"]="Abby Bennett",["Vengeful Spirit"]="Celeste Dubois",["Manipulative Father"]="Jonas Martin",["The Pawn"]="Luca Martin",["Devious Bloodwitch"]="Mary Louise",["Arrogant Bloodwitch"]="Nora Hildegard",["Carefree Bloodwitch"]="Oscar",["Vengeful Bloodwitch"]="Malcolm",["Charismatic Wolf"]="Rafael Waithe",["Shy Wolf"]="Aiden",["Smart Wolf"]="Keelin Malraux",["Deceptive Wolf"]="Mason Lockwood",["Fearful Wolf"]="Finch Tarrayo",["Arrogant Wolf"]="Jules",["Confident Wolf"]="Jed",["Original Hybrid"]="Klaus Mikaelson",["Enzo St. John"]="Lorenzo Enzo St. John",["Klaus Mikaelson"]="Klaus Mikaelson",["Rebekah Mikaelson"]="Rebekah Mikaelson",["Elijah Mikaelson"]="Elijah Mikaelson",["Freya Mikaelson"]="Freya Mikaelson",["Hope Mikaelson"]="Hope Mikaelson",["Esther Mikaelson"]="Esther Mikaelson",["Marcel Gerard"]="Marcel Gerard",["Katherine Pierce"]="Katherine Pierce",["Stefan Salvatore"]="Stefan Salvatore",["Damon Salvatore"]="Damon Salvatore",["Caroline Forbes"]="Caroline Forbes",["Alexia Branson"]="Alexia Branson",["Bonnie Bennett"]="Bonnie Bennett",["Davina Claire"]="Davina Claire",["Cleo Sowande"]="Cleo Sowande",["Qetsiyah"]="Qetsiyah",["Malachi Kai Parker"]="Malachi Kai Parker",["Josie Saltzman"]="Josie Saltzman",["Lizzie Saltzman"]="Lizzie Saltzman",["Dark Josie"]="Dark Josie",["Silas"]="Silas",["Amara"]="Amara",["Landon Kirby"]="Landon Kirby",["Alaric Saltzman"]="Alaric Saltzman",["Jeremy Gilbert"]="Jeremy Gilbert",["Elena Gilbert"]="Elena Gilbert",["Matt Donovan"]="Matt Donovan",["Tyler Lockwood"]="Tyler Lockwood",["Hayley Marshall-Kenner"]="Hayley Marshall-Kenner",["Jackson Kenner"]="Jackson Kenner",["Valerie Tulle"]="Valerie Tulle",["Beau"]="Beau",["Dahlia"]="Dahlia",["Jules"]="Jules",["Rose"]="Rose",["Sage"]="Sage",["Jed"]="Jed",["Aiden"]="Aiden",["Mason Lockwood"]="Mason Lockwood",["Keelin Malraux"]="Keelin Malraux",["Rafael Waithe"]="Rafael Waithe",["Finch Tarrayo"]="Finch Tarrayo",["Milton MG Greasley"]="Milton MG Greasley",["Kaleb Hawkins"]="Kaleb Hawkins",["Lily Salvatore"]="Lily Salvatore",["Vicki Donovan"]="Vicki Donovan",["Joshua Josh Rosza"]="Joshua Josh Rosza",["Annabelle Zhu"]="Annabelle Zhu",["Pearl Zhu"]="Pearl Zhu",["Isobel Flemming"]="Isobel Flemming",["Lucien Castle"]="Lucien Castle",["Aya Al-Rashid"]="Aya Al-Rashid",["Aurora De Martel"]="Aurora De Martel",["Tristan De Martel"]="Tristan De Martel",["Sebastian The Merciless"]="Sebastian The Merciless",["Nadia Petrova"]="Nadia Petrova",["Roman"]="Roman",["Genevieve"]="Genevieve",["Bastianna Natale"]="Bastianna Natale",["Agnes"]="Agnes",["Josephine LaRue"]="Josephine LaRue",["Papa Tunde"]="Papa Tunde",["Vincent Griffith"]="Vincent Griffith",["Josette Jo Parker"]="Josette Jo Parker",["Olivia Parker"]="Olivia Parker",["Luke Parker"]="Luke Parker",["Alyssa Chang"]="Alyssa Chang",["Monique Deveraux"]="Monique Deveraux",["Sophie Deveraux"]="Sophie Deveraux",["Lucy Bennett"]="Lucy Bennett",["Sheila Bennett"]="Sheila Bennett",["Abby Bennett"]="Abby Bennett",["Celeste Dubois"]="Celeste Dubois",["Jonas Martin"]="Jonas Martin",["Luca Martin"]="Luca Martin",["Mary Louise"]="Mary Louise",["Nora Hildegard"]="Nora Hildegard",["Oscar"]="Oscar",["Malcolm"]="Malcolm",["Camille O'Connor"]="Camille O'Connor",["Jenna Sommers"]="Jenna Sommers",["Carol Lockwood"]="Carol Lockwood",["Liz Forbes"]="Liz Forbes",["Wade Rivers"]="Wade Rivers",["Mikael Mikaelson"]="Mikael Mikaelson",["Kol Mikaelson"]="Kol Mikaelson",["Finn Mikaelson"]="Finn Mikaelson",["Luna"]="Luna",["Marina"]="Marina",["Raven"]="Raven",["TheGrinch"]="TheGrinch",["TheDeer"]="TheDeer",["Elora"]="Elora",["Valeria"]="Valeria",["DataSigh"]="DataSigh",["Emchikuwu"]="Emchikuwu",["Kardashszn"]="Kardashszn",["Halohashira"]="Halohashira",["ChowLlama"]="ChowLlama",["AnimateWithRick"]="AnimateWithRick",["agussts_13"]="agussts_13",["HayleyMarshallKenner"]="HayleyMarshallKenner",["SebastianTheMerciless"]="SebastianTheMerciless",["MiltonMGGreasley"]="MiltonMGGreasley",["JoshuaJoshRosza"]="JoshuaJoshRosza",["LorenzoEnzoStJohn"]="LorenzoEnzoStJohn",["CamilleOConnor"]="CamilleOConnor",["MalachiKaiParker"]="MalachiKaiParker",["JosetteJoParker"]="JosetteJoParker",["PenelopePark"]="PenelopePark"}

-- ===== SPECIES DICTIONARY =====
local S = {
    Firstblood = "Original",
    Triblood = "Tribrid",
    Bloodwitch = "Heretic",
    Heretic = "Heretic",
    Vampire = "Vampire",
    Werewolf = "Werewolf",
    Witch = "Witch",
    ["Ancestor-Witch"] = "Witch",
    ["AncestorWitch"] = "Witch",
    ["Ancestor Witch"] = "Witch",
    Hybrid = "Hybrid",
    Mortal = "Mortal",
    Hunter = "Hunter",
    Phoenix = "Phoenix",
    Immortal = "Immortal",
    Siphoner = "Siphoner",
    Muse = "Muse",
    Fairy = "Fairy",
    Werewitch = "Werewitch",
    Original = "Original",
    Tribrid = "Tribrid",
    Possessed = "Possessed"
}

-- ===== SPECIES COLORS =====
local SPECIES_COLORS = {
    Vampire = Color3_fromRGB(196, 30, 58),
    Werewolf = Color3_fromRGB(249, 228, 103),
    Witch = Color3_fromRGB(195, 145, 195),
    Original = Color3_fromRGB(154, 42, 42),
    Hybrid = Color3_fromRGB(245, 185, 102),
    Heretic = Color3_fromRGB(188, 101, 169),
    Mortal = Color3_fromRGB(193, 225, 193),
    Phoenix = Color3_fromRGB(223, 129, 96),
    Hunter = Color3_fromRGB(120, 199, 114),
    Tribrid = Color3_fromRGB(182, 208, 226),
    Immortal = Color3_fromRGB(126, 53, 248),
    Siphoner = Color3_fromRGB(114, 147, 202),
    Muse = Color3_fromRGB(254, 194, 14),
    Fairy = Color3_fromRGB(254, 194, 14),
    Werewitch = Color3_fromRGB(201, 69, 150),
    Firstblood = Color3_fromRGB(178, 58, 64),
    Triblood = Color3_fromRGB(135, 206, 235),
    Bloodwitch = Color3_fromRGB(188, 101, 169),
    Possessed = Color3_fromRGB(255, 215, 0),
    Default = Color3_fromRGB(255, 255, 255),
}

-- ===== NOTIFICATION =====
local function notify(message, title, duration)
    Lib:Notify(title or "Dav's Gui", message, duration or 5)
end

-- ===== FUNCTIE PENTRU A VERIFICA DACĂ ESTE BODY JUMPED =====
local function CheckIfBodyJumped(plr)
    if not plr then return false end
    local char = plr.Character
    if char then
        if plr:GetAttribute("BodyJumped") then
            local jumpedBy = plr:GetAttribute("BodyJumpedBy")
            if jumpedBy == "Esther Mikaelson" then return true end
        end
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("BasePart") and child.Name == "PossessionMarkPart" then return true end
        end
        if char:FindFirstChild("BodyJumped") then return true end
    end
    return false
end

-- ===== FUNCTIE PENTRU A VERIFICA DACĂ JUCĂTORUL ESTE QETSIYAH =====
local function IsQetsiyah(plr)
    if not plr then return false end
    local charName = plr:GetAttribute("CharacterName")
    if charName == "Qetsiyah" or charName == "Ancient Witch" then return true end
    local char = plr.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("BillboardGui") then
                    for _, label in pairs(child:GetDescendants()) do
                        if label:IsA("TextLabel") and label.Text == "Qetsiyah" then return true end
                    end
                end
            end
        end
    end
    return false
end

-- ===== CACHE SYSTEM =====
local PlayerCache = {}
local ItemCache = {}
local PlantCache = {}
local IWOSCache = {}
local CureCache = {}
local CureData = nil
local TextCache = {}
local BodyJumpedCache = {}
local QetsiyahCache = {}

-- ===== UI SETUP =====
local Visuals = win:Tab("Visuals", "eye")
local Notifiers = win:Tab("Notifiers", "bell")
win:AddSettingsTab("cog")

local PlayerESP = Visuals:Section("Player ESP", "Left")
PlayerESP:Toggle("Enable Player ESP", Options.EnablePlayerESP, function(on) Options.EnablePlayerESP = on; notify("Player ESP " .. (on and "enabled" or "disabled"), "ESP", 2) end)
PlayerESP:Slider("Max Distance", Options.MaxDist, 500, 500, 5000, "s", function(v) Options.MaxDist = v end)
PlayerESP:Slider("Update Rate (FPS)", Options.UpdateRate, 10, 5, 60, "fps", function(v) Options.UpdateRate = v end)

local ToolsESP = Visuals:Section("Tools ESP", "Left")
ToolsESP:Toggle("Enable IWOS ESP", Options.EnableToolsESP, function(on) Options.EnableToolsESP = on; notify("IWOS ESP " .. (on and "enabled" or "disabled"), "ESP", 2) end)
ToolsESP:Toggle("Enable Cure ESP", Options.EnableCureESP, function(on) Options.EnableCureESP = on; notify("Cure ESP " .. (on and "enabled" or "disabled"), "ESP", 2) end)
ToolsESP:Slider("Max Distance", Options.ToolsMaxDist, 500, 500, 10000, "s", function(v) Options.ToolsMaxDist = v end)

ToolsESP:Button("Check IWOS", function()
    if #IWOSCache > 0 then
        notify("IWOS found on map! (" .. #IWOSCache .. " total)", "IWOS Check", 3)
        local lr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        for _, rt in ipairs(IWOSCache) do
            if rt and rt.Position and lr then
                local dist = math_floor((rt.Position - lr.Position).Magnitude + 0.5)
                notify("IWOS Distance: " .. dist .. "s", "IWOS Check", 5)
            end
        end
    else
        notify("No IWOS found on map", "IWOS Check", 3)
    end
end)

ToolsESP:Button("Check Cure", function()
    if #CureCache > 0 then
        notify("Cure found on map! (" .. #CureCache .. " total)", "Cure Check", 3)
        local lr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        for _, rt in ipairs(CureCache) do
            if rt and rt.Position and lr then
                local dist = math_floor((rt.Position - lr.Position).Magnitude + 0.5)
                notify("Cure Distance: " .. dist .. "s", "Cure Check", 5)
            end
        end
    else
        notify("No Cure found on map", "Cure Check", 3)
    end
end)

local ESPFeatures = Visuals:Section("ESP Features", "Right")
ESPFeatures:Toggle("Show Species", Options.ShowSpecies, function(on) Options.ShowSpecies = on end)
ESPFeatures:Toggle("Show Character Name", Options.ShowRealName, function(on) Options.ShowRealName = on end)
ESPFeatures:Toggle("Show Player Name", Options.ShowPlayerName, function(on) Options.ShowPlayerName = on end)
ESPFeatures:Toggle("Show Distance", Options.ShowDistance, function(on) Options.ShowDistance = on end)
ESPFeatures:Toggle("Show Backpack Items", Options.ShowItems, function(on) Options.ShowItems = on end)

local PlantESP = Visuals:Section("Plant ESP", "Left")
PlantESP:Toggle("Enable Plant ESP", Options.EnablePlantESP, function(on) Options.EnablePlantESP = on; notify("Plant ESP " .. (on and "enabled" or "disabled"), "ESP", 2) end)
PlantESP:Slider("Max Distance", Options.PlantMaxDist, 500, 500, 5000, "s", function(v) Options.PlantMaxDist = v end)

local PlantFeatures = Visuals:Section("Plant Features", "Right")
PlantFeatures:Toggle("Show Plant Name", Options.ShowPlantName, function(on) Options.ShowPlantName = on end)
PlantFeatures:Toggle("Show Plant Distance", Options.ShowPlantDist, function(on) Options.ShowPlantDist = on end)

local PlantTypes = Visuals:Section("Plant Types", "Full")
PlantTypes:Toggle("WolfsbanePlant", Options.ShowWolfsbane, function(on) Options.ShowWolfsbane = on end)
PlantTypes:Toggle("VampitePlant", Options.ShowVampite, function(on) Options.ShowVampite = on end)
PlantTypes:Toggle("SeniaPlant", Options.ShowSenia, function(on) Options.ShowSenia = on end)
PlantTypes:Toggle("MooncapPlant", Options.ShowMooncap, function(on) Options.ShowMooncap = on end)
PlantTypes:Toggle("NightshadePlant", Options.ShowNightshade, function(on) Options.ShowNightshade = on end)
PlantTypes:Toggle("AerpinePlant", Options.ShowAerpine, function(on) Options.ShowAerpine = on end)
PlantTypes:Toggle("YarrowPlant", Options.ShowYarrow, function(on) Options.ShowYarrow = on end)
PlantTypes:Toggle("ArcanithPlant", Options.ShowArcanith, function(on) Options.ShowArcanith = on end)
PlantTypes:Toggle("DerridaPlant", Options.ShowDerrida, function(on) Options.ShowDerrida = on end)
PlantTypes:Toggle("SanguiniaPlant", Options.ShowSanguinia, function(on) Options.ShowSanguinia = on end)
PlantTypes:Toggle("PerenniaPlant", Options.ShowPerennia, function(on) Options.ShowPerennia = on end)

local NotifSection = Notifiers:Section("Notifiers", "Left")
NotifSection:Toggle("IWOS Notifier", Options.IWOSNotifier, function(on) Options.IWOSNotifier = on; notify("IWOS Notifier " .. (on and "enabled" or "disabled"), "Notifier", 2) end)
NotifSection:Toggle("Cure Notifier", Options.CureNotifier, function(on) Options.CureNotifier = on; notify("Cure Notifier " .. (on and "enabled" or "disabled"), "Notifier", 2) end)
NotifSection:Slider("Notification Duration", Options.NotifDuration, 1, 1, 15, "s", function(v) Options.NotifDuration = v end)

local StaffSection = Notifiers:Section("Staff Notifier", "Left")
StaffSection:Toggle("Staff Notifier", Options.StaffNotifier, function(on) Options.StaffNotifier = on; notify("Staff Notifier " .. (on and "enabled" or "disabled"), "Notifier", 2) end)

local settingsSection = win:SettingsSection("Menu", "Left")
settingsSection:Button("Unload", function()
    Lib:Dialog({title = "Unload?", text = "Remove Dav's Gui from the game?", confirm = "Unload", onConfirm = function()
        RenderConnection:Disconnect()
        notify("Dav's Gui has been unloaded", "Goodbye!", 3); task_wait(3); Lib:Destroy()
    end})
end)

-- ===== ITEM HELPER =====
local function GetItemsFromPlayer(plr)
    local items = {}
    local function check(obj)
        if not obj then return end
        local n = obj.Name
        if n == "TheCure" then
            items[#items + 1] = "Cure"
        elseif n == "QetsiyahCure" then
            if IsQetsiyah(plr) then
                items[#items + 1] = "QetCure"
            end
        elseif n:find("RedOak") then
            items[#items + 1] = "RedOak"
        elseif n:find("WhiteOak") and not n:find("Indestructible") then
            items[#items + 1] = "WhiteOak"
        elseif n:find("Indestructible") then
            items[#items + 1] = "IWOS"
        end
    end
    local bp = plr:FindFirstChild("Backpack")
    local char = plr.Character
    if bp then for _, t in pairs(bp:GetChildren()) do check(t) end end
    if char then for _, t in pairs(char:GetChildren()) do if t:IsA("Tool") then check(t) end end end
    return items
end

-- ===== CACHE UPDATE FUNCTIONS (FĂRĂ SELF) =====
local function UpdatePlayerCache()
    local fd = W:FindFirstChild("PlayerNameTagFolder")
    if not fd then return end
    local new = {}
    local newTextCache = {}
    
    for _, t in pairs(fd:GetChildren()) do
        if t:IsA("BillboardGui") then
            local tx = {}
            for _, c in pairs(t:GetDescendants()) do
                if c:IsA("TextLabel") and c.Text ~= "" then tx[#tx + 1] = c.Text end
            end
            
            if #tx >= 3 then
                local rawSpecie = tx[1]
                local charNameTag = tx[2]
                local displayName = tx[3]
                
                -- SKIP SELF - NU arăta propriul jucător
                if displayName == MY_NAME then continue end
                
                local plr = P:FindFirstChild(displayName)
                
                if not plr then
                    for _, p in ipairs(P:GetPlayers()) do
                        if p.Name ~= MY_NAME then
                            local checkChar = p.Character
                            if checkChar then
                                local isJumped = false
                                if p:GetAttribute("BodyJumped") then isJumped = true end
                                if checkChar:FindFirstChild("BodyJumped") then isJumped = true end
                                for _, child in pairs(checkChar:GetChildren()) do
                                    if child:IsA("BasePart") and child.Name == "PossessionMarkPart" then isJumped = true end
                                end
                                
                                if isJumped then
                                    plr = p
                                    BodyJumpedCache[plr.Name] = true
                                    break
                                end
                            end
                        end
                    end
                end
                
                -- Verificare dublă să nu fie self
                if plr and plr ~= LP and plr.Name ~= MY_NAME then
                    local cleanSpecie = rawSpecie:gsub("^%s*(.-)%s*$", "%1")
                    local sp = S[cleanSpecie] or S[cleanSpecie:lower()] or S[cleanSpecie:upper()] or cleanSpecie
                    
                    local nm = N[charNameTag] or charNameTag
                    if sp == "Immortal" then nm = (charNameTag == "The Anchor" or charNameTag == "Amara") and "Amara" or "Silas" end
                    
                    local isBodyJumped = BodyJumpedCache[plr.Name] or false
                    
                    if isBodyJumped then
                        nm = N[charNameTag] or charNameTag
                        sp = "Witch"
                    end
                    
                    local color = SPECIES_COLORS[sp] or SPECIES_COLORS.Default
                    
                    new[plr.Name] = {sp = sp, nm = nm, color = color, player = plr}
                    
                    local parts = {}
                    if isBodyJumped then
                        parts[#parts + 1] = "[Body Jumped] " .. nm
                    else
                        if Options.ShowSpecies then parts[#parts + 1] = "[" .. sp .. "]" end
                        if Options.ShowRealName then parts[#parts + 1] = nm end
                    end
                    newTextCache[plr.Name] = table_concat(parts, " ")
                end
            end
        end
    end
    PlayerCache = new
    TextCache = newTextCache
end

local function UpdateIWOSCache()
    local newIWOS = {}
    local iwosFolder = W:FindFirstChild("IndestructibleWhiteOakStake")
    if iwosFolder then
        for _, stake in pairs(iwosFolder:GetChildren()) do
            local rt = stake:IsA("BasePart") and stake or (stake:IsA("Model") and stake.PrimaryPart)
            if not rt then for _, p in pairs(stake:GetChildren()) do if p:IsA("BasePart") then rt = p break end end end
            if rt then newIWOS[#newIWOS + 1] = rt end
        end
    end
    IWOSCache = newIWOS
end

local function UpdateCureCache()
    local newCure = {}
    
    -- Caută TheCure în SilasTomb
    local theCure = W:FindFirstChild("Interactables") and W.Interactables:FindFirstChild("SilasTomb") and W.Interactables.SilasTomb:FindFirstChild("CureBox") and W.Interactables.SilasTomb.CureBox:FindFirstChild("TheCure")
    if theCure then
        local rt = theCure:IsA("BasePart") and theCure or (theCure:IsA("Model") and theCure.PrimaryPart)
        if not rt then for _, p in pairs(theCure:GetChildren()) do if p:IsA("BasePart") then rt = p break end end end
        if rt then newCure[#newCure + 1] = rt end
    end
    
    -- Caută QetsiyahCure
    local qetCure = W:FindFirstChild("Interactables") and W.Interactables:FindFirstChild("QetsiyahCure")
    if qetCure then
        local rt = qetCure:IsA("BasePart") and qetCure or (qetCure:IsA("Model") and qetCure.PrimaryPart)
        if not rt then for _, p in pairs(qetCure:GetChildren()) do if p:IsA("BasePart") then rt = p break end end end
        if rt then newCure[#newCure + 1] = rt end
    end
    
    CureCache = newCure
    if #newCure > 0 then
        CureData = newCure[1].Position
    else
        CureData = nil
    end
end

-- ===== SIMPLE POLLING UPDATE =====
task_spawn(function()
    while true do task_wait(1) UpdatePlayerCache() UpdateIWOSCache() UpdateCureCache() end
end)

task_spawn(function()
    while true do
        task_wait(2)
        if Options.ShowItems then
            local lr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if lr then
                local lrp = lr.Position
                for _, plr in ipairs(P:GetPlayers()) do
                    if plr ~= LP and plr.Name ~= MY_NAME then
                        local char = plr.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp and (hrp.Position - lrp).Magnitude <= 500 then 
                                ItemCache[plr.Name] = GetItemsFromPlayer(plr) 
                            end
                        end
                    end
                end
            end
        end
    end
end)

task_spawn(function()
    while true do
        task_wait(5)
        if Options.EnablePlantESP then
            local newPlants = {}
            local fd = W:FindFirstChild("Interactables")
            if fd then
                local pls = fd:FindFirstChild("Plants")
                if pls then
                    for _, pl in pairs(pls:GetChildren()) do
                        if pl:IsA("Folder") or pl:IsA("Model") then
                            for _, ch in pairs(pl:GetChildren()) do
                                if ch:IsA("BasePart") and ch.Name ~= "WaypointReference" then
                                    newPlants[#newPlants + 1] = {root = ch, name = pl.Name}
                                    break
                                end
                            end
                        end
                    end
                end
            end
            PlantCache = newPlants
        end
    end
end)

-- ===== PLAYER ESP DRAWING SYSTEM =====
local function GetSpeciesColor(species)
    return SPECIES_COLORS[species] or SPECIES_COLORS.Default
end

if _G.PLAYER_ESP_CLEANUP then pcall(_G.PLAYER_ESP_CLEANUP) end

local running = true
local playerDrawings = {}
local renderConn = nil

_G.PLAYER_ESP_CLEANUP = function()
    running = false
    if renderConn then
        pcall(function() renderConn:Disconnect() end)
        renderConn = nil
    end
    for obj in pairs(playerDrawings) do
        pcall(function() obj:Remove() end)
    end
    playerDrawings = {}
end

local FONT = Drawing.Fonts.SystemBold or Drawing.Fonts.System
local MAX_PLAYER_SLOTS = 100

local function newText(color)
    local t = Drawing.new("Text")
    t.Size = 13
    t.Center = true
    t.Outline = true
    t.Font = FONT
    t.Color = color or Color3.new(1, 1, 1)
    t.Visible = false
    playerDrawings[t] = true
    return t
end

local function wrap(o) return { o = o } end

local function wVis(w, v)
    if w.vis ~= v then w.o.Visible = v; w.vis = v end
end
local function wCol(w, v)
    if w.col ~= v then w.o.Color = v; w.col = v end
end
local function wPos(w, x, y)
    if w.px ~= x or w.py ~= y then w.o.Position = Vector2.new(x, y); w.px = x; w.py = y end
end
local function wText(w, s)
    if w.txt ~= s then w.o.Text = s; w.txt = s end
end
local function wSize(w, s)
    if w.sz ~= s then w.o.Size = s; w.sz = s end
end

local function newSlot()
    return {
        main   = wrap(newText(SPECIES_COLORS.Default)),
        name   = wrap(newText(SPECIES_COLORS.Default)),
        dist   = wrap(newText(SPECIES_COLORS.Default)),
        items  = wrap(newText(SPECIES_COLORS.Default)),
    }
end

local slots = {}
for i = 1, MAX_PLAYER_SLOTS do slots[i] = newSlot() end

local function hideSlot(s)
    wVis(s.main, false)
    wVis(s.name, false)
    wVis(s.dist, false)
    wVis(s.items, false)
end

local playerESPItems = {}
local lastPlayerUpdate = 0

local function rebuildPlayerESP()
    local maxDist = Options.MaxDist
    local maxDistSq = maxDist * maxDist
    
    local lr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not lr then return end
    
    local lpx, lpy, lpz = lr.Position.X, lr.Position.Y, lr.Position.Z
    local newItems = {}
    local showItems = Options.ShowItems
    local showDist = Options.ShowDistance
    local showName = Options.ShowPlayerName
    
    for name, data in pairs(PlayerCache) do
        local plr = data.player
        if plr and plr ~= LP and plr.Name ~= MY_NAME then
            local char = plr.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    local pos = head.Position
                    local dx = pos.X - lpx
                    local dy = pos.Y - lpy
                    local dz = pos.Z - lpz
                    local distSq = dx*dx + dy*dy + dz*dz
                    
                    if distSq <= maxDistSq then
                        local dist = math.floor(math.sqrt(distSq) + 0.5)
                        local distText = "[" .. tostring(dist) .. "]"
                        
                        local entry = {
                            name = name,
                            displayText = TextCache[name] or name,
                            distText = distText,
                            headPos = pos,
                            color = data.color,
                            isBodyJumped = BodyJumpedCache[name] or false,
                            items = showItems and ItemCache[name] or nil,
                            species = data.sp,
                            realName = data.nm,
                            showName = false,
                        }
                        
                        if showName then
                            local alreadyShown = false
                            if TextCache[name] and TextCache[name]:find(name) then
                                alreadyShown = true
                            end
                            if not alreadyShown then
                                entry.showName = true
                            end
                        end
                        
                        newItems[#newItems + 1] = entry
                        
                        if #newItems >= MAX_PLAYER_SLOTS then break end
                    end
                end
            end
        end
    end
    
    playerESPItems = newItems
end

-- ===== 60 FPS RENDER LOOP =====
local TARGET_FPS = 60
local FRAME_TIME = 1 / TARGET_FPS
local lpx, lpy, lpz = 0, 0, 0
local lastFrame = 0

local function UpdatePlayerESP()
    if not Options.EnablePlayerESP then
        for i = 1, MAX_PLAYER_SLOTS do hideSlot(slots[i]) end
        return
    end
    
    local now = tick()
    local rate = Options.UpdateRate or 30
    if (now - lastPlayerUpdate) >= (1 / math.max(1, rate)) then
        lastPlayerUpdate = now
        rebuildPlayerESP()
    end
    
    local slot = 0
    
    for _, it in ipairs(playerESPItems) do
        if slot >= MAX_PLAYER_SLOTS then break end
        
        local screenPos, onScreen = WorldToScreen(it.headPos)
        if onScreen then
            slot = slot + 1
            local s = slots[slot]
            
            local px, py = screenPos.X, screenPos.Y
            local currentY = py - 6
            
            if it.displayText and it.displayText ~= "" then
                wText(s.main, it.displayText)
                wPos(s.main, px, currentY)
                wCol(s.main, it.color)
                wSize(s.main, 14)
                wVis(s.main, true)
                currentY = currentY + 16
            else
                wVis(s.main, false)
            end
            
            if it.showName then
                wText(s.name, it.name)
                wPos(s.name, px, currentY)
                wCol(s.name, Color3_fromRGB(180, 180, 180))
                wSize(s.name, 14)
                wVis(s.name, true)
                currentY = currentY + 16
            else
                wVis(s.name, false)
            end
            
            if Options.ShowDistance then
                wText(s.dist, it.distText)
                wPos(s.dist, px, currentY)
                wCol(s.dist, Color3_fromRGB(180, 180, 180))
                wSize(s.dist, 12)
                wVis(s.dist, true)
                currentY = currentY + 14
            else
                wVis(s.dist, false)
            end
            
            if Options.ShowItems and it.items and #it.items > 0 then
                wText(s.items, table_concat(it.items, " "))
                wPos(s.items, px, currentY)
                wCol(s.items, Color3_fromRGB(255, 255, 255))
                wSize(s.items, 11)
                wVis(s.items, true)
            else
                wVis(s.items, false)
            end
        end
    end
    
    for i = slot + 1, MAX_PLAYER_SLOTS do
        hideSlot(slots[i])
    end
end

-- ===== PUSHTEXT =====
local MAX_DRAWINGS = 300
local DrawPool = {}
local DrawVisible = {}
local DrawText = {}
local DrawPosX = {}
local DrawPosY = {}
local DrawSize = {}
local DrawColor = {}

for i = 1, MAX_DRAWINGS do
    local d = Drawing_new("Text")
    d.Font = Drawing.Fonts.SystemBold
    d.Center = true
    d.Outline = true
    d.Visible = false
    DrawPool[i] = d
    DrawVisible[i] = false
    DrawText[i] = ""
    DrawPosX[i] = 0
    DrawPosY[i] = 0
    DrawSize[i] = 13
    DrawColor[i] = Color3_fromRGB(255, 255, 255)
end

local drawIdx = 0
local function PushText(text, x, y, size, color)
    drawIdx = drawIdx + 1
    if drawIdx > MAX_DRAWINGS then return end
    DrawVisible[drawIdx] = true
    DrawText[drawIdx] = text
    DrawPosX[drawIdx] = x
    DrawPosY[drawIdx] = y
    DrawSize[drawIdx] = size
    DrawColor[drawIdx] = color
end

local TOOL_Y_OFFSET = 1
local PLANT_Y_OFFSET = 1
local DEFAULT_WHITE = Color3_fromRGB(255, 255, 255)
local COLOR_GRAY = Color3_fromRGB(180, 180, 180)
local COLOR_OFFWHITE = Color3_fromRGB(200, 200, 200)
local COLOR_RED = Color3_fromRGB(255, 0, 0)
local COLOR_GREEN = Color3_fromRGB(0, 255, 100)
local COLOR_CURE = Color3_fromRGB(255, 50, 50)
local COLOR_QETCURE = Color3_fromRGB(255, 150, 0)

local PLANT_NAMES = {"WolfsbanePlant", "VampitePlant", "SeniaPlant", "MooncapPlant", "NightshadePlant", "AerpinePlant", "YarrowPlant", "ArcanithPlant", "DerridaPlant", "SanguiniaPlant", "PerenniaPlant"}
local PLANT_COLORS = {
    Color3_fromRGB(255, 100, 100), Color3_fromRGB(200, 50, 200), Color3_fromRGB(100, 255, 100),
    Color3_fromRGB(255, 200, 50), Color3_fromRGB(150, 50, 255), Color3_fromRGB(50, 200, 255),
    Color3_fromRGB(255, 255, 100), Color3_fromRGB(255, 150, 50), Color3_fromRGB(100, 200, 100),
    Color3_fromRGB(255, 50, 50), Color3_fromRGB(50, 255, 200)
}

-- ===== RENDER CONNECTION =====
local RenderConnection = R.RenderStepped:Connect(function(deltaTime)
    local currentTime = tick()
    if currentTime - lastFrame < FRAME_TIME then return end
    lastFrame = currentTime
    
    drawIdx = 0
    
    local lpChar = LP.Character
    if not lpChar or not lpChar:IsDescendantOf(W) then 
        for i = 1, MAX_DRAWINGS do DrawPool[i].Visible = false end
        for i = 1, MAX_PLAYER_SLOTS do hideSlot(slots[i]) end
        return 
    end
    
    local lpRoot = lpChar:FindFirstChild("HumanoidRootPart")
    if not lpRoot then 
        for i = 1, MAX_DRAWINGS do DrawPool[i].Visible = false end
        for i = 1, MAX_PLAYER_SLOTS do hideSlot(slots[i]) end
        return 
    end
    
    lpx, lpy, lpz = lpRoot.Position.X, lpRoot.Position.Y, lpRoot.Position.Z
    
    UpdatePlayerESP()
    
    -- IWOS ESP
    if Options.EnableToolsESP then
        local toolsMaxDistSq = Options.ToolsMaxDist * Options.ToolsMaxDist
        local lastIwosPos = nil 
        
        for i = 1, #IWOSCache do
            local rt = IWOSCache[i]
            if rt and rt.Position then
                local rx, ry, rz = rt.Position.X, rt.Position.Y, rt.Position.Z
                local dx, dy, dz = rx - lpx, ry - lpy, rz - lpz
                
                if lastIwosPos then
                    local distBetween = (Vector3_new(rx, ry, rz) - lastIwosPos).Magnitude
                    if distBetween < 2 then continue end
                end
                
                if dx*dx + dy*dy + dz*dz <= toolsMaxDistSq then
                    local screenPos, onScreen = WorldToScreen(Vector3_new(rx, ry + TOOL_Y_OFFSET, rz))
                    if onScreen then
                        local dist = math_floor((dx*dx + dy*dy + dz*dz)^0.5 + 0.5)
                        PushText("[Indestructible]", screenPos.X, screenPos.Y - 6, 14, DEFAULT_WHITE)
                        PushText(dist .. "s", screenPos.X, screenPos.Y + 8, 12, COLOR_OFFWHITE)
                        lastIwosPos = Vector3_new(rx, ry, rz)
                    end
                end
            end
        end
    end
    
    -- CURE ESP (TheCure si QetsiyahCure ca ESP separat)
    if Options.EnableCureESP then
        local cureMaxDistSq = Options.ToolsMaxDist * Options.ToolsMaxDist
        
        for i = 1, #CureCache do
            local rt = CureCache[i]
            if rt and rt.Position then
                local rx, ry, rz = rt.Position.X, rt.Position.Y, rt.Position.Z
                local dx, dy, dz = rx - lpx, ry - lpy, rz - lpz
                
                if dx*dx + dy*dy + dz*dz <= cureMaxDistSq then
                    local screenPos, onScreen = WorldToScreen(Vector3_new(rx, ry + TOOL_Y_OFFSET, rz))
                    if onScreen then
                        local dist = math_floor((dx*dx + dy*dy + dz*dz)^0.5 + 0.5)
                        -- Verifică dacă e TheCure sau QetsiyahCure
                        if rt.Name == "TheCure" then
                            PushText("[The Cure]", screenPos.X, screenPos.Y - 6, 14, COLOR_CURE)
                        elseif rt.Name == "QetsiyahCure" then
                            PushText("[Qet Cure]", screenPos.X, screenPos.Y - 6, 14, COLOR_QETCURE)
                        else
                            PushText("[Cure]", screenPos.X, screenPos.Y - 6, 14, COLOR_CURE)
                        end
                        PushText(dist .. "s", screenPos.X, screenPos.Y + 8, 12, COLOR_OFFWHITE)
                    end
                end
            end
        end
    end
    
    -- PLANT ESP
    if Options.EnablePlantESP then
        local plantMaxDistSq = Options.PlantMaxDist * Options.PlantMaxDist
        local showPlantName = Options.ShowPlantName
        local showPlantDist = Options.ShowPlantDist
        
        for i = 1, #PlantCache do
            local plantData = PlantCache[i]
            if plantData then
                local rt = plantData.root
                if rt then
                    local nm = plantData.name
                    local plantVis = false
                    if nm == PLANT_NAMES[1] then plantVis = Options.ShowWolfsbane
                    elseif nm == PLANT_NAMES[2] then plantVis = Options.ShowVampite
                    elseif nm == PLANT_NAMES[3] then plantVis = Options.ShowSenia
                    elseif nm == PLANT_NAMES[4] then plantVis = Options.ShowMooncap
                    elseif nm == PLANT_NAMES[5] then plantVis = Options.ShowNightshade
                    elseif nm == PLANT_NAMES[6] then plantVis = Options.ShowAerpine
                    elseif nm == PLANT_NAMES[7] then plantVis = Options.ShowYarrow
                    elseif nm == PLANT_NAMES[8] then plantVis = Options.ShowArcanith
                    elseif nm == PLANT_NAMES[9] then plantVis = Options.ShowDerrida
                    elseif nm == PLANT_NAMES[10] then plantVis = Options.ShowSanguinia
                    elseif nm == PLANT_NAMES[11] then plantVis = Options.ShowPerennia end
                    
                    if plantVis then
                        local rx, ry, rz = rt.Position.X, rt.Position.Y, rt.Position.Z
                        local dx, dy, dz = rx - lpx, ry - lpy, rz - lpz
                        
                        if dx*dx + dy*dy + dz*dz <= plantMaxDistSq then
                            local screenPos, onScreen = WorldToScreen(Vector3_new(rx, ry + PLANT_Y_OFFSET, rz))
                            if onScreen then
                                local plantColor = COLOR_GREEN
                                if nm == PLANT_NAMES[1] then plantColor = PLANT_COLORS[1]
                                elseif nm == PLANT_NAMES[2] then plantColor = PLANT_COLORS[2]
                                elseif nm == PLANT_NAMES[3] then plantColor = PLANT_COLORS[3]
                                elseif nm == PLANT_NAMES[4] then plantColor = PLANT_COLORS[4]
                                elseif nm == PLANT_NAMES[5] then plantColor = PLANT_COLORS[5]
                                elseif nm == PLANT_NAMES[6] then plantColor = PLANT_COLORS[6]
                                elseif nm == PLANT_NAMES[7] then plantColor = PLANT_COLORS[7]
                                elseif nm == PLANT_NAMES[8] then plantColor = PLANT_COLORS[8]
                                elseif nm == PLANT_NAMES[9] then plantColor = PLANT_COLORS[9]
                                elseif nm == PLANT_NAMES[10] then plantColor = PLANT_COLORS[10]
                                elseif nm == PLANT_NAMES[11] then plantColor = PLANT_COLORS[11] end
                                
                                if showPlantName then PushText(nm, screenPos.X, screenPos.Y - 6, 12, plantColor) end
                                if showPlantDist then
                                    local dist = math_floor((dx*dx + dy*dy + dz*dz)^0.5 + 0.5)
                                    PushText(dist .. "s", screenPos.X, screenPos.Y + 6, 12, COLOR_OFFWHITE)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Apply all visible drawings
    for i = 1, MAX_DRAWINGS do
        local d = DrawPool[i]
        if DrawVisible[i] then
            d.Text = DrawText[i]
            d.Position = Vector2_new(DrawPosX[i], DrawPosY[i])
            d.Size = DrawSize[i]
            d.Color = DrawColor[i]
            d.Visible = true
            DrawVisible[i] = false
        else
            d.Visible = false
        end
    end
end)

-- ===== INITIAL NOTIFICATIONS =====
if #IWOSCache > 0 then notify("IWOS found on map! (" .. #IWOSCache .. " total)", "IWOS Detected", 6) end
if #CureCache > 0 then 
    local cureNames = {}
    for _, rt in ipairs(CureCache) do
        if rt.Name == "TheCure" then cureNames[#cureNames + 1] = "The Cure"
        elseif rt.Name == "QetsiyahCure" then cureNames[#cureNames + 1] = "Qet Cure" end
    end
    notify("Cure found on map! (" .. table_concat(cureNames, ", ") .. ")", "Cure Info", 5)
end
notify("Welcome!", "Dav's Gui - The Vampire Legends Hub", 6)