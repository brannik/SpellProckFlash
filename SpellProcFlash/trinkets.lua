local function CreateGlowEffect(frame)
    frame:SetFrameStrata("HIGH") -- Ensure it appears on top
    frame:SetBackdrop({
        edgeFile = "Interface\\GLUES\\COMMON\\TextPanel-Border",
        edgeSize = 16,
    })
    frame:SetBackdropBorderColor(1, 1, 0, 1) -- Yellow glow
    frame:SetPoint("CENTER", frame:GetParent(), "CENTER")
    frame:SetSize(frame:GetParent():GetWidth() + 8, frame:GetParent():GetHeight() + 8)

    -- Create animation group
    local glowAnim = frame:CreateAnimationGroup()

    -- Fade In animation
    local fadeIn = glowAnim:CreateAnimation("Alpha")
    fadeIn:SetDuration(0.5)
    fadeIn:SetChange(0.7) -- Increase opacity
    fadeIn:SetOrder(1)

    -- Fade Out animation
    local fadeOut = glowAnim:CreateAnimation("Alpha")
    fadeOut:SetDuration(0.5)
    fadeOut:SetChange(-0.7) -- Decrease opacity
    fadeOut:SetOrder(2)

    -- Make it loop
    glowAnim:SetLooping("REPEAT")

    frame.glowAnim = glowAnim
    frame:Hide()
    return frame
end



local TrinketFrame = CreateFrame("Frame", "TrinketWatcher", UIParent)
TrinketFrame:SetSize(40, 40)
TrinketFrame:SetPoint("CENTER", UIParent, "CENTER", -23, -150)
local TrinketGlow = CreateGlowEffect(CreateFrame("Frame", nil, TrinketFrame))

local TrinketFrame2 = CreateFrame("Frame", "TrinketWatcher2", UIParent)
TrinketFrame2:SetSize(40, 40)
TrinketFrame2:SetPoint("CENTER", UIParent, "CENTER", 23, -150)
local TrinketGlow2 = CreateGlowEffect(CreateFrame("Frame", nil, TrinketFrame2))

-- Create textures for trinkets
local TrinketIcon = TrinketFrame:CreateTexture(nil, "BACKGROUND")
TrinketIcon:SetAllPoints()
local TrinketCooldown = CreateFrame("Cooldown", nil, TrinketFrame, "CooldownFrameTemplate")

local TrinketIcon2 = TrinketFrame2:CreateTexture(nil, "BACKGROUND")
TrinketIcon2:SetAllPoints()
local TrinketCooldown2 = CreateFrame("Cooldown", nil, TrinketFrame2, "CooldownFrameTemplate")

-- Create font strings for buff/internal CD timers
local TrinketTimerText = TrinketFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
TrinketTimerText:SetPoint("CENTER", TrinketFrame, "CENTER", 0, -30)
TrinketTimerText:SetText("")

local TrinketTimerText2 = TrinketFrame2:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
TrinketTimerText2:SetPoint("CENTER", TrinketFrame2, "CENTER", 0, -30)
TrinketTimerText2:SetText("")

-- Trinkets table
local trinkets = {
    [54590] = { -- STS HC
        procs = {75456},  -- Spell IDs that trigger on proc
        buffCD = 15,      -- Duration of buff
        internalCD = 30   -- Internal cooldown
    },
    [54589] = { -- STS NM
        procs = {75455},  -- Spell IDs that trigger on proc
        buffCD = 15,      -- Duration of buff
        internalCD = 45   -- Internal cooldown
    },
    [50364] = { -- DBW NM
        procs = {71557,71558,71559,71560,71561,71599},  -- Spell IDs that trigger on proc
        buffCD = 30,      -- Duration of buff
        internalCD = 45   -- Internal cooldown
    },
    [50363] = { -- DBW HC
        procs = {71556,71558,71559,71560,71561,71599},  -- Spell IDs that trigger on proc
        buffCD = 30,      -- Duration of buff
        internalCD = 75   -- Internal cooldown
    },
    [45609] = { -- Comet's Trail
        procs = {64772},  -- Spell IDs that trigger on proc
        buffCD = 10,      -- Duration of buff
        internalCD = 35   -- Internal cooldown
    },
    [46038] = { -- Dark Matter
        procs = {65024},  -- Spell IDs that trigger on proc
        buffCD = 10,      -- Duration of buff
        internalCD = 35   -- Internal cooldown
    },
    [54569] = { -- STS Norm
        procs = {75458},  -- Spell IDs that trigger on proc
        buffCD = 15,      -- Duration of buff
        internalCD = 30   -- Internal cooldown
    },
    [50362] = { -- DBW Norm
        procs = {71485,71484,71492},  -- Spell IDs that trigger on proc
        buffCD = 30,      -- Duration of buff
        internalCD = 75   -- Internal cooldown
    },
    -- icc trinkets
    -- rs trinkets

}

local procs = {}
local activeProcs = {} -- Buff timers
local activeICDs = {}  -- Internal cooldown timers

local function UpdateTrinkets()
    local trinket1 = GetInventoryItemID("player", 13)
    local trinket2 = GetInventoryItemID("player", 14)
    procs = {}
    
    if trinket1 then
        TrinketIcon:SetTexture(GetItemIcon(trinket1))
        TrinketFrame:Show()
        if trinkets[trinket1] then
            for _, procID in pairs(trinkets[trinket1].procs) do
                procs[procID] = {slot = 13, buffCD = trinkets[trinket1].buffCD, internalCD = trinkets[trinket1].internalCD}
            end
        end
    else
        TrinketFrame:Hide()
    end
    
    if trinket2 then
        TrinketIcon2:SetTexture(GetItemIcon(trinket2))
        TrinketFrame2:Show()
        if trinkets[trinket2] then
            for _, procID in pairs(trinkets[trinket2].procs) do
                procs[procID] = {slot = 14, buffCD = trinkets[trinket2].buffCD, internalCD = trinkets[trinket2].internalCD}
            end
        end
    else
        TrinketFrame2:Hide()
    end
end

local function CombatLogHandler(_, event, destGUID, spellID)
    if event == "SPELL_AURA_APPLIED" and destGUID == UnitName("player") then
        if procs[spellID] then
            local trinketSlot = procs[spellID].slot
            local buffCD = procs[spellID].buffCD
            local expirationTime = GetTime() + buffCD
            activeProcs[trinketSlot] = expirationTime 

            -- Show glow while buff is active
            if trinketSlot == 13 then
                TrinketGlow:Show()
                TrinketTimerText:SetText(string.format("|cFF00FF00%d|r", buffCD)) -- Green color
            elseif trinketSlot == 14 then
                TrinketGlow2:Show()
                TrinketTimerText2:SetText(string.format("|cFF00FF00%d|r", buffCD)) -- Green color
            end
        end
    elseif event == "SPELL_AURA_REMOVED" and destGUID == UnitName("player") then
        if procs[spellID] then
            local trinketSlot = procs[spellID].slot
            activeProcs[trinketSlot] = nil

            -- Hide glow when buff expires
            if trinketSlot == 13 then
                TrinketGlow:Hide()
            elseif trinketSlot == 14 then
                TrinketGlow2:Hide()
            end

            -- Start internal cooldown timer
            local internalCD = procs[spellID].internalCD
            local icdExpiration = GetTime() + internalCD
            activeICDs[trinketSlot] = icdExpiration

            if trinketSlot == 13 then
                TrinketTimerText:SetText(string.format("|cFFFF0000%d|r", internalCD))
            elseif trinketSlot == 14 then
                TrinketTimerText2:SetText(string.format("|cFFFF0000%d|r", internalCD))
            end
        end
    end
end

local function OnUpdate(self, elapsed)
    for slot, expireTime in pairs(activeProcs) do
        local remaining = expireTime - GetTime()
        if remaining > 0 then
            if slot == 13 then
                TrinketTimerText:SetText(string.format("|cFF00FF00%d|r", remaining))
            elseif slot == 14 then
                TrinketTimerText2:SetText(string.format("|cFF00FF00%d|r", remaining))
            end
        else
            activeProcs[slot] = nil
        end
    end

    for slot, expireTime in pairs(activeICDs) do
        local remaining = expireTime - GetTime()
        if remaining > 0 then
            if slot == 13 then
                TrinketTimerText:SetText(string.format("|cFFFF0000%d|r", remaining))
            elseif slot == 14 then
                TrinketTimerText2:SetText(string.format("|cFFFF0000%d|r", remaining))
            end
        else
            activeICDs[slot] = nil
            if slot == 13 then
                TrinketTimerText:SetText("")
            elseif slot == 14 then
                TrinketTimerText2:SetText("")
            end
        end
    end
end
TrinketFrame:RegisterEvent("ADDON_LOADED")
TrinketFrame:RegisterEvent("PLAYER_LOGIN")
TrinketFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
TrinketFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
TrinketFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
TrinketFrame:SetScript("OnEvent", function(self, event, ...)
    local _, subEvent, _, senderName, _, _, _, _, spellID = ...
    if senderName == UnitName("player") then
        if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
            UpdateTrinkets()
        elseif event == "UNIT_INVENTORY_CHANGED" then 
            local unit = ...
            if unit == "player" then
                UpdateTrinkets()
            end
        elseif event == "ADDON_LOADED" then
            local addon = ...
            if addon == "SpellProcFlash" then
                UpdateTrinkets()
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            CombatLogHandler(self, subEvent, senderName, spellID)
        end
    end
end)

TrinketFrame:SetScript("OnUpdate", OnUpdate)
UpdateTrinkets()
