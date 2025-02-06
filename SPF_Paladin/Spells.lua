-- List of proc spell IDs to track
local procSpells = {
    [46916] = { -- slam
        texture = "Interface\\AddOns\\SPF_Paladin\\Resources\\raging_blow.blp",
        position = "LEFT",
        missing = true,
        rotation = 0
    }
}

local active_icons = {
    -- [spellid] = frame
}
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
            end
        end
    end

end)
