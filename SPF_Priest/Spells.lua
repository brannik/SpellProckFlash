-- List of proc spell IDs to track
local procSpells = {
    [46916] = { -- slam
        texture = "Interface\\AddOns\\SPF_Priest\\Resources\\raging_blow.blp",
        position = "LEFT",
        missing = true,
        rotation = 0,
        relativeSpell = {9999999}
    }
}

local active_icons = {
    -- [spellid] = frame
}
local glowFrames = {} -- Store glow textures per button
local pulseFrames = {} -- Store pulse animation groups for each button

-- Check if Bartender 4 is loaded
local function IsBartender4Loaded()
    return IsAddOnLoaded("Bartender4") or false
end

-- Get the correct action button based on slot, considering Bartender
local function GetActionButton(slot)
    -- If Bartender 4 is loaded, we use Bartender buttons
    if IsBartender4Loaded() then
        local button = _G["BT4Button" .. slot]
        if button then
            return button
        end
    end

    -- Default action bars if Bartender 4 is not loaded
    local buttonNames = {
        "ActionButton", -- Main bar
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton"
    }

    for _, prefix in ipairs(buttonNames) do
        local button = _G[prefix .. slot]
        if button then
            return button
        end
    end

    return nil
end

local function GlowSpellOnActionBar(spellIDProc, shouldGlow)
    for slot = 1, 48 do -- Check action bar slots (adjust the range if needed)
        local actionType, id = GetActionInfo(slot)
        
        if actionType == "spell" then
            -- Loop through the relative spells defined in procSpells[spellIDProc].relativeSpell
            for _, relativeSpellID in ipairs(procSpells[spellIDProc].relativeSpell) do
                -- If the spell ID matches and the relativeSpellID is valid
                if id == relativeSpellID and relativeSpellID ~= nil then
                    local button = GetActionButton(slot) -- Get the correct button

                    if button then
                        -- Create a more aggressive glow effect (brighter and with more opacity)
                        if not glowFrames[button] then
                            local glow = button:CreateTexture(nil, "OVERLAY")
                            glow:SetTexture(1, 0.84, 0, 1) -- Bright gold color (RGBA: R = 1, G = 0.84, B = 0, A = 1 for full opacity)
                            glow:SetParent(button) -- Attach to button
                            glow:SetAllPoints(button) -- Ensure it covers the whole button
                            glow:SetBlendMode("ADD") -- Glow effect
                            glow:SetAlpha(0) -- Start with invisible glow
                            glowFrames[button] = glow

                            -- Set up pulse animation using a simple OnUpdate loop
                            local pulseFrame = CreateFrame("Frame", nil, button)
                            pulseFrame.timeElapsed = 0 -- Initialize timeElapsed variable

                            -- Pulse animation logic: more pronounced pulse effect
                            pulseFrame:SetScript("OnUpdate", function(self, elapsed)
                                self.timeElapsed = (self.timeElapsed or 0) + elapsed
                                local pulseDuration = 0.5 -- Faster pulse duration (0.5 seconds per cycle)
                                local alpha = math.sin(self.timeElapsed * (math.pi / pulseDuration)) * 0.8 + 0.2 -- Stronger pulse, larger range (0.2 to 1.0)
                                glowFrames[button]:SetAlpha(alpha)

                                -- Reset the timer after one complete pulse cycle
                                if self.timeElapsed > pulseDuration then
                                    self.timeElapsed = 0
                                end
                            end)
                            pulseFrames[button] = pulseFrame
                        end

                        -- Show or hide the glow based on shouldGlow
                        if shouldGlow then
                            glowFrames[button]:Show()

                            -- If the animation is already running, reset the pulse (reset the timer and restart the animation)
                            if pulseFrames[button]:GetScript("OnUpdate") then
                                pulseFrames[button].timeElapsed = 0 -- Reset the timeElapsed to start the pulse from the beginning
                            else
                                -- Start the pulse animation if it's not running
                                pulseFrames[button]:SetScript("OnUpdate", pulseFrames[button]:GetScript("OnUpdate"))
                            end
                        else
                            -- Hide the glow and stop the pulse animation
                            glowFrames[button]:Hide()
                            pulseFrames[button]:SetScript("OnUpdate", nil)
                            
                            -- Destroy the pulse animation and reset its state
                            pulseFrames[button] = nil
                            glowFrames[button] = nil
                        end
                    end
                    break -- Stop searching once the spell is found
                end
            end
        end
    end
end


local function RotateTexture(texture, rotation)
    if rotation == -90 then
        texture:SetRotation(-math.pi / 2)
    end
    if rotation == 90 then
        texture:SetRotation(math.pi / 2)
    end
    if rotation == 180 then
        texture:SetRotation(math.pi)
    end
    if rotation == 0 then
        texture:SetRotation(0)
    end
end
local function ShowIconInMiddle(texturePath,rotation)
    -- Create a frame to hold the texture
    local textureFrame = CreateFrame("Frame", nil, UIParent)
    textureFrame:SetSize(40, 40)  -- Set the size of the texture (40x40)
    textureFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)  -- Position it in the center of the screen

    -- Create a texture to hold the texture from BLP
    local texture = textureFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(textureFrame)  -- Make the texture fill the entire frame

    -- Set the texture using the provided texture path
    texture:SetTexture(texturePath)
    RotateTexture(texture,rotation)

    return textureFrame
end

local function ShowTopFrame(texturePath,rotation)
    -- Create a frame to hold the texture
    local textureFrame = CreateFrame("Frame", nil, UIParent)
    textureFrame:SetSize(200, 80)  -- Set the size of the texture (width x height)
    textureFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)  -- Position it at the top of the screen

    -- Create a texture to hold the texture from BLP
    local texture = textureFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(textureFrame)  -- Make the texture fill the entire frame

    -- Set the texture using the provided texture path
    texture:SetTexture(texturePath)

    RotateTexture(texture,rotation)

    return textureFrame
end


local function ShowBottomFrame(texturePath,rotation)
    -- Create a frame to hold the texture
    local textureFrame = CreateFrame("Frame", nil, UIParent)
    textureFrame:SetSize(200, 80)  -- Set the size of the texture (width x height)
    textureFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -100)  -- Position it at the bottom of the screen

    -- Create a texture to hold the texture from BLP
    local texture = textureFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(textureFrame)  -- Make the texture fill the entire frame

    -- Set the texture using the provided texture path
    texture:SetTexture(texturePath)

    RotateTexture(texture,rotation)
    return textureFrame
end

local function ShowLeftFrame(texturePath,rotation)
    -- Create a frame to hold the texture
    local textureFrame = CreateFrame("Frame", nil, UIParent)
    textureFrame:SetSize(80, 200)  -- Set the size of the texture (width x height)
    textureFrame:SetPoint("CENTER", UIParent, "CENTER", -80, 0)  -- Position it to the left of the center of the screen

    -- Create a texture to hold the texture from BLP
    local texture = textureFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(textureFrame)  -- Make the texture fill the entire frame

    -- Set the texture using the provided texture path
    texture:SetTexture(texturePath)

    RotateTexture(texture,rotation)
    -- Return the texture frame in case further modification is needed
    return textureFrame
end

local function ShowRightFrame(texturePath,rotation)
    -- Create a frame to hold the texture
    local textureFrame = CreateFrame("Frame", nil, UIParent)
    textureFrame:SetSize(80, 200)  -- Initial size (width and height)
    textureFrame:SetPoint("CENTER", UIParent, "CENTER", 80, 0)  -- Position to the right of the player

    -- Create a texture to hold the texture from BLP
    local texture = textureFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(textureFrame)  -- Make the texture fill the entire frame

    -- Set the texture using the provided texture path
    texture:SetTexture(texturePath)

    RotateTexture(texture,rotation)
    -- Return the texture frame in case further modification is needed
    return textureFrame
end

local function ShowMidFrame(texturePath,rotation)
    -- Create a frame to hold the texture
    local textureFrame = CreateFrame("Frame", nil, UIParent)
    textureFrame:SetSize(120, 120) -- Set the initial size of the frame (you can change it later)
    textureFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Position it in the center of the screen

    -- Create a texture to hold the texture from BLP
    local texture = textureFrame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(textureFrame) -- Make the texture fill the entire frame

    -- Set the texture using the provided texture path
    texture:SetTexture(texturePath)

    RotateTexture(texture,rotation)
    -- Return the texture frame in case further modification is needed
    return textureFrame
end


local function HideIcon(spellId)
    if active_icons[spellId] then
        active_icons[spellId]:Hide()
        active_icons[spellId] = nil
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function(self, event, ...)
    --if not UnitAffectingCombat("player") then return end
    -- Get combat log event details
    local arg1, subEvent, arg3, 
          senderName, arg5, arg6, arg7, 
          arg8, spellID, arg10, arg11, 
          arg12, arg13, arg14, 
          arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23 = ...

    local playerName = UnitName("player")

    -- Check if the event is SPELL_AURA_APPLIED and if the player is involved
    if subEvent == "SPELL_AURA_APPLIED" then
        -- Check if the source or destination is the player
        if senderName == playerName then
            -- If the applied spell is in the list of tracked proc spells
            if procSpells[spellID] then
                GlowSpellOnActionBar(spellID, true)
                -- Get the icon of the proc spell
                if procSpells[spellID].position == "MID" then
                    local frame = ShowMidFrame(procSpells[spellID].texture,procSpells[spellID].rotation)
                    if not active_icons[spellID] then
                        active_icons[spellID] = frame
                        active_icons[spellID]:Show()
                    end
                end
                if procSpells[spellID].position == "TOP" then
                    local frame = ShowTopFrame(procSpells[spellID].texture,procSpells[spellID].rotation)
                    if not active_icons[spellID] then
                        active_icons[spellID] = frame
                        active_icons[spellID]:Show()
                    end
                end
                if procSpells[spellID].position == "BOTTOM" then
                    local frame = ShowBottomFrame(procSpells[spellID].texture,procSpells[spellID].rotation)
                    if not active_icons[spellID] then
                        active_icons[spellID] = frame
                        active_icons[spellID]:Show()
                    end
                end
                if procSpells[spellID].position == "LEFT" then
                    local frame = ShowLeftFrame(procSpells[spellID].texture,procSpells[spellID].rotation)
                    if not active_icons[spellID] then
                        active_icons[spellID] = frame
                        active_icons[spellID]:Show()
                    end
                end
                if procSpells[spellID].position == "RIGHT" then
                    local frame = ShowRightFrame(procSpells[spellID].texture,procSpells[spellID].rotation)
                    if not active_icons[spellID] then
                        active_icons[spellID] = frame
                        active_icons[spellID]:Show()
                    end
                end
                if procSpells[spellID].position == "ICON" then
                    local frame = ShowIconInMiddle(procSpells[spellID].texture,procSpells[spellID].rotation)
                    if not active_icons[spellID] then
                        active_icons[spellID] = frame
                        active_icons[spellID]:Show()
                    end
                end
                
            end
        end
    end

    if subEvent == "SPELL_AURA_REMOVED" then
        -- Check if the source or destination is the player
        if senderName == playerName then
            -- If the applied spell is in the list of tracked proc spells
            if procSpells[spellID] then
                -- Get the icon of the proc spell
                HideIcon(spellID)
                GlowSpellOnActionBar(spellID, false)
            end
        end
    end

end)
