local _, addon = ...

addon.accessibility = addon.accessibility or {}
local accessibility = addon.accessibility

local palettes = {
    deuteranopia = {
        friendly = "FF2D9CDB", enemy = "FFE69F00", loot = "FF56B4E9",
        warn = "FFF0E442", pick = "FFCC79A7", buy = "FF0072B2"
    },
    protanopia = {
        friendly = "FF00A6D6", enemy = "FFFFA600", loot = "FF64C2A6",
        warn = "FFFFFF33", pick = "FFB66DFF", buy = "FF0088CC"
    },
    tritanopia = {
        friendly = "FF00B060", enemy = "FFFF5A5F", loot = "FF00AEEF",
        warn = "FFFFD166", pick = "FFB56BFF", buy = "FF008C72"
    },
    contrast = {
        friendly = "FFFFFFFF", enemy = "FFFF8000", loot = "FF00FFFF",
        warn = "FFFFFF00", pick = "FFFF00FF", buy = "FF00FF00"
    }
}

local tokenPrefixes = {
    RXP_FRIENDLY_ = "[F] ",
    RXP_ENEMY_ = "[E] ",
    RXP_LOOT_ = "[L] ",
    RXP_WARN_ = "[!] ",
    RXP_PICK_ = "[P] ",
    RXP_BUY_ = "[$] "
}

local accessibleSteps = {
    current = {
        background = {0.30, 0.24, 0.00, 1},
        text = {1.00, 0.92, 0.20}
    },
    completed = {
        background = {0.00, 0.20, 0.32, 1},
        text = {0.45, 0.90, 1.00}
    },
    sticky = {
        background = {0.28, 0.08, 0.38, 1},
        text = {0.92, 0.65, 1.00}
    },
    skipped = {text = {0.70, 0.70, 0.70}}
}

function accessibility:GetStepVisuals()
    if (addon.settings.profile.colorBlindMode or "off") == "off" then
        return nil
    end
    return accessibleSteps
end

function accessibility:GetTokenPrefix(token)
    if (addon.settings.profile.colorBlindMode or "off") == "off" then
        return ""
    end
    return tokenPrefixes[token] or ""
end

function accessibility:ApplyStepNumber(numberFrame, step, state)
    if not numberFrame or not numberFrame.text or not step then return end
    local index = tonumber(step.index) or 0
    local prefix = index < 10 and "0" or ""
    if (addon.settings.profile.colorBlindMode or "off") == "off" then
        numberFrame.text:SetText(prefix .. index)
    else
        local symbol = state == "completed" and "[x]" or
                           state == "current" and ">" or
                           state == "sticky" and "[+]" or "-"
        numberFrame.text:SetText(symbol .. prefix .. index)
    end
    numberFrame:SetWidth(numberFrame.text:GetStringWidth() + 4)
end

function accessibility:SetMode(mode)
    mode = type(mode) == "string" and mode:lower()
    if mode == "highcontrast" or mode == "high-contrast" then mode = "contrast" end
    if mode ~= "off" and not palettes[mode] then return false end
    local profile = addon.settings.profile
    if mode ~= "off" and not profile.colorBlindBackup then
        profile.colorBlindBackup = {
            textFriendlyColor = profile.textFriendlyColor,
            textEnemyColor = profile.textEnemyColor,
            textLootColor = profile.textLootColor,
            textWarnColor = profile.textWarnColor,
            textPickColor = profile.textPickColor,
            textBuyColor = profile.textBuyColor
        }
    end
    if mode == "off" then
        for key, value in pairs(profile.colorBlindBackup or {}) do
            profile[key] = value
        end
        profile.colorBlindBackup = nil
    else
        local palette = palettes[mode]
        profile.textFriendlyColor = palette.friendly
        profile.textEnemyColor = palette.enemy
        profile.textLootColor = palette.loot
        profile.textWarnColor = palette.warn
        profile.textPickColor = palette.pick
        profile.textBuyColor = palette.buy
    end
    profile.colorBlindMode = mode
    addon.settings:LoadTextColors()
    addon.RenderFrame()
    addon.UpdateMap()
    if addon.targeting and addon.targeting.UpdateTargetFrame then
        pcall(addon.targeting.UpdateTargetFrame, addon.targeting)
    end
    addon.updateBottomFrame = true
    addon.updateStepText = true
    return true
end

function accessibility:Setup()
    local mode = addon.settings.profile.colorBlindMode or "off"
    if mode ~= "off" then self:SetMode(mode) end
end

