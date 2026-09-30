local _, addon = ...

local state = addon.guideState or {}
addon.guideState = state

function state:FindStepById(guide, stepId)
    if type(guide) ~= "table" or type(guide.steps) ~= "table" or
        stepId == nil then return nil end
    for index, step in ipairs(guide.steps) do
        if step.stepId ~= nil and
            (step.stepId == stepId or tostring(step.stepId) == tostring(stepId)) then
            return index, step
        end
    end
end

function state:ResolvePosition(guide, stepId, numericStep)
    if type(guide) ~= "table" or type(guide.steps) ~= "table" or
        #guide.steps == 0 then return 1 end
    local byId = self:FindStepById(guide, stepId)
    if byId then return byId, true end
    numericStep = tonumber(numericStep)
    if numericStep and numericStep == math.floor(numericStep) and
        numericStep >= 1 and numericStep <= #guide.steps then
        return numericStep, true
    end
    return 1, false
end

function state:GoToStep(step)
    if addon.GoToStep then return addon.GoToStep(step) end
end

function state:SetStep(step)
    if addon.SetStep then return addon.SetStep(step) end
end

function state:SaveLegacyProgress()
    if addon.SaveCharacterGuideProgress then
        return addon:SaveCharacterGuideProgress()
    end
end

-- Pure eligibility query: never evaluates directives or invokes automation.
function state:CanAdvance(step)
    if not step then return false end
    local waitingForHearth
    for _, element in ipairs(step.elements or {}) do
        if step.waitForHearth and (element.tag == "hs" or element.tag == "hsbatching") and
            element.hearthPending and not element.completed then waitingForHearth = true end
    end
    if step.completed and not step.completionFromElements and not waitingForHearth then
        return true -- an explicit guide gate, not the completion latch
    end
    local complete = true
    for _, element in ipairs(step.elements or {}) do
        if not (element.completed or element.skip or element.textOnly) then complete = false; break end
    end
    return complete
end

function state:QueueAdvance(step, manual)
    self.pendingAdvance = {guide = addon.currentGuide, step = step, manual = manual}
    addon.loadNextStep = true
end

function state:CancelAdvance()
    self.pendingAdvance = nil
    addon.loadNextStep = false
end

function state:InvalidateAdvance(step)
    if step and step.completionFromElements then
        step.completed, step.completionFromElements = nil, nil
    end
    if self.pendingAdvance and not self.pendingAdvance.manual and self.pendingAdvance.step == step and
        not self:CanAdvance(step) then self:CancelAdvance() end
end

function state:ConsumeAdvance()
    local pending = self.pendingAdvance
    self:CancelAdvance()
    return pending and pending.guide == addon.currentGuide and
        pending.guide.steps[RXPCData.currentStep] == pending.step and
        (pending.manual or self:CanAdvance(pending.step)) or false
end

local MAX_FLAGS = 2048
local function Identity(step)
    local value = step and step.progressIdentity
    return type(value) == "string" and #value > 0 and #value <= 1024 and value or nil
end

local identityIndexes = setmetatable({}, {__mode = "k"})
local function IdentityIndex(guide, refresh)
    if not refresh and identityIndexes[guide] then return identityIndexes[guide] end
    local index = {}
    for n, step in ipairs(guide.steps or {}) do
        local id = Identity(step)
        if id then
            if index[id] ~= nil then index[id] = false else index[id] = n end
        end
    end
    identityIndexes[guide] = index
    return index
end

function state:WaypointKey(step, element)
    if not step or not element then return nil end
    if type(element.zone) ~= "number" or type(element.x) ~= "number" or
        type(element.y) ~= "number" then return nil end
    local geometry = string.format(":%.17g,%.17g,%.17g,%.17g",
        element.zone, element.x, element.y, tonumber(element.radius) or 0)
    -- The step identity already authenticates source and element order.
    -- Hashes include the displayed step index, so persist the source ordinal
    -- as well, then verify the new hash at actual pin generation.
    for n, candidate in ipairs(step.elements or {}) do
        if candidate == element then return "e" .. n .. geometry end
    end
    for n, candidate in ipairs(step.centerPins or {}) do
        if candidate == element then return "c" .. n .. geometry end
    end
end

local function CopyFlags(skips, waypoints)
    local result, count, visited = {stepSkip = {}, completedWaypoints = {}}, 0, 0
    local function validIndex(n)
        return type(n) == "number" and n >= 1 and n <= 100000 and n % 1 == 0
    end
    for n, value in pairs(type(skips) == "table" and skips or {}) do
        visited = visited + 1
        if count >= MAX_FLAGS or visited > MAX_FLAGS * 2 then break end
        if validIndex(n) and value == true then
            result.stepSkip[n], count = true, count + 1
        end
    end
    for n, values in pairs(type(waypoints) == "table" and waypoints or {}) do
        visited = visited + 1
        if count >= MAX_FLAGS or visited > MAX_FLAGS * 2 then break end
        if (validIndex(n) or n == "tip") and type(values) == "table" then
            for hash, value in pairs(values) do
                visited = visited + 1
                if count >= MAX_FLAGS or visited > MAX_FLAGS * 2 then break end
                if type(hash) == "number" and hash == hash and math.abs(hash) < 2^53 and value == true then
                    result.completedWaypoints[n] = result.completedWaypoints[n] or {}
                    result.completedWaypoints[n][hash], count = true, count + 1
                end
            end
        end
    end
    return result
end

function state:CaptureFlags(guide, previous)
    local progress = {version = 1, skipped = {}, waypoints = {}}
    local index, count = IdentityIndex(guide), 0
    if type(previous) == "table" and self:ValidateFlags(previous) then
        -- Retain authenticated but currently absent/ambiguous identities.
        -- They remain unapplied until that exact source layout returns.
        for id, value in pairs(previous.skipped) do
            if not index[id] and count < MAX_FLAGS then
                progress.skipped[id], count = value, count + 1
            end
        end
        for id, values in pairs(previous.waypoints) do
            if not index[id] and count < MAX_FLAGS - 1 then
                local points = {}
                count = count + 1
                for key, value in pairs(values) do
                    if count < MAX_FLAGS then points[key], count = value, count + 1 end
                end
                progress.waypoints[id] = points
            end
        end
    end
    local candidates = {}
    local skips = type(RXPCData.stepSkip) == "table" and RXPCData.stepSkip or {}
    local waypoints = type(RXPCData.completedWaypoints) == "table" and RXPCData.completedWaypoints or {}
    for n in pairs(skips) do candidates[n] = true end
    for n in pairs(waypoints) do candidates[n] = true end
    for n in pairs(guide.pendingCheckpointSteps or {}) do candidates[n] = true end
    for n in pairs(candidates) do
        local step = guide.steps and guide.steps[n]
        local id = Identity(step)
        if id and index[id] == n then
            if skips[n] == true and count < MAX_FLAGS then
                progress.skipped[id], count = true, count + 1
            end
            local saved = type(waypoints[n]) == "table" and waypoints[n] or {}
            local points = {}
            local function addPoint(key, value)
                local cost = next(points) and 1 or 2
                if key and value and not points[key] and count + cost <= MAX_FLAGS then
                    points[key], count = true, count + cost
                end
            end
            for key, value in pairs(step.pendingCheckpointWaypoints or {}) do
                addPoint(key, value)
            end
            for _, list in ipairs(next(saved) and {step.elements or {}, step.centerPins or {}} or {}) do
                for _, element in ipairs(list) do
                    if element.wpHash and saved[element.wpHash] == true and count < MAX_FLAGS then
                        local key = self:WaypointKey(step, element)
                        addPoint(key, true)
                    end
                end
            end
            if next(points) then progress.waypoints[id] = points end
        end
    end
    -- Keep the first quarantined legacy snapshot through ordinary saves.
    local recovery = type(previous) == "table" and previous.recovery
    if type(recovery) == "table" then
        progress.recovery = CopyFlags(recovery.stepSkip, recovery.completedWaypoints)
    end
    return progress
end

function state:RestoreFlags(guide, checkpoint)
    if type(checkpoint) ~= "table" then checkpoint = nil end
    local progress = checkpoint and checkpoint.progress
    RXPCData.stepSkip, RXPCData.completedWaypoints = {}, {}
    local index = IdentityIndex(guide, true)
    local verified = type(progress) == "table" and self:ValidateFlags(progress)
    guide.pendingCheckpointSteps = {}
    for _, step in ipairs(guide.steps or {}) do step.pendingCheckpointWaypoints = nil end
    if verified then
        for id in pairs(progress.skipped) do
            local n = index[id]
            if n then RXPCData.stepSkip[n] = true end
        end
        for id, points in pairs(progress.waypoints) do
            local n = index[id]
            if n then
                local pending = {}
                for key, value in pairs(points) do pending[key] = value end
                guide.steps[n].pendingCheckpointWaypoints = pending
                guide.pendingCheckpointSteps[n] = true
            end
        end
    end
    if checkpoint then
        if not verified then progress = {version = 1, skipped = {}, waypoints = {}} end
        -- Legacy/changed identities cannot authenticate numeric flags.
        -- Retain a bounded original snapshot, never silently reapply it.
        if not progress.recovery then
            progress.recovery = CopyFlags(checkpoint.stepSkip, checkpoint.completedWaypoints)
        end
        checkpoint.progress = progress
    end
end

function state:RestoreWaypoint(step, element)
    local pending = step and step.pendingCheckpointWaypoints
    if not pending or not step.active or not element.wpHash then return end
    local key = self:WaypointKey(step, element)
    if key and pending[key] then
        local n = step.index
        if n then
            RXPCData.completedWaypoints[n] = RXPCData.completedWaypoints[n] or {}
            RXPCData.completedWaypoints[n][element.wpHash] = true
            pending[key] = nil
        end
    end
end

function state:ValidateFlags(progress)
    if type(progress) ~= "table" or progress.version ~= 1 or
        type(progress.skipped) ~= "table" or type(progress.waypoints) ~= "table" then return false end
    local count = 0
    for key in pairs(progress) do
        if key ~= "version" and key ~= "skipped" and key ~= "waypoints" and key ~= "recovery" then return false end
    end
    local function validId(id)
        return type(id) == "string" and #id > 0 and #id <= 1024
    end
    for id, value in pairs(progress.skipped) do
        count = count + 1
        if not validId(id) or value ~= true or count > MAX_FLAGS then return false end
    end
    for id, points in pairs(progress.waypoints) do
        count = count + 1
        if not validId(id) or type(points) ~= "table" or count > MAX_FLAGS then return false end
        for key, value in pairs(points) do
            count = count + 1
            if type(key) ~= "string" or #key > 128 or not key:match("^[ec]%d+:[%d%.,eE%+%-]+$") or
                value ~= true or count > MAX_FLAGS then return false end
        end
    end
    if progress.recovery ~= nil then
        local r = progress.recovery
        if type(r) ~= "table" or type(r.stepSkip) ~= "table" or
            type(r.completedWaypoints) ~= "table" then return false end
        local normalized = CopyFlags(r.stepSkip, r.completedWaypoints)
        for key in pairs(r) do if key ~= "stepSkip" and key ~= "completedWaypoints" then return false end end
        local recoveryCount = 0
        for key, value in pairs(r.stepSkip) do
            recoveryCount = recoveryCount + 1
            if value ~= true or not normalized.stepSkip[key] or recoveryCount > MAX_FLAGS * 2 then return false end
        end
        for key, points in pairs(r.completedWaypoints) do
            recoveryCount = recoveryCount + 1
            if type(points) ~= "table" or not next(points) or recoveryCount > MAX_FLAGS * 2 then return false end
            for hash, value in pairs(points) do
                recoveryCount = recoveryCount + 1
                if value ~= true or not (normalized.completedWaypoints[key] and
                    normalized.completedWaypoints[key][hash]) or recoveryCount > MAX_FLAGS * 2 then return false end
            end
        end
    end
    return true
end

addon.services:Register("guide-state", state, "guideState")
