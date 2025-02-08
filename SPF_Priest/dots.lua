local DoTTracker = CreateFrame("Frame")
DoTTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DoTTracker:RegisterEvent("ADDON_LOADED")
DoTTracker:RegisterEvent("PLAYER_LOGIN")

local playerName = UnitName("player")
local activeDoTs = {}

-- Function to calculate and update the DoT durations based on the player's haste
local DoTs = {
    [48160] = {duration = 15, hasteAffected = true},  -- Vampiric Touch (15 seconds)
    [48300] = {duration = 24, hasteAffected = true},  -- Devouring Plague (24 seconds)
    [48125] = {duration = 18, hasteAffected = false}, -- Shadow Word: Pain (18 seconds, not affected by haste)
}

local function UpdateDoTDurations()
    -- Get the player's spell haste (this example uses a fixed value of 29.52% for testing)
    local spellHaste = 29.52  -- Example: Player's spell haste at 29.52%
    -- Print haste info for debugging (optional)
    print("Player Spell Haste: " .. string.format("%.2f", spellHaste) .. "%")
    
    -- Loop through the DoTs and adjust their durations based on spell haste if the flag is true
    for spellID, data in pairs(DoTs) do
        local baseDuration = data.duration
        local hasteAffected = data.hasteAffected
        
        -- Apply haste only if the flag is true
        if hasteAffected then
            local newDuration = baseDuration / (1 + spellHaste / 100)  -- Adjust the duration based on haste percentage
            DoTs[spellID].duration = newDuration  -- Update the table with the new duration
            print("Updated duration for spell ID " .. spellID .. ": " .. string.format("%.2f", newDuration))
        else
            -- If haste is not applied, print the base duration
            print("Spell ID " .. spellID .. " is not affected by haste. Duration: " .. baseDuration)
        end
    end
end

-- Example call to update durations
UpdateDoTDurations()

local dotFrame = CreateFrame("Frame", "DoTTrackerFrame", UIParent)
dotFrame:SetSize(50, 200)
dotFrame:SetPoint("CENTER", UIParent, "CENTER", -200, 0)

-- Table to hold icon frames for efficient reuse
local iconFrames = {}
-- Function to get the remaining duration of a DoT debuff on the target
local function GetRemainingDoTDurationOnTarget(spellID)
    -- Loop through all debuffs on the target (up to 40 debuffs)
    for i = 1, 40 do
        -- Get debuff details from UnitDebuff API
        local name, _, _, _, _, duration, expirationTime, _, _, _, _, debuffSpellId = UnitDebuff("target", i)

        -- If no debuff is found, stop the loop
        if not name then
            break
        end

        -- Check if the debuff matches the given spellID
        if debuffSpellId == spellID then
            -- Calculate the remaining duration of the debuff
            local remaining = expirationTime - GetTime()
            return remaining  -- Return the remaining duration
        end
    end
    return nil  -- Return nil if the debuff was not found
end
-- Function to update the UI to show the DoTs and their durations
local function UpdateDoTIcons()
    local index = 0
    for spellID, expiration in pairs(activeDoTs) do
        -- Get the remaining duration of the DoT debuff on the target
        local remaining = GetRemainingDoTDurationOnTarget(spellID)

        -- If the debuff is not found on the target, fallback to the fixed duration
        if not remaining then
            remaining = expiration - GetTime()
        end

        -- Debug print: Show the remaining time and the spell being processed
        local spellName, _, icon = GetSpellInfo(spellID)

        if remaining > 0 then
            -- Create or reuse the icon frame
            local iconFrame = iconFrames[index] or CreateFrame("Frame", "DoTIcon"..index, dotFrame)
            iconFrame:SetSize(40, 40)
            iconFrame:SetPoint("TOP", dotFrame, "TOP", 0, -index * 45)

            local iconTexture = iconFrame.icon or iconFrame:CreateTexture(nil, "ARTWORK")
            iconTexture:SetAllPoints()
            iconTexture:SetTexture(icon)
            iconFrame.icon = iconTexture

            -- Display the remaining time on the icon
            local timeText = iconFrame.text or iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            timeText:SetPoint("CENTER", iconFrame, "CENTER", -55, 0)

            -- Set font size (larger size) and apply outline
            timeText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")  -- Adjust font size and apply outline
            timeText:SetText(string.format("%.1fs", remaining))

            iconFrame.text = timeText

            iconFrame:Show()
            iconFrames[index] = iconFrame -- Store for reuse
            index = index + 1
        else
            -- Expired DoT, show only the icon
            local iconFrame = iconFrames[index] or CreateFrame("Frame", "DoTIcon"..index, dotFrame)
            iconFrame:SetSize(40, 40)
            iconFrame:SetPoint("TOP", dotFrame, "TOP", 0, -index * 45)

            local iconTexture = iconFrame.icon or iconFrame:CreateTexture(nil, "ARTWORK")
            iconTexture:SetAllPoints()
            iconTexture:SetTexture(icon)
            iconFrame.icon = iconTexture

            iconFrame:Show()
            iconFrames[index] = iconFrame -- Store for reuse
            index = index + 1
        end
    end

    -- Destroy any icons that are no longer needed
    for i = index, #iconFrames do
        local iconFrame = iconFrames[i]
        if iconFrame then
            iconFrame:Hide()
            iconFrame.icon:Hide()  -- Hide the texture
            iconFrame.text:Hide()  -- Hide the text
            iconFrame:ClearAllPoints()  -- Clear all anchor points
            iconFrame:Hide()  -- Hide the frame itself
            iconFrames[i] = nil  -- Remove reference to the icon frame
            --print("|cffff0000[DoTTracker]|r Destroyed icon: DoTIcon" .. i)
        end
    end
end

DoTTracker:SetScript("OnEvent", function(self, event, ...)
    local arg1, subEvent, arg3, 
          senderName, arg5, arg6, arg7, 
          arg8, spellID, arg10, arg11, 
          arg12, arg13, arg14, 
          arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23 = ...
    -- Only track debuffs from the player
    if senderName == playerName and DoTs[spellID] then
        if subEvent == "SPELL_AURA_APPLIED" then
            -- Apply the DoT
            if not activeDoTs[spellID] then 
                activeDoTs[spellID] = GetTime() + DoTs[spellID].duration
            end
        elseif subEvent == "SPELL_AURA_REFRESH" then
            -- Refresh the DoT duration
            if activeDoTs[spellID] then
                -- Update the expiration time based on the refresh
                activeDoTs[spellID] = GetTime() + DoTs[spellID].duration
                -- Debug print: Show the refreshed duration
                local spellName = GetSpellInfo(spellID)
                --print("|cff00ff00[DoTTracker]|r Refreshed DoT: " .. spellName .. ", New Expiration: " .. string.format("%.1fs", activeDoTs[spellID] - GetTime()))
            end
        elseif subEvent == "SPELL_AURA_REMOVED" then
            -- Remove the DoT when it expires or is removed
            activeDoTs[spellID] = nil
        end
        UpdateDoTIcons()
    end
end)

-- Update UI every 0.1s to keep durations accurate
dotFrame:SetScript("OnUpdate", function()
    UpdateDoTIcons()
end)
