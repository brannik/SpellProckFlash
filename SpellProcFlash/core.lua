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
