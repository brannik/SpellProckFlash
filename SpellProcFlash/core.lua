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


local function CreateTrinketIconWithCooldown(trinketSlot, xOffset, yOffset, trinketCDS)
    -- Create a frame to hold the trinket icon
    local iconFrame = CreateFrame("Frame", nil, UIParent)
    iconFrame:SetSize(40, 40)  -- Set the size of the icon
    iconFrame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)  -- Position it near the center of the screen

    -- Create a texture to hold the trinket icon
    local icon = iconFrame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(iconFrame)  -- Make the texture fill the entire frame
    local trinketID = GetInventoryItemID("player", trinketSlot)

    -- Set the texture to the trinket's icon
    if trinketID then
        local texturePath = GetItemIcon(trinketID)
        icon:SetTexture(texturePath)
    else
        icon:SetColorTexture(1, 0, 0)  -- Fallback color (red) if no trinket is equipped
    end

    -- Create a font string for the cooldown timer text
    local cooldownText = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cooldownText:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)  -- Position it in the center of the icon
    cooldownText:SetText("")  -- Initially, there is no cooldown text
    cooldownText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")  -- Set font size and style for better visibility
    cooldownText:SetTextColor(1, 1, 1)  -- Set text color to white for better contrast

    -- Variables to hold the cooldown start time and duration for this trinket
    local cooldownStart = 0
    local cooldownDuration = 0
    local procApplied = false  -- Flag to track if the proc has been applied

    -- Function to update the cooldown text
    local function UpdateCooldownText()
        if cooldownDuration > 0 then
            local timeLeft = cooldownStart + cooldownDuration - GetTime()
            if timeLeft > 0 then
                cooldownText:SetText(string.format("%.1f", timeLeft))  -- Show the cooldown time (seconds)
            else
                cooldownText:SetText("")  -- Clear the text when the cooldown is finished
            end
        else
            cooldownText:SetText("")  -- Clear the text if no cooldown is active
        end
    end

    -- Update the cooldown text every frame using OnUpdate
    iconFrame:SetScript("OnUpdate", function(self, elapsed)
        UpdateCooldownText()
    end)

    -- Detect when the trinket procs (via a buff/debuff on the player)
    local function OnTrinketProc()
        -- Check if the cooldown is already active, if so, do not refresh
        if procApplied then return end  -- If proc has already been applied, exit

        local procFound = false

        -- Scan the player's buffs to find any proc from the list
        for i = 1, 40 do  -- Maximum number of buffs
            local buffName = UnitBuff("player", i)
            if buffName then
                -- Check for specific buffs related to this trinket
                for _, buffID in ipairs(trinketCDS[trinketID].buffs) do
                    if buffName == GetSpellInfo(buffID) then
                        -- If the buff is found in the list, get the cooldown duration
                        procFound = true
                        cooldownDuration = trinketCDS[trinketID].cd
                        break
                    end
                end
            end
        end

        -- Start the cooldown when the proc is found
        if procFound and cooldownDuration > 0 then
            cooldownStart = GetTime()  -- Set the cooldown start time
            procApplied = true  -- Mark the proc as applied
        end
    end

    -- Register the UNIT_AURA event to detect buffs/debuffs related to the trinket proc
    iconFrame:RegisterEvent("UNIT_AURA")
    iconFrame:SetScript("OnEvent", function(self, event, arg1)
        if event == "UNIT_AURA" and arg1 == "player" then
            OnTrinketProc()
        end
    end)

    -- Initialize the cooldown immediately (waiting for proc)
    cooldownStart = GetTime()  -- Set initial time
    cooldownDuration = 0  -- No cooldown initially

    return iconFrame
end

-- Trinket CD data with buffs and internal cooldowns
local trinketCDS = {
    [54590] = {  -- Piercing Twilight (Trinket ID)
        buffs = {75456},  -- Buff ID: Piercing Twilight
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50363] = {  -- The Black Heart (Trinket ID)
        buffs = {71561, 71559},  -- Buff IDs: The Black Heart
        cd = 180  -- Internal cooldown: 3 minutes
    },
    [44661] = {  -- Dying Curse (Trinket ID)
        buffs = {61511},  -- Buff ID: Dying Curse
        cd = 180  -- Internal cooldown: 3 minutes
    },
    [50365] = {  -- Lifeblood (Trinket ID)
        buffs = {75455},  -- Buff ID: Lifeblood
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50362] = {  -- Essence of Gossamer (Trinket ID)
        buffs = {71562},  -- Buff ID: Essence of Gossamer
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [40255] = {  -- Darkmoon Card: Greatness (Trinket ID)
        buffs = {56330},  -- Buff ID: Darkmoon Card: Greatness
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50158] = {  -- Figurine - Sapphire Owl (Trinket ID)
        buffs = {71567},  -- Buff ID: Figurine - Sapphire Owl
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [49888] = {  -- Icon of the Silver Crescent (Trinket ID)
        buffs = {71254},  -- Buff ID: Icon of the Silver Crescent
        cd = 180  -- Internal cooldown: 3 minutes
    },
    [40256] = {  -- Talisman of Ephemeral Power (Trinket ID)
        buffs = {56333},  -- Buff ID: Talisman of Ephemeral Power
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50608] = {  -- Fury of the Five Flights (Trinket ID)
        buffs = {71556},  -- Buff ID: Fury of the Five Flights
        cd = 180  -- Internal cooldown: 3 minutes
    },
    [50258] = {  -- Dragon's Eye (Trinket ID)
        buffs = {71568},  -- Buff ID: Dragon's Eye
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [49807] = {  -- Black Magic (Trinket ID)
        buffs = {71263},  -- Buff ID: Black Magic
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [40077] = {  -- Mithril Pocketwatch (Trinket ID)
        buffs = {56318},  -- Buff ID: Mithril Pocketwatch
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50254] = {  -- Strength of the Taunka (Trinket ID)
        buffs = {71569},  -- Buff ID: Strength of the Taunka
        cd = 90  -- Internal cooldown: 1.5 minutes
    },
    [40532] = {  -- Solace of the Fallen (Trinket ID)
        buffs = {56314},  -- Buff ID: Solace of the Fallen
        cd = 180  -- Internal cooldown: 3 minutes
    },
    [39229] = {  -- Gnomeregan Auto-Blocker (Trinket ID)
        buffs = {56317},  -- Buff ID: Gnomeregan Auto-Blocker
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50364] = {  -- Darkmoon Card: Death (Trinket ID)
        buffs = {71555},  -- Buff ID: Darkmoon Card: Death
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50361] = {  -- Figurine - Ruby Serpent (Trinket ID)
        buffs = {71560},  -- Buff ID: Figurine - Ruby Serpent
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50259] = {  -- Star of Xavias (Trinket ID)
        buffs = {71564},  -- Buff ID: Star of Xavias
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50742] = {  -- Mirror of Truth (Trinket ID)
        buffs = {71572},  -- Buff ID: Mirror of Truth
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [50456] = {  -- Frostbrood Sapphire Ring (Trinket ID)
        buffs = {71573},  -- Buff ID: Frostbrood Sapphire Ring
        cd = 180  -- Internal cooldown: 3 minutes
    },
    [40680] = {  -- Volcano (Trinket ID)
        buffs = {56315},  -- Buff ID: Volcano
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [40681] = {  -- Medallion of the Alliance (Trinket ID)
        buffs = {56312},  -- Buff ID: Medallion of the Alliance
        cd = 120  -- Internal cooldown: 2 minutes
    },
    [40682] = {  -- Medallion of the Horde (Trinket ID)
        buffs = {56313},  -- Buff ID: Medallion of the Horde
        cd = 120  -- Internal cooldown: 2 minutes
    }
}


-- Create the two trinket icons for each equipped trinket
local trinket1Icon = CreateTrinketIconWithCooldown(13, -22, -180, trinketCDS)  -- Trinket 1 (Slot 13)
local trinket2Icon = CreateTrinketIconWithCooldown(14, 22, -180, trinketCDS)  -- Trinket 2 (Slot 14)

