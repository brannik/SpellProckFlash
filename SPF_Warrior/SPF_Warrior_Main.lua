-- Warrior-specific spell proc logic
-- ...existing code...

local frame = CreateFrame("Frame", "SPF_WarriorFrame", UIParent)

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_Warrior" then
        print("Hello Warrior")
    end
end)

-- ...existing code...
