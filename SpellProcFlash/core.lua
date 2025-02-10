local _, playerClass = UnitClass("player")

-- Function to properly format class names
local function FormatClassName(class)
    if class == "DEATHKNIGHT" then
        return "DeathKnight"
    else
        return class:sub(1,1):upper() .. class:sub(2):lower()
    end
end

local formattedClass = FormatClassName(playerClass)

-- Load the correct addon
local addonName = "SPF_" .. formattedClass
LoadAddOn(addonName)

-- Disable other class addons
local classes = {"Paladin", "Warrior", "Mage", "Druid", "Hunter", "Rogue", "Priest", "Shaman", "Warlock", "DeathKnight"}
for _, class in ipairs(classes) do
    if class ~= formattedClass then
        DisableAddOn("SPF_" .. class)
    end
end

local function IsBartender4Loaded()
    return IsAddOnLoaded("Bartender4") or false
end

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

function PrintAllActionBarsAndSpells()
    for slot = 1, 48 do -- Check action bar slots (adjust the range if needed)
        local actionType, id = GetActionInfo(slot)

        -- Retrieve the action button associated with the slot
        local button = GetActionButton(slot)
        
        -- Print the action button's name (for reference)
        if button then
            print("Action Bar Slot " .. slot .. ": Button - " .. button:GetName())
        else
            print("Action Bar Slot " .. slot .. ": No Button Found")
        end
        
        if actionType == "spell" then
            local spellName, _, spellId = GetSpellInfo(id)  -- Ensure we are retrieving the spell ID correctly
            if spellName then
                -- Print the spell information (name and ID)
                print("    Spell - " .. spellName .. " (ID: " .. spellId .. ")")
            end
        elseif actionType == "macro" then
            local macroName = GetMacroInfo(id)
            if macroName then
                -- Print the macro information
                print("    Macro - " .. macroName)
            end
        elseif actionType == "item" then
            local itemName, _, itemId = GetItemInfo(id)
            if itemName then
                -- Print the item information
                print("    Item - " .. itemName .. " (ID: " .. itemId .. ")")
            end
        else
            -- In case the action is empty or an unrecognized type
            print("    Empty slot")
        end
    end
end
