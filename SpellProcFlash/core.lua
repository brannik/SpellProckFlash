local _, playerClass = UnitClass("player")
-- update
local addonName = "SPF_" .. playerClass:sub(1,1):upper() .. playerClass:sub(2):lower()
LoadAddOn(addonName)

-- Disable other class addons
local classes = {"Paladin", "Warrior", "Mage", "Druid", "Hunter", "Rogue", "Priest", "Shaman", "Warlock", "DeathKnight"}
for _, class in ipairs(classes) do
    if class ~= playerClass:sub(1,1):upper() .. playerClass:sub(2):lower() then
        DisableAddOn("SPF_" .. class)
    end
end


