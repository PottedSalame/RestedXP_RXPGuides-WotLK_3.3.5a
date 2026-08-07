local _, addon = ...

local runtime = addon.runtime or {}
addon.runtime = runtime

local specs = {}
local states = {}
local registrationOrder = {}

local function ValidateSpec(spec)
    if type(spec) ~= "table" then
        error("RXPGuides subsystem descriptors must be tables", 3)
    end
    if type(spec.id) ~= "string" or spec.id == "" then
        error("RXPGuides subsystem id must be a non-empty string", 3)
    end
    if spec.depends ~= nil and type(spec.depends) ~= "table" then
        error("RXPGuides subsystem dependencies must be a table", 3)
    end
    for _, dependency in ipairs(spec.depends or {}) do
        if type(dependency) ~= "string" or dependency == "" then
            error("RXPGuides subsystem dependencies must be names", 3)
        end
    end
end

function runtime:Register(spec)
    ValidateSpec(spec)
    local current = specs[spec.id]
    if current and current ~= spec then
        error("RXPGuides subsystem '" .. spec.id .. "' is already registered", 2)
    end
    if not current then
        spec.phase = spec.phase or "initialize"
        specs[spec.id] = spec
        states[spec.id] = {status = "registered"}
        registrationOrder[#registrationOrder + 1] = spec.id
    end
    return spec
end

function runtime:GetState(id)
    return states[id]
end

function runtime:Get(id)
    return specs[id]
end

local function ResolvePhase(phase)
    local result, visiting, visited = {}, {}, {}
    local function Visit(id)
        if visited[id] then return end
        if visiting[id] then
            error("RXPGuides subsystem dependency cycle at '" .. id .. "'", 3)
        end
        local spec = specs[id]
        if not spec then
            error("RXPGuides subsystem dependency '" .. id .. "' is missing", 3)
        end
        visiting[id] = true
        for _, dependency in ipairs(spec.depends or {}) do Visit(dependency) end
        visiting[id] = nil
        visited[id] = true
        if spec.phase == phase then result[#result + 1] = id end
    end
    for _, id in ipairs(registrationOrder) do
        if specs[id].phase == phase then Visit(id) end
    end
    return result
end

local function ReportError(errorText)
    local handler = _G.geterrorhandler and _G.geterrorhandler()
    if handler then handler(errorText) end
end

local function RunSpec(spec, callback)
    if spec.optional and addon.roadmap and addon.roadmap.RunOptional then
        return addon.roadmap:RunOptional(spec.label or spec.id, callback,
                                         spec.reset)
    end
    local ok, result = pcall(callback)
    if not ok then ReportError(result) end
    return ok, result
end

function runtime:InitializePhase(phase)
    phase = phase or "initialize"
    local order = ResolvePhase(phase)
    for _, id in ipairs(order) do
        local spec, state = specs[id], states[id]
        if state.status == "registered" then
            for _, dependency in ipairs(spec.depends or {}) do
                local dependencyState = states[dependency]
                if not dependencyState or dependencyState.status ~= "initialized" then
                    error("RXPGuides subsystem '" .. id ..
                              "' requires uninitialized subsystem '" ..
                              dependency .. "'", 2)
                end
            end
            if type(spec.initialize) == "function" then
                state.status = "initializing"
                local ok, result = RunSpec(spec, spec.initialize)
                if not ok then
                    state.status = spec.optional and "unavailable" or "failed"
                    state.error = tostring(result)
                    if not spec.optional then error(result, 2) end
                else
                    state.status = "initialized"
                    state.result = result
                end
            else
                state.status = "initialized"
            end
        end
    end
    return order
end

function runtime:EnableAll()
    for _, id in ipairs(registrationOrder) do
        local spec, state = specs[id], states[id]
        if state.status == "initialized" and type(spec.enable) == "function" then
            local ok, result = RunSpec(spec, spec.enable)
            if ok then state.status = "enabled" else state.error = tostring(result) end
        end
    end
end

function runtime:DisableAll()
    for index = #registrationOrder, 1, -1 do
        local id = registrationOrder[index]
        local spec, state = specs[id], states[id]
        if (state.status == "enabled" or state.status == "initialized") and
            type(spec.disable) == "function" then
            pcall(spec.disable)
        end
        addon.scheduler:CancelOwner(id)
        if state.status ~= "unavailable" then state.status = "disabled" end
    end
end

function runtime:List()
    local result = {}
    for index, id in ipairs(registrationOrder) do result[index] = id end
    return result
end

addon.services:Register("runtime", runtime, "runtime")

