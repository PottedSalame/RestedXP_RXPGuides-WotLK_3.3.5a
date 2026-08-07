local _, addon = ...
local L = addon.locale.Get

-- Anonymous account-wide run history.  Records deliberately omit character,
-- realm, GUID, guild, account, and Battle.net identifiers.  The only link from
-- a character is an opaque incrementing archive number in per-character data.

local _G = _G
local format = string.format
local floor, max = math.floor, math.max
local tinsert = table.insert

addon.runArchive = addon.runArchive or {}
local archive = addon.runArchive

local MAX_RUNS = 30
local ROWS = 12

local function Store()
    RXPData.levelingArchives = type(RXPData.levelingArchives) == "table" and
                                    RXPData.levelingArchives or {}
    local store = RXPData.levelingArchives
    store.runs = type(store.runs) == "table" and store.runs or {}
    store.nextId = max(1, floor(tonumber(store.nextId) or 1))
    while store.runs[store.nextId] do store.nextId = store.nextId + 1 end
    return store
end

local function DurationText(seconds)
    seconds = max(0, floor(tonumber(seconds) or 0))
    local hours = floor(seconds / 3600)
    local minutes = floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return hours > 0 and format("%d:%02d:%02d", hours, minutes, secs) or
               format("%02d:%02d", minutes, secs)
end

local function SanitizedLevel(level, data)
    if type(data) ~= "table" then return end
    local duration = addon.tracker and addon.tracker.GetLevelDuration and
                         addon.tracker:GetLevelDuration(level, data)
    if not duration then return end
    local quests, mobs = 0, 0
    for _, values in pairs(type(data.quests) == "table" and data.quests or {}) do
        for _, xp in pairs(type(values) == "table" and values or {}) do
            quests = quests + max(0, tonumber(xp) or 0)
        end
    end
    for _, values in pairs(type(data.mobs) == "table" and data.mobs or {}) do
        if type(values) == "table" then
            mobs = mobs + max(0, tonumber(values.xp) or 0)
        else
            mobs = mobs + max(0, tonumber(values) or 0)
        end
    end
    return {
        duration = floor(duration + 0.5),
        deaths = max(0, floor(tonumber(data.deaths) or 0)),
        questXP = floor(quests),
        mobXP = floor(mobs)
    }
end

function archive:Prune()
    local runs = Store().runs
    local count = 0
    for _ in pairs(runs) do count = count + 1 end
    while count > MAX_RUNS do
        local oldestId, oldestTime
        for id, run in pairs(runs) do
            if id ~= RXPCData.levelingArchiveRunId and not run.pinned then
                local stamp = tonumber(run.updatedAt) or tonumber(run.startedAt) or 0
                if not oldestTime or stamp < oldestTime then
                    oldestId, oldestTime = id, stamp
                end
            end
        end
        if not oldestId then break end
        runs[oldestId] = nil
        count = count - 1
    end
end

function archive:NewRun(silent)
    local store = Store()
    local id = store.nextId
    store.nextId = id + 1
    local class = addon.player and addon.player.class or select(2, UnitClass("player"))
    local race = addon.player and addon.player.race or select(2, UnitRace("player"))
    local faction = UnitFactionGroup("player")
    local level = UnitLevel("player")
    local run = {
        id = id,
        class = tostring(class or "UNKNOWN"),
        race = tostring(race or "UNKNOWN"),
        faction = tostring(faction or "Neutral"),
        xpRate = addon.settings and tonumber(addon.settings.profile.xprate) or 1,
        startLevel = level,
        endLevel = level,
        startedAt = _G.time(),
        updatedAt = _G.time(),
        levels = {},
        route = {},
        finished = false
    }
    store.runs[id] = run
    RXPCData.levelingArchiveRunId = id
    self.current = run
    self:Prune()
    if not silent then addon.comms.PrettyPrint("Started anonymous leveling archive #%d.", id) end
    self:Refresh()
    return run
end

function archive:GetCurrent(create)
    local runs = Store().runs
    local id = tonumber(RXPCData.levelingArchiveRunId)
    local run = id and runs[id]
    if type(run) ~= "table" or run.finished then
        if create then return self:NewRun(true) end
        return
    end
    self.current = run
    return run
end

function archive:Snapshot()
    local run = self:GetCurrent(true)
    local tracker = addon.tracker
    local levels = tracker and tracker.db and tracker.db.profile and
                       tracker.db.profile.levels
    if type(levels) == "table" then
        for rawLevel, data in pairs(levels) do
            local level = tonumber(rawLevel)
            local clean = level and level >= (tonumber(run.startLevel) or 1) and
                              SanitizedLevel(level, data)
            if clean then run.levels[level] = clean end
        end
    end
    run.endLevel = UnitLevel("player")
    run.updatedAt = _G.time()
    local partial = tracker and tracker.GetElapsedTimes and tracker:GetElapsedTimes()
    run.currentLevelElapsed = max(0, floor(tonumber(partial) or 0))
    local total = run.currentLevelElapsed
    for _, data in pairs(run.levels) do total = total + (data.duration or 0) end
    run.totalDuration = total
    self:Refresh()
    return run
end

function archive:RecordGuide(guide)
    local run = self:GetCurrent(true)
    if type(guide) ~= "table" or guide.empty then return end
    local key = guide.key or (addon.BuildGuideKey and addon.BuildGuideKey(guide))
    if not key or run.route[#run.route] == key then return end
    tinsert(run.route, tostring(key):sub(1, 180))
    while #run.route > 100 do table.remove(run.route, 1) end
    run.updatedAt = _G.time()
end

function archive:Finish()
    local run = self:Snapshot()
    if not run then return end
    run.finished = true
    run.finishedAt = _G.time()
    run.currentLevelElapsed = nil
    RXPCData.levelingArchiveRunId = nil
    self.current = nil
    addon.comms.PrettyPrint("Finished anonymous archive #%d (%s).",
                            run.id, DurationText(run.totalDuration))
    self:Refresh()
end

function archive:IsPersonalBest(run)
    if type(run) ~= "table" or not run.finished or not run.totalDuration then return false end
    for _, other in pairs(Store().runs) do
        if other ~= run and other.finished and other.class == run.class and
            other.race == run.race and other.startLevel == run.startLevel and
            other.endLevel == run.endLevel and
            tonumber(other.xpRate) == tonumber(run.xpRate) and
            tonumber(other.totalDuration) and other.totalDuration < run.totalDuration then
            return false
        end
    end
    return true
end

function archive:InstallComparison(run)
    if type(run) ~= "table" then return end
    addon.db.profile.reports = type(addon.db.profile.reports) == "table" and
                                   addon.db.profile.reports or {}
    addon.db.profile.reports.splits =
        type(addon.db.profile.reports.splits) == "table" and
            addon.db.profile.reports.splits or {}
    local levels = {}
    for level, data in pairs(run.levels or {}) do
        levels[level + 1] = {
            duration = data.duration,
            text = addon.tracker and addon.tracker.BuildSplitsLevelLine and
                addon.tracker:BuildSplitsLevelLine(level + 1,
                    DurationText(data.duration)) or DurationText(data.duration)
        }
    end
    local key = "anonymous-archive:" .. tostring(run.id)
    addon.db.profile.reports.splits[key] = {
        title = format("Anonymous %s %d-%d%s", run.class or "Run",
                       run.startLevel or 1, run.endLevel or 1,
                       self:IsPersonalBest(run) and " (PB)" or ""),
        history = {levels = levels}
    }
    if addon.tracker and addon.tracker.state then
        addon.tracker.state.splitsComparisonKey = key
        addon.tracker.state.splitsMenu = nil
        addon.tracker:UpdateLevelSplits("full")
    end
    addon.comms.PrettyPrint("Level splits now compare against archive #%d.", run.id)
end

local function SortedRuns()
    local list = {}
    for _, run in pairs(Store().runs) do
        if type(run) == "table" then tinsert(list, run) end
    end
    table.sort(list, function(a, b)
        if a.pinned ~= b.pinned then return a.pinned == true end
        return (tonumber(a.updatedAt) or 0) > (tonumber(b.updatedAt) or 0)
    end)
    return list
end

function archive:Refresh()
    local frame = self.frame
    if not (frame and frame:IsShown()) then return end
    local runs = SortedRuns()
    frame.runs = runs
    FauxScrollFrame_Update(frame.scroll, #runs, ROWS, 27)
    local offset = FauxScrollFrame_GetOffset(frame.scroll)
    for rowIndex, row in ipairs(frame.rows) do
        local run = runs[offset + rowIndex]
        if run then
            row.run = run
            local status = run.finished and (self:IsPersonalBest(run) and "PB" or "done") or "active"
            row.text:SetText(format("#%d  %s %d-%d  %sx  %s  [%s]%s",
                run.id, run.class or "?", run.startLevel or 0,
                run.endLevel or 0, tostring(run.xpRate or 1),
                DurationText(run.totalDuration), status,
                run.pinned and "  *" or ""))
            row:Show()
        else
            row.run = nil
            row:Hide()
        end
    end
end

function archive:CreateWindow()
    local frame = CreateFrame("Frame", "RXPLevelingArchives", UIParent)
    frame:SetSize(610, 430)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true,
        tileSize = 32, edgeSize = 32,
        insets = {left = 8, right = 8, top = 8, bottom = 8}})
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText(L("Anonymous Leveling Archives"))
    local privacy = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    privacy:SetPoint("TOPLEFT", 22, -45)
    privacy:SetText(L("Account-wide; character, realm and GUID information is never stored here."))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    frame.rows = {}
    for i = 1, ROWS do
        local row = CreateFrame("Button", nil, frame)
        row:SetSize(545, 25)
        row:SetPoint("TOPLEFT", 22, -70 - (i - 1) * 27)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 5, 0)
        row.text:SetJustifyH("LEFT")
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        row:SetScript("OnClick", function(self, button)
            if not self.run then return end
            if button == "RightButton" then
                self.run.pinned = not self.run.pinned
                archive:Refresh()
            else
                archive.selected = self.run.id
                for _, other in ipairs(frame.rows) do
                    other.text:SetTextColor(other.run == self.run and 1 or 1,
                                            other.run == self.run and 0.82 or 1,
                                            other.run == self.run and 0 or 1)
                end
            end
        end)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        frame.rows[i] = row
    end
    local scroll = CreateFrame("ScrollFrame", "RXPLevelingArchivesScroll", frame,
                               "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", frame.rows[1], "TOPLEFT", 0, 0)
    scroll:SetPoint("BOTTOMRIGHT", frame.rows[ROWS], "BOTTOMRIGHT", 25, 0)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 27,
            function() archive:Refresh() end)
    end)
    frame.scroll = scroll

    local compare = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    compare:SetSize(92, 24)
    compare:SetPoint("BOTTOMLEFT", 20, 17)
    compare:SetText(L("Compare"))
    compare:SetScript("OnClick", function()
        local run = Store().runs[archive.selected]
        if run then archive:InstallComparison(run) end
    end)
    local finish = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    finish:SetSize(92, 24)
    finish:SetPoint("LEFT", compare, "RIGHT", 7, 0)
    finish:SetText(L("Finish Run"))
    finish:SetScript("OnClick", function() archive:Finish() end)
    local new = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    new:SetSize(92, 24)
    new:SetPoint("LEFT", finish, "RIGHT", 7, 0)
    new:SetText(L("New Run"))
    new:SetScript("OnClick", function()
        addon.comms:ConfirmChoice("RXP_ARCHIVE_NEW",
            L("Finish the current archive and start a new anonymous run?"),
            function()
                if archive:GetCurrent(false) then archive:Finish() end
                archive:NewRun()
            end)
    end)
    local delete = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    delete:SetSize(92, 24)
    delete:SetPoint("LEFT", new, "RIGHT", 7, 0)
    delete:SetText(L("Delete"))
    delete:SetScript("OnClick", function()
        local id = archive.selected
        if not id or id == RXPCData.levelingArchiveRunId then return end
        addon.comms:ConfirmChoice("RXP_ARCHIVE_DELETE",
            L("Delete the selected anonymous archive?"), function()
                Store().runs[id] = nil
                archive.selected = nil
                archive:Refresh()
            end)
    end)
    frame:SetScript("OnShow", function() archive:Snapshot() end)
    frame:Hide()
    self.frame = frame
    self:Refresh()
end

function archive:Toggle()
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function archive:Setup()
    if self.setup then return end
    self.setup = true
    Store()
    self:GetCurrent(true)
    addon:RegisterMessage("RXP_LEVEL_TIME_RECORDED", function()
        archive:Snapshot()
        local maxLevel = addon.tracker and addon.tracker.maxLevel or
                             (type(_G.GetMaxPlayerLevel) == "function" and
                                  _G.GetMaxPlayerLevel()) or 80
        if UnitLevel("player") >= maxLevel and archive:GetCurrent(false) then
            archive:Finish()
        end
    end)
    addon:RegisterMessage("RXP_GUIDE_LOADED", function(_, guide)
        archive:RecordGuide(guide)
    end)
    local frame = CreateFrame("Frame")
    pcall(frame.RegisterEvent, frame, "PLAYER_LOGOUT")
    frame:SetScript("OnEvent", function() archive:Snapshot() end)
    self.eventFrame = frame
end
