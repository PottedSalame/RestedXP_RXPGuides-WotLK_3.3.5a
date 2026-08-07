local _, addon = ...

local _G = _G
local scheduler = addon.scheduler or {}
addon.scheduler = scheduler

local owners = {}
local combatQueue = {}
local combatFrame

local function CheckKey(owner, key)
    if owner == nil then error("RXPGuides scheduler owner is required", 3) end
    if type(key) ~= "string" or key == "" then
        error("RXPGuides scheduler keys must be non-empty strings", 3)
    end
end

local function OwnerEntries(owner, create)
    local entries = owners[owner]
    if not entries and create then
        entries = {}
        owners[owner] = entries
    end
    return entries
end

local function CancelHandle(handle)
    if handle and type(handle.Cancel) == "function" then handle:Cancel() end
end

function scheduler:Cancel(owner, key)
    CheckKey(owner, key)
    local entries = OwnerEntries(owner, false)
    if entries then
        CancelHandle(entries[key])
        entries[key] = nil
        if not next(entries) then owners[owner] = nil end
    end
    local queued = combatQueue[owner]
    if queued then
        queued[key] = nil
        if not next(queued) then combatQueue[owner] = nil end
    end
end

function scheduler:After(owner, key, delay, callback)
    CheckKey(owner, key)
    if type(callback) ~= "function" then
        error("RXPGuides scheduler callbacks must be functions", 2)
    end
    delay = math.max(0, tonumber(delay) or 0)
    self:Cancel(owner, key)
    local entries = OwnerEntries(owner, true)
    local handle
    handle = _G.C_Timer.NewTimer(delay, function(...)
        local current = OwnerEntries(owner, false)
        if not current or current[key] ~= handle then return end
        current[key] = nil
        if not next(current) then owners[owner] = nil end
        callback(...)
    end)
    entries[key] = handle
    return handle
end

function scheduler:Ticker(owner, key, interval, callback, iterations)
    CheckKey(owner, key)
    if type(callback) ~= "function" then
        error("RXPGuides scheduler callbacks must be functions", 2)
    end
    interval = math.max(0.01, tonumber(interval) or 0.01)
    self:Cancel(owner, key)
    local entries = OwnerEntries(owner, true)
    local handle = _G.C_Timer.NewTicker(interval, callback, iterations)
    entries[key] = handle
    return handle
end

function scheduler:CancelOwner(owner)
    if owner == nil then return end
    local entries = OwnerEntries(owner, false)
    if entries then
        for _, handle in pairs(entries) do CancelHandle(handle) end
        owners[owner] = nil
    end
    combatQueue[owner] = nil
end

local function FlushCombatQueue()
    if _G.InCombatLockdown and _G.InCombatLockdown() then return end
    local pending = combatQueue
    combatQueue = {}
    for owner, callbacks in pairs(pending) do
        for key, callback in pairs(callbacks) do
            scheduler:After(owner, key, 0, callback)
        end
    end
    if combatFrame then combatFrame:UnregisterEvent("PLAYER_REGEN_ENABLED") end
end

local function EnsureCombatFrame()
    if combatFrame then return end
    combatFrame = _G.CreateFrame("Frame", "RXPCoreSchedulerFrame")
    combatFrame:SetScript("OnEvent", FlushCombatQueue)
end

function scheduler:AfterCombat(owner, key, callback)
    CheckKey(owner, key)
    if type(callback) ~= "function" then
        error("RXPGuides scheduler callbacks must be functions", 2)
    end
    self:Cancel(owner, key)
    if not (_G.InCombatLockdown and _G.InCombatLockdown()) then
        return self:After(owner, key, 0, callback)
    end
    local queued = combatQueue[owner]
    if not queued then
        queued = {}
        combatQueue[owner] = queued
    end
    queued[key] = callback
    EnsureCombatFrame()
    combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function scheduler:Has(owner, key)
    local entries = owner ~= nil and OwnerEntries(owner, false)
    local queued = owner ~= nil and combatQueue[owner]
    return (entries and entries[key] ~= nil) or
               (queued and queued[key] ~= nil) or false
end

addon.services:Register("scheduler", scheduler, "scheduler")

