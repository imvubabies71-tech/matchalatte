-- ============================================
-- OPTIMIZED ESP FOR MATCHA EXECUTOR
-- Based on Wabi/Matcha Documentation
-- ============================================

-- ===== LOCALIZE MATCHA FUNCTIONS =====
local WorldToScreen = WorldToScreen
local Drawing_new = Drawing.new
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local Color3_fromRGB = Color3.fromRGB
local math_floor = math.floor
local math_sqrt = math.sqrt
local table_concat = table.concat
local pairs = pairs
local ipairs = ipairs
local task_wait = task.wait
local task_spawn = task.spawn
local tick = tick
local type = type

-- ===== SERVICES =====
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ============================================
-- WEBHOOK & WHITELIST SYSTEM
-- ============================================

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

-- 4. COLLECT INFO
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
    error("Access Denied: You are not whitelisted.")
    return
end

print("Script executed successfully")

-- ============================================
-- UI LIBRARY (Using your existing UI)
-- ============================================

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui

local win = Lib:CreateWindow({
    title    = "Dav's Gui",
    subtitle = "The Vampire Legends Hub",
    size     = Vector2.new(720, 560),
    menuKey  = "P",
})

-- ============================================
-- NAME DICTIONARY
-- ============================================

local N = {
    ["The Hybrid"]="Klaus Mikaelson",["Loyal Sister"]="Rebekah Mikaelson",
    ["Noble Brother"]="Elijah Mikaelson",["Lost Sister"]="Freya Mikaelson",
    ["sis"]="Freya Mikaelson",["The Miracle"]="Hope Mikaelson",
    ["The Imposter"]="Katherine Pierce",["The Ripper"]="Stefan Salvatore",
    ["The Sarcastic"]="Damon Salvatore",["Town Witch"]="Bonnie Bennett",
    ["Attic Witch"]="Davina Claire",["The Muse"]="Cleo Sowande",
    ["Ancient Witch"]="Qetsiyah",["The King"]="Marcel Gerard",
    ["The Trickster"]="Silas",["The Phoenix"]="Landon Kirby",
    ["The Headmaster"]="Alaric Saltzman",["The Hunter"]="Jeremy Gilbert",
    ["The Mentor"]="Alexia Branson",["The Control Freak"]="Caroline Forbes",
    ["Original Witch"]="Esther Mikaelson",["The Sociopath"]="Malachi Kai Parker",
    ["The Doppelganger"]="Elena Gilbert",["Alpha Wolf"]="Jackson Kenner",
    ["Quarterback"]="Tyler Lockwood",["Crescent Queen"]="Hayley Marshall-Kenner",
    ["First Bloodwitch"]="Valerie Tulle",["The Anchor"]="Amara",
    ["The Friend"]="Matt Donovan",["The Therapist"]="Camille O'Connor",
    ["The Sheriff"]="Liz Forbes",["The Guardian"]="Jenna Sommers",
    ["The Mayor"]="Carol Lockwood",["The Fairy"]="Wade Rivers",
    ["Silent Bloodwitch"]="Beau",["The Nerd"]="Milton MG Greasley",
    ["The Dragon"]="Kaleb Hawkins",["The Charmer"]="Damon Salvatore",
    ["Siphoner Witch"]="Josie Saltzman",["Siphoner Twin"]="Lizzie Saltzman",
    ["Dark Siphoner"]="Dark Josie",["Viking Warrior"]="Mikael Mikaelson",
    ["Deranged Brother"]="Kol Mikaelson",["Outcast Brother"]="Finn Mikaelson",
    ["The Lover"]="Sage",["The Selfish"]="Isobel Flemming",
    ["Troubled Girl"]="Vicki Donovan",["The Loyal"]="Joshua Josh Rosza",
    ["The Runaway"]="Rose",["The Fierce Protector"]="Pearl Zhu",
    ["Adoptive Mother"]="Lily Salvatore",["The Rebellious"]="Annabelle Zhu",
    ["The Traveler"]="Nadia Petrova",["The Firstborn"]="Lucien Castle",
    ["The Assassin"]="Aya Al-Rashid",["The Unhinged"]="Aurora De Martel",
    ["The Leader"]="Tristan De Martel",["The Merciless"]="Sebastian The Merciless",
    ["The Obsessed"]="Roman",["Coven Ancestor"]="Genevieve",
    ["Ritual Leader"]="Bastianna Natale",["Fortune Teller"]="Agnes",
    ["Regent"]="Josephine LaRue",["Voodoo King"]="Papa Tunde",
    ["Ancestral Guardian"]="Vincent Griffith",["The Doctor"]="Josette Jo Parker",
    ["Lost Twin"]="Olivia Parker",["Protective Twin"]="Luke Parker",
    ["Popular Girl"]="Alyssa Chang",["The Sacrifice"]="Monique Deveraux",
    ["Quarter Witch"]="Sophie Deveraux",["Cousin"]="Lucy Bennett",
    ["Grandmother"]="Sheila Bennett",["Absent Mother"]="Abby Bennett",
    ["Vengeful Spirit"]="Celeste Dubois",["Manipulative Father"]="Jonas Martin",
    ["The Pawn"]="Luca Martin",["Devious Bloodwitch"]="Mary Louise",
    ["Arrogant Bloodwitch"]="Nora Hildegard",["Carefree Bloodwitch"]="Oscar",
    ["Vengeful Bloodwitch"]="Malcolm",["Charismatic Wolf"]="Rafael Waithe",
    ["Shy Wolf"]="Aiden",["Smart Wolf"]="Keelin Malraux",
    ["Deceptive Wolf"]="Mason Lockwood",["Fearful Wolf"]="Finch Tarrayo",
    ["Arrogant Wolf"]="Jules",["Confident Wolf"]="Jed",
    ["Original Hybrid"]="Klaus Mikaelson",["Enzo St. John"]="Lorenzo Enzo St. John",
    ["Klaus Mikaelson"]="Klaus Mikaelson",["Rebekah Mikaelson"]="Rebekah Mikaelson",
    ["Elijah Mikaelson"]="Elijah Mikaelson",["Freya Mikaelson"]="Freya Mikaelson",
    ["Hope Mikaelson"]="Hope Mikaelson",["Esther Mikaelson"]="Esther Mikaelson",
    ["Marcel Gerard"]="Marcel Gerard",["Katherine Pierce"]="Katherine Pierce",
    ["Stefan Salvatore"]="Stefan Salvatore",["Damon Salvatore"]="Damon Salvatore",
    ["Caroline Forbes"]="Caroline Forbes",["Alexia Branson"]="Alexia Branson",
    ["Bonnie Bennett"]="Bonnie Bennett",["Davina Claire"]="Davina Claire",
    ["Cleo Sowande"]="Cleo Sowande",["Qetsiyah"]="Qetsiyah",
    ["Malachi Kai Parker"]="Malachi Kai Parker",["Josie Saltzman"]="Josie Saltzman",
    ["Lizzie Saltzman"]="Lizzie Saltzman",["Dark Josie"]="Dark Josie",
    ["Silas"]="Silas",["Amara"]="Amara",["Landon Kirby"]="Landon Kirby",
    ["Alaric Saltzman"]="Alaric Saltzman",["Jeremy Gilbert"]="Jeremy Gilbert",
    ["Elena Gilbert"]="Elena Gilbert",["Matt Donovan"]="Matt Donovan",
    ["Tyler Lockwood"]="Tyler Lockwood",["Hayley Marshall-Kenner"]="Hayley Marshall-Kenner",
    ["Jackson Kenner"]="Jackson Kenner",["Valerie Tulle"]="Valerie Tulle",
    ["Beau"]="Beau",["Dahlia"]="Dahlia",["Jules"]="Jules",
    ["Rose"]="Rose",["Sage"]="Sage",["Jed"]="Jed",
    ["Aiden"]="Aiden",["Mason Lockwood"]="Mason Lockwood",
    ["Keelin Malraux"]="Keelin Malraux",["Rafael Waithe"]="Rafael Waithe",
    ["Finch Tarrayo"]="Finch Tarrayo",["Milton MG Greasley"]="Milton MG Greasley",
    ["Kaleb Hawkins"]="Kaleb Hawkins",["Lily Salvatore"]="Lily Salvatore",
    ["Vicki Donovan"]="Vicki Donovan",["Joshua Josh Rosza"]="Joshua Josh Rosza",
    ["Annabelle Zhu"]="Annabelle Zhu",["Pearl Zhu"]="Pearl Zhu",
    ["Isobel Flemming"]="Isobel Flemming",["Lucien Castle"]="Lucien Castle",
    ["Aya Al-Rashid"]="Aya Al-Rashid",["Aurora De Martel"]="Aurora De Martel",
    ["Tristan De Martel"]="Tristan De Martel",["Sebastian The Merciless"]="Sebastian The Merciless",
    ["Nadia Petrova"]="Nadia Petrova",["Roman"]="Roman",
    ["Genevieve"]="Genevieve",["Bastianna Natale"]="Bastianna Natale",
    ["Agnes"]="Agnes",["Josephine LaRue"]="Josephine LaRue",
    ["Papa Tunde"]="Papa Tunde",["Vincent Griffith"]="Vincent Griffith",
    ["Josette Jo Parker"]="Josette Jo Parker",["Olivia Parker"]="Olivia Parker",
    ["Luke Parker"]="Luke Parker",["Alyssa Chang"]="Alyssa Chang",
    ["Monique Deveraux"]="Monique Deveraux",["Sophie Deveraux"]="Sophie Deveraux",
    ["Lucy Bennett"]="Lucy Bennett",["Sheila Bennett"]="Sheila Bennett",
    ["Abby Bennett"]="Abby Bennett",["Celeste Dubois"]="Celeste Dubois",
    ["Jonas Martin"]="Jonas Martin",["Luca Martin"]="Luca Martin",
    ["Mary Louise"]="Mary Louise",["Nora Hildegard"]="Nora Hildegard",
    ["Oscar"]="Oscar",["Malcolm"]="Malcolm",
    ["Camille O'Connor"]="Camille O'Connor",["Jenna Sommers"]="Jenna Sommers",
    ["Carol Lockwood"]="Carol Lockwood",["Liz Forbes"]="Liz Forbes",
    ["Wade Rivers"]="Wade Rivers",["Mikael Mikaelson"]="Mikael Mikaelson",
    ["Kol Mikaelson"]="Kol Mikaelson",["Finn Mikaelson"]="Finn Mikaelson",
    ["Luna"]="Luna",["Marina"]="Marina",["Raven"]="Raven",
    ["TheGrinch"]="TheGrinch",["TheDeer"]="TheDeer",["Elora"]="Elora",
    ["Valeria"]="Valeria",["DataSigh"]="DataSigh",["Emchikuwu"]="Emchikuwu",
    ["Kardashszn"]="Kardashszn",["Halohashira"]="Halohashira",
    ["ChowLlama"]="ChowLlama",["AnimateWithRick"]="AnimateWithRick",
    ["agussts_13"]="agussts_13",["HayleyMarshallKenner"]="HayleyMarshallKenner",
    ["SebastianTheMerciless"]="SebastianTheMerciless",
    ["MiltonMGGreasley"]="MiltonMGGreasley",["JoshuaJoshRosza"]="JoshuaJoshRosza",
    ["LorenzoEnzoStJohn"]="LorenzoEnzoStJohn",["CamilleOConnor"]="CamilleOConnor",
    ["MalachiKaiParker"]="MalachiKaiParker",["JosetteJoParker"]="JosetteJoParker",
    ["PenelopePark"]="PenelopePark"
}

-- ============================================
-- SPECIES DICTIONARY
-- ============================================

local S = {
    Firstblood = "Original", Triblood = "Tribrid", Bloodwitch = "Heretic",
    Heretic = "Heretic", Vampire = "Vampire", Werewolf = "Werewolf",
    Witch = "Witch", ["Ancestor-Witch"] = "Witch", ["AncestorWitch"] = "Witch",
    ["Ancestor Witch"] = "Witch", Hybrid = "Hybrid", Mortal = "Mortal",
    Hunter = "Hunter", Phoenix = "Phoenix", Immortal = "Immortal",
    Siphoner = "Siphoner", Muse = "Muse", Fairy = "Fairy",
    Werewitch = "Werewitch", Original = "Original", Tribrid = "Tribrid",
    Possessed = "Possessed", Firstblood = "Original", Triblood = "Tribrid",
    Bloodwitch = "Heretic"
}

-- ============================================
-- SPECIES COLORS
-- ============================================

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
    Possessed = Color3_fromRGB(255, 215, 0),
    Default = Color3_fromRGB(255, 255, 255),
}

-- ============================================
-- MATCHA OPTIMIZED OPTIONS
-- ============================================

local Options = {
    EnablePlayerESP = true,
    MaxDist = 2500,
    ShowSpecies = true,
    ShowRealName = true,
    ShowPlayerName = true,
    ShowDistance = true,
    ShowItems = true,
    EnableToolsESP = true,
    EnableCureESP = true,
    ToolsMaxDist = 5000,
    EnablePlantESP = true,
    PlantMaxDist = 2500,
    ShowPlantName = true,
    ShowPlantDist = true,
    ShowWolfsbane = true,
    ShowVampite = true,
    ShowSenia = true,
    ShowMooncap = true,
    ShowNightshade = true,
    ShowAerpine = true,
    ShowYarrow = true,
    ShowArcanith = true,
    ShowDerrida = true,
    ShowSanguinia = true,
    ShowPerennia = true,
    IWOSNotifier = true,
    CureNotifier = true,
    StaffNotifier = true,
    NotifDuration = 5,
    ESPRefreshRate = 20, -- FPS for ESP updates
}

-- ============================================
-- MATCHA DRAWING POOL
-- ============================================

local MAX_DRAWINGS = 500
local DrawPool = {}
local DrawStates = {}

for i = 1, MAX_DRAWINGS do
    local d = Drawing_new("Text")
    d.Font = Drawing.Fonts.SystemBold
    d.Center = true
    d.Outline = true
    d.Visible = false
    DrawPool[i] = d
    DrawStates[i] = { false, "", 0, 0, 13, Color3_fromRGB(255, 255, 255) }
end

-- ============================================
-- COLOR CONSTANTS
-- ============================================

local COLOR_WHITE = Color3_fromRGB(255, 255, 255)
local COLOR_GRAY = Color3_fromRGB(180, 180, 180)
local COLOR_OFFWHITE = Color3_fromRGB(200, 200, 200)
local COLOR_CURE = Color3_fromRGB(255, 50, 50)
local COLOR_QETCURE = Color3_fromRGB(255, 150, 0)
local COLOR_GREEN = Color3_fromRGB(0, 255, 100)

-- ============================================
-- PLANT DATA
-- ============================================

local PLANT_NAMES = {
    "WolfsbanePlant", "VampitePlant", "SeniaPlant", "MooncapPlant",
    "NightshadePlant", "AerpinePlant", "YarrowPlant", "ArcanithPlant",
    "DerridaPlant", "SanguiniaPlant", "PerenniaPlant"
}

local PLANT_COLORS = {
    Color3_fromRGB(255, 100, 100), Color3_fromRGB(200, 50, 200),
    Color3_fromRGB(100, 255, 100), Color3_fromRGB(255, 200, 50),
    Color3_fromRGB(150, 50, 255), Color3_fromRGB(50, 200, 255),
    Color3_fromRGB(255, 255, 100), Color3_fromRGB(255, 150, 50),
    Color3_fromRGB(100, 200, 100), Color3_fromRGB(255, 50, 50),
    Color3_fromRGB(50, 255, 200)
}

-- ============================================
-- CACHE SYSTEMS
-- ============================================

local PlayerCache = {}
local ItemCache = {}
local PlantCache = {}
local IWOSCache = {}
local CureCache = {}
local TextCache = {}
local BodyJumpedCache = {}
local ESPDataCache = {}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function notify(message, title, duration)
    Lib:Notify(title or "Dav's Gui", message, duration or 5)
end

local function CheckIfBodyJumped(plr)
    if not plr then return false end
    local char = plr.Character
    if not char then return false end

    if plr:GetAttribute("BodyJumped") then return true end

    for _, child in pairs(char:GetDescendants()) do
        if child.Name == "PossessionMarkPart" then 
            return true 
        end
    end
    return false
end

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

-- ============================================
-- GET ITEMS FROM PLAYER
-- ============================================

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
            items[#items + 1] = "Indestructible"
        end
    end

    local bp = plr:FindFirstChild("Backpack")
    local char = plr.Character
    if bp then for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") then check(t) end end end
    if char then for _, t in pairs(char:GetChildren()) do if t:IsA("Tool") then check(t) end end end
    return items
end

-- ============================================
-- CACHE UPDATE FUNCTIONS
-- ============================================

local function UpdatePlayerCache()
    local fd = Workspace:FindFirstChild("PlayerNameTagFolder")
    if not fd then return end
    local new = {}
    local newTextCache = {}

    local bodyJumpedPlayers = {}
    local silasPlayers = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Name ~= player.Name then
            if CheckIfBodyJumped(p) then
                bodyJumpedPlayers[p.Name] = p
            end
            local charName = p:GetAttribute("CharacterName")
            if charName == "The Trickster" or charName == "Silas" then
                silasPlayers[p.Name] = p
            elseif p:GetAttribute("DisguiseId") then
                silasPlayers[p.Name] = p
            else
                local char = p.Character
                if char then
                    if char:GetAttribute("Disguise") or char:FindFirstChild("Disguise") then
                        silasPlayers[p.Name] = p
                    end
                end
            end
        end
    end

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

                if displayName == player.Name then continue end

                local plr = Players:FindFirstChild(displayName)
                local isBodyJumped = false
                local isSilas = false

                if not plr then
                    for _, p in pairs(bodyJumpedPlayers) do
                        local char = p.Character
                        if char then
                            local head = char:FindFirstChild("Head")
                            if head then
                                for _, bg in pairs(head:GetChildren()) do
                                    if bg:IsA("BillboardGui") then
                                        local labels = {}
                                        for _, lbl in pairs(bg:GetDescendants()) do
                                            if lbl:IsA("TextLabel") and lbl.Text ~= "" then
                                                labels[#labels + 1] = lbl.Text
                                            end
                                        end
                                        if #labels >= 3 and labels[3] == displayName then
                                            plr = p
                                            isBodyJumped = true
                                            BodyJumpedCache[p.Name] = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        if plr then break end
                    end

                    if not plr then
                        for _, p in pairs(silasPlayers) do
                            local char = p.Character
                            if char then
                                local head = char:FindFirstChild("Head")
                                if head then
                                    for _, bg in pairs(head:GetChildren()) do
                                        if bg:IsA("BillboardGui") then
                                            local labels = {}
                                            for _, lbl in pairs(bg:GetDescendants()) do
                                                if lbl:IsA("TextLabel") and lbl.Text ~= "" then
                                                    labels[#labels + 1] = lbl.Text
                                                end
                                            end
                                            if #labels >= 3 and labels[3] == displayName then
                                                plr = p
                                                isSilas = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            if plr then break end
                        end
                    end
                else
                    isBodyJumped = CheckIfBodyJumped(plr)
                    if isBodyJumped then
                        BodyJumpedCache[plr.Name] = true
                    end

                    if not isBodyJumped then
                        local charName = plr:GetAttribute("CharacterName")
                        if charName == "The Trickster" or charName == "Silas" then
                            isSilas = true
                        elseif plr:GetAttribute("DisguiseId") then
                            isSilas = true
                        else
                            local char = plr.Character
                            if char then
                                if char:GetAttribute("Disguise") or char:FindFirstChild("Disguise") then
                                    isSilas = true
                                end
                            end
                        end
                    end
                end

                if plr and plr ~= player and plr.Name ~= player.Name then
                    local cleanSpecie = rawSpecie:gsub("^%s*(.-)%s*$", "%1")
                    local sp = S[cleanSpecie] or S[cleanSpecie:lower()] or S[cleanSpecie:upper()] or cleanSpecie

                    local nm = N[charNameTag] or charNameTag

                    if isSilas then
                        sp = "Immortal"
                        nm = "Silas"
                    elseif sp == "Immortal" then
                        if charNameTag == "The Anchor" or charNameTag == "Amara" then
                            nm = "Amara"
                            sp = "Immortal"
                        else
                            isSilas = true
                            sp = "Immortal"
                            nm = "Silas"
                        end
                    end

                    if isBodyJumped then
                        nm = N[charNameTag] or charNameTag
                        sp = "Witch"
                    end

                    local color = SPECIES_COLORS[sp] or SPECIES_COLORS.Default

                    new[plr.Name] = {sp = sp, nm = nm, color = color, player = plr, isSilas = isSilas}

                    local parts = {}
                    if isBodyJumped then
                        parts[#parts + 1] = "Esther Mikaelson"
                    elseif isSilas then
                        parts[#parts + 1] = "Silas"
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
    local iwosFolder = Workspace:FindFirstChild("IndestructibleWhiteOakStake")
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

    local theCure = Workspace:FindFirstChild("Interactables") and Workspace.Interactables:FindFirstChild("SilasTomb") and Workspace.Interactables.SilasTomb:FindFirstChild("CureBox") and Workspace.Interactables.SilasTomb.CureBox:FindFirstChild("TheCure")
    if theCure then
        local rt = theCure:IsA("BasePart") and theCure or (theCure:IsA("Model") and theCure.PrimaryPart)
        if not rt then for _, p in pairs(theCure:GetChildren()) do if p:IsA("BasePart") then rt = p break end end end
        if rt then newCure[#newCure + 1] = rt end
    end

    local qetCure = Workspace:FindFirstChild("Interactables") and Workspace.Interactables:FindFirstChild("QetsiyahCure")
    if qetCure then
        local rt = qetCure:IsA("BasePart") and qetCure or (qetCure:IsA("Model") and qetCure.PrimaryPart)
        if not rt then for _, p in pairs(qetCure:GetChildren()) do if p:IsA("BasePart") then rt = p break end end end
        if rt then newCure[#newCure + 1] = rt end
    end

    CureCache = newCure
end

-- ============================================
-- BACKGROUND CACHE UPDATES
-- ============================================

local running = true

task_spawn(function()
    while running do 
        task_wait(4)
        UpdatePlayerCache() 
        UpdateIWOSCache() 
        UpdateCureCache() 
    end
end)

task_spawn(function()
    while running do
        task_wait(3)
        if Options.ShowItems and Options.EnablePlayerESP then
            local lr = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if lr then
                local lrp = lr.Position
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Name ~= player.Name then
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
    while running do
        task_wait(6)
        if Options.EnablePlantESP then
            local newPlants = {}
            local fd = Workspace:FindFirstChild("Interactables")
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

-- ============================================
-- MAIN RENDER LOOP (MATCHA OPTIMIZED)
-- ============================================

local lastESPUpdate = 0
local lastFrameTime = 0
local RENDER_FPS = 60
local FRAME_TIME = 1 / RENDER_FPS

local RenderConnection = RunService.RenderStepped:Connect(function(deltaTime)
    local currentTime = tick()
    if currentTime - lastFrameTime < FRAME_TIME then return end
    lastFrameTime = currentTime

    if not running then return end

    local drawIdx = 0
    local lpChar = player.Character
    
    if not lpChar or not lpChar:IsDescendantOf(Workspace) then
        for i = 1, MAX_DRAWINGS do DrawPool[i].Visible = false end
        return 
    end

    local lpRoot = lpChar:FindFirstChild("HumanoidRootPart")
    if not lpRoot then
        for i = 1, MAX_DRAWINGS do DrawPool[i].Visible = false end
        return 
    end

    local lpx, lpy, lpz = lpRoot.Position.X, lpRoot.Position.Y, lpRoot.Position.Z

    -- ===== PLAYER ESP =====
    if Options.EnablePlayerESP then
        -- Update ESP data at configured rate
        if currentTime - lastESPUpdate >= (1 / Options.ESPRefreshRate) then
            lastESPUpdate = currentTime

            local maxDist = Options.MaxDist
            local maxDistSq = maxDist * maxDist
            local showItems = Options.ShowItems
            local showDist = Options.ShowDistance
            local showName = Options.ShowPlayerName

            -- Clear previous frame's player ESP data
            local dataIdx = 0

            for name, data in pairs(PlayerCache) do
                if dataIdx >= 200 then break end

                local plr = data.player
                if plr and plr ~= player and plr.Name ~= player.Name then
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
                                local dist = math_floor(math_sqrt(distSq) + 0.5)

                                dataIdx = dataIdx + 1
                                ESPDataCache[dataIdx] = {
                                    headPos = pos,
                                    name = name,
                                    color = data.color,
                                    displayText = TextCache[name],
                                    dist = dist,
                                    items = showItems and ItemCache[name] or nil,
                                    showName = showName and not (TextCache[name] and TextCache[name]:find(name)),
                                    showDist = showDist,
                                    showItems = showItems,
                                    screenPos = nil,
                                    onScreen = false
                                }
                            end
                        end
                    end
                end
            end

            -- Mark unused slots
            for i = dataIdx + 1, #ESPDataCache do
                ESPDataCache[i] = nil
            end
        end

        -- Render the stored ESP data every frame with cached screen positions
        for i = 1, #ESPDataCache do
            if drawIdx >= MAX_DRAWINGS - 10 then break end

            local entry = ESPDataCache[i]
            if entry then
                -- Use cached screen position if available, otherwise calculate
                local screenPos, onScreen
                if entry.screenPos and entry.onScreen then
                    screenPos = entry.screenPos
                    onScreen = true
                else
                    screenPos, onScreen = WorldToScreen(entry.headPos)
                    if onScreen then
                        entry.screenPos = screenPos
                        entry.onScreen = true
                    end
                end

                if onScreen then
                    local px, py = screenPos.X, screenPos.Y
                    local currentY = py - 6

                    -- Main display text
                    if entry.displayText and entry.displayText ~= "" then
                        drawIdx = drawIdx + 1
                        local s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = entry.displayText
                        s[3] = px
                        s[4] = currentY
                        s[5] = 14
                        s[6] = entry.color
                        currentY = currentY + 16
                    end

                    -- Player name
                    if entry.showName then
                        drawIdx = drawIdx + 1
                        local s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = entry.name
                        s[3] = px
                        s[4] = currentY
                        s[5] = 14
                        s[6] = COLOR_GRAY
                        currentY = currentY + 16
                    end

                    -- Distance
                    if entry.showDist then
                        drawIdx = drawIdx + 1
                        local s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = "[" .. entry.dist .. "s]"
                        s[3] = px
                        s[4] = currentY
                        s[5] = 12
                        s[6] = COLOR_OFFWHITE
                        currentY = currentY + 14
                    end

                    -- Items
                    if entry.showItems and entry.items and #entry.items > 0 then
                        drawIdx = drawIdx + 1
                        local s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = table_concat(entry.items, " ")
                        s[3] = px
                        s[4] = currentY
                        s[5] = 11
                        s[6] = COLOR_GRAY
                    end
                end
            end
        end
    end

    -- ===== IWOS ESP =====
    if Options.EnableToolsESP then
        local toolsMaxDistSq = Options.ToolsMaxDist * Options.ToolsMaxDist

        for i = 1, #IWOSCache do
            if drawIdx >= MAX_DRAWINGS - 5 then break end
            local rt = IWOSCache[i]
            if rt and rt.Position then
                local rx, ry, rz = rt.Position.X, rt.Position.Y, rt.Position.Z
                local dx, dy, dz = rx - lpx, ry - lpy, rz - lpz

                if dx*dx + dy*dy + dz*dz <= toolsMaxDistSq then
                    local screenPos, onScreen = WorldToScreen(Vector3_new(rx, ry + 1, rz))
                    if onScreen then
                        local dist = math_floor(math_sqrt(dx*dx + dy*dy + dz*dz) + 0.5)

                        drawIdx = drawIdx + 1
                        local s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = "[Indestructible]"
                        s[3] = screenPos.X
                        s[4] = screenPos.Y - 6
                        s[5] = 14
                        s[6] = COLOR_WHITE

                        drawIdx = drawIdx + 1
                        s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = dist .. "s"
                        s[3] = screenPos.X
                        s[4] = screenPos.Y + 8
                        s[5] = 12
                        s[6] = COLOR_OFFWHITE
                    end
                end
            end
        end
    end

    -- ===== CURE ESP =====
    if Options.EnableCureESP then
        local cureMaxDistSq = Options.ToolsMaxDist * Options.ToolsMaxDist

        for i = 1, #CureCache do
            if drawIdx >= MAX_DRAWINGS - 5 then break end
            local rt = CureCache[i]
            if rt and rt.Position then
                local rx, ry, rz = rt.Position.X, rt.Position.Y, rt.Position.Z
                local dx, dy, dz = rx - lpx, ry - lpy, rz - lpz

                if dx*dx + dy*dy + dz*dz <= cureMaxDistSq then
                    local screenPos, onScreen = WorldToScreen(Vector3_new(rx, ry + 1, rz))
                    if onScreen then
                        local dist = math_floor(math_sqrt(dx*dx + dy*dy + dz*dz) + 0.5)
                        local label = "[Cure]"
                        local col = COLOR_CURE
                        if rt.Name == "TheCure" then
                            label = "[The Cure]"
                        elseif rt.Name == "QetsiyahCure" then
                            label = "[Qet Cure]"
                            col = COLOR_QETCURE
                        end

                        drawIdx = drawIdx + 1
                        local s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = label
                        s[3] = screenPos.X
                        s[4] = screenPos.Y - 6
                        s[5] = 14
                        s[6] = col

                        drawIdx = drawIdx + 1
                        s = DrawStates[drawIdx]
                        s[1] = true
                        s[2] = dist .. "s"
                        s[3] = screenPos.X
                        s[4] = screenPos.Y + 8
                        s[5] = 12
                        s[6] = COLOR_OFFWHITE
                    end
                end
            end
        end
    end

    -- ===== PLANT ESP =====
    if Options.EnablePlantESP then
        local plantMaxDistSq = Options.PlantMaxDist * Options.PlantMaxDist
        local showPlantName = Options.ShowPlantName
        local showPlantDist = Options.ShowPlantDist

        for i = 1, #PlantCache do
            if drawIdx >= MAX_DRAWINGS - 5 then break end
            local plantData = PlantCache[i]
            if plantData then
                local rt = plantData.root
                if rt then
                    local nm = plantData.name
                    local plantVis = false
                    local plantColorIdx = 0

                    if nm == PLANT_NAMES[1] then plantVis = Options.ShowWolfsbane; plantColorIdx = 1
                    elseif nm == PLANT_NAMES[2] then plantVis = Options.ShowVampite; plantColorIdx = 2
                    elseif nm == PLANT_NAMES[3] then plantVis = Options.ShowSenia; plantColorIdx = 3
                    elseif nm == PLANT_NAMES[4] then plantVis = Options.ShowMooncap; plantColorIdx = 4
                    elseif nm == PLANT_NAMES[5] then plantVis = Options.ShowNightshade; plantColorIdx = 5
                    elseif nm == PLANT_NAMES[6] then plantVis = Options.ShowAerpine; plantColorIdx = 6
                    elseif nm == PLANT_NAMES[7] then plantVis = Options.ShowYarrow; plantColorIdx = 7
                    elseif nm == PLANT_NAMES[8] then plantVis = Options.ShowArcanith; plantColorIdx = 8
                    elseif nm == PLANT_NAMES[9] then plantVis = Options.ShowDerrida; plantColorIdx = 9
                    elseif nm == PLANT_NAMES[10] then plantVis = Options.ShowSanguinia; plantColorIdx = 10
                    elseif nm == PLANT_NAMES[11] then plantVis = Options.ShowPerennia; plantColorIdx = 11 end

                    if plantVis then
                        local rx, ry, rz = rt.Position.X, rt.Position.Y, rt.Position.Z
                        local dx, dy, dz = rx - lpx, ry - lpy, rz - lpz

                        if dx*dx + dy*dy + dz*dz <= plantMaxDistSq then
                            local screenPos, onScreen = WorldToScreen(Vector3_new(rx, ry + 1, rz))
                            if onScreen then
                                local plantColor = PLANT_COLORS[plantColorIdx] or COLOR_GREEN
                                if showPlantName then
                                    drawIdx = drawIdx + 1
                                    local s = DrawStates[drawIdx]
                                    s[1] = true
                                    s[2] = nm
                                    s[3] = screenPos.X
                                    s[4] = screenPos.Y - 6
                                    s[5] = 12
                                    s[6] = plantColor
                                end
                                if showPlantDist then
                                    local dist = math_floor(math_sqrt(dx*dx + dy*dy + dz*dz) + 0.5)
                                    drawIdx = drawIdx + 1
                                    local s = DrawStates[drawIdx]
                                    s[1] = true
                                    s[2] = dist .. "s"
                                    s[3] = screenPos.X
                                    s[4] = screenPos.Y + 6
                                    s[5] = 12
                                    s[6] = COLOR_OFFWHITE
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- ===== APPLY ALL DRAWINGS =====
    for i = 1, MAX_DRAWINGS do
        local d = DrawPool[i]
        local s = DrawStates[i]
        if s[1] then
            d.Text = s[2]
            d.Position = Vector2_new(s[3], s[4])
            d.Size = s[5]
            d.Color = s[6]
            d.Visible = true
            s[1] = false
        else
            d.Visible = false
        end
    end
end)

-- ============================================
-- UI SETUP
-- ============================================

local Visuals = win:Tab("Visuals", "eye")
local Notifiers = win:Tab("Notifiers", "bell")
win:AddSettingsTab("cog")

-- Player ESP Section
local PlayerESP = Visuals:Section("Player ESP", "Left")
PlayerESP:Toggle("Enable Player ESP", Options.EnablePlayerESP, function(on) 
    Options.EnablePlayerESP = on
    if not on then
        for i = 1, MAX_DRAWINGS do DrawPool[i].Visible = false end
    end
    notify("Player ESP " .. (on and "enabled" or "disabled"), "ESP", 2) 
end)
PlayerESP:Slider("Max Distance", Options.MaxDist, 500, 500, 5000, "s", function(v) Options.MaxDist = v end)
PlayerESP:Slider("ESP Refresh Rate", Options.ESPRefreshRate, 15, 5, 60, "fps", function(v) Options.ESPRefreshRate = v end)

-- Tools ESP Section
local ToolsESP = Visuals:Section("Tools ESP", "Left")
ToolsESP:Toggle("Enable IWOS ESP", Options.EnableToolsESP, function(on) 
    Options.EnableToolsESP = on
    notify("IWOS ESP " .. (on and "enabled" or "disabled"), "ESP", 2) 
end)
ToolsESP:Toggle("Enable Cure ESP", Options.EnableCureESP, function(on) 
    Options.EnableCureESP = on
    notify("Cure ESP " .. (on and "enabled" or "disabled"), "ESP", 2) 
end)
ToolsESP:Slider("Max Distance", Options.ToolsMaxDist, 500, 500, 10000, "s", function(v) Options.ToolsMaxDist = v end)

ToolsESP:Button("Check IWOS", function()
    if #IWOSCache > 0 then
        notify("IWOS found on map! (" .. #IWOSCache .. " total)", "IWOS Check", 3)
    else
        notify("No IWOS found on map", "IWOS Check", 3)
    end
end)

ToolsESP:Button("Check Cure", function()
    if #CureCache > 0 then
        notify("Cure found on map! (" .. #CureCache .. " total)", "Cure Check", 3)
    else
        notify("No Cure found on map", "Cure Check", 3)
    end
end)

-- ESP Features Section
local ESPFeatures = Visuals:Section("ESP Features", "Right")
ESPFeatures:Toggle("Show Species", Options.ShowSpecies, function(on) Options.ShowSpecies = on end)
ESPFeatures:Toggle("Show Character Name", Options.ShowRealName, function(on) Options.ShowRealName = on end)
ESPFeatures:Toggle("Show Player Name", Options.ShowPlayerName, function(on) Options.ShowPlayerName = on end)
ESPFeatures:Toggle("Show Distance", Options.ShowDistance, function(on) Options.ShowDistance = on end)
ESPFeatures:Toggle("Show Backpack Items", Options.ShowItems, function(on) Options.ShowItems = on end)

-- Plant ESP Section
local PlantESP = Visuals:Section("Plant ESP", "Left")
PlantESP:Toggle("Enable Plant ESP", Options.EnablePlantESP, function(on) 
    Options.EnablePlantESP = on
    notify("Plant ESP " .. (on and "enabled" or "disabled"), "ESP", 2) 
end)
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

-- Notifiers Section
local NotifSection = Notifiers:Section("Notifiers", "Left")
NotifSection:Toggle("IWOS Notifier", Options.IWOSNotifier, function(on) 
    Options.IWOSNotifier = on
    notify("IWOS Notifier " .. (on and "enabled" or "disabled"), "Notifier", 2) 
end)
NotifSection:Toggle("Cure Notifier", Options.CureNotifier, function(on) 
    Options.CureNotifier = on
    notify("Cure Notifier " .. (on and "enabled" or "disabled"), "Notifier", 2) 
end)
NotifSection:Slider("Notification Duration", Options.NotifDuration, 1, 1, 15, "s", function(v) Options.NotifDuration = v end)

local StaffSection = Notifiers:Section("Staff Notifier", "Left")
StaffSection:Toggle("Staff Notifier", Options.StaffNotifier, function(on) 
    Options.StaffNotifier = on
    notify("Staff Notifier " .. (on and "enabled" or "disabled"), "Notifier", 2) 
end)

-- Settings Section
local settingsSection = win:SettingsSection("Menu", "Left")
settingsSection:Button("Unload", function()
    Lib:Dialog({title = "Unload?", text = "Remove Dav's Gui from the game?", confirm = "Unload", onConfirm = function()
        running = false
        RenderConnection:Disconnect()
        for i = 1, MAX_DRAWINGS do
            if DrawPool[i] then
                DrawPool[i]:Remove()
                DrawPool[i] = nil
            end
        end
        notify("Dav's Gui has been unloaded", "Goodbye!", 3)
        task_wait(3)
        Lib:Destroy()
    end})
end)

-- ============================================
-- INITIAL NOTIFICATIONS
-- ============================================

if #IWOSCache > 0 then 
    notify("IWOS found on map! (" .. #IWOSCache .. " total)", "IWOS Detected", 6) 
end

if #CureCache > 0 then 
    local cureNames = {}
    for _, rt in ipairs(CureCache) do
        if rt.Name == "TheCure" then cureNames[#cureNames + 1] = "The Cure"
        elseif rt.Name == "QetsiyahCure" then cureNames[#cureNames + 1] = "Qet Cure" 
        end
    end
    notify("Cure found on map! (" .. table_concat(cureNames, ", ") .. ")", "Cure Info", 5)
end

notify("Welcome!", "Dav's Gui - The Vampire Legends Hub", 6)
print("Dav's Gui loaded successfully!")