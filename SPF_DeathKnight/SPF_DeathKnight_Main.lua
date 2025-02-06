
local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "SPF_DeathKnight" then
        print("|cFFFFA500SPF>>> Welcome DeathKnight|r")
    end
end)

