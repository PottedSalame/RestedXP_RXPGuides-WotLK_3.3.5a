local _, addon = ...

local storage = addon.storage or {}
addon.storage = storage

local migrations = {}
local CURRENT_SCHEMA = 1

local function RequireTable(value, label)
    if type(value) ~= "table" then
        error("RXPGuides " .. label .. " storage is not a table", 3)
    end
    return value
end

function storage:Bind(account, character, profile)
    self.account = RequireTable(account, "account")
    self.character = RequireTable(character, "character")
    self.profile = RequireTable(profile, "profile")
    return self
end

function storage:Account()
    return RequireTable(self.account, "account")
end

function storage:Character()
    return RequireTable(self.character, "character")
end

function storage:Profile()
    return RequireTable(self.profile, "profile")
end

function storage:RegisterMigration(version, callback)
    version = tonumber(version)
    if not version or version < 1 or version % 1 ~= 0 then
        error("RXPGuides migration versions must be positive integers", 2)
    end
    if type(callback) ~= "function" then
        error("RXPGuides migration callbacks must be functions", 2)
    end
    if migrations[version] and migrations[version] ~= callback then
        error("RXPGuides migration " .. version .. " is already registered", 2)
    end
    migrations[version] = callback
end

-- Schema one introduces the migration runner only. Existing SavedVariables
-- are deliberately not reshaped at this behavior-preserving refactor gate.
storage:RegisterMigration(1, function() end)

function storage:Migrate()
    local account = self:Account()
    local version = math.max(0, math.floor(tonumber(
        account.runtimeSchemaVersion) or 0))
    if version > CURRENT_SCHEMA then
        return false, "Saved data was written by a newer runtime schema."
    end
    for nextVersion = version + 1, CURRENT_SCHEMA do
        local migration = migrations[nextVersion]
        if not migration then
            return false, "Missing runtime migration " .. nextVersion .. "."
        end
        local ok, errorText = pcall(migration, self)
        if not ok then return false, errorText end
        account.runtimeSchemaVersion = nextVersion
    end
    return true
end

function storage:GetSchemaVersion()
    return CURRENT_SCHEMA
end

addon.services:Register("storage", storage, "storage")

