local env = getfenv(1)
if type(env.VinlandResearch) == "table" then
    for _, key in ipairs({"testImage", "testBox"}) do
        local object = env.VinlandResearch[key]
        if object then
            pcall(function() object.Visible = false end)
            pcall(function() object:Remove() end)
            env.VinlandResearch[key] = nil
        end
    end
end
if type(env.Larpsec) == "table" and type(env.Larpsec.Unload) == "function" then
    local ok, restored = pcall(env.Larpsec.Unload)
    if not ok or restored == false then
        print("Larpsec: the previous session could not restore its templates. Keep Allow Unsafe LuaU enabled and call Larpsec.Unload() again.")
        return
    end
    for _, object in pairs(env.Larpsec.DrawingRegistry or env.Larpsec.OverlayDrawings or {}) do
        pcall(function() object.Visible = false end)
        pcall(function() object:Remove() end)
    end
end
if type(env.Vinland) == "table" and type(env.Vinland.Unload) == "function" then
    pcall(env.Vinland.Unload)
end
pcall(function()
    if type(UI) == "table" then UI.RemoveTab("Vinland") end
end)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Http = game:GetService("HttpService")
local Run = game:GetService("RunService")
local player = Players.LocalPlayer
if not player or game.PlaceId ~= 120851538706364 then
    print("Larpsec: open Murder Duels before running this script.")
    return
end
if type(UI) ~= "table" or type(Drawing) ~= "table" then
    print("Larpsec: this Matcha build needs UI Binding and Drawing.")
    return
end

local metadata = {
    ["Knife:Alien"] = {"Alien", "76947360651099", "Rare"},
    ["Knife:Astronaut"] = {"Astronaut", "115194445964397", "Rare"},
    ["Knife:Banana"] = {"Banana", "99981294531183", "Legendary"},
    ["Knife:BaseballBat"] = {"Baseball Bat", "94858337720347", "Legendary"},
    ["Knife:Berry"] = {"Berry", "90063391758248", "Rare"},
    ["Knife:BlueEnergyBlade"] = {"Beta Energy Blade", "96191889430279", "Legendary"},
    ["Knife:Blueprint"] = {"Blueprint", "90714254475492", "Rare"},
    ["Knife:CandyCorn"] = {"Candy Corn", "136836288375503", "Epic"},
    ["Knife:CatAxe"] = {"Cat Axe", "84020876787794", "Legendary"},
    ["Knife:ChampionKnife"] = {"Champion's Knife", "99735601715115", "Exclusive"},
    ["Knife:ChromaKatana"] = {"Chroma Katana", "113864410604080", "Collectible"},
    ["Knife:Cobweb"] = {"Cobweb", "119883366800498", "Uncommon"},
    ["Knife:Constellation"] = {"Constellation", "79515314347765", "Rare"},
    ["Knife:CthuluKarambit"] = {"Cthulhu Karambit", "106195793511887", "Secret"},
    ["Knife:DarkKarambit"] = {"Dark Karambit", "98797881472817", "Legendary"},
    ["Knife:Default"] = {"Original / Default", "103518456673098", "Common"},
    ["Knife:DevilTrident"] = {"Devil's Trident", "122206688240939", "Secret"},
    ["Knife:Dusekkar"] = {"Dusekkar", "129672419505890", "Legendary"},
    ["Knife:ET"] = {"ET", "109224204163009", "Rare"},
    ["Knife:EmoKawaii"] = {"Heartbreaker", "137033130517220", "Epic"},
    ["Knife:EpicFace"] = {"Epic Face", "133323859843217", "Uncommon"},
    ["Knife:EvilKitty"] = {"Evil Kitty", "130448173172665", "Secret"},
    ["Knife:Fire"] = {"Inferno", "72621303144988", "Epic"},
    ["Knife:Firework"] = {"Firework", "99593534945702", "Epic"},
    ["Knife:GalaxyKarambit"] = {"Cosmic Karambit", "89816989952276", "Secret"},
    ["Knife:Ghost"] = {"Ghost", "140163058352015", "Rare"},
    ["Knife:Glass"] = {"Glass", "92315688990019", "Rare"},
    ["Knife:GoldenStiletto"] = {"Golden Stiletto", "119586150762279", "Legendary"},
    ["Knife:GreenEnergyBlade"] = {"Gamma Energy Blade", "78625883985119", "Legendary"},
    ["Knife:Guest666"] = {"Guest 666", "136058085816639", "Uncommon"},
    ["Knife:Hacker"] = {"Hacker", "134303794069073", "Epic"},
    ["Knife:HeartKeeperKnife"] = {"Heart Keeper", "98095464465031", "Legendary"},
    ["Knife:HeartStealerKnife"] = {"Heart Stealer", "85464693127399", "Legendary"},
    ["Knife:Infected"] = {"Infected", "91079392225987", "Epic"},
    ["Knife:Infernum"] = {"Infernum", "88774637538202", "Secret"},
    ["Knife:Karambit"] = {"Karambit", "124484328585281", "Legendary"},
    ["Knife:KitchenKnife"] = {"Kitchen Knife", "85034951081389", "Epic"},
    ["Knife:Kitty"] = {"Kitty", "118920004665939", "Epic"},
    ["Knife:KittyCone"] = {"Kitty Cone", "123012236031090", "Legendary"},
    ["Knife:Kunai"] = {"Kunai", "106471222888583", "Legendary"},
    ["Knife:LMAD"] = {"[OG] LMaD", "106390349525010", "Legendary"},
    ["Knife:LMADNew"] = {"LMaD", "78885364898599", "Legendary"},
    ["Knife:LibertysEdge"] = {"Liberty's Edge", "123817213548184", "Legendary"},
    ["Knife:Lightning"] = {"Lightning", "122625127426092", "Legendary"},
    ["Knife:Lotus"] = {"Lotus", "111378083145156", "Legendary"},
    ["Knife:Lunaris"] = {"Lunaris", "104680532199869", "Legendary"},
    ["Knife:Megalodon"] = {"Megalodon", "77917097156627", "Legendary"},
    ["Knife:Mermaid"] = {"Mermaid", "76172380731880", "Legendary"},
    ["Knife:Meteor"] = {"Meteor", "140446601082911", "Epic"},
    ["Knife:MidnightKatana"] = {"Midnight Katana", "134405098379727", "Legendary"},
    ["Knife:MonoSaber"] = {"Mono Saber", "98665351713383", "Secret"},
    ["Knife:Moonrock"] = {"Moonrock", "113366202960398", "Rare"},
    ["Knife:NegativeMidnightKatana"] = {"[NEGATIVE] Midnight Katana", "77604076787343", "Legendary"},
    ["Knife:Noob"] = {"Noob", "77260651295271", "Rare"},
    ["Knife:OG"] = {"OG", "123335838537457", "Exclusive"},
    ["Knife:OmegaEnergyBlade"] = {"Omega Energy Blade", "95117527383202", "Secret"},
    ["Knife:Oops"] = {"Oops!", "80393575914809", "Common"},
    ["Knife:Paintbrush"] = {"Paintbrush", "114292006145928", "Exclusive"},
    ["Knife:Pineapple"] = {"Pineapple", "110129998204602", "Rare"},
    ["Knife:Popsicle"] = {"Popsicle", "129277182724615", "Legendary"},
    ["Knife:Poseidon"] = {"Poseidon", "129682058342038", "Secret"},
    ["Knife:Pumpkin"] = {"Pumpkin", "95088680944687", "Rare"},
    ["Knife:PumpkinBucket"] = {"Pumpkin Bucket", "106178170576331", "Legendary"},
    ["Knife:PurpleInfected"] = {"Purple Infected", "85199135738754", "Epic"},
    ["Knife:RedEnergyBlade"] = {"Alpha Energy Blade", "107314489273924", "Legendary"},
    ["Knife:RedStiletto"] = {"Red Stiletto", "103805000884758", "Exclusive"},
    ["Knife:Robux"] = {"Robux", "126303185251459", "Rare"},
    ["Knife:Saber"] = {"Saber", "118790627055947", "Secret"},
    ["Knife:Seraphim"] = {"Seraphim", "91541830281504", "Secret"},
    ["Knife:ShootingStar"] = {"Shooting Star", "106590594853332", "Epic"},
    ["Knife:Skeleta"] = {"Skeleta", "101469136691328", "Secret"},
    ["Knife:SkullSword"] = {"Riddling Daggers", "90200438861523", "Legendary"},
    ["Knife:Sky"] = {"Sky", "115109389811161", "Uncommon"},
    ["Knife:Smooch"] = {"Smooch", "83345205276006", "Uncommon"},
    ["Knife:Snake"] = {"Snake", "122042857128919", "Rare"},
    ["Knife:Solaris"] = {"Solaris", "131797865281568", "Legendary"},
    ["Knife:SpaceKitty"] = {"Space Kitty", "73119498555095", "Secret"},
    ["Knife:SpiderKnife"] = {"Spider Knife", "139229342174289", "Secret"},
    ["Knife:USA"] = {"USA", "97460062881978", "Rare"},
    ["Knife:VampireScythes"] = {"Vampire Scythes", "86063677496159", "Legendary"},
    ["Knife:Voidreaver"] = {"Voidreaver", "113010665465530", "Secret"},
    ["Knife:Watermelon"] = {"Watermelon", "101692685073806", "Rare"},
    ["Knife:WhiteCatAxe"] = {"White Cat Axe", "79104534767459", "Legendary"},
    ["Knife:Zombie"] = {"Zombie", "85336026177365", "Rare"},
    ["Revolver:Alien"] = {"Alien", "122110500453018", "Rare"},
    ["Revolver:Astronaut"] = {"Astronaut", "117628383233582", "Rare"},
    ["Revolver:BlueEnergyBlaster"] = {"Beta Energy Blaster", "91693707122064", "Legendary"},
    ["Revolver:Camo"] = {"Camo", "84516295025267", "Uncommon"},
    ["Revolver:CandyCorn"] = {"Candy Corn", "101037756422820", "Epic"},
    ["Revolver:Caramel"] = {"Caramel", "132254348735068", "Rare"},
    ["Revolver:CatShotgun"] = {"Cat Shotgun", "98300018455990", "Legendary"},
    ["Revolver:Caution"] = {"Caution", "87176067372634", "Uncommon"},
    ["Revolver:ChampionSniper"] = {"Champion's Sniper", "81861642329371", "Exclusive"},
    ["Revolver:ChromaSniper"] = {"Chroma Sniper", "137676519041912", "Collectible"},
    ["Revolver:DarkDeagle"] = {"Dark Deagle", "132947538954476", "Legendary"},
    ["Revolver:Deagle"] = {"Deagle", "122336383053245", "Legendary"},
    ["Revolver:Default"] = {"Original / Default", "88923165127035", "Common"},
    ["Revolver:Diamond"] = {"Diamond", "75252226760940", "Rare"},
    ["Revolver:Dusekkar"] = {"Dusekkar", "139577601507973", "Legendary"},
    ["Revolver:EmoKawaii"] = {"Heartbreaker", "72092865919517", "Epic"},
    ["Revolver:EvilKitty"] = {"Evil Kitty", "91213766191880", "Secret"},
    ["Revolver:EvilSniper"] = {"Devil's Sight", "85269801008661", "Collectible"},
    ["Revolver:Fire"] = {"Inferno", "107392103220579", "Epic"},
    ["Revolver:Firework"] = {"Firework", "105749047612813", "Epic"},
    ["Revolver:Galaxy"] = {"Cosmic Sight", "94250711597757", "Secret"},
    ["Revolver:Ghost"] = {"Ghost", "113618697740067", "Rare"},
    ["Revolver:Glass"] = {"Glass", "112392644365302", "Rare"},
    ["Revolver:GoldenLuger"] = {"Golden Luger", "111560601883739", "Legendary"},
    ["Revolver:Graffiti"] = {"Graffiti", "129480728102714", "Rare"},
    ["Revolver:GreenEnergyBlaster"] = {"Gamma Energy Blaster", "87278722181497", "Legendary"},
    ["Revolver:Hacker"] = {"Hacker", "117489452383506", "Epic"},
    ["Revolver:HeartKeeperGun"] = {"Heart Keeper", "120876295568246", "Legendary"},
    ["Revolver:HeartStealerGun"] = {"Heart Stealer", "111349502828048", "Legendary"},
    ["Revolver:Ice"] = {"Ice", "125508191918010", "Epic"},
    ["Revolver:Infernum"] = {"Infernum", "106804078238591", "Secret"},
    ["Revolver:Kitty"] = {"Kitty", "139193290482965", "Epic"},
    ["Revolver:KittyCone"] = {"Kitty Cone", "80531718679371", "Legendary"},
    ["Revolver:LibertysJustice"] = {"Liberty's Justice", "98016907670935", "Legendary"},
    ["Revolver:Lightning"] = {"Lightning", "99838731321666", "Legendary"},
    ["Revolver:Lunaris"] = {"Lunaris", "79914974151200", "Legendary"},
    ["Revolver:Megalodon"] = {"Megalodon", "117003177988706", "Legendary"},
    ["Revolver:Mermaid"] = {"Mermaid", "109976740802084", "Legendary"},
    ["Revolver:Meteor"] = {"Meteor", "88529962745101", "Epic"},
    ["Revolver:MidnightCrossbow"] = {"Midnight Crossbow", "112700905336796", "Legendary"},
    ["Revolver:MoneyGun"] = {"Money Gun", "84692740534763", "Exclusive"},
    ["Revolver:Moonrock"] = {"Moonrock", "109863043118822", "Rare"},
    ["Revolver:MurderNote"] = {"Murder Note", "124998417829989", "Collectible"},
    ["Revolver:NegativeMidnightCrossbow"] = {"[NEGATIVE] Midnight Crossbow", "122433284368757", "Legendary"},
    ["Revolver:OmegaEnergyBlaster"] = {"Omega Energy Blaster", "75601278060441", "Secret"},
    ["Revolver:Poltergeist"] = {"Ghostwatcher", "121935479610180", "Secret"},
    ["Revolver:Pumpkin"] = {"Pumpkin", "107715279565111", "Rare"},
    ["Revolver:PumpkinLauncher"] = {"Pumpkin Launcher", "128482648181854", "Legendary"},
    ["Revolver:PurpleLuger"] = {"Purple Luger", "82313936587992", "Exclusive"},
    ["Revolver:Railgun"] = {"Railgun Z1", "78884788771522", "Collectible"},
    ["Revolver:RayGun"] = {"Ray Blaster", "128274569084868", "Secret"},
    ["Revolver:RedEnergyBlaster"] = {"Alpha Energy Blaster", "106649051731783", "Legendary"},
    ["Revolver:RedLuger"] = {"Red Luger", "119998555646801", "Exclusive"},
    ["Revolver:Rusty"] = {"Rusty", "107475626358393", "Uncommon"},
    ["Revolver:Seaside"] = {"Seaside", "95324781516315", "Uncommon"},
    ["Revolver:Seraphim"] = {"Seraphim", "132903002071637", "Secret"},
    ["Revolver:ShootingStar"] = {"Shooting Star", "139982404269553", "Epic"},
    ["Revolver:Silencer"] = {"Silencer", "101309265091993", "Legendary"},
    ["Revolver:SkullRevolver"] = {"Riddling Revolver", "135677828046284", "Legendary"},
    ["Revolver:Snake"] = {"Snake", "85335899569392", "Rare"},
    ["Revolver:Solaris"] = {"Solaris", "83792847858499", "Legendary"},
    ["Revolver:SpaceKitty"] = {"Space Kitty", "102728522721646", "Secret"},
    ["Revolver:SpiderBow"] = {"Spider Bow", "81171100843068", "Secret"},
    ["Revolver:Toxic"] = {"Toxic", "96130088955905", "Rare"},
    ["Revolver:Triton"] = {"Triton", "107913443977903", "Legendary"},
    ["Revolver:Turtle"] = {"Turtle", "100749733504362", "Rare"},
    ["Revolver:USA"] = {"USA", "115295309690166", "Rare"},
    ["Revolver:UltraSoaker"] = {"Ultra Soaker", "128363506851249", "Legendary"},
    ["Revolver:Unblinking"] = {"Unblinking", "77071504745543", "Uncommon"},
    ["Revolver:VampireGun"] = {"Vampire Gunblade", "126969830150293", "Legendary"},
    ["Revolver:Voidcaster"] = {"Voidcaster", "105128254496254", "Secret"},
    ["Revolver:Watermelon"] = {"Watermelon", "81878210615984", "Rare"},
    ["Revolver:WhiteCatShotgun"] = {"White Cat Shotgun", "77987996744091", "Legendary"},
    ["Revolver:Zombie"] = {"Zombie", "109643917787271", "Rare"},
}
local state = {
    Running = true,
    Visible = true,
    Enabled = true,
    AutoApply = true,
    ApplyEnabled = false,
    NativeHotbarIcons = true,
    NativeIconReady = false,
    NativeIconOffset = 0xAA8,
    NativeIconBindings = {},
    NativeIconUnavailable = {},
    ExtendedSkins = true,
    UnsafeReady = false,
    AliasBindings = {},
    AliasNames = {},
    Suspended = {},
    ReplayActive = false,
    ResumeAfterReplay = false,
    Page = 1,
    Tab = "Skins",
    Filter = "All",
    Query = "",
    Focus = false,
    Dirty = true,
    Favorites = {},
    Selected = {},
    SelectionRevision = {Knife = 0, Revolver = 0},
    Pending = {},
    Originals = {},
    Written = {},
    EffectOriginals = {},
    EffectWritten = {},
    EffectUnavailable = {},
    EffectAttempted = {},
    EffectFailedValue = {},
    Applied = {},
    Images = {},
    ImageQueue = {},
    ImageQueued = {},
    ImageFailures = {},
    HotbarRefs = {},
    Errors = 0,
    Status = "Choose a skin, then switch weapons to refresh its model.",
    Connections = {},
    Catalog = {},
    Lookup = {},
    Bounds = {},
    Hover = "",
    LastToggle = -10,
    Version = "2.8",
    DrawingRegistry = {},
    ProfileLoaded = false,
    IconCount = 0
}
env.Larpsec = state
local restoreNativeIcons, validateNativeIconLayout
local kinds = {"Knife", "Revolver"}
local labels = {Knife = "KNIFE", Revolver = "REVOLVER"}
local folders = {Knife = RS:FindFirstChild("Knives"), Revolver = RS:FindFirstChild("Revolvers")}
local effectRoot = RS:FindFirstChild("Effect")
effectRoot = effectRoot and effectRoot:FindFirstChild("Container")
local effectFolders = {
    Knife = effectRoot and effectRoot:FindFirstChild("ThrowEffects"),
    Revolver = effectRoot and effectRoot:FindFirstChild("BulletEffects")
}
local effectAttributes = {Knife = "ThrowEffect", Revolver = "ShotEffect"}
local effectAliases = {HeartKeeperKnife = "HeartKeeperTrail", HeartStealerKnife = "HeartStealerTrail"}
local mouse = player:GetMouse()
local replayRoot
local function replayContextActive()
    replayRoot = workspace:FindFirstChild("Replays")
    local replayId = player:GetAttribute("LobbySpectateMatchId")
    local replayFreecam = player:GetAttribute("ReplayFreecam")
    return replayId == "__REPLAY__" or replayFreecam == true or (replayRoot ~= nil and #replayRoot:GetChildren() > 0)
end
state.ReplayActive = replayContextActive()
local configPath = "Larpsec/profile.json"
local legacyConfigPath = "Vinland/profile.json"
local colors = {
    Background = Color3.fromRGB(11, 12, 13),
    Panel = Color3.fromRGB(17, 18, 19),
    Card = Color3.fromRGB(18, 19, 20),
    Hover = Color3.fromRGB(29, 30, 31),
    Selected = Color3.fromRGB(34, 35, 36),
    Border = Color3.fromRGB(43, 44, 45),
    White = Color3.fromRGB(229, 229, 226),
    Muted = Color3.fromRGB(143, 144, 143),
    Yellow = Color3.fromRGB(190, 190, 184),
    Dark = Color3.fromRGB(17, 18, 19),
    Green = Color3.fromRGB(157, 176, 159)
}
local rarityColors = {
    Common = Color3.fromRGB(151, 153, 154),
    Uncommon = Color3.fromRGB(139, 162, 145),
    Rare = Color3.fromRGB(139, 155, 174),
    Epic = Color3.fromRGB(161, 146, 170),
    Legendary = Color3.fromRGB(181, 166, 136),
    Secret = Color3.fromRGB(177, 148, 159),
    Collectible = Color3.fromRGB(181, 147, 140)
}
local rarityOrder = {Collectible = 7, Secret = 6, Legendary = 5, Epic = 4, Rare = 3, Uncommon = 2, Common = 1}

local function clean(text)
    return tostring(text or ""):gsub("[\128-\255]", ""):gsub("[%c]", " ")
end

local function address(obj)
    return obj and obj.Address or 0
end

local function rigAddress(kind)
    local char = player.Character
    return address(char and char:FindFirstChild(kind .. "Rig"))
end

local function equippedName()
    local char = player.Character
    if char then
        for _, kind in ipairs(kinds) do
            local tool = char:FindFirstChild(kind)
            if tool and tool.ClassName == "Tool" then return kind end
        end
    end
    return ""
end
state.EquippedName = equippedName()
state.EquipEpoch = 0

local function setStatus(text)
    state.Status = text
    state.Dirty = true
end

local function diskSetup()
    if not isfolder("Larpsec") then makefolder("Larpsec") end
    if not isfolder("Larpsec/icons") then makefolder("Larpsec/icons") end
    if not isfile(configPath) and isfile(legacyConfigPath) then
        local oldProfile = readfile(legacyConfigPath)
        if type(oldProfile) == "string" then writefile(configPath, oldProfile) end
    end
end
pcall(diskSetup)

local function validPointer(value)
    return type(value) == "number" and value > 65536 and value < 140737488355328
end

local function nameMatches(pointer, expected)
    if not validPointer(pointer) then return false end
    if memory_read("string", pointer) == expected then return true end
    local buffer = memory_read("uintptr", pointer)
    return validPointer(buffer) and memory_read("string", buffer) == expected
end

local function validateMemory()
    state.UnsafeReady = false
    if type(memory_read) ~= "function" or type(memory_write) ~= "function" then return false end
    local ok = pcall(function()
        local knife = folders.Knife and folders.Knife:FindFirstChild("Default")
        local gun = folders.Revolver and folders.Revolver:FindFirstChild("Default")
        local root = knife and knife:FindFirstChild("KnifeRoot")
        assert(knife and gun and root, "Reference templates are unavailable")
        local matches = {}
        for offset = 32, 384, 8 do
            if nameMatches(memory_read("uintptr", knife.Address + offset), "Default")
                and nameMatches(memory_read("uintptr", gun.Address + offset), "Default")
                and nameMatches(memory_read("uintptr", root.Address + offset), "KnifeRoot") then
                matches[#matches + 1] = offset
            end
        end
        assert(#matches == 1, "This Roblox build could not be validated")
        state.NameOffset = matches[1]
        state.UnsafeReady = true
    end)
    return ok and state.UnsafeReady
end
validateMemory()

local soundRoot = RS:FindFirstChild("Sound")
local animationRoot = RS:FindFirstChild("Anims")
animationRoot = animationRoot and animationRoot:FindFirstChild("Default")
local aliasSources = {}
for _, category in ipairs({"UI", "Misc"}) do
    local folder = soundRoot and soundRoot:FindFirstChild(category)
    if folder then
        for _, object in ipairs(folder:GetChildren()) do
            local name = object.Name
            if #name > 0 and #name <= 12 and not folders.Knife:FindFirstChild(name) and not folders.Revolver:FindFirstChild(name) then
                aliasSources[#aliasSources + 1] = object
            end
        end
    end
end

for _, kind in ipairs(kinds) do
    state.Originals[kind] = player:GetAttribute(kind .. "Skin") or "Default"
    local folder = folders[kind]
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if model.ClassName == "Model" then
                local key = kind .. ":" .. model.Name
                local info = metadata[key] or {}
                local item = {
                    Key = key,
                    Kind = kind,
                    Id = model.Name,
                    Name = clean(info[1] or model.Name:gsub("(%l)(%u)", "%1 %2")),
                    Icon = info[2],
                    Rarity = info[3] or "",
                    Template = model,
                    RequiresUnsafe = #model.Name > 15
                }
                if item.RequiresUnsafe then
                    local source = aliasSources[#state.AliasNames + 1]
                    if source then
                        state.AliasNames[#state.AliasNames + 1] = source.Name
                        item.AliasSource = source
                        item.Alias = source.Name
                    end
                end
                state.Catalog[#state.Catalog + 1] = item
                state.Lookup[key] = item
                if item.Icon then state.IconCount = state.IconCount + 1 end
            end
        end
    end
end
local function aliasConflict(kind, id)
    for _, target in ipairs(Players:GetPlayers()) do
        if target.UserId ~= player.UserId and target:GetAttribute(kind .. "Skin") == id then return true end
    end
    return false
end

local function releaseBinding(binding)
    if not binding then return end
    local failures = {}
    for i = #binding.Changes, 1, -1 do
        local change = binding.Changes[i]
        local ok, failure = pcall(function()
            local current = memory_read("uintptr", change.Object.Address + state.NameOffset)
            if current == change.AliasPointer then
                memory_write("uintptr", change.Object.Address + state.NameOffset, change.OriginalPointer)
                assert(nameMatches(memory_read("uintptr", change.Object.Address + state.NameOffset), change.Name), "Template restoration failed")
            else
                assert(current == change.OriginalPointer, "A template changed while Larpsec was using it")
            end
        end)
        if not ok then failures[#failures + 1] = tostring(failure) end
    end
    assert(#failures == 0, table.concat(failures, "; "))
end

local function prepareBinding(item)
    if not item.RequiresUnsafe then return nil end
    assert(state.ExtendedSkins and state.UnsafeReady, "Enable Extended skins and Allow Unsafe LuaU for this ID")
    assert(item.AliasSource and item.Alias, "No verified short alias is available")
    assert(not aliasConflict(item.Kind, item.Id), "Another player is using this template; retry later")
    local existing = state.AliasBindings[item.Kind]
    if existing and existing.Id == item.Id then return existing end
    local aliasPointer = memory_read("uintptr", item.AliasSource.Address + state.NameOffset)
    assert(nameMatches(aliasPointer, item.Alias), "The alias reference changed")
    local binding = {Id = item.Id, Alias = item.Alias, Changes = {}}
    local seen = {}
    local function bind(object)
        if not object or seen[object.Address] then return end
        seen[object.Address] = true
        local parent = object.Parent
        assert(parent and not parent:FindFirstChild(item.Alias), "An asset alias already exists")
        local name = object.Name
        local original = memory_read("uintptr", object.Address + state.NameOffset)
        assert(nameMatches(original, name), "An asset name could not be validated")
        binding.Changes[#binding.Changes + 1] = {Object = object, Name = name, OriginalPointer = original, AliasPointer = aliasPointer}
        memory_write("uintptr", object.Address + state.NameOffset, aliasPointer)
        assert(object.Name == item.Alias and address(parent:FindFirstChild(item.Alias)) == object.Address, "Asset alias verification failed")
    end
    local function child(parent, name)
        return parent and parent:FindFirstChild(name)
    end
    local ok, failure = pcall(function()
        bind(item.Template)
        bind(child(child(soundRoot, item.Kind), item.Id))
        bind(child(child(animationRoot, item.Kind == "Knife" and "Knives" or "Revolvers"), item.Id))
        bind(child(child(child(effectRoot, "EquipEffects"), item.Kind), item.Id))
        local effectName = item.Kind == "Knife" and (effectAliases[item.Id] or item.Id .. "Trail") or item.Id
        local effect = child(effectFolders[item.Kind], effectName)
        if effect then bind(effect); binding.EffectAlias = item.Alias end
    end)
    if not ok then
        releaseBinding(binding)
        error(failure)
    end
    return binding
end

table.sort(state.Catalog, function(a, b)
    local ar, br = rarityOrder[a.Rarity] or 0, rarityOrder[b.Rarity] or 0
    if ar ~= br then return ar > br end
    if a.Name ~= b.Name then return a.Name < b.Name end
    return a.Key < b.Key
end)

local function save(silent)
    local config = {
        Version = 3,
        Favorites = state.Favorites,
        Selected = state.Selected,
        AutoApply = state.AutoApply,
        NativeHotbarIcons = state.NativeHotbarIcons,
        ExtendedSkins = state.ExtendedSkins
    }
    local ok, failure = pcall(function()
        diskSetup()
        local encoded = Http:JSONEncode(config)
        if isfile(configPath) then
            local previous = readfile(configPath)
            local valid, decoded = pcall(function() return Http:JSONDecode(previous) end)
            if valid and type(decoded) == "table" then writefile("Larpsec/profile.previous.json", previous) end
        end
        writefile(configPath, encoded)
        assert(readfile(configPath) == encoded, "Profile verification failed")
    end)
    if ok then state.ProfileError = nil else state.ProfileError = tostring(failure) end
    if not ok then
        setStatus("Could not save the profile: " .. state.ProfileError)
        print("Larpsec profile: " .. state.ProfileError)
    elseif not silent then
        setStatus("Profile saved on this device.")
    end
    return ok
end
state.Save = save

local function writeEffect(kind, id)
    local attr = effectAttributes[kind]
    local folder = effectFolders[kind]
    local desired = kind == "Knife" and (effectAliases[id] or id .. "Trail") or id
    local binding = state.AliasBindings[kind]
    if binding and binding.Id == id and binding.EffectAlias then desired = binding.EffectAlias end
    if not folder or not folder:FindFirstChild(desired) then desired = "Default" end
    local current = player:GetAttribute(attr)
    if current == nil and desired == "Default" then
        state.EffectUnavailable[attr] = nil
        return true
    end
    if state.EffectUnavailable[attr] and state.EffectAttempted[attr] == desired and state.EffectFailedValue[attr] == current then return false end
    if state.EffectWritten[attr] == nil then
        state.EffectOriginals[attr] = {Value = current}
    elseif current ~= state.EffectWritten[attr] and current ~= desired then
        state.EffectOriginals[attr] = {Value = current}
    end
    if current ~= desired then player:SetAttribute(attr, desired) end
    state.EffectAttempted[attr] = desired
    if player:GetAttribute(attr) ~= desired then
        state.EffectUnavailable[attr] = true
        state.EffectFailedValue[attr] = current
        return false
    end
    state.EffectUnavailable[attr] = nil
    state.EffectWritten[attr] = desired
    return true
end

local function queue(kind, id, silent)
    id = tostring(id)
    local item = state.Lookup[kind .. ":" .. id]
    if not item then return false end
    if state.ReplayActive then
        state.Selected[kind] = id
        state.ResumeAfterReplay = true
        state.Dirty = true
        if not silent then save(true) end
        setStatus("Replay active. This selection will apply after you leave the replay.")
        return true
    end
    local attr = kind .. "Skin"
    local previousSelected = state.Selected[kind]
    local previousRevision = state.SelectionRevision[kind] or 0
    local previousWritten = state.Written[kind]
    local previousPending = state.Pending[kind]
    local previousSuspended = state.Suspended[kind]
    local previousApplied = state.Applied[kind]
    local previousOriginal = state.Originals[kind]
    local previousApplyEnabled = state.ApplyEnabled
    local previousAttribute = player:GetAttribute(attr)
    local previousBinding = state.AliasBindings[kind]
    local preparedBinding
    local ok, failure = pcall(function()
        local current = player:GetAttribute(attr)
        assert(type(current) ~= "string" or #current <= 15, "The current native skin ID cannot be restored safely by this Matcha build")
        if current ~= previousWritten and current ~= id and current then
            state.Originals[kind] = current
        end
        local before = rigAddress(kind)
        state.ApplyEnabled = false
        preparedBinding = prepareBinding(item)
        local effectiveId = preparedBinding and preparedBinding.Alias or id
        state.SelectionRevision[kind] = previousRevision + 1
        state.Selected[kind] = id
        state.Pending[kind] = {Before = before, Id = effectiveId, SourceId = id, Time = tick(), Epoch = state.EquipEpoch}
        state.Applied[kind] = nil
        player:SetAttribute(attr, effectiveId)
        assert(player:GetAttribute(attr) == effectiveId, "Matcha rejected the local skin attribute")
        state.AliasBindings[kind] = preparedBinding
        writeEffect(kind, id)
        if previousBinding and previousBinding ~= preparedBinding then releaseBinding(previousBinding) end
        state.Written[kind] = effectiveId
        state.Suspended[kind] = nil
        state.ApplyEnabled = true
    end)
    if not ok then
        if preparedBinding and preparedBinding ~= previousBinding then pcall(releaseBinding, preparedBinding) end
        state.AliasBindings[kind] = previousBinding
        pcall(function() player:SetAttribute(attr, previousAttribute) end)
        state.Selected[kind] = previousSelected
        state.SelectionRevision[kind] = previousRevision
        state.Written[kind] = previousWritten
        state.Pending[kind] = previousPending
        state.Applied[kind] = previousApplied
        state.Originals[kind] = previousOriginal
        state.ApplyEnabled = previousApplyEnabled
        state.Suspended[kind] = previousSuspended
        if item.RequiresUnsafe and not previousBinding and previousSelected == id then state.Suspended[kind] = id end
        setStatus("Could not queue " .. item.Name .. ": " .. tostring(failure))
        return false
    end
    if not silent then
        local unavailable = state.EffectUnavailable[effectAttributes[kind]]
        setStatus(item.Name .. (unavailable and ": model queued; Matcha cannot set its separate effect attribute." or ": queued. Switch weapons to preview it."))
        save(true)
    end
    state.Dirty = true
    return true
end

local function restore(silent)
    state.Pending = {}
    state.Applied = {}
    state.ApplyEnabled = false
    for _, kind in ipairs(kinds) do
        local current = player:GetAttribute(kind .. "Skin")
        if state.Written[kind] and current == state.Written[kind] then
            pcall(function() player:SetAttribute(kind .. "Skin", state.Originals[kind]) end)
        end
        state.Written[kind] = nil
    end
    local restorationErrors = {}
    for kind, binding in pairs(state.AliasBindings) do
        local ok, failure = pcall(releaseBinding, binding)
        if ok then state.AliasBindings[kind] = nil else restorationErrors[#restorationErrors + 1] = tostring(failure) end
    end
    state.Suspended = {}
    for attr, written in pairs(state.EffectWritten) do
        if player:GetAttribute(attr) == written then
            local original = state.EffectOriginals[attr]
            pcall(function() player:SetAttribute(attr, original and original.Value or nil) end)
        end
    end
    state.EffectWritten = {}
    state.EffectOriginals = {}
    state.EffectAttempted = {}
    state.EffectFailedValue = {}
    state.EffectUnavailable = {}
    if not silent then
        state.ResumeAfterReplay = false
        save(true)
        setStatus("Original skins restored. Saved loadout retained. Switch weapons to refresh.")
    end
    assert(#restorationErrors == 0, table.concat(restorationErrors, "; "))
end

local function setVisible(value)
    local nextVisible = value == true
    if nextVisible and not state.MouseOwned then
        state.MouseOriginal = player:GetAttribute("MouseUnlocked")
        pcall(function() player:SetAttribute("MouseUnlocked", (tonumber(state.MouseOriginal) or 0) + 1) end)
        state.MouseOwned = true
    elseif not nextVisible and state.MouseOwned then
        pcall(function()
            local current = tonumber(player:GetAttribute("MouseUnlocked")) or 0
            if current > 0 then
                local remaining = current - 1
                if remaining == 0 and state.MouseOriginal == nil then
                    player:SetAttribute("MouseUnlocked", nil)
                else
                    player:SetAttribute("MouseUnlocked", remaining)
                end
            end
        end)
        state.MouseOwned = false
    end
    state.Visible = nextVisible
    state.Focus = false
    state.Dirty = true
    pcall(setrobloxinput, not (state.Visible and isrbxactive()))
end

local pools = {Square = {}, Text = {}, Image = {}}
local counts = {Square = 0, Text = 0, Image = 0}
local limits = {Square = 180, Text = 130, Image = 18}
local function initPool()
    for kind, limit in pairs(limits) do
        for i = 1, limit do
            local obj = Drawing.new(kind)
            state.DrawingRegistry[#state.DrawingRegistry + 1] = obj
            obj.Visible = false
            obj.Transparency = 1
            obj.ZIndex = kind == "Square" and 100 or 104
            if kind == "Square" then obj.Filled = true end
            if kind == "Text" then
                obj.Font = 1
                obj.Outline = false
                obj.Center = false
            end
            pools[kind][i] = {Object = obj, Cache = {Visible = false}}
        end
    end
end
local poolOk, poolError = pcall(initPool)
if not poolOk then
    for _, pool in pairs(pools) do for _, entry in ipairs(pool) do pcall(function() entry.Object:Remove() end) end end
    state.Running = false
    print("Larpsec Drawing: " .. tostring(poolError))
    return
end

local function prop(entry, key, value)
    if entry.Cache[key] == value then return end
    entry.Object[key] = value
    entry.Cache[key] = value
end

local function take(kind)
    counts[kind] = counts[kind] + 1
    local entry = pools[kind][counts[kind]]
    assert(entry, "Larpsec: visual element limit reached")
    prop(entry, "Visible", true)
    return entry
end

local function position(entry, x, y)
    if entry.Cache.X ~= x or entry.Cache.Y ~= y then
        entry.Object.Position = Vector2.new(x, y)
        entry.Cache.X, entry.Cache.Y = x, y
    end
end

local function size(entry, w, h)
    if entry.Cache.W ~= w or entry.Cache.H ~= h then
        entry.Object.Size = Vector2.new(w, h)
        entry.Cache.W, entry.Cache.H = w, h
    end
end

local layout = {X = 0, Y = 0, Scale = 1, Width = 920, Height = 620}
local function rect(x, y, w, h, color, corner, z)
    local e = take("Square")
    position(e, layout.X + x * layout.Scale, layout.Y + y * layout.Scale)
    size(e, w * layout.Scale, h * layout.Scale)
    prop(e, "Color", color)
    prop(e, "Corner", (corner or 0) * layout.Scale)
    prop(e, "ZIndex", z or 100)
    return e
end

local function text(value, x, y, fontSize, color, maxWidth, bold)
    local e = take("Text")
    value = clean(value)
    if maxWidth then
        local n = math.max(2, math.floor(maxWidth / (fontSize * 0.53)))
        if #value > n then value = value:sub(1, n - 2) .. ".." end
    end
    prop(e, "Text", value)
    position(e, layout.X + x * layout.Scale, layout.Y + y * layout.Scale)
    prop(e, "Size", math.max(10, math.floor(fontSize * layout.Scale)))
    prop(e, "Color", color or colors.White)
    prop(e, "Font", bold and 2 or 1)
    return e
end

local function gradient(x, y, w, h, steps)
    for i = 0, steps - 1 do
        local t = i / math.max(1, steps - 1)
        rect(x + w * i / steps, y, w / steps + 0.5, h,
            Color3.fromRGB(255, 235 - 64 * t, 137 - 101 * t), 0, 102)
    end
end

local function imagePath(ref)
    if type(ref) ~= "string" then return nil end
    if ref:match("^%d+$") then return "Larpsec/icons/" .. ref .. ".dat" end
    local slug = ref:match("^https://murderduels%.org/items/([%w%-]+)%.webp$")
    return slug and "Larpsec/icons/site_" .. slug .. ".dat" or nil
end

local function legacyImagePath(ref)
    if type(ref) ~= "string" then return nil end
    if ref:match("^%d+$") then return "Vinland/icons/" .. ref .. ".dat" end
    local slug = ref:match("^https://murderduels%.org/items/([%w%-]+)%.webp$")
    return slug and "Vinland/icons/site_" .. slug .. ".dat" or nil
end

local function requestImage(ref)
    if not imagePath(ref) then return end
    if state.Images[ref] ~= nil or state.ImageQueued[ref] then return end
    state.ImageQueued[ref] = true
    state.ImageQueue[#state.ImageQueue + 1] = ref
end

local function icon(item, x, y, w, h)
    if not item or not item.Icon then
        text(item and "NO ICON" or "-", x + 5, y + h * 0.35, 10, colors.Muted, w - 10, true)
        return
    end
    requestImage(item.Icon)
    local bytes = state.Images[item.Icon]
    if type(bytes) ~= "string" then
        text(bytes == false and "?" or "...", x + w * 0.4, y + h * 0.25, 17, colors.Muted)
        return
    end
    local e = take("Image")
    position(e, layout.X + x * layout.Scale, layout.Y + y * layout.Scale)
    size(e, w * layout.Scale, h * layout.Scale)
    prop(e, "Color", colors.White)
    if e.Cache.ImageId ~= item.Icon then
        e.Object.Data = bytes
        e.Cache.ImageId = item.Icon
    end
end

local function button(id, label, x, y, w, h, fn, active, primary)
    local color = active and colors.Selected or (state.Hover == id and colors.Hover or colors.Card)
    rect(x, y, w, h, color, 2)
    if active then rect(x, y + 5, 2, h - 10, colors.White, 0, 103) end
    text(label, x + 12, y + (h - 14) / 2, 14, colors.White, w - 22, true)
    state.Bounds[#state.Bounds + 1] = {Id = id, X = x, Y = y, W = w, H = h, Action = fn}
end

local function filtered()
    local out = {}
    local query = state.Query:lower()
    for _, item in ipairs(state.Catalog) do
        local matches = (state.Filter == "All" or item.Kind == state.Filter) and type(item.Icon) == "string" and item.Icon:match("^%d+$") ~= nil
        matches = matches and (not item.RequiresUnsafe or (state.ExtendedSkins and state.UnsafeReady and item.Alias ~= nil))
        if state.Tab == "Favorites" then matches = matches and state.Favorites[item.Key] == true end
        if state.Tab == "Selected" then matches = matches and state.Selected[item.Kind] == item.Id end
        if matches and (query == "" or item.Name:lower():find(query, 1, true) or item.Id:lower():find(query, 1, true)) then
            out[#out + 1] = item
        end
    end
    return out
end

local firstPage = filtered()
for i = 1, math.min(12, #firstPage) do
    requestImage(firstPage[i].Icon)
end

local function render()
    for kind in pairs(counts) do counts[kind] = 0 end
    state.Bounds = {}
    if state.Visible and state.Active ~= false then
        rect(-2, -2, 924, 624, colors.Border, 10, 98)
        rect(0, 0, 920, 620, colors.Background, 9, 99)
        rect(20, 21, 2, 26, colors.White, 0)
        text("LARPSEC", 36, 21, 23, colors.White, 120, true)
        text("MURDER DUELS / COSMETICS", 164, 31, 11, colors.Muted, 330, true)
        button("close", "X", 868, 19, 32, 29, function() setVisible(false) end)
        rect(20, 62, 880, 1, colors.Border)
        for i, tab in ipairs({"Skins", "Favorites", "Selected", "Settings"}) do
            button("tab" .. tab, tab, 20 + (i - 1) * 220, 75, 212, 38, function()
                state.Tab, state.Page, state.Focus, state.Dirty = tab, 1, false, true
            end, state.Tab == tab)
        end
        rect(20, 127, 880, 40, colors.Panel, 5)
        text("SEARCH", 34, 141, 11, colors.Yellow, 86, true)
        local query = state.Query ~= "" and state.Query or "Search skins by name..."
        text(query .. (state.Focus and " |" or ""), 122, 139, 14, state.Query ~= "" and colors.White or colors.Muted, 690)
        state.Bounds[#state.Bounds + 1] = {Id = "search", X = 20, Y = 127, W = 835, H = 40, Action = function() state.Focus, state.Dirty = true, true end}
        button("clearsearch", "X", 860, 131, 33, 31, function() state.Query, state.Page, state.Dirty = "", 1, true end)
        rect(20, 183, 184, 339, colors.Panel, 6)
        text("COLLECTION", 34, 199, 12, colors.White, 160, true)
        for i, pair in ipairs({{"All", "All skins"}, {"Knife", "Knives"}, {"Revolver", "Revolvers"}}) do
            button("filter" .. pair[1], pair[2], 31, 226 + (i - 1) * 36, 162, 30, function()
                state.Filter, state.Page, state.Dirty = pair[1], 1, true
            end, state.Filter == pair[1])
        end
        rect(34, 343, 156, 1, colors.Border)
        text("YOUR SELECTION", 34, 357, 10, colors.Muted, 156, true)
        for i, kind in ipairs(kinds) do
            local id = state.Selected[kind]
            local item = id and state.Lookup[kind .. ":" .. id]
            local y = 382 + (i - 1) * 63
            icon(item, 34, y, 42, 42)
            text(labels[kind], 84, y + 2, 10, colors.Muted, 104, true)
            text(item and item.Name or "Original", 84, y + 17, 12, colors.White, 104)
            local pending = state.Pending[kind]
            text(pending and "On weapon switch" or (state.Applied[kind] and "Model updated" or "No changes"), 84, y + 33, 10, pending and colors.Yellow or colors.Green, 104)
        end
        rect(218, 183, 682, 339, colors.Panel, 6)
        if state.Tab == "Settings" then
            text("SETTINGS", 238, 202, 16, colors.White, 638, true)
            text("Auto apply saved loadout at startup", 238, 238, 13, colors.White, 460)
            text("Does not change your choice during this session", 238, 257, 10, colors.Muted, 460)
            button("autoapply", state.AutoApply and "ON" or "OFF", 790, 239, 82, 34, function()
                state.AutoApply = not state.AutoApply
                save(true)
                setStatus("Auto Apply " .. (state.AutoApply and "enabled" or "disabled") .. ".")
            end, state.AutoApply)
            rect(238, 291, 634, 1, colors.Border)
            text("Native hotbar icons", 238, 307, 13, colors.White, 460)
            text(state.NativeIconReady and "Patches the native hotbar locally; Roblox asset IDs only." or "Requires Allow Unsafe LuaU and a validated image layout.", 238, 326, 10, colors.Muted, 460)
            button("nativeicons", state.NativeHotbarIcons and "ON" or "OFF", 790, 307, 82, 34, function()
                if not state.NativeIconReady then
                    if state.UnsafeReady then
                        local ok, ready = pcall(validateNativeIconLayout)
                        state.NativeIconReady = ok and ready == true
                    end
                    if not state.NativeIconReady then
                        setStatus("Enable Allow Unsafe LuaU and reload to validate native hotbar icons.")
                        return
                    end
                end
                state.NativeHotbarIcons = not state.NativeHotbarIcons
                if not state.NativeHotbarIcons and restoreNativeIcons then pcall(restoreNativeIcons) end
                save(true)
                setStatus("Native hotbar icons " .. (state.NativeHotbarIcons and "enabled" or "restored") .. ".")
            end, state.NativeHotbarIcons and state.NativeIconReady)
            rect(238, 360, 634, 1, colors.Border)
            text("Extended skins", 238, 376, 13, colors.White, 460)
            text("Long IDs need Allow Unsafe LuaU. Memory layout is checked at startup.", 238, 395, 10, colors.Muted, 460)
            button("extendedskins", state.ExtendedSkins and state.UnsafeReady and "ON" or "OFF", 790, 377, 82, 34, function()
                if not state.UnsafeReady and not validateMemory() then
                    setStatus("Enable Allow Unsafe LuaU in Matcha, then reload Larpsec to use long IDs.")
                    return
                end
                state.ExtendedSkins = not state.ExtendedSkins
                if not state.ExtendedSkins then
                    for kind, binding in pairs(state.AliasBindings) do
                        player:SetAttribute(kind .. "Skin", state.Originals[kind])
                        releaseBinding(binding)
                        state.AliasBindings[kind] = nil
                        state.Written[kind], state.Pending[kind], state.Applied[kind] = nil, nil, nil
                        state.Suspended[kind] = binding.Id
                    end
                else
                    for _, kind in ipairs(kinds) do
                        local id = state.Selected[kind]
                        local item = id and state.Lookup[kind .. ":" .. id]
                        if item and item.RequiresUnsafe then queue(kind, id, true) end
                    end
                end
                save(true)
                setStatus("Extended skins " .. (state.ExtendedSkins and "enabled" or "disabled") .. ". Switch weapons to refresh.")
            end, state.ExtendedSkins and state.UnsafeReady)
            rect(238, 429, 634, 1, colors.Border)
            button("restore", "Restore original skins", 238, 449, 263, 36, function() restore(false) end)
            button("unload", "Unload Larpsec", 516, 449, 263, 36, function() state.Unload() end)
        else
            local list = filtered()
            state.Page = math.max(1, math.min(state.Page, math.max(1, math.ceil(#list / 12))))
            text(state.Tab == "Skins" and "CHOOSE A SKIN" or state.Tab:upper(), 234, 198, 13, colors.White, 380, true)
            text(tostring(#list) .. " SKINS", 806, 200, 10, colors.Muted, 80)
            for slot = 1, 12 do
                local item = list[(state.Page - 1) * 12 + slot]
                if item then
                    local x = 230 + ((slot - 1) % 4) * 164
                    local y = 228 + math.floor((slot - 1) / 4) * 85
                    local selected = state.Selected[item.Kind] == item.Id
                    local hovered = state.Hover == "skin" .. item.Key
                    rect(x, y, 157, 77, selected and colors.Selected or (hovered and colors.Hover or colors.Panel), 2)
                    rect(x + 7, y + 74, 143, 1, selected and colors.White or colors.Border, 0, 103)
                    icon(item, x + 7, y + 5, 51, 51)
                    text(item.Name, x + 63, y + 13, 12, colors.White, 88, true)
                    text(item.Rarity ~= "" and item.Rarity or labels[item.Kind], x + 63, y + 31, 10, rarityColors[item.Rarity] or colors.Muted, 88)
                    local cardLabel = item.Kind == "Knife" and "KNIFE" or "REVOLVER"
                    text(cardLabel .. (item.RequiresUnsafe and " / EXTENDED" or ""), x + 9, y + 57, 9, colors.Muted, 130)
                    text(state.Favorites[item.Key] and "*" or "+", x + 138, y + 3, 15, state.Favorites[item.Key] and colors.Yellow or colors.Muted)
                    state.Bounds[#state.Bounds + 1] = {Id = "skin" .. item.Key, X = x, Y = y, W = 132, H = 77, Action = function() queue(item.Kind, item.Id) end}
                    state.Bounds[#state.Bounds + 1] = {Id = "fav" .. item.Key, X = x + 133, Y = y, W = 24, H = 77, Action = function()
                        state.Favorites[item.Key] = not state.Favorites[item.Key] or nil
                        save(true)
                        state.Dirty = true
                    end}
                end
            end
            if #list == 0 then
                text("No skins match these filters.", 360, 336, 16, colors.Muted, 470)
            end
            button("previous", "<", 236, 487, 37, 25, function() state.Page, state.Dirty = math.max(1, state.Page - 1), true end)
            text("PAGE " .. state.Page .. " / " .. math.max(1, math.ceil(#list / 12)), 468, 494, 11, colors.Muted, 260, true)
            button("next", ">", 847, 487, 37, 25, function() state.Page, state.Dirty = math.min(math.max(1, math.ceil(#list / 12)), state.Page + 1), true end)
        end
        rect(20, 536, 880, 65, colors.Panel, 6)
        text("SAVED LOADOUT", 34, 549, 11, colors.White, 600, true)
        text(state.Status, 34, 573, 12, colors.Muted, 670)
        button("hide", "DONE / HIDE", 737, 551, 147, 35, function() setVisible(false) end, false, true)
    end
    for kind, pool in pairs(pools) do
        for i = counts[kind] + 1, #pool do prop(pool[i], "Visible", false) end
    end
    state.Dirty = false
end

state.Select = queue
state.Restore = function() restore(false) end
state.SetVisible = setVisible
state.Search = function(query)
    state.Query, state.Page, state.Dirty = clean(query):sub(1, 60), 1, true
end
state.Unload = function()
    if state.Unloaded then return true end
    if state.ProfileLoaded then save(true) end
    if restoreNativeIcons then pcall(restoreNativeIcons) end
    pcall(setVisible, false)
    state.Running = false
    state.Visible = false
    local restored, restoreError = pcall(restore, true)
    for _, conn in ipairs(state.Connections) do pcall(function() conn:Disconnect() end) end
    for _, object in ipairs(state.DrawingRegistry) do
        pcall(function() object.Visible = false end)
        pcall(function() object:Remove() end)
    end
    pcall(UI.RemoveTab, "Larpsec")
    pcall(UI.RemoveTab, "Vinland")
    pcall(setrobloxinput, true)
    state.Unloaded = restored
    if not restored then print("Larpsec restore: " .. tostring(restoreError)) end
    print("Larpsec unloaded. Switch weapons to refresh the original model.")
    return restored
end

local profileOk, profileError = pcall(function()
    if isfile(configPath) then
        local config = Http:JSONDecode(readfile(configPath))
        if type(config) == "table" and (config.Version == 1 or config.Version == 2 or config.Version == 3) then
            if type(config.AutoApply) == "boolean" then state.AutoApply = config.AutoApply end
            if type(config.NativeHotbarIcons) == "boolean" then state.NativeHotbarIcons = config.NativeHotbarIcons end
            if type(config.ExtendedSkins) == "boolean" then state.ExtendedSkins = config.ExtendedSkins end
            if type(config.Favorites) == "table" then
                for key, value in pairs(config.Favorites) do
                    if value == true and state.Lookup[key] then state.Favorites[key] = true end
                end
            end
            if type(config.Selected) == "table" then
                for _, kind in ipairs(kinds) do
                    local id = config.Selected[kind]
                    if type(id) == "string" and state.Lookup[kind .. ":" .. id] then
                        state.Selected[kind] = id
                        if state.AutoApply then queue(kind, id, true) end
                    end
                end
            end
        end
    end
end)
state.ProfileLoaded = profileOk
if not profileOk then
    state.ProfileError = tostring(profileError)
    setStatus("Could not load the saved profile: " .. state.ProfileError)
    print("Larpsec profile: " .. state.ProfileError)
end

pcall(function()
    UI.RemoveTab("Larpsec")
    UI.AddTab("Larpsec", function(tab)
        if not state.Running then return end
        local left = tab:Section("Larpsec", "Left")
        left:Text("Right Shift opens or hides the panel")
        left:Text("Local cosmetic preview")
        left:Button("Open skin panel", function() setVisible(true) end)
        left:Button("Restore original skins", function() restore(false) end)
        left:Button("Unload Larpsec", function() state.Unload() end)
        local right = tab:Section("Status", "Right")
        right:Text(state.Status)
        right:Text("Switch weapons after Matcha accepts a skin ID.")
        right:Text("Some server-controlled effects may stay unchanged.")
    end)
end)

local function findHotbarRefs()
    local refs = {}
    local playerGui = player:FindFirstChild("PlayerGui")
    local inMatch = playerGui and playerGui:FindFirstChild("InMatchUI")
    local abilities = inMatch and inMatch:FindFirstChild("Abilities")
    local knife = abilities and abilities:FindFirstChild("Knife")
    local revolver = abilities and abilities:FindFirstChild("Gun")
    refs.Knife = {Icon = knife and knife:FindFirstChild("WeaponIcon"), Slot = knife}
    refs.Revolver = {Icon = revolver and revolver:FindFirstChild("WeaponIcon"), Slot = revolver}
    state.HotbarRefs = refs
    local matchId = player:GetAttribute("MatchId")
    state.HotbarInMatch = type(matchId) == "string" and matchId ~= "" and matchId ~= "__REPLAY__"
end

local function readNativeIconField(icon)
    assert(state.UnsafeReady and type(memory_read) == "function", "Allow Unsafe LuaU is required")
    assert(icon and type(icon.Address) == "number", "WeaponIcon is unavailable")
    local field = icon.Address + state.NativeIconOffset
    local buffer = memory_read("uintptr", field)
    local length = memory_read("int", field + 16)
    local capacity = memory_read("int", field + 24)
    assert(validPointer(buffer), "Image buffer pointer is invalid")
    assert(type(length) == "number" and type(capacity) == "number", "Image string metadata is unavailable")
    assert(length >= 0 and capacity >= length and capacity <= 256, "Image string bounds are invalid")
    local value = memory_read("string", buffer)
    assert(type(value) == "string" and #value == length, "Image string length did not validate")
    return {Address = icon.Address, Field = field, Buffer = buffer, Length = length, Capacity = capacity, Value = value}
end

validateNativeIconLayout = function()
    if not state.UnsafeReady then return false end
    for _, kind in ipairs(kinds) do
        local ref = state.HotbarRefs[kind]
        local info = readNativeIconField(ref and ref.Icon)
        assert(info.Value:match("^rbxassetid://%d+$"), kind .. " image is not a Roblox asset id")
        assert(info.Capacity >= #info.Value, kind .. " image buffer is too small")
    end
    return true
end

local function writeNativeIcon(binding, value)
    assert(type(memory_write) == "function", "Allow Unsafe LuaU is required")
    assert(value:match("^rbxassetid://%d+$"), "Only Roblox asset IDs can be written to the native hotbar")
    assert(#value <= binding.Capacity, "The current image buffer is too small for this icon")
    assert(memory_read("uintptr", binding.Field) == binding.Buffer, "The game replaced the image buffer")
    assert(memory_read("int", binding.Field + 24) == binding.Capacity, "The image buffer capacity changed")
    local previous = memory_read("string", binding.Buffer)
    local previousLength = memory_read("int", binding.Field + 16)
    assert(#previous == previousLength and previousLength <= binding.Capacity, "Current image string did not validate")
    local ok, failure = pcall(function()
        for i = 1, #value do memory_write("byte", binding.Buffer + i - 1, value:byte(i)) end
        memory_write("byte", binding.Buffer + #value, 0)
        memory_write("int", binding.Field + 16, #value)
        assert(memory_read("string", binding.Buffer) == value, "Native image bytes did not verify")
        assert(memory_read("int", binding.Field + 16) == #value, "Native image length did not verify")
    end)
    if not ok then
        local restored, restoreFailure = pcall(function()
            for i = 1, #previous do memory_write("byte", binding.Buffer + i - 1, previous:byte(i)) end
            memory_write("byte", binding.Buffer + #previous, 0)
            memory_write("int", binding.Field + 16, previousLength)
            assert(memory_read("string", binding.Buffer) == previous, "Native icon rollback did not verify")
        end)
        if not restored then error(tostring(failure) .. " | rollback failed: " .. tostring(restoreFailure)) end
        error(failure)
    end
    binding.LastWritten = value
end

local function restoreNativeIcon(kind)
    local binding = state.NativeIconBindings[kind]
    if not binding then return end
    local ref = state.HotbarRefs[kind]
    local icon = ref and ref.Icon
    if icon and icon.Address == binding.Address then
        local ok, info = pcall(readNativeIconField, icon)
        if ok and info.Buffer == binding.Buffer and info.Value == binding.LastWritten then
            pcall(writeNativeIcon, binding, binding.Original)
        end
    end
    state.NativeIconBindings[kind] = nil
end

restoreNativeIcons = function()
    for _, kind in ipairs(kinds) do restoreNativeIcon(kind) end
end

local function nativeIconUri(item)
    if not item or type(item.Icon) ~= "string" then return nil end
    if item.Icon:match("^%d+$") then return "rbxassetid://" .. item.Icon end
    if item.Icon:match("^rbxassetid://%d+$") then return item.Icon end
    return nil
end

local function applyNativeIcon(kind, item)
    local ref = state.HotbarRefs[kind]
    local icon = ref and ref.Icon
    local uri = nativeIconUri(item)
    if not icon or not uri then
        restoreNativeIcon(kind)
        if item and state.NativeIconUnavailable[kind] ~= item.Id then
            state.NativeIconUnavailable[kind] = item.Id
            setStatus(item.Name .. " has no Roblox image ID for the native hotbar.")
        end
        return
    end
    local info = readNativeIconField(icon)
    local binding = state.NativeIconBindings[kind]
    if not binding or binding.Address ~= info.Address or binding.Buffer ~= info.Buffer or binding.Capacity ~= info.Capacity then
        binding = {
            Address = info.Address,
            Field = info.Field,
            Buffer = info.Buffer,
            Capacity = info.Capacity,
            Original = info.Value,
            OriginalLength = info.Length,
            LastWritten = nil
        }
        state.NativeIconBindings[kind] = binding
    end
    if #uri > binding.Capacity then
        if state.NativeIconUnavailable[kind] ~= item.Id then
            state.NativeIconUnavailable[kind] = item.Id
            setStatus(item.Name .. " icon exceeds the native hotbar buffer capacity.")
        end
        return
    end
    if info.Value ~= uri then writeNativeIcon(binding, uri) else binding.LastWritten = uri end
    state.NativeIconUnavailable[kind] = nil
end

local nextNativeValidation = 0
local function updateNativeIcons()
    local now = tick()
    if not state.NativeIconReady and state.UnsafeReady and now >= nextNativeValidation then
        nextNativeValidation = now + 1
        local ok, ready = pcall(validateNativeIconLayout)
        state.NativeIconReady = ok and ready == true
    end
    if not state.NativeHotbarIcons or not state.NativeIconReady or not state.HotbarInMatch or state.ReplayActive then
        restoreNativeIcons()
        return
    end
    for _, kind in ipairs(kinds) do
        local id = state.ApplyEnabled and state.Selected[kind] or player:GetAttribute(kind .. "Skin") or "Default"
        applyNativeIcon(kind, state.Lookup[kind .. ":" .. id])
    end
end

findHotbarRefs()
local nativeLayoutOk, nativeLayoutReady = pcall(validateNativeIconLayout)
state.NativeIconReady = nativeLayoutOk and nativeLayoutReady == true
local nextHotbarScan = 0
local function refreshNativeIcons()
    local now = tick()
    if now >= nextHotbarScan then
        local scanOk = pcall(findHotbarRefs)
        nextHotbarScan = now + (state.HotbarInMatch and 0.05 or 0.1)
        if not scanOk then return end
    end
    local iconOk, iconError = pcall(updateNativeIcons)
    if not iconOk then
        state.Errors = state.Errors + 1
        if state.NativeIconError ~= tostring(iconError) then
            state.NativeIconError = tostring(iconError)
            setStatus("Native hotbar icon update failed: " .. state.NativeIconError)
        end
    else
        state.NativeIconError = nil
    end
end

local function updateReplayContext()
    local active = replayContextActive()
    if active == state.ReplayActive then return end
    state.ReplayActive = active
    if active then
        local resume = state.ApplyEnabled
        restore(true)
        if restoreNativeIcons then pcall(restoreNativeIcons) end
        state.ResumeAfterReplay = resume
        setStatus("Replay active. Cosmetic overrides are paused; the recorded loadout is unchanged.")
    elseif state.ResumeAfterReplay then
        state.ResumeAfterReplay = false
        for _, kind in ipairs(kinds) do
            local id = state.Selected[kind]
            if id then queue(kind, id, true) end
        end
        setStatus("Replay ended. Saved cosmetics resumed; switch weapons to refresh.")
    end
end

task.spawn(function()
    while state.Running do
        local replayOk, replayError = pcall(updateReplayContext)
        if not replayOk then setStatus("Could not update replay state: " .. tostring(replayError)) end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while state.Running do
        for kind, binding in pairs(state.AliasBindings) do
            if aliasConflict(kind, binding.Id) then
                local ok, failure = pcall(function()
                    if player:GetAttribute(kind .. "Skin") == binding.Alias then player:SetAttribute(kind .. "Skin", state.Originals[kind]) end
                    releaseBinding(binding)
                    state.AliasBindings[kind] = nil
                    state.Written[kind], state.Pending[kind], state.Applied[kind] = nil, nil, nil
                    state.Suspended[kind] = binding.Id
                end)
                setStatus(ok and "Extended skin paused: another player is using that template. Select it again later." or "Could not restore an extended template: " .. tostring(failure))
            end
        end
        task.wait(1)
    end
end)

local function imageBytes(value)
    if type(value) ~= "string" or #value < 12 or #value >= 2000000 then return false end
    return value:sub(1, 4) == "\137PNG" or (value:sub(1, 4) == "RIFF" and value:sub(9, 12) == "WEBP")
end

local function finishImage(ref, bytes)
    state.ImageQueued[ref] = nil
    if imageBytes(bytes) then
        state.Images[ref] = bytes
        state.ImageFailures[ref] = nil
        pcall(writefile, imagePath(ref), bytes)
    else
        local failures = (state.ImageFailures[ref] or 0) + 1
        state.ImageFailures[ref] = failures
        if failures <= 2 then
            state.Images[ref] = nil
            state.ImageQueued[ref] = true
            task.delay(failures * 0.6, function()
                if state.Running and state.Images[ref] == nil then
                    state.ImageQueued[ref] = nil
                    requestImage(ref)
                    state.Dirty = true
                end
            end)
        else
            state.Images[ref] = false
            state.ImageFailures[ref] = nil
        end
    end
    state.Dirty = true
end

local function downloadImages(jobs)
    if #jobs == 0 then return end
    local nextIndex, completed = 1, 0
    local function worker()
        while state.Running do
            local index = nextIndex
            nextIndex = nextIndex + 1
            if index > #jobs then break end
            local job = jobs[index]
            local ok, bytes = pcall(httpget, job.Url)
            pcall(finishImage, job.Ref, ok and bytes or nil)
            completed = completed + 1
        end
    end
    for i = 1, math.min(4, #jobs) do task.spawn(worker) end
    while completed < #jobs and state.Running do task.wait(0.02) end
end

task.spawn(function()
    task.wait(0.2)
    while state.Running do
        if #state.ImageQueue > 0 then
            local batch = {}
            local direct = {}
            local number = math.min(12, #state.ImageQueue)
            for i = 1, number do
                local ref = table.remove(state.ImageQueue, 1)
                local path = imagePath(ref)
                local legacyPath = legacyImagePath(ref)
                local ok, bytes = pcall(function()
                    if isfile(path) then
                        local cached = readfile(path)
                        if imageBytes(cached) then return cached end
                    end
                    if legacyPath and isfile(legacyPath) then
                        local cached = readfile(legacyPath)
                        if imageBytes(cached) then
                            pcall(writefile, path, cached)
                            return cached
                        end
                    end
                    return nil
                end)
                if ok and imageBytes(bytes) then
                    state.Images[ref] = bytes
                    state.ImageQueued[ref] = nil
                    state.ImageFailures[ref] = nil
                    state.Dirty = true
                elseif ref:match("^https://") then
                    direct[#direct + 1] = {Ref = ref, Url = ref}
                else
                    batch[#batch + 1] = ref
                end
                task.wait(0.01)
            end
            downloadImages(direct)
            if #batch > 0 and state.Running then
                local ok, data = pcall(function()
                    local url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. table.concat(batch, ",") .. "&returnPolicy=PlaceHolder&size=150x150&format=Png&isCircular=false"
                    local raw = httpget(url):gsub('(\"targetId\"%s*:%s*)(%d+)', '%1\"%2\"')
                    return Http:JSONDecode(raw)
                end)
                local urls = {}
                if ok and type(data) == "table" and type(data.data) == "table" then
                    for _, row in ipairs(data.data) do
                        if row.state == "Completed" and type(row.imageUrl) == "string" and row.imageUrl:match("^https://[%w%-]+%.rbxcdn%.com/") then
                            urls[tostring(row.targetId)] = row.imageUrl
                        end
                    end
                end
                local jobs = {}
                for _, id in ipairs(batch) do
                    if urls[id] then
                        jobs[#jobs + 1] = {Ref = id, Url = urls[id]}
                    else
                        finishImage(id, nil)
                    end
                end
                downloadImages(jobs)
            end
        end
        task.wait(0.15)
    end
end)

task.spawn(function()
    while state.Running do
        local ok, err = pcall(function()
            local equipped = equippedName()
            if equipped ~= state.EquippedName then
                state.EquippedName = equipped
                state.EquipEpoch = state.EquipEpoch + 1
            end
            for _, kind in ipairs(kinds) do
                local revision = state.SelectionRevision[kind] or 0
                local id = state.Selected[kind]
                if state.ApplyEnabled and id and not state.Suspended[kind] and state.SelectionRevision[kind] == revision and state.Selected[kind] == id then
                    local binding = state.AliasBindings[kind]
                    local effectiveId = binding and binding.Id == id and binding.Alias or id
                    if #effectiveId > 15 then state.Suspended[kind] = id; return end
                    writeEffect(kind, id)
                    local current = player:GetAttribute(kind .. "Skin")
                    if type(current) == "string" and #current > 15 and current ~= effectiveId then
                        if binding then releaseBinding(binding); state.AliasBindings[kind] = nil end
                        state.Written[kind], state.Pending[kind], state.Applied[kind] = nil, nil, nil
                        state.Suspended[kind] = id
                        setStatus("Skin override paused: the native loadout changed to a long ID.")
                        return
                    end
                    if state.SelectionRevision[kind] == revision and state.Selected[kind] == id and current ~= effectiveId then
                        if current and current ~= state.Written[kind] then state.Originals[kind] = current end
                        player:SetAttribute(kind .. "Skin", effectiveId)
                        state.Written[kind] = effectiveId
                        state.Pending[kind] = {Before = rigAddress(kind), Id = effectiveId, SourceId = id, Time = tick(), Epoch = state.EquipEpoch}
                        state.Applied[kind] = nil
                        state.Dirty = true
                    end
                    local pending = state.Pending[kind]
                    if pending and state.SelectionRevision[kind] == revision and state.Selected[kind] == id then
                        local now = rigAddress(kind)
                        local refreshed = now ~= pending.Before or (state.EquipEpoch > pending.Epoch and tick() - pending.Time > 0.2)
                        if now ~= 0 and refreshed and player:GetAttribute(kind .. "Skin") == pending.Id then
                            state.Applied[kind] = pending.SourceId or pending.Id
                            state.Pending[kind] = nil
                            local note = state.EffectUnavailable[effectAttributes[kind]] and ": separate effect unavailable in this Matcha session." or ""
                            setStatus((state.Lookup[kind .. ":" .. (pending.SourceId or pending.Id)].Name) .. ": model updated." .. note)
                        end
                    end
                end
            end
        end)
        if not ok then
            state.Errors = state.Errors + 1
            if state.Errors == 1 then print("Larpsec: " .. tostring(err)) end
        end
        task.wait(0.3)
    end
end)

local function rightShiftDown()
    local ok, down = pcall(iskeypressed, 161)
    if ok and down == true then return true end
    ok, down = pcall(iskeypressed, 303)
    return ok and down == true
end
local lastShift = rightShiftDown()
local lastMouse = ismouse1pressed()
local lastActive = nil
local keyStates = {}
local heldSince = {}
local lastRepeat = {}
local lastSizeX, lastSizeY = 0, 0
local lastFrame = 0
local function toggle()
    if tick() - state.LastToggle < 0.22 then return end
    state.LastToggle = tick()
    setVisible(not state.Visible)
end
local function frame()
    if not state.Running then return end
    pcall(refreshNativeIcons)
    local active = isrbxactive()
    local shift = rightShiftDown()
    if active and shift and not lastShift then toggle() end
    lastShift = shift
    if active ~= lastActive then
        pcall(setrobloxinput, not (active and state.Visible))
        state.Active = active
        state.Dirty = true
        lastActive = active
    end
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if viewport and viewport.X > 100 and viewport.X < 20000 and viewport.Y > 100 and viewport.Y < 20000 then
        if viewport.X ~= lastSizeX or viewport.Y ~= lastSizeY then
            lastSizeX, lastSizeY = viewport.X, viewport.Y
            local topReserve = math.min(150, viewport.Y * 0.2)
            layout.Scale = math.min(1, (viewport.X - 34) / 920, (viewport.Y - topReserve - 24) / 620)
            layout.X = math.floor((viewport.X - 920 * layout.Scale) / 2)
            layout.Y = math.floor(math.max(topReserve, (viewport.Y - 620 * layout.Scale) / 2))
            state.Dirty = true
        end
    end
    local down = ismouse1pressed()
    if state.Visible and active then
        local mx = (mouse.X - layout.X) / layout.Scale
        local my = (mouse.Y - layout.Y) / layout.Scale
        local hover, target = "", nil
        for i = #state.Bounds, 1, -1 do
            local b = state.Bounds[i]
            if mx >= b.X and my >= b.Y and mx <= b.X + b.W and my <= b.Y + b.H then
                hover, target = b.Id, b
                break
            end
        end
        if hover ~= state.Hover then state.Hover, state.Dirty = hover, true end
        if down and not lastMouse then
            state.Pressed = hover
        elseif not down and lastMouse then
            state.Focus = false
            if target and state.Pressed == hover then target.Action() end
            state.Pressed = nil
            state.Dirty = true
        end
        if state.Focus then
            local now = tick()
            local shifted = iskeypressed(16)
            for key = 8, 90 do
                if key == 8 or key == 13 or key == 32 or (key >= 48 and key <= 57) or (key >= 65 and key <= 90) then
                    local pressed = iskeypressed(key)
                    if pressed and (not keyStates[key] or (now - (heldSince[key] or now) > 0.4 and now - (lastRepeat[key] or 0) > 0.06)) then
                        if not keyStates[key] then heldSince[key] = now end
                        lastRepeat[key] = now
                        if key == 8 then state.Query = state.Query:sub(1, -2)
                        elseif key == 13 then state.Focus = false
                        elseif #state.Query < 60 then
                            local char = key == 32 and " " or string.char(key)
                            state.Query = state.Query .. (shifted and char or char:lower())
                        end
                        state.Page, state.Dirty = 1, true
                    end
                    keyStates[key] = pressed
                    if not pressed then heldSince[key] = nil end
                end
            end
        end
    end
    lastMouse = down
    if state.Dirty and state.Running then render() end
end

setVisible(true)
local ok, conn = pcall(function()
    return Run.RenderStepped:Connect(function()
        if tick() - lastFrame < 1 / 60 then return end
        lastFrame = tick()
        local success, err = pcall(frame)
        if not success then
            print("Larpsec stopped: " .. tostring(err))
            state.Unload()
        end
    end)
end)
if ok and conn then
    state.Connections[#state.Connections + 1] = conn
    print("Larpsec catalog loaded: " .. #state.Catalog .. " skins, " .. state.IconCount .. " with native icons. Right Shift toggles the panel. Larpsec.Unload() restores and unloads.")
else
    print("Larpsec: could not connect RenderStepped.")
    state.Unload()
end

