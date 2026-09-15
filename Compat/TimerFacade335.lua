--[[ ------------------------------------------------------------------------
    TimerFacade335.lua - private, frame-backed timer service for 3.3.5a

    Some private-server UI packs publish a partial or nonfunctional C_Timer.
    RXPGuides must not overwrite that shared namespace: another addon may own
    it and may depend on the exact table and function identities it installed.

    The addon therefore always uses this private implementation. A compatible
    global C_Timer facade is published only when no table existed before RXP
    loaded, preserving standalone stock-client behavior.
------------------------------------------------------------------------------ ]]

local addonName, addon = ...
local _G = _G

if select(4, _G.GetBuildInfo()) ~= 30300 then return end

local inheritedTimer = _G.C_Timer
-- A foreign addon owns any non-nil value, even if it is malformed. RXPGuides
-- can work through its private service without rewriting that global.
local ownsGlobalTimer = inheritedTimer == nil
addon._ownsGlobalCTimer335 = ownsGlobalTimer
addon._inheritedGlobalCTimer335 = ownsGlobalTimer and nil or inheritedTimer

local timerAPI = {}
-- The driver is private state, so leave it anonymous instead of claiming a
-- global frame name which another compatibility addon may already use.
local driver = _G.CreateFrame("Frame", nil, _G.UIParent)
local active = {}
local activeCount = 0

local function SetDriverActive(enabled)
    if enabled then
        if driver.Show then driver:Show() end
    elseif driver.Hide then
        driver:Hide()
    end
end

local function ReleaseTicker(ticker)
    if active[ticker] then
        active[ticker] = nil
        activeCount = activeCount - 1
    end
    ticker._callback = nil
    ticker._cancelled = true
    if activeCount <= 0 then
        activeCount = 0
        SetDriverActive(false)
    end
end

local tickerMeta = {}
tickerMeta.__index = tickerMeta

function tickerMeta:Cancel()
    self._cancelled = true
end

function tickerMeta:IsCancelled()
    return self._cancelled == true
end

local function NewTicker(interval, callback, iterations)
    interval = tonumber(interval) or 0
    if interval < 0 then interval = 0 end

    -- Timer handles are intentionally never pooled. Callers may retain a
    -- completed handle; reusing its table would let a stale :Cancel() affect
    -- an unrelated future timer owned by RXPGuides or another addon.
    local ticker = setmetatable({}, tickerMeta)
    ticker._cancelled = false
    ticker._interval = interval
    ticker._expires = _G.GetTime() + interval
    ticker._callback = callback
    ticker._iterations = tonumber(iterations) or math.huge
    active[ticker] = true
    activeCount = activeCount + 1
    SetDriverActive(true)
    return ticker
end

driver:SetScript("OnUpdate", function()
    local now = _G.GetTime()
    local due

    -- Snapshot due work so callbacks which create zero-delay timers cannot run
    -- those new callbacks synchronously in the same update dispatch.
    for ticker in pairs(active) do
        if ticker._cancelled then
            ReleaseTicker(ticker)
        elseif now >= ticker._expires then
            due = due or {}
            due[#due + 1] = ticker
        end
    end

    if not due then return end
    for index = 1, #due do
        local ticker = due[index]
        if active[ticker] and not ticker._cancelled then
            local callback = ticker._callback
            ticker._iterations = ticker._iterations - 1
            local finished = ticker._iterations <= 0
            if not finished then
                ticker._expires = now + ticker._interval
            end

            if type(callback) == "function" then
                local ok, err = pcall(callback, ticker)
                if not ok and type(_G.geterrorhandler) == "function" then
                    local gotHandler, handler = pcall(_G.geterrorhandler)
                    if gotHandler and type(handler) == "function" then
                        -- Error reporting must not prevent cleanup or stop an
                        -- unrelated due callback from running.
                        pcall(handler, err)
                    end
                end
            end

            if finished or ticker._cancelled then ReleaseTicker(ticker) end
        end
    end
end)

function timerAPI.After(delay, callback)
    NewTicker(delay, function()
        if type(callback) == "function" then callback() end
    end, 1)
end

function timerAPI.NewTimer(delay, callback)
    return NewTicker(delay, callback, 1)
end

function timerAPI.NewTicker(interval, callback, iterations)
    return NewTicker(interval, callback, iterations)
end

addon.timerAPI335 = timerAPI
SetDriverActive(false)

if ownsGlobalTimer then
    -- Keep the published table separate: a later addon may replace its fields,
    -- but cannot thereby alter the private implementation RXPGuides consumes.
    local globalTimer = {}
    globalTimer.After = timerAPI.After
    globalTimer.NewTimer = timerAPI.NewTimer
    globalTimer.NewTicker = timerAPI.NewTicker
    _G.C_Timer = globalTimer
end
