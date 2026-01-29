-- === CONFIG ===
local ActiveNullKicker = nil

local TELEPORT_DISTANCE = 25
local TELEPORT_INTERVAL = 0.333
local NK_TEST = 0

local CONE_DOT_LIMIT = 0

-- === LISTS ===
local Blacklist = {
    ["76561199357513893"] = { chat = "NULLKICKER JOINED! peter chinabitch is here so hide under map / offender: %name%", say = "ALERT! peter is here so hide under map / offender: %name%" },
    ["76561199266512057"] = { chat = "NULLKICKER ALERT! troll that kicks ppl, offender: %name%", say = "ALERT! this bitch kept kicking us and hes back, hide under map (no-name moron) / offender: %name%" },
    ["76561199725046418"] = { chat = "Nullkicker! (phabok), kicks people", say = "ALERT! Phabok (nullkicker, kicks poeple) is here, hide under map! (%name%)" },
    ["76561199717720957"] = { chat = "NULLKICKER JOINED! peter chinabitch is here so hide under map / offender: %name%", say = "ALERT! peter is here so hide under map / offender: %name%" },
    ["76561199229624110"] = { chat = "NULLKICKER (%name%, aka. fake garry newman) joined, nullkicking people", say = "NULLKICKER (%name%, aka. fake garry newman) joined, nullkicks people" },
    ["76561198783221192"] = { chat = "Rogue AI (%name%) joined (prop spam + crashing.)", say = "Rogue AI (%name%) joined (prop spam + crashing.)" },
    ["76561198930801968"] = { chat = "homophobic troll joined (%name%), u dont need to killbind", say = "protected yall from this guy's mouth" },
    ["76561199657896172"] = { chat = "NUISANCE (%name%) joined (mingebag, he crashes servers.)", say = "NUISANCE (%name%) joined (mingebag, he crashes servers.)" },
    ["76561199432874618"] = { chat = "nullkick %name%", say = "NULLKICKER (%name%) mrnoob56! DO NOT CRASH THE SERVER! ..." },
    ["76561199484486648"] = { chat = "troll %name%", say = "troll" }, -- change all instances of %% to %name%
    ["76561199128820338"] = { chat = "", say = "THIS MOTHERFUCKER %name% WAS SPRAYING PORN" },
    ["76561199779980659"] = { chat = "crasher %name%", say = "user %name% aka merge joined, a crasher" },
    ["76561198131634752"] = { chat = "accomplise of spawnkiller, crashes %name%", say = "accomplise of spawnkiller, crashes" },
    ["76561198030937859"] = { chat = "annoyance %name%", say = "kicked %name% cuz hes a annoyance" },
    ["76561198085391699"] = { chat = "FUCKING ANNOYING %name%", say = "kicked %name% cuz hes FUCKING ANNOYING" },
    ["76561199446876490"] = { chat = "crasher %name%", say = "user %name% joined, a crasher" },
    ["76561198267679665"] = { chat = "nullkicker %name%", say = "user %name% is a nullkicker"},
    ["76561198069581073"] = { chat = "crasher %name%", say = "user %name% is a crasher"},
    ["76561198884674286"] = { chat = "crasher %name%", say = "user %name% is a crasher"},
    ["76561198884674286"] = { chat = "crasher %name%", say = "user %name% is a crasher"},
    ["76561197961602996"] = { chat = "npc spam (%name%)", say = "kicked %name% for npc spamming" },
    ["76561199229874527"] = { chat = "spawnkiller (%name%)", say = "kicked %name% for spawnkilling" },
    ["76561199851974973"] = { chat = "spawnkiller (%name%)", say = "kicked %name% for spawnkilling" },
    ["76561199701722538"] = { chat = "crasher, also spawnkiller (%name%)", say = "kicked %name% for crashing and spawnkilling" },
    ["76561198273930793"] = { chat = "trolling idiot (%name%)", say = "kicked %name% for being a troll" },
    ["76561199405832222"] = { chat = "spawnkiller (%name%) agh", say = "kicked %name% for being a spawnkiller" },
    ["76561199389219448"] = { chat = "crasher (%name%)", say = "kicked %name% for crashing" },
    ["76561199110686458"] = { chat = "annoying spawnkiller (%name%)", say = "kicked %name% for being an annoying spawnkiller" },
    ["76561198754867119"] = { chat = "spawnkiller bruh (%name%)", say = "kicked %name% for being a spawnkiller" },
    ["76561198058892659"] = { chat = "spawnkiller (%name%)", say = "kicked %name% for being a spawnkiller" },
    ["76561199725046418"] = { chat = "faker alt??? (%name%)", say = "kicked %name% for being phabok's alt" },
    ["76561199806691331"] = { chat = "spawnkiller (%name%)", say = "kicked %name% for being a spawnkiller" },
    -- ["76561198246406488"] = { chat = "spawnkiller (%name%)", say = "kicked %name% for being a spawnkiller" },
    -- ["76561199175691694"] = { chat = "nullkicker %name%", say = "user %name"}, -- mentalsnotfrog
    -- ["76561199580784922"] = { chat = "spawnkiller %name%", say = "kicked %name%, a spawnkiller" }, -- IAMNOTAFISH
    -- ["76561199812012807"] = { chat = "crasher %name%", say = "user %name% is a crasher"},
    -- ["76561199539479166"] = { chat = "annoying spawnkiller (%name%)", say = "kicked %name% for being an annoying spawnkiller" },
}



local Whitelist = {
    ["76561199688284437"] = true -- marten
}

-- === UTIL ===
local function Msg(col, txt)
    chat.AddText(col, txt)
end

local function Process(msg, name)
    return string.Replace(msg, "%name%", name)
end

-- === TEST BOT CHECK ===
local function IsTestBot(sid64)
    return NK_TEST == 1 and string.StartWith(sid64, "90071")
end

-- === HEAD POSITION ===
local function GetHeadPos(ply)
    local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
    if bone then
        local pos = ply:GetBonePosition(bone)
        if pos then return pos end
    end
    return ply:EyePos()
end

-- === FORCE BEHIND POSITION (GUARANTEED) ===
local function GetForcedBehindPos(target)
    local forward = target:EyeAngles():Forward()
    local behindDir = -forward:GetNormalized()

    -- safety: ensure we are not in front cone
    local dot = behindDir:Dot(forward)
    if dot > CONE_DOT_LIMIT then
        behindDir = -forward -- hard force
    end

    return
        target:GetPos()
        + behindDir * TELEPORT_DISTANCE
        + Vector(0, 0, 20)
end

-- === TEST AIM CHECK ===
local function TestImpulse(ply, target)
    local tr = util.TraceLine({
        start  = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 8192,
        filter = ply
    })

    if tr.Entity == target then
        Msg(Color(0,255,0), "[NK TEST] SUCCESS (aim on target)")
    else
        Msg(Color(255,0,0), "[NK TEST] FAIL (aim miss)")
    end
end

-- === NULLKICKER LOOP ===
local function StartNullKicker(target)
    if not IsValid(target) then return end

    ActiveNullKicker = target
    timer.Remove("NullKicker_Loop")

    timer.Create("NullKicker_Loop", TELEPORT_INTERVAL, 0, function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not IsValid(ActiveNullKicker) then
            timer.Remove("NullKicker_Loop")
            ActiveNullKicker = nil
            return
        end

        -- pause while dead, resume when alive
        if not ActiveNullKicker:Alive() then return end

        -- FORCE behind teleport (always)
        local behindPos = GetForcedBehindPos(ActiveNullKicker)

        RunConsoleCommand("setpos",
            behindPos.x,
            behindPos.y,
            behindPos.z
        )

        -- aim at head AFTER teleport
        timer.Simple(0, function()
            if not IsValid(ply) or not IsValid(ActiveNullKicker) then return end

            local head = GetHeadPos(ActiveNullKicker)
            local ang = (head - ply:EyePos()):Angle()

            RunConsoleCommand("setang", ang.p, ang.y, 0)

            if NK_TEST == 1 then
                TestImpulse(ply, ActiveNullKicker)
            else
                RunConsoleCommand("impulse", "203")
            end
        end)
    end)
end

-- === PLAYER CHECK ===
local function CheckPlayer(ply)
    if not IsValid(ply) then return end

    local sid = ply:SteamID64()
    if not sid or Whitelist[sid] then return end

    if IsTestBot(sid) then
        Msg(Color(160,80,255), "[NK TEST] bot detected: " .. ply:Nick())
        StartNullKicker(ply)
        return
    end

    local data = Blacklist[sid]
    if data then
        Msg(Color(255,0,0), Process(data.chat, ply:Nick()))
        StartNullKicker(ply)
    end
end

-- === AUTO SCAN ===
hook.Add("InitPostEntity", "NK_InitScan", function()
    timer.Simple(0.3, function()
        for _, ply in ipairs(player.GetAll()) do
            CheckPlayer(ply)
        end
    end)
end)

hook.Add("OnEntityCreated", "NK_PlayerSpawn", function(ent)
    if IsValid(ent) and ent:IsPlayer() then
        timer.Simple(0.2, function()
            CheckPlayer(ent)
        end)
    end
end)

-- === MANUAL SCAN ===
concommand.Add("blacklist_scan", function()
    Msg(Color(255,0,0), "BLACKLIST SCAN STARTED")
    for _, ply in ipairs(player.GetAll()) do
        CheckPlayer(ply)
    end
end)

-- === TEST MODE TOGGLE ===
concommand.Add("nk_test", function(_,_,args)
    local v = tonumber(args[1])
    if v ~= 0 and v ~= 1 then return end
    NK_TEST = v
    Msg(Color(160,80,255), "[NK] test mode = " .. v)
end)
