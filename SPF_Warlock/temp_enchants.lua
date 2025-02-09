local frame = CreateFrame("Frame", "EnchantCheckerFrame", UIParent)
frame:SetSize(220, 100)  -- Adjusted width to fit the new Soul Shard icon
frame:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
frame:Hide()  

-- Main text for missing enchants and time left
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.text:SetPoint("TOP", frame, "TOP", 0, -120)

-- Main Hand Weapon Icon
frame.mainHandIcon = frame:CreateTexture(nil, "OVERLAY")
frame.mainHandIcon:SetSize(30, 30)
frame.mainHandIcon:SetPoint("LEFT", frame, "LEFT", 0, 0)

-- Warning icon (for enchant expiration)
frame.warningIcon = frame:CreateTexture(nil, "OVERLAY")
frame.warningIcon:SetSize(20, 20)
frame.warningIcon:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
frame.warningIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")  
frame.warningIcon:Hide()  

-- Soul Shard Icon
frame.soulShardIcon = frame:CreateTexture(nil, "OVERLAY")
frame.soulShardIcon:SetSize(30, 30)
frame.soulShardIcon:SetPoint("RIGHT", frame, "RIGHT", 0, 0)  -- Position right of weapon icon
frame.soulShardIcon:SetTexture("Interface\\Icons\\INV_Misc_Gem_Amethyst_02")  -- Soul Shard icon

-- Soul Shard Count Text
frame.soulShardText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.soulShardText:SetPoint("CENTER", frame.soulShardIcon, "CENTER", 0, 0)

-- Function to check for main hand enchant
local function HasMainHandEnchant()
    local hasMainHandEnchant, mainHandExpiration = GetWeaponEnchantInfo()
    return hasMainHandEnchant, mainHandExpiration
end

-- Function to update Soul Shard count
local function UpdateSoulShardCount()
    local shardCount = GetItemCount(6265)  
    frame.soulShardText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")  -- Bigger font + outline
    frame.soulShardText:SetText("|cff00ff00" .. shardCount .. "|r")  -- Green color
end

-- Function to display warning if enchant is about to expire
local function DisplayWarning(expirationTime, weaponType)
    local currentTime = GetTime()
    local timeRemaining = expirationTime / 1000  
    
    if timeRemaining < 300 and timeRemaining > 0 then
        frame.warningIcon:Show()
        local minutesRemaining = math.floor(timeRemaining / 60)
        local secondsRemaining = math.floor(timeRemaining % 60)
        frame.text:SetText(weaponType .. " Enchant: " .. minutesRemaining .. "m " .. secondsRemaining .. "s left")
    else
        frame.warningIcon:Hide()
    end
end

-- Function to check for missing weapon enchants and update UI
local function CheckEnchantStatus()
    local mainHandIcon = GetInventoryItemTexture("player", 16)
    local mainHandHasEnchant, mainHandExpiration = HasMainHandEnchant()

    if mainHandHasEnchant then
        frame.mainHandIcon:Hide()
        frame.text:SetText("")
        DisplayWarning(mainHandExpiration, "Main Hand")
    else
        frame.mainHandIcon:SetTexture(mainHandIcon)
        frame.mainHandIcon:Show()
        frame.text:SetText("Missing Weapon Enchant!")
        frame.warningIcon:Hide()
    end

    UpdateSoulShardCount()  -- Update Soul Shard count
    frame:Show()
end

-- Event Handling
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_INVENTORY_CHANGED" then
        CheckEnchantStatus()
    elseif event == "BAG_UPDATE" then
        UpdateSoulShardCount()
    end
end)

-- Register Events
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:RegisterEvent("BAG_UPDATE")

-- Initial check when the addon loads
CheckEnchantStatus()
