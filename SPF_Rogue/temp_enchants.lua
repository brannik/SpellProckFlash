local frame = CreateFrame("Frame", "EnchantCheckerFrame", UIParent)
frame:SetSize(160, 100)  -- Adjust frame size to fit both icons
frame:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
frame:Hide()  -- Hide by default

-- Create text to display missing enchants and time left
frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.text:SetPoint("TOP", frame, "TOP", 0, -120)

-- Create texture to display main hand weapon icon
frame.mainHandIcon = frame:CreateTexture(nil, "OVERLAY")
frame.mainHandIcon:SetSize(30, 30)  -- Size of the main hand weapon icon
frame.mainHandIcon:SetPoint("LEFT", frame, "LEFT", 0, 0)

-- Create texture to display off-hand weapon icon
frame.offHandIcon = frame:CreateTexture(nil, "OVERLAY")
frame.offHandIcon:SetSize(30, 30)  -- Size of the off-hand weapon icon
frame.offHandIcon:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

-- Warning icon
frame.warningIcon = frame:CreateTexture(nil, "OVERLAY")
frame.warningIcon:SetSize(20, 20)  -- Size of the warning icon
frame.warningIcon:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
frame.warningIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")  -- Example warning icon (replace with a better one if needed)
frame.warningIcon:Hide()  -- Hide by default

-- Function to check if the main hand is enchanted or has poison
local function HasMainHandEnchant()
    local hasMainHandEnchant, mainHandExpiration = GetWeaponEnchantInfo()  -- Get the main hand enchant info
    return hasMainHandEnchant, mainHandExpiration
end

-- Function to check if the off-hand is enchanted or has poison
local function HasOffHandEnchant()
    local _, _, _, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo()  -- Get the off-hand enchant info
    return hasOffHandEnchant, offHandExpiration
end

-- Function to display the warning if the enchant is about to expire
local function DisplayWarning(expirationTime, weaponType)
    local currentTime = GetTime()  -- Get the current time
    local timeRemaining = expirationTime - currentTime  -- Calculate the remaining time
    
    if timeRemaining < 300 and timeRemaining > 0 then  -- If less than 5 minutes remaining
        frame.warningIcon:Show()  -- Show warning icon
        local minutesRemaining = math.floor(timeRemaining / 60)
        local secondsRemaining = math.floor(timeRemaining % 60)
        frame.text:SetText(weaponType .. " Enchant: " .. minutesRemaining .. "m " .. secondsRemaining .. "s left")
    else
        frame.warningIcon:Hide()  -- Hide warning icon if not close to expiration
    end
end

-- Function to check for missing poisons and show weapon icons
local function CheckEnchantStatus()
    local mainHandIcon = GetInventoryItemTexture("player", 16)  -- Main hand weapon icon
    local offHandIcon = GetInventoryItemTexture("player", 17)  -- Off-hand weapon icon

    -- Check for poisons/enchants on both weapons
    local mainHandHasEnchant, mainHandExpiration = HasMainHandEnchant()
    local offHandHasEnchant, offHandExpiration = HasOffHandEnchant()

    -- If both weapons are enchanted
    if mainHandHasEnchant and offHandHasEnchant then
        frame.mainHandIcon:Hide()  -- Hide main hand icon if enchanted
        frame.offHandIcon:Hide()  -- Hide off-hand icon if enchanted
        frame.text:SetText("")
        
        -- Display warnings if enchant is close to expiring
        DisplayWarning(mainHandExpiration, "Main Hand")
        DisplayWarning(offHandExpiration, "Off Hand")
        
    -- If only main hand is enchanted
    elseif mainHandHasEnchant then
        frame.mainHandIcon:Hide()  -- Hide main hand icon if enchanted
        frame.offHandIcon:SetTexture(offHandIcon)  -- Show off-hand icon
        frame.offHandIcon:Show()  -- Off-hand needs enchant
        frame.text:SetText("Off-hand missing enchant!")
        
        -- Display warning if the main hand enchant is about to expire
        DisplayWarning(mainHandExpiration, "Main Hand")
        
    -- If only off-hand is enchanted
    elseif offHandHasEnchant then
        frame.offHandIcon:Hide()  -- Hide off-hand icon if enchanted
        frame.mainHandIcon:SetTexture(mainHandIcon)  -- Show main hand icon
        frame.mainHandIcon:Show()  -- Main hand needs enchant
        frame.text:SetText("Main-hand missing enchant!")
        
        -- Display warning if the off-hand enchant is about to expire
        DisplayWarning(offHandExpiration, "Off Hand")
        
    -- If neither weapon is enchanted
    else
        frame.mainHandIcon:SetTexture(mainHandIcon)  -- Show main hand icon
        frame.offHandIcon:SetTexture(offHandIcon)  -- Show off-hand icon
        frame.mainHandIcon:Show()  -- Main hand needs enchant
        frame.offHandIcon:Show()  -- Off-hand needs enchant
        frame.text:SetText("Both missing enchant!")
        
        -- Hide the warning icon if no enchantment
        frame.warningIcon:Hide()
    end

    -- Show the frame
    frame:Show()
end

-- Event handling
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_INVENTORY_CHANGED" then
        CheckEnchantStatus()
    end
end)

-- Register events
frame:RegisterEvent("PLAYER_ENTERING_WORLD")  -- Fires when the player logs in
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")  -- Fires when inventory changes

-- Initial check when the addon loads
CheckEnchantStatus()
