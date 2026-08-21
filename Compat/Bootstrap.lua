--[[ ------------------------------------------------------------------------
    Compat/Bootstrap.lua - WoW 3.3.5a compatibility prelude for RXPGuides

    RXPGuides is written for modern WoW clients (Retail + all "Classic" flavors),
    which expose the C_* API namespaces and the uiMapID map system. The original
    3.3.5a client predates both. This file polyfills the C_* namespaces the addon
    indexes so the existing `C_Foo and C_Foo.Bar or _G.Bar` fallback idiom works,
    and provides real implementations for the APIs 3.3.5a lacks.

    LOAD ORDER: this file must load FIRST in the TOC, before libs\embeds*.xml and
    every core file, because the addon indexes C_* tables at file scope.

    The map/coordinate namespace (C_Map) and the HereBeDragons libraries are
    handled separately by the Astrolabe-backed shim (libs\HBD335\*). This file
    only creates an empty C_Map table so file-scope indexing is safe; the shim
    fills it in.
------------------------------------------------------------------------------ ]]

-- This manifest is for the 3.3.5a build only. Check the interface explicitly so
-- compatibility globals published by another addon cannot make RXP skip its own
-- standalone adapters.
if select(4, _G.GetBuildInfo()) ~= 30300 then return end

local _G = _G
local addonName, addon = ...

-- Fetch-or-create a global namespace table.
local function ns(name)
    local t = _G[name]
    if type(t) ~= "table" then
        t = {}
        _G[name] = t
    end
    return t
end

-- Define t.key only if it is not already present (never clobber a real API).
local function def(t, key, fn)
    if t[key] == nil then t[key] = fn end
end

-- Stock 3.3.5 APIs normally use 1/nil for boolean return values. Some private
-- server clients return 0 instead of nil, which is still truthy in Lua. Keep
-- that representation from leaking into modern boolean facades.
local function legacyTrue(value)
    return value == true or value == 1
end

--=========================================================================
-- Missing globals / constants
--=========================================================================

-- WOW_PROJECT_* identifiers (used by some libraries for flavor detection).
def(_G, "WOW_PROJECT_MAINLINE", 1)
def(_G, "WOW_PROJECT_CLASSIC", 2)
def(_G, "WOW_PROJECT_BURNING_CRUSADE_CLASSIC", 5)
def(_G, "WOW_PROJECT_WRATH_CLASSIC", 11)
def(_G, "WOW_PROJECT_CATACLYSM_CLASSIC", 14)
def(_G, "WOW_PROJECT_MISTS_CLASSIC", 19)
def(_G, "WOW_PROJECT_ID", _G.WOW_PROJECT_WRATH_CLASSIC)

-- Modern code names the stock UI sounds through SOUNDKIT. 3.3.5's PlaySound
-- accepts the original string tokens, so expose the subset used by RXP and
-- its bundled libraries without requiring another addon to define the table.
local SOUNDKIT = ns("SOUNDKIT")
SOUNDKIT.GS_TITLE_OPTION_EXIT = SOUNDKIT.GS_TITLE_OPTION_EXIT or
                                    "gsTitleOptionExit"
SOUNDKIT.IG_CHARACTER_INFO_TAB = SOUNDKIT.IG_CHARACTER_INFO_TAB or
                                     "igCharacterInfoTab"
SOUNDKIT.IG_MAINMENU_CLOSE = SOUNDKIT.IG_MAINMENU_CLOSE or
                                 "igMainMenuClose"
SOUNDKIT.IG_MAINMENU_OPTION = SOUNDKIT.IG_MAINMENU_OPTION or
                                  "igMainMenuOption"
SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF =
    SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or
        "igMainMenuOptionCheckBoxOff"
SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON =
    SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or
        "igMainMenuOptionCheckBoxOn"
SOUNDKIT.IG_PLAYER_INVITE_DECLINE = SOUNDKIT.IG_PLAYER_INVITE_DECLINE or
                                        "igPlayerInviteDecline"
SOUNDKIT.RAID_WARNING = SOUNDKIT.RAID_WARNING or "RaidWarning"
SOUNDKIT.U_CHAT_SCROLL_BUTTON = SOUNDKIT.U_CHAT_SCROLL_BUTTON or
                                    "UChatScrollButton"

-- securecallfunction / securecall
def(_G, "securecall", function(func, ...)
    if type(func) == "string" then func = _G[func] end
    return func(...)
end)
def(_G, "securecallfunction", _G.securecall)

-- Mixin helpers (added in Legion; some modern library code expects them).
def(_G, "Mixin", function(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        if type(mixin) == "table" then
            for k, v in pairs(mixin) do object[k] = v end
        end
    end
    return object
end)
def(_G, "CreateFromMixins", function(...)
    return _G.Mixin({}, ...)
end)
def(_G, "CreateAndInitFromMixin", function(mixin, ...)
    local o = _G.CreateFromMixins(mixin)
    if o.Init then o:Init(...) end
    return o
end)

-- tInvert: build a value->key lookup table.
def(_G, "tInvert", function(tbl)
    local inverted = {}
    for k, v in pairs(tbl) do inverted[v] = k end
    return inverted
end)

-- CreateVector2D / Vector2DMixin (Legion+). RXPGuides and HBD create these at
-- file scope, so the global must exist before those files load.
if not _G.CreateVector2D then
    local Vector2DMixin = {}
    Vector2DMixin.__index = Vector2DMixin
    function Vector2DMixin:GetXY() return self.x, self.y end
    function Vector2DMixin:SetXY(x, y) self.x, self.y = x, y end
    function Vector2DMixin:GetLength() return ((self.x or 0)^2 + (self.y or 0)^2)^0.5 end
    function _G.CreateVector2D(x, y)
        return setmetatable({ x = x, y = y }, Vector2DMixin)
    end
end

-- Enum table (namespaced constants used by some modern map code). Provide the
-- UIMapType values the map shim reports.
do
    local Enum = ns("Enum")
    -- Several private-server UI packs publish partial modern Enum tables. A
    -- table-level fallback is not sufficient in that case: a missing member
    -- becomes a nil table key as soon as ItemUpgrades builds its class maps.
    -- Merge only absent values so complete client/addon-provided enums remain
    -- authoritative while the standalone 3.3.5 surface is always usable.
    local function FillEnum(name, defaults)
        local values = Enum[name]
        if type(values) ~= "table" then
            values = {}
            Enum[name] = values
        end
        for key, value in pairs(defaults) do
            if values[key] == nil then values[key] = value end
        end
        return values
    end

    FillEnum("UIMapType", {
        Cosmic = 0, World = 1, Continent = 2, Zone = 3,
        Dungeon = 4, Micro = 5, Orphan = 6,
    })
    FillEnum("ItemQuality", {
        Poor = 0, Common = 1, Uncommon = 2, Rare = 3, Epic = 4,
        Legendary = 5, Artifact = 6, Heirloom = 7, WoWToken = 8,
    })
    -- Item class/subclass enums are used by ItemUpgrades as table keys while
    -- that file is loading, so every referenced legacy value must exist.
    FillEnum("ItemArmorSubclass", {
        Generic = 0, Cloth = 1, Leather = 2, Mail = 3, Plate = 4,
        Cosmetic = 5, Shield = 6, Libram = 7, Idol = 8, Totem = 9,
        Sigil = 10, Relic = 11,
    })
    FillEnum("ItemWeaponSubclass", {
        Axe1H = 0, Axe2H = 1, Bows = 2, Guns = 3, Mace1H = 4, Mace2H = 5,
        Polearm = 6, Sword1H = 7, Sword2H = 8, Warglaive = 9, Staff = 10,
        Bearclaw = 11, Catclaw = 12, Unarmed = 13, Generic = 14, Dagger = 15,
        Thrown = 16, Crossbow = 18, Wand = 19, Fishingpole = 20,
    })
    Enum.ItemClass = type(Enum.ItemClass) == "table" and Enum.ItemClass or {}
    local itemClasses = {
        Consumable = 0, Container = 1, Weapon = 2, Gem = 3, Armor = 4,
        Reagent = 5, Projectile = 6, Tradegoods = 7, ItemEnhancement = 8,
        Recipe = 9, Money = 10, Quiver = 11, Questitem = 12, Key = 13,
        Permanent = 14, Miscellaneous = 15, Glyph = 16,
    }
    for name, value in pairs(itemClasses) do
        if Enum.ItemClass[name] == nil then Enum.ItemClass[name] = value end
    end

    Enum.FlightPathState = type(Enum.FlightPathState) == "table" and
                               Enum.FlightPathState or {}
    if Enum.FlightPathState.Unreachable == nil then Enum.FlightPathState.Unreachable = 0 end
    if Enum.FlightPathState.Current == nil then Enum.FlightPathState.Current = 1 end
    if Enum.FlightPathState.Reachable == nil then Enum.FlightPathState.Reachable = 2 end

    Enum.PlayerInteractionType = type(Enum.PlayerInteractionType) == "table" and
                                     Enum.PlayerInteractionType or {}
    -- The numeric values are private to this adapter. Callers only pass them
    -- back to C_PlayerInteractionManager below.
    if Enum.PlayerInteractionType.Binder == nil then Enum.PlayerInteractionType.Binder = 1 end
    if Enum.PlayerInteractionType.SpiritHealer == nil then Enum.PlayerInteractionType.SpiritHealer = 2 end
    if Enum.PlayerInteractionType.ChromieTime == nil then Enum.PlayerInteractionType.ChromieTime = 3 end
end

-- RAID_CLASS_COLORS on 3.3.5a are plain {r,g,b} tables; modern code expects a
-- ColorMixin-style `.colorStr` ("ffRRGGBB") and helpers. Add them in place.
if _G.RAID_CLASS_COLORS then
    local function hex(c)
        return string.format("ff%02x%02x%02x",
            math.floor((c.r or 0) * 255 + 0.5),
            math.floor((c.g or 0) * 255 + 0.5),
            math.floor((c.b or 0) * 255 + 0.5))
    end
    for _, color in pairs(_G.RAID_CLASS_COLORS) do
        if type(color) == "table" and not color.colorStr then
            color.colorStr = hex(color)
            if not color.GenerateHexColor then
                function color:GenerateHexColor() return self.colorStr end
            end
            if not color.GetRGB then
                function color:GetRGB() return self.r, self.g, self.b end
            end
        end
    end
end

--=========================================================================
-- Missing frame methods (added in later expansions). Patch the metatables of
-- the common frame types so both RXPGuides and other addons' code works.
--=========================================================================
do
    local newMethods = {
        SetShown = function(self, shown)
            if shown then self:Show() else self:Hide() end
        end,
        -- GameTooltip:Set*ByID helpers (added post-3.3.5a). RXP's Active Item
        -- button uses them on hover; emulate via SetHyperlink so a nil method does
        -- not error (a plain SetHyperlink shows the same item/spell tooltip).
        SetItemByID = function(self, id)
            if self.SetHyperlink and id then self:SetHyperlink("item:" .. id) end
        end,
        SetInventoryItemByID = function(self, id)
            if self.SetHyperlink and id then self:SetHyperlink("item:" .. id) end
        end,
        SetToyByItemID = function(self, id)
            if self.SetHyperlink and id then self:SetHyperlink("item:" .. id) end
        end,
        SetSpellByID = function(self, id)
            if self.SetHyperlink and id then self:SetHyperlink("spell:" .. id) end
        end,
        SetMouseClickEnabled = function() end,   -- 9.0; EnableMouse covers it
        SetMouseMotionEnabled = function() end,  -- 9.0
        SetFixedFrameStrata = function() end,    -- 9.0
        SetFixedFrameLevel = function() end,     -- 9.0
        SetIgnoreParentScale = function() end,   -- best-effort no-op
        SetIgnoreParentAlpha = function() end,   -- 5.x; best-effort no-op
        -- 5.x: keep this a pure no-op. Emulating it via EnableKeyboard risks a
        -- frame grabbing the keyboard (swallowing Enter/Esc). RXPGuides never
        -- calls EnableKeyboard(true), so a no-op is safe here.
        SetPropagateKeyboardInput = function() end,
        IsForbidden = function() return false end,  -- 7.0; no frames are forbidden on 3.3.5a
        -- 9.0 BackdropTemplateMixin method; on 3.3.5a clearing == SetBackdrop(nil).
        ClearBackdrop = function(self) if self.SetBackdrop then self:SetBackdrop(nil) end end,
        -- 6.0 Cooldown:Clear(); on 3.3.5a zero the cooldown to clear its swipe.
        -- (RXP calls this on the Active Item button when the tracked item changes;
        -- a nil method here was crashing SetStep, blocking step navigation.)
        Clear = function(self) if self.SetCooldown then self:SetCooldown(0, 0) end end,
        -- 7.0 line objects don't exist on 3.3.5a. A rotated solid WHITE8X8
        -- texture is not sufficient: rotating its texture coordinates still
        -- leaves an opaque axis-aligned bounding box, which produced the large
        -- purple/black rectangles seen around small guide areas. Emulate the
        -- LineMixin subset RXP uses with a reusable chain of small texture tiles.
        -- The result remains thin at every angle and needs no external library.
        CreateLine = function(self, name, layer, template, subLevel)
            local line = {
                __lineParent = self,
                __tiles = {},
                __thickness = 2,
                __layer = layer or "OVERLAY",
                __subLevel = subLevel,
                __color = {1, 1, 1, 1},
                __alpha = 1,
                __shown = true
            }

            local function HideUnused(t, first)
                for i = first or 1, #t.__tiles do t.__tiles[i]:Hide() end
            end

            local function ApplyTileStyle(t, tile)
                tile:SetTexture("Interface\\Buttons\\WHITE8X8")
                tile:SetVertexColor(unpack(t.__color))
                tile:SetAlpha(t.__alpha or 1)
                if type(t.__subLevel) == "number" then
                    tile:SetDrawLayer(t.__layer or "OVERLAY", t.__subLevel)
                else
                    tile:SetDrawLayer(t.__layer or "OVERLAY")
                end
            end

            function line:__redrawLine()
                local sx, sy, ex, ey = self.__x1, self.__y1,
                                             self.__x2, self.__y2
                if not (self.__shown and sx and sy and ex and ey) then
                    HideUnused(self)
                    return
                end

                local dx, dy = ex - sx, ey - sy
                local length = (dx * dx + dy * dy) ^ 0.5
                if length <= 0 then
                    HideUnused(self)
                    return
                end

                local thickness = math.max(0.75,
                                           tonumber(self.__thickness) or 2)
                local spacing = math.max(0.75, thickness * 0.60)
                local count = math.max(2, math.ceil(length / spacing) + 1)
                -- A malformed or continent-spanning segment must not allocate an
                -- unbounded number of regions. Normal guide segments are far
                -- below this limit; longer ones become a fine dotted line.
                count = math.min(count, 512)
                local relPoint = self.__point or "TOPLEFT"

                for i = 1, count do
                    local tile = self.__tiles[i]
                    if not tile then
                        tile = self.__lineParent:CreateTexture(nil,
                                                               self.__layer or
                                                                   "OVERLAY")
                        self.__tiles[i] = tile
                    end
                    ApplyTileStyle(self, tile)
                    tile:ClearAllPoints()
                    tile:SetWidth(thickness)
                    tile:SetHeight(thickness)
                    local progress = (i - 1) / (count - 1)
                    tile:SetPoint("CENTER", self.__lineParent, relPoint,
                                  sx + dx * progress, sy + dy * progress)
                    tile:Show()
                end
                HideUnused(self, count + 1)
            end

            local function endpoint(t, key1, key2, point, a, b, c)
                -- Accept LineMixin's (relativePoint, x, y) and
                -- (relativePoint, relativeTo, x, y) forms.
                local x, y
                if type(a) == "number" then x, y = a, b else x, y = b, c end
                t.__point = point
                t[key1], t[key2] = x, y
                t:__redrawLine()
            end
            line.SetStartPoint = function(t, point, a, b, c)
                endpoint(t, "__x1", "__y1", point, a, b, c)
            end
            line.SetEndPoint = function(t, point, a, b, c)
                endpoint(t, "__x2", "__y2", point, a, b, c)
            end
            line.SetThickness = function(t, th)
                t.__thickness = th or 2
                t:__redrawLine()
            end
            line.SetColorTexture = function(t, r, g, b, a)
                t.__color = {r or 1, g or 1, b or 1, a or 1}
                t:__redrawLine()
            end
            line.SetDrawLayer = function(t, newLayer, newSubLevel)
                t.__layer = newLayer or "OVERLAY"
                t.__subLevel = newSubLevel
                t:__redrawLine()
            end
            line.SetAlpha = function(t, alpha)
                t.__alpha = tonumber(alpha) or 1
                t:__redrawLine()
            end
            line.Hide = function(t)
                t.__shown = false
                HideUnused(t)
            end
            line.Show = function(t)
                t.__shown = true
                t:__redrawLine()
            end
            return line
        end,
    }
    local frameTypes = {
        "Frame", "Button", "CheckButton", "StatusBar", "EditBox", "Slider",
        "ScrollFrame", "GameTooltip", "MessageFrame", "SimpleHTML", "Cooldown",
    }
    for _, ft in ipairs(frameTypes) do
        -- Cooldown frames can fail to create without a parent/template on 3.3.5a;
        -- if the probe fails we never patch their metatable (e.g. the :Clear
        -- polyfill), so give Cooldown an explicit parent + template.
        local ok, f
        if ft == "Cooldown" then
            ok, f = pcall(CreateFrame, ft, nil, _G.UIParent, "CooldownFrameTemplate")
        else
            ok, f = pcall(CreateFrame, ft)
        end
        if ok and f then
            -- CRITICAL: a freshly created EditBox is shown with autofocus ON, so
            -- it immediately grabs the keyboard. This throwaway frame exists only
            -- to reach the shared metatable, so neutralise it before discarding
            -- (otherwise an invisible focused EditBox eats Enter/Esc/all keys).
            if f.SetAutoFocus then pcall(f.SetAutoFocus, f, false) end
            if f.ClearFocus then pcall(f.ClearFocus, f) end
            if f.EnableKeyboard then pcall(f.EnableKeyboard, f, false) end
            if f.Hide then pcall(f.Hide, f) end
            local mt = getmetatable(f)
            local idx = mt and mt.__index
            if type(idx) == "table" then
                for name, fn in pairs(newMethods) do
                    if idx[name] == nil then idx[name] = fn end
                end
            end
        end
    end

    -- Guarantee the real tooltip frames get the Set*ByID polyfills even if the
    -- CreateFrame("GameTooltip") probe above did not reach their metatable.
    for _, tip in ipairs({_G.GameTooltip, _G.ItemRefTooltip, _G.ShoppingTooltip1}) do
        local mt = tip and getmetatable(tip)
        local idx = mt and mt.__index
        if type(idx) == "table" then
            for name, fn in pairs(newMethods) do
                if idx[name] == nil then idx[name] = fn end
            end
        end
    end

    -- Textures and FontStrings (Regions) also lack IsForbidden/SetShown on
    -- 3.3.5a, and RXPGuides calls those on textures (e.g. quest-reward icons).
    local regionMethods = {
        IsForbidden = function() return false end,
        SetShown = function(self, shown)
            if shown then self:Show() else self:Hide() end
        end,
    }
    local ok, probe = pcall(CreateFrame, "Frame")
    if ok and probe then
        local regions = {}
        local okT, tex = pcall(probe.CreateTexture, probe)
        if okT and tex then regions[#regions + 1] = tex end
        local okF, fs = pcall(probe.CreateFontString, probe)
        if okF and fs then regions[#regions + 1] = fs end
        for _, obj in ipairs(regions) do
            local mt = getmetatable(obj)
            local idx = mt and mt.__index
            if type(idx) == "table" then
                for name, fn in pairs(regionMethods) do
                    if idx[name] == nil then idx[name] = fn end
                end
            end
        end
    end
end

-- WorldMapFrame:OnMapChanged does not exist on 3.3.5a; UI/Map.lua hooks
-- it unconditionally. Provide a no-op so the hook installs without error.
if _G.WorldMapFrame and _G.WorldMapFrame.OnMapChanged == nil then
    _G.WorldMapFrame.OnMapChanged = function() end
end

-- WorldMapFrame:GetCanvas() (modern) returns the frame the map art/pins live on.
-- On 3.3.5a that is WorldMapDetailFrame.
if _G.WorldMapFrame and _G.WorldMapFrame.GetCanvas == nil then
    _G.WorldMapFrame.GetCanvas = function()
        return _G.WorldMapDetailFrame or _G.WorldMapButton or _G.WorldMapFrame
    end
end

--=========================================================================
-- Object/Frame/Texture pools (Blizzard Pools.lua, added in Legion). UI/Map.lua
-- uses these for world/minimap pin management via :Acquire / :ReleaseAll /
-- :EnumerateActive and by setting pool.creationFunc / pool.resetterFunc.
--=========================================================================
if not _G.CreateObjectPool then
    local ObjectPoolMixin = {}
    ObjectPoolMixin.__index = ObjectPoolMixin

    function ObjectPoolMixin:Acquire()
        local numInactive = #self.inactiveObjects
        local obj
        local isNew = false
        if numInactive > 0 then
            obj = self.inactiveObjects[numInactive]
            self.inactiveObjects[numInactive] = nil
        else
            isNew = true
            obj = self.creationFunc(self)
            if self.resetterFunc and not self.disallowResetIfNew then
                self.resetterFunc(self, obj)
            end
        end
        self.activeObjects[obj] = true
        self.numActiveObjects = self.numActiveObjects + 1
        return obj, isNew
    end

    function ObjectPoolMixin:Release(obj)
        if self.activeObjects[obj] then
            self.inactiveObjects[#self.inactiveObjects + 1] = obj
            self.activeObjects[obj] = nil
            self.numActiveObjects = self.numActiveObjects - 1
            if self.resetterFunc then self.resetterFunc(self, obj) end
            return true
        end
        return false
    end

    function ObjectPoolMixin:ReleaseAll()
        for obj in pairs(self.activeObjects) do
            self:Release(obj)
        end
    end

    function ObjectPoolMixin:EnumerateActive()
        return pairs(self.activeObjects)
    end
    function ObjectPoolMixin:GetNextActive(current)
        return (next(self.activeObjects, current))
    end
    function ObjectPoolMixin:IsActive(obj) return self.activeObjects[obj] == true end
    function ObjectPoolMixin:GetNumActive() return self.numActiveObjects end
    function ObjectPoolMixin:SetResetDisallowedIfNew(disallow) self.disallowResetIfNew = disallow end

    local function newPool(creationFunc, resetterFunc)
        return setmetatable({
            creationFunc = creationFunc,
            resetterFunc = resetterFunc,
            activeObjects = {},
            inactiveObjects = {},
            numActiveObjects = 0,
        }, ObjectPoolMixin)
    end

    _G.CreateObjectPool = function(creationFunc, resetterFunc)
        return newPool(creationFunc, resetterFunc)
    end

    _G.CreateFramePool = function(frameType, parent, template, resetterFunc, forbidden)
        local pool = newPool(nil, resetterFunc)
        pool.frameType = frameType or "Frame"
        pool.parent = parent
        pool.frameTemplate = template
        pool.creationFunc = function(p)
            return CreateFrame(p.frameType, nil, p.parent, p.frameTemplate)
        end
        return pool
    end

    -- Distinct from CreateFramePool so UI/Map.lua's `CreateSecureFramePool ==
    -- CreateFramePool` test is false and it uses the clean creationFunc path.
    _G.CreateSecureFramePool = function(frameType, parent, template, resetterFunc, forbidden)
        return _G.CreateFramePool(frameType, parent, template, resetterFunc, true)
    end

    _G.CreateTexturePool = function(parent, layer, subLayer, template, resetterFunc)
        local pool = newPool(nil, resetterFunc)
        pool.parent = parent
        pool.layer = layer
        pool.subLayer = subLayer
        pool.textureTemplate = template
        pool.creationFunc = function(p)
            return p.parent:CreateTexture(nil, p.layer, p.textureTemplate, p.subLayer)
        end
        return pool
    end
    _G.CreateUnsecuredTexturePool = _G.CreateTexturePool
end

-- UnitEffectiveLevel (Legion+); on 3.3.5a effective == actual level.
def(_G, "UnitEffectiveLevel", function(unit) return _G.UnitLevel(unit) end)

-- IsPlayerSpell (added in 4.0.1). Approximate with IsSpellKnown.
def(_G, "IsPlayerSpell", function(spellID) return _G.IsSpellKnown(spellID) end)

-- GetSpellSubtext (added ~4.0). On 3.3.5a the spell rank/subtext is the 2nd
-- return of GetSpellInfo.
def(_G, "GetSpellSubtext", function(spell) return (select(2, _G.GetSpellInfo(spell))) end)

-- Settings API (added in 10.0). Route to the classic Interface Options panel.
if not _G.Settings then
    _G.Settings = {
        OpenToCategory = function(category)
            if _G.InterfaceOptionsFrame_OpenToCategory then
                -- Classic quirk: call twice so it actually scrolls to the panel.
                _G.InterfaceOptionsFrame_OpenToCategory(category)
                _G.InterfaceOptionsFrame_OpenToCategory(category)
            end
        end,
        RegisterCanvasLayoutCategory = function() return nil end,
        RegisterAddOnCategory = function() end,
        RegisterVerticalLayoutCategory = function() return nil end,
    }
end

-- GetSpecialization / spec APIs (added in MoP). WotLK talents are tab-based;
-- return nil so guarded call sites fall through.
def(_G, "GetSpecialization", function() return nil end)
def(_G, "GetSpecializationInfo", function() return nil end)

-- GetCurrentRegion (added in 6.0). Core/Addon.lua and AceDB use it; 1 = US-like.
def(_G, "GetCurrentRegion", function() return 1 end)

-- GetMaxPlayerLevel (added in 5.0). WotLK cap is 80.
def(_G, "GetMaxPlayerLevel", function() return _G.MAX_PLAYER_LEVEL or 80 end)

-- IsInRaid / IsInGroup (added in 5.0). Derive from the 3.3.5a group-count APIs.
def(_G, "IsInRaid", function() return (_G.GetNumRaidMembers() or 0) > 0 end)
def(_G, "IsInGroup", function()
    return (_G.GetNumPartyMembers() or 0) > 0 or (_G.GetNumRaidMembers() or 0) > 0
end)

-- GetNumGroupMembers (added in 5.0): raid size if in a raid, else party size
-- INCLUDING the player. GetNumPartyMembers() excludes the player on 3.3.5a.
_G.GetNumGroupMembers = function()
    local raid = _G.GetNumRaidMembers() or 0
    if raid > 0 then return raid end
    local party = _G.GetNumPartyMembers() or 0
    return party > 0 and party + 1 or 0
end
def(_G, "GetNumSubgroupMembers", function() return _G.GetNumPartyMembers() or 0 end)

-- RXPGuides reads GetQuestLogTitle expecting the "modern Classic" return order
-- (isComplete at #6, questID at #8). AzerothCore's 3.3.5a client has an extra
-- questTag at #3 and returns questID at #9,
-- so every position-dependent read in RXP is off by one. This wrapper reshapes
-- the return into the order RXP expects; RXPGuides files point their local
-- GetQuestLogTitle at it (see Guide/Directives.lua and Guide/QuestLog.lua).
_G.RXPCompatGetQuestLogTitle = function(index)
    local title, level, questTag, suggestedGroup, isHeader, isCollapsed,
          isComplete, isDaily, questID = _G.GetQuestLogTitle(index)
    -- If the client didn't provide the backported questID at #9, fall back to it
    -- being absent (callers already tolerate nil).
    return title, level, suggestedGroup, legacyTrue(isHeader),
           legacyTrue(isCollapsed), legacyTrue(isComplete),
           (legacyTrue(isDaily) and 2 or 1), questID
end

-- HaveQuestData / HaveQuestRewardData (added ~6.x): on 3.3.5a all quest data is
-- local, so it is always "available".
def(_G, "HaveQuestData", function() return true end)
def(_G, "HaveQuestRewardData", function() return true end)

-- PlayerHasToy (toys added in 6.x); no toys on 3.3.5a.
def(_G, "PlayerHasToy", function() return false end)

-- GetQuestID (added ~4.x): the quest currently shown in the quest-giver frame.
-- 3.3.5a has no such API, but for a quest we already hold (turn-in / progress)
-- we can recover the real numeric ID: match the frame's title (GetTitleText)
-- against the quest log, whose entries expose the ID at position 9 on
-- AzerothCore.  A quest still being *offered* (accept) is not in the log yet,
-- so this returns nil there and callers fall back to title matching.
def(_G, "GetQuestID", function()
    local title = _G.GetTitleText and _G.GetTitleText()
    if not title or title == "" then return nil end
    local n = _G.GetNumQuestLogEntries and _G.GetNumQuestLogEntries() or 0
    for i = 1, n do
        local t, _, _, _, isHeader = _G.GetQuestLogTitle(i)
        if not legacyTrue(isHeader) and t == title then
            local id = select(9, _G.GetQuestLogTitle(i))
            if type(id) == "number" and id > 0 then return id end
        end
    end
    return nil
end)

-- QuestInfo_GetRewardButton (Cata+ helper) resolves a quest-reward item button by
-- index. 3.3.5a has no such function; the reward buttons are plain global frames.
-- RXPGuides' quest-choice recommendation calls this during QUEST_COMPLETE and it
-- errored (nil global), aborting handleQuestComplete mid-turn-in. Resolve the
-- button from the known stock 3.3.5a frame names.
def(_G, "QuestInfo_GetRewardButton", function(rewardsFrame, index)
    if type(rewardsFrame) == "table" and rewardsFrame.RewardButtons then
        return rewardsFrame.RewardButtons[index]
    end
    if not index then return nil end
    local names = {
        "QuestInfoRewardsFrameQuestInfoItem" .. index,
        "QuestInfoItem" .. index,
        "QuestRewardItem" .. index,
        "QuestFrameRewardPanelItem" .. index,
    }
    for _, name in ipairs(names) do
        local b = _G[name]
        if b and b:IsShown() then return b end
    end
    for _, name in ipairs(names) do
        if _G[name] then return _G[name] end
    end
    return nil
end)

-- Ambiguate (added in 5.4): strips/keeps realm from a name. Best-effort: drop realm.
def(_G, "Ambiguate", function(name, context)
    if type(name) ~= "string" then return name end
    return (name:gsub("%-.*$", ""))
end)

-- GetItemInfoInstant (added in 7.0): returns cache-independent item facts. RXP's
-- ItemUpgrades only consumes the first return (itemID); provide that reliably by
-- parsing the item string/link, and fill the rest best-effort from GetItemInfo.
def(_G, "GetItemInfoInstant", function(item)
    local id
    if type(item) == "number" then
        id = item
    elseif type(item) == "string" then
        id = tonumber(item:match("item:(%d+)")) or tonumber(item)
    end
    if not id then return nil end
    local _, _, _, _, _, itemType, itemSubType, _, itemEquipLoc, icon =
        _G.GetItemInfo(item)
    return id, itemType, itemSubType, itemEquipLoc, icon
end)

-- BNSendGameData (Battle.net game data, added in 6.1). Stub so libraries that
-- securely hook it (e.g. ChatThrottleLib) do not error.
def(_G, "BNSendGameData", function() end)

-- Global UI string constants that don't exist on 3.3.5a but are referenced by
-- SettingsPanel's options table (many are passed to string.format, which errors
-- on nil). `def` only fills a value when the constant is genuinely missing, so
-- any of these that DO exist on 3.3.5a are left untouched.
do
    local strings = {
        POWER_TYPE_EXPERIENCE = "Experience",
        COMMUNITIES_SETTINGS_LABEL = "Communities",
        COMMUNITIES_NOTIFICATION_SETTINGS = "Notification Settings",
        FEATURES_LABEL = "Features",
        ITEM_UPGRADE = "Item Upgrade",
        SETTINGS = "Settings",
        MAINMENU = "Main Menu",
        EXPANSION_FILTER_TEXT = "Expansion",
        LOCALE_TEXT_LABEL = "Locale",
        HELP_LABEL = "Help",
        OPTION_TOOLTIP_COMBAT_TARGET_MODE_NEW = "",
        QUEUED_STATUS_READY_CHECK_IN_PROGRESS = "Ready Check",
        SHOW_FULLSCREEN_STATUS_TEXT = "Show Status Text",
        EVENTTRACE_BUTTON_PLAY = "Play",
        COMBATLOG_HIGHLIGHT_KILL = "Highlight Kills",
        MAP_OPTIONS_TEXT = "Map Options",
        MINIMAP_TRACKING_AUCTIONEER = "Auctioneer",
        -- Remaining SettingsPanel string references; harmless where they exist.
        PREVIEW = "Preview",
        AUCTION_ITEM = "Auction Item",
        QUALITY = "Quality",
        SEARCH = "Search",
        TALENTS = "Talents",
        HELP = "Help",
        GENERAL = "General",
        RESET = "Reset",
        APPLY = "Apply",
        CLOSE = "Close",
        OKAY = "Okay",
        HIDE = "Hide",
        SHOW = "Show",
        BACKGROUND = "Background",
        LOOT = "Loot",
        HISTORY = "History",
        FRIENDLY = "Friendly",
        MASTER = "Master",
        ADDON_NOT_AVAILABLE = "AddOn not available",
        GAMEOPTIONS_MENU = "Game Options",
        INVENTORY_TOOLTIP = "Inventory",
        ERR_QUEST_COMPLETE_S = "%s (Complete)",
        AMBIENCE_VOLUME = "Ambience Volume",
        DIALOG_VOLUME = "Dialog Volume",
        MUSIC_VOLUME = "Music Volume",
        TUTORIAL_TITLE18 = "Map",
        BINDING_HEADER_DEBUG = "Debug",
        BINDING_HEADER_TARGETING = "Targeting",
        -- Item-stat / spell-school constants ItemUpgrades concatenates or uses as
        -- table keys at load; missing ones on 3.3.5a would abort the whole module.
        ITEM_MOD_CR_SPEED_SHORT = "Haste",
        ITEM_MOD_ATTACK_POWER_SHORT = "Attack Power",
        ITEM_MOD_SPELL_POWER = "Spell Power",
        ITEM_MOD_SPELL_DAMAGE_DONE = "Spell Damage",
        SPELL_SCHOOL2_NAME = "Fire",
        SPELL_SCHOOL3_NAME = "Nature",
        SPELL_SCHOOL4_NAME = "Frost",
        SPELL_SCHOOL5_NAME = "Shadow",
        SPELL_SCHOOL6_NAME = "Arcane",
    }
    for name, value in pairs(strings) do
        def(_G, name, value)
    end
end

-- Month-name table used by the leveling tracker's date formatting.
if type(_G.CALENDAR_FULLDATE_MONTH_NAMES) ~= "table" then
    _G.CALENDAR_FULLDATE_MONTH_NAMES = {
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December",
    }
end

-- GetContainerItemQuestInfo etc. left to per-namespace polyfills above.

--=========================================================================
-- C_Timer  (OnUpdate-based scheduler; must be self-contained since this file
--           loads before AceTimer)
--=========================================================================
if not _G.C_Timer then
    local C_Timer = ns("C_Timer")
    local scheduler = CreateFrame("Frame", "RXPCompat335TimerFrame")
    local active = {}      -- ticker -> true
    local pool = {}

    local function releaseTicker(ticker)
        active[ticker] = nil
        ticker._callback = nil
        pool[#pool + 1] = ticker
    end

    scheduler:SetScript("OnUpdate", function(_, elapsed)
        local now = GetTime()
        -- Snapshot to allow tickers to schedule new tickers safely.
        local due
        for ticker in pairs(active) do
            if ticker._cancelled then
                releaseTicker(ticker)
            elseif now >= ticker._expires then
                due = due or {}
                due[#due + 1] = ticker
            end
        end
        if not due then return end
        for i = 1, #due do
            local ticker = due[i]
            if not ticker._cancelled and active[ticker] then
                local cb = ticker._callback
                ticker._iterations = ticker._iterations - 1
                if ticker._iterations <= 0 then
                    releaseTicker(ticker)
                else
                    ticker._expires = now + ticker._interval
                end
                if cb then
                    -- Ticker callbacks receive the ticker as the arg (Blizzard behavior).
                    local ok, err = pcall(cb, ticker)
                    if not ok and _G.geterrorhandler then _G.geterrorhandler()(err) end
                end
            end
        end
    end)

    local tickerMeta = {}
    tickerMeta.__index = tickerMeta
    function tickerMeta:Cancel()
        self._cancelled = true
    end
    function tickerMeta:IsCancelled()
        return self._cancelled == true
    end

    local function newTicker(interval, callback, iterations)
        if type(interval) ~= "number" then interval = 0 end
        if interval < 0 then interval = 0 end
        local ticker = pool[#pool]
        if ticker then
            pool[#pool] = nil
        else
            ticker = setmetatable({}, tickerMeta)
        end
        ticker._cancelled = false
        ticker._interval = interval
        ticker._expires = GetTime() + interval
        ticker._callback = callback
        ticker._iterations = iterations or math.huge
        active[ticker] = true
        return ticker
    end

    function C_Timer.After(delay, callback)
        newTicker(delay, function() if callback then callback() end end, 1)
    end
    function C_Timer.NewTimer(delay, callback)
        return newTicker(delay, callback, 1)
    end
    function C_Timer.NewTicker(interval, callback, iterations)
        return newTicker(interval, callback, iterations)
    end
end

--=========================================================================
-- C_AddOns  (all map to old globals)
--=========================================================================
do
    local C_AddOns = ns("C_AddOns")
    def(C_AddOns, "LoadAddOn", _G.LoadAddOn)
    def(C_AddOns, "IsAddOnLoaded", _G.IsAddOnLoaded)
    def(C_AddOns, "IsAddOnLoadOnDemand", _G.IsAddOnLoadOnDemand)
    def(C_AddOns, "GetAddOnMetadata", _G.GetAddOnMetadata)
    def(C_AddOns, "GetAddOnInfo", _G.GetAddOnInfo)
    def(C_AddOns, "GetNumAddOns", _G.GetNumAddOns)
    def(C_AddOns, "EnableAddOn", _G.EnableAddOn)
    def(C_AddOns, "DisableAddOn", _G.DisableAddOn)
end

--=========================================================================
-- C_Item  (item info; most map to old globals, a few need shims)
--=========================================================================
do
    local C_Item = ns("C_Item")
    def(C_Item, "GetItemInfo", _G.GetItemInfo)
    def(C_Item, "GetItemCount", _G.GetItemCount)
    def(C_Item, "GetItemSpell", _G.GetItemSpell)
    def(C_Item, "GetItemInfoInstant", function(item)
        -- itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID.
        -- Parse the itemID from the item string first so it is returned even for
        -- items not yet in the client cache (GetItemInfoInstant is cache-free).
        local itemID
        if type(item) == "number" then
            itemID = item
        elseif type(item) == "string" then
            itemID = tonumber(item:match("item:(%d+)")) or tonumber(item)
        end
        local _, _, _, _, _, itemType, itemSubType, _, equipLoc, icon = _G.GetItemInfo(item)
        return itemID, itemType, itemSubType, equipLoc, icon
    end)
    def(C_Item, "IsEquippedItem", function(item) return _G.IsEquippedItem(item) end)
    def(C_Item, "GetItemQualityByID", function(item)
        return select(3, _G.GetItemInfo(item))
    end)
    def(C_Item, "IsBound", function() return nil end) -- best-effort; no direct 3.3.5 API
    def(C_Item, "GetItemStats", _G.GetItemStats)
end

--=========================================================================
-- C_Spell / C_SpellBook
--   Leave the plain multi-return getters (GetSpellInfo/Texture/etc.) UNDEFINED
--   so guarded call sites fall back to the identical _G globals. Only define
--   the ones with no 3.3.5 equivalent.
--=========================================================================
do
    local C_Spell = ns("C_Spell")
    def(C_Spell, "IsSpellDataCached", function() return true end)
    def(C_Spell, "RequestLoadSpellData", function() end)
    def(C_Spell, "GetSpellName", function(spellID) return (_G.GetSpellInfo(spellID)) end)
    def(C_Spell, "IsPlayerSpell", function(spellID) return _G.IsSpellKnown(spellID) end)
    def(C_Spell, "IsSpellKnown", _G.IsSpellKnown)

    local C_SpellBook = ns("C_SpellBook")
    def(C_SpellBook, "IsSpellKnown", _G.IsSpellKnown)
end

--=========================================================================
-- C_Container  (modern namespace over old GetContainer* globals)
--=========================================================================
do
    local C_Container = ns("C_Container")
    def(C_Container, "GetContainerNumSlots", _G.GetContainerNumSlots)
    def(C_Container, "GetContainerNumFreeSlots", _G.GetContainerNumFreeSlots)
    def(C_Container, "GetContainerItemLink", _G.GetContainerItemLink)
    def(C_Container, "GetContainerItemID", function(bag, slot)
        if _G.GetContainerItemID then
            return _G.GetContainerItemID(bag, slot)
        end
        -- Some unmodified 3.3.5 clients expose only the item link. The first
        -- item-string field is the same numeric ID required by modern callers.
        local link = _G.GetContainerItemLink and
                         _G.GetContainerItemLink(bag, slot)
        return link and tonumber(link:match("item:(%-?%d+)")) or nil
    end)
    def(C_Container, "GetContainerItemCooldown", _G.GetContainerItemCooldown)
    def(C_Container, "PickupContainerItem", _G.PickupContainerItem)
    def(C_Container, "UseContainerItem", _G.UseContainerItem)
    def(C_Container, "GetItemCooldown", _G.GetItemCooldown)
    def(C_Container, "GetContainerItemInfo", function(bag, slot)
        local texture, itemCount, locked, quality, readable, lootable, itemLink =
            _G.GetContainerItemInfo(bag, slot)
        if texture == nil and itemLink == nil then return nil end
        return {
            iconFileID  = texture,
            stackCount  = itemCount,
            isLocked    = locked,
            quality     = quality,
            isReadable  = readable,
            hasLoot     = lootable,
            hyperlink   = itemLink,
            isFiltered  = false,
            hasNoValue  = false,
            itemID      = C_Container.GetContainerItemID(bag, slot),
            isBound     = nil,
        }
    end)
end

--=========================================================================
-- C_CurrencyInfo
--=========================================================================
do
    local C_CurrencyInfo = ns("C_CurrencyInfo")
    def(C_CurrencyInfo, "GetCoinTextureString", _G.GetCoinTextureString)
    def(C_CurrencyInfo, "GetCurrencyInfo", function() return nil end)
    def(C_CurrencyInfo, "GetBasicCurrencyInfo", function() return nil end)
end

--=========================================================================
-- C_ChatInfo  (addon messaging)
--=========================================================================
do
    local C_ChatInfo = ns("C_ChatInfo")
    def(C_ChatInfo, "SendChatMessage", _G.SendChatMessage)
    def(C_ChatInfo, "SendAddonMessage", function(prefix, message, channel, target)
        return _G.SendAddonMessage(prefix, message, channel, target)
    end)
    def(C_ChatInfo, "SendAddonMessageLogged", function(prefix, message, channel, target)
        return _G.SendAddonMessage(prefix, message, channel, target)
    end)
    -- RegisterAddonMessagePrefix added in 4.1; not needed on 3.3.5a.
    def(C_ChatInfo, "RegisterAddonMessagePrefix", function() return true end)
    def(C_ChatInfo, "IsAddonMessagePrefixRegistered", function() return true end)
end

--=========================================================================
-- C_EventUtils.IsEventValid  (probe the real event system)
--=========================================================================
do
    local C_EventUtils = ns("C_EventUtils")
    if not C_EventUtils.IsEventValid then
        local probe = CreateFrame("Frame")
        local cache = {}
        function C_EventUtils.IsEventValid(event)
            if cache[event] ~= nil then return cache[event] end
            local ok = pcall(probe.RegisterEvent, probe, event)
            if ok then pcall(probe.UnregisterEvent, probe, event) end
            cache[event] = ok and true or false
            return cache[event]
        end
    end
end

--=========================================================================
-- C_UnitAuras  (aura data by index). RXPGuides already guards these behind a
-- `if not (UnitAura and UnitBuff and UnitDebuff)` check, so on 3.3.5a the old
-- globals win. Provide adapters anyway for any direct call sites.
--=========================================================================
do
    local C_UnitAuras = ns("C_UnitAuras")
    local function pack(unit, index, filter, fn)
        local name, icon, count, dispelType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId = fn(unit, index, filter)
        if not name then return nil end
        return {
            name = name, icon = icon, applications = count, dispelName = dispelType,
            duration = duration, expirationTime = expirationTime, sourceUnit = source,
            isStealable = isStealable, spellId = spellId, auraInstanceID = index,
        }
    end
    def(C_UnitAuras, "GetAuraDataByIndex", function(unit, index, filter)
        return pack(unit, index, filter, _G.UnitAura)
    end)
    def(C_UnitAuras, "GetBuffDataByIndex", function(unit, index, filter)
        return pack(unit, index, filter or "HELPFUL", _G.UnitBuff)
    end)
    def(C_UnitAuras, "GetDebuffDataByIndex", function(unit, index, filter)
        return pack(unit, index, filter or "HARMFUL", _G.UnitDebuff)
    end)
    def(C_UnitAuras, "GetPlayerAuraBySpellID", function(spellID)
        for i = 1, 40 do
            local name, _, _, _, _, _, _, _, _, sid = _G.UnitAura("player", i)
            if not name then break end
            if sid == spellID then
                return C_UnitAuras.GetAuraDataByIndex("player", i)
            end
        end
        return nil
    end)
end

--=========================================================================
-- C_Reputation
--=========================================================================
do
    local C_Reputation = ns("C_Reputation")
    def(C_Reputation, "GetFactionDataByID", function(factionID)
        -- The addon also polyfills addon.GetFactionInfoByID; provide a matching
        -- structured return in case C_Reputation is used directly.
        local name, _, standingID, barMin, barMax, barValue = _G.GetFactionInfoByID(factionID)
        if not name then return nil end
        return {
            factionID = factionID, name = name, reaction = standingID,
            currentReactionThreshold = barMin, nextReactionThreshold = barMax,
            currentStanding = barValue,
        }
    end)
end

--=========================================================================
-- C_DateAndTime  (used by LevelingTracker + daily-reset helpers)
--=========================================================================
do
    local C_DateAndTime = ns("C_DateAndTime")
    def(C_DateAndTime, "GetCurrentCalendarTime", function()
        if type(_G.CalendarGetDate) == "function" then
            local ok, weekday, month, monthDay, year =
                pcall(_G.CalendarGetDate)
            if ok and year and month and monthDay then
                local hour, minute = 0, 0
                if type(_G.GetGameTime) == "function" then
                    hour, minute = _G.GetGameTime()
                end
                return {
                    year = year, month = month, monthDay = monthDay,
                    weekday = weekday, hour = hour, minute = minute,
                    second = 0,
                }
            end
        end
        local t = _G.date("*t")
        return {
            year = t.year, month = t.month, monthDay = t.day, weekday = t.wday,
            hour = t.hour, minute = t.min, second = t.sec,
        }
    end)
    def(C_DateAndTime, "GetSecondsUntilDailyReset", function()
        -- Best-effort: seconds until next local midnight. Refined if needed.
        local t = _G.date("*t")
        return (24 - t.hour) * 3600 - t.min * 60 - t.sec
    end)
    def(C_DateAndTime, "GetServerTimeLocal", function() return _G.time() end)
end

--=========================================================================
-- No-op / nil-returning stubs for modern-only namespaces that RXPGuides calls
-- behind feature checks. These let guarded call sites degrade gracefully.
--=========================================================================
do
    -- SuperTracking (no equivalent in 3.3.5a)
    local C_SuperTrack = ns("C_SuperTrack")
    def(C_SuperTrack, "SetSuperTrackedQuestID", function() end)
    def(C_SuperTrack, "GetSuperTrackedQuestID", function() return 0 end)

    -- Player interaction manager. Map the two interactions used by Wrath guides
    -- to the original confirmation functions instead of presenting a no-op API.
    local C_PlayerInteractionManager = ns("C_PlayerInteractionManager")
    C_PlayerInteractionManager.ConfirmationInteraction = function(interactionType)
        if interactionType == _G.Enum.PlayerInteractionType.Binder and
            type(_G.ConfirmBinder) == "function" then
            _G.ConfirmBinder()
            return true
        elseif interactionType == _G.Enum.PlayerInteractionType.SpiritHealer and
            type(_G.AcceptXPLoss) == "function" then
            _G.AcceptXPLoss()
            return true
        end
        return false
    end
    C_PlayerInteractionManager.ClearInteraction = function() end

    -- Nameplates (Features/Targeting.lua)
    local C_NamePlate = ns("C_NamePlate")
    def(C_NamePlate, "GetNamePlates", function() return {} end)
    def(C_NamePlate, "GetNamePlateForUnit", function() return nil end)

    -- Hardcore / seasons / warmode / chromie: none exist on 3.3.5a
    local C_GameRules = ns("C_GameRules")
    def(C_GameRules, "IsHardcoreActive", function() return false end)

    local C_Seasons = ns("C_Seasons")
    def(C_Seasons, "HasActiveSeason", function() return false end)
    def(C_Seasons, "GetActiveSeason", function() return 0 end)

    local C_PvP = ns("C_PvP")
    def(C_PvP, "IsWarModeActive", function() return false end)
    def(C_PvP, "IsWarModeDesired", function() return false end)
    def(C_PvP, "GetWarModeRewardBonus", function() return 0 end)

    local C_PlayerInfo = ns("C_PlayerInfo")
    def(C_PlayerInfo, "CanPlayerEnterChromieTime", function() return false end)

    -- Collections / journals (retail leveling features)
    local C_ToyBox = ns("C_ToyBox")
    def(C_ToyBox, "GetToyInfo", function() return nil end)
    def(C_ToyBox, "IsToyUsable", function() return false end)

    local C_MountJournal = ns("C_MountJournal")
    def(C_MountJournal, "GetCollectedDragonridingMounts", function() return {} end)
    def(C_MountJournal, "IsDragonridingUnlocked", function() return false end)
    def(C_MountJournal, "GetMountInfoByID", function() return nil end)

    local C_PetJournal = ns("C_PetJournal")
    def(C_PetJournal, "GetNumPets", function() return 0, 0 end)
    def(C_PetJournal, "GetPetInfoByIndex", function() return nil end)
    def(C_PetJournal, "SetSearchFilter", function() end)
    def(C_PetJournal, "SetFilterChecked", function() end)
    def(C_PetJournal, "SetAllPetTypesChecked", function() end)
    def(C_PetJournal, "SetAllPetSourcesChecked", function() end)

    -- Scenarios (Cata+); guides check these behind version gates
    local C_ScenarioInfo = ns("C_ScenarioInfo")
    def(C_ScenarioInfo, "GetScenarioInfo", function() return nil end)
    def(C_ScenarioInfo, "GetScenarioStepInfo", function() return nil end)
    def(C_ScenarioInfo, "GetCriteriaInfo", function() return nil end)
    def(C_ScenarioInfo, "GetCriteriaInfoByStep", function() return nil end)
    local C_Scenario = ns("C_Scenario")
    def(C_Scenario, "GetCriteriaInfo", function() return nil end)
    def(C_Scenario, "GetCriteriaInfoByStep", function() return nil end)

    -- Task/world quests, engraving (SoD), chromie, player choice, adventure map
    local C_TaskQuest = ns("C_TaskQuest")
    def(C_TaskQuest, "GetQuestsForPlayerByMapID", function() return {} end)
    def(C_TaskQuest, "GetQuestTimeLeftMinutes", function() return nil end)

    local C_Engraving = ns("C_Engraving")
    def(C_Engraving, "GetRuneForEquipmentSlot", function() return nil end)
    def(C_Engraving, "GetRuneCategories", function() return {} end)
    def(C_Engraving, "GetRunesForCategory", function() return {} end)
    def(C_Engraving, "IsEngravingEnabled", function() return false end)

    local C_ChromieTime = ns("C_ChromieTime")
    def(C_ChromieTime, "GetChromieTimeExpansionOptions", function() return {} end)
    def(C_ChromieTime, "SelectChromieTimeOption", function() end)

    local C_PlayerChoice = ns("C_PlayerChoice")
    def(C_PlayerChoice, "GetCurrentPlayerChoiceInfo", function() return nil end)
    def(C_PlayerChoice, "SendPlayerChoiceResponse", function() end)
    def(C_PlayerChoice, "OnUIClosed", function() end)

    local C_AdventureMap = ns("C_AdventureMap")
    def(C_AdventureMap, "GetQuestInfo", function() return nil end)
    def(C_AdventureMap, "StartQuest", function() end)

    local C_ScrappingMachineUI = ns("C_ScrappingMachineUI")
    def(C_ScrappingMachineUI, "RemoveAllScrapItems", function() end)
    def(C_ScrappingMachineUI, "DropPendingScrapItemFromCursor", function() end)

    local C_AreaPoiInfo = ns("C_AreaPoiInfo")
    def(C_AreaPoiInfo, "GetAreaPOIInfo", function() return nil end)

    -- NOTE: C_ZoneAbility is intentionally NOT stubbed. It only exists on
    -- retail/SoD; leaving it nil makes RXPGuides skip its zone-ability code path
    -- (which also calls the modern C_Spell.GetSpellInfo) instead of running it.

    local C_SpecializationInfo = ns("C_SpecializationInfo")
    def(C_SpecializationInfo, "GetActiveSpecGroup", function() return _G.GetActiveTalentGroup and _G.GetActiveTalentGroup() or 1 end)
    def(C_SpecializationInfo, "GetSpecialization", function() return nil end)

    local C_ActionBar = ns("C_ActionBar")
    C_ActionBar.IsOnBarOrSpecialBar = function(spellID)
        spellID = tonumber(spellID)
        if not spellID or not _G.GetActionInfo then return false end

        local wantedName = _G.GetSpellInfo and (_G.GetSpellInfo(spellID))
        for slot = 1, 120 do
            if not _G.HasAction or _G.HasAction(slot) then
                local actionType, id = _G.GetActionInfo(slot)
                if actionType == "spell" and tonumber(id) == spellID then
                    return true
                elseif actionType == "macro" and id and _G.GetMacroSpell then
                    local macroName, _, macroSpellID = _G.GetMacroSpell(id)
                    if tonumber(macroName) == spellID or
                        tonumber(macroSpellID) == spellID or
                        (wantedName and macroName == wantedName) then
                        return true
                    end
                end
            end
        end
        return false
    end

    local C_TradeSkillUI = ns("C_TradeSkillUI")
    def(C_TradeSkillUI, "GetTradeSkillDisplayName", function() return nil end)

    local C_TaxiMap = ns("C_TaxiMap")
    local taxiCache = {}

    local function normalizeTaxiName(name)
        if type(name) ~= "string" then return nil end
        name = name:lower():gsub("[%s%p]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        name = name:gsub("^the%s+", "")
        return name ~= "" and name or nil
    end

    local function addTaxiLookup(lookup, key, id)
        key = normalizeTaxiName(key)
        if not key then return end
        if lookup[key] == nil then
            lookup[key] = id
        elseif lookup[key] ~= id then
            lookup[key] = false -- ambiguous names are never auto-selected
        end
    end

    local function addTaxiRecord(records, name, id)
        local normalized = normalizeTaxiName(name)
        if normalized then
            records[#records + 1] = {id = id, name = normalized}
        end
    end

    local function taxiBaseName(name)
        if type(name) ~= "string" then return nil end
        -- zhCN/zhTW clients and some private-server locale packs use a
        -- full-width or ideographic comma in compound flight-node names.
        local delimiter = name:find(",", 1, true)
        for _, punctuation in ipairs({"，", "、"}) do
            local position = name:find(punctuation, 1, true)
            if position and (not delimiter or position < delimiter) then
                delimiter = position
            end
        end
        return delimiter and name:sub(1, delimiter - 1) or name
    end

    local function addTaxiName(exact, short, records, name, id)
        addTaxiLookup(exact, name, id)
        if type(name) == "string" then
            addTaxiLookup(short, taxiBaseName(name), id)
            addTaxiRecord(records, name, id)
        end
    end

    local function buildTaxiLookup()
        local exact, short, records = {}, {}, {}
        local faction = addon and addon.player and addon.player.faction
        local db = faction and addon.FPDB and addon.FPDB[faction]
        if db then
            for id, data in pairs(db) do
                if type(id) == "number" and type(data) == "table" and data.name then
                    addTaxiName(exact, short, records, data.name, id)
                    if addon and
                        type(addon.LocalizeLegacyLocationName) == "function" then
                        local localized = addon.LocalizeLegacyLocationName(data.name)
                        if localized ~= data.name then
                            addTaxiName(exact, short, records, localized, id)
                        end
                    end
                end
            end
        end
        if type(_G.RXPCData) == "table" and type(_G.RXPCData.flightPaths) == "table" then
            for id, name in pairs(_G.RXPCData.flightPaths) do
                if type(id) == "number" then
                    addTaxiName(exact, short, records, name, id)
                end
            end
        end
        return exact, short, records, faction
    end

    local function resolveTaxiID(name, nodeType, exact, short, records, faction)
        local normalized = normalizeTaxiName(name)
        local id = normalized and exact[normalized]
        if id == false then return nil, true end
        if not id and type(name) == "string" then
            local base = normalizeTaxiName(taxiBaseName(name))
            id = base and short[base]
            if id == false then return nil, true end
        end
        if not id and normalized then
            local partialID
            for _, record in ipairs(records) do
                if record.name:find(normalized, 1, true) then
                    if partialID and partialID ~= record.id then
                        return nil, true
                    end
                    partialID = record.id
                end
            end
            id = partialID
        end
        if not id and nodeType == "CURRENT" and addon and addon.FPbyZone and faction then
            local mapID = _G.C_Map and _G.C_Map.GetBestMapForUnit and
                _G.C_Map.GetBestMapForUnit("player")
            id = mapID and addon.FPbyZone[faction] and addon.FPbyZone[faction][mapID]
        end
        return type(id) == "number" and id or nil, false
    end

    -- Shared by guide .fp/.fly parsing and the live legacy taxi cache.  The
    -- lookup is always restricted to the player's faction and refuses every
    -- ambiguous full, base, or partial name.
    addon.ResolveLegacyFlightPath = function(name, nodeType)
        if addon.compatibilityPacks and
            addon.compatibilityPacks.ResolveFlightAlias then
            name = addon.compatibilityPacks:ResolveFlightAlias(name)
        end
        local exact, short, records, faction = buildTaxiLookup()
        return resolveTaxiID(name, nodeType, exact, short, records, faction)
    end

    local function rebuildTaxiCache()
        for key in pairs(taxiCache) do taxiCache[key] = nil end
        if not (_G.NumTaxiNodes and _G.TaxiNodeName and _G.TaxiNodeGetType) then
            return taxiCache
        end
        local exact, short, records, faction = buildTaxiLookup()
        for slot = 1, _G.NumTaxiNodes() do
            local name = _G.TaxiNodeName(slot)
            local legacyType = _G.TaxiNodeGetType(slot)
            local state = _G.Enum.FlightPathState.Unreachable
            if legacyType == "CURRENT" then
                state = _G.Enum.FlightPathState.Current
            elseif legacyType == "REACHABLE" then
                state = _G.Enum.FlightPathState.Reachable
            end
            local id = resolveTaxiID(name, legacyType, exact, short, records, faction)
            local x, y
            if _G.TaxiNodePosition then x, y = _G.TaxiNodePosition(slot) end
            taxiCache[#taxiCache + 1] = {
                nodeID = id, slotIndex = slot, name = name, state = state,
                legacyType = legacyType,
                position = x and y and _G.CreateVector2D(x, y) or nil,
            }
        end
        return taxiCache
    end

    C_TaxiMap.GetAllTaxiNodes = rebuildTaxiCache
    C_TaxiMap.GetTaxiNodesForMap = rebuildTaxiCache
    C_TaxiMap.RefreshLegacyTaxiNodes = rebuildTaxiCache

    local C_DeathInfo = ns("C_DeathInfo")
    def(C_DeathInfo, "GetCorpseMapPosition", function() return nil end)

    local C_Minimap = ns("C_Minimap")
    def(C_Minimap, "GetPOITextureCoords", function() return 0, 0, 0, 0, 0, 0, 0, 0 end)
    def(C_Minimap, "GetViewRadius", function() return 0 end)

    local C_Calendar = ns("C_Calendar")
    local calendarOpened
    local holidayIDs = {
        winterveil = 141,
        noblegarden = 181,
        childrensweek = 201,
        harvestfestival = 283,
        hallowsend = 301,
        lunarfestival = 321,
        midsummerfirefestival = 324,
        brewfest = 327,
        loveisintheair = 335,
        dayofthedead = 341,
        pilgrimsbounty = 372,
        darkmoonfaireelwynn = 374,
        darkmoonfairemulgore = 375,
        darkmoonfaireterokkar = 376,
    }

    local function openLegacyCalendar()
        if type(_G.IsAddOnLoaded) == "function" and
            not _G.IsAddOnLoaded("Blizzard_Calendar") and
            type(_G.LoadAddOn) == "function" then
            pcall(_G.LoadAddOn, "Blizzard_Calendar")
        end
        if type(_G.OpenCalendar) == "function" then
            local ok = pcall(_G.OpenCalendar)
            calendarOpened = calendarOpened or ok
            return ok
        end
        return false
    end

    local function normalizedCalendarToken(...)
        local value = ""
        for index = 1, select("#", ...) do
            value = value .. tostring(select(index, ...) or "")
        end
        return value:lower():gsub("[^%w]", "")
    end

    local function resolveHolidayID(title, texture, holidayName,
                                    holidayTexture)
        local token = normalizedCalendarToken(title, texture, holidayName,
                                              holidayTexture)
        for name, id in pairs(holidayIDs) do
            if token:find(name, 1, true) then return id end
        end
        if token:find("darkmoonfaire", 1, true) then return 374 end
    end

    def(C_Calendar, "OpenCalendar", openLegacyCalendar)
    def(C_Calendar, "GetNumDayEvents", function(monthOffset, monthDay)
        if not calendarOpened then openLegacyCalendar() end
        if type(_G.CalendarGetNumDayEvents) ~= "function" then return 0 end
        return tonumber(_G.CalendarGetNumDayEvents(monthOffset or 0,
                                                   monthDay)) or 0
    end)
    def(C_Calendar, "GetDayEvent", function(monthOffset, monthDay, index)
        if not calendarOpened then openLegacyCalendar() end
        if type(_G.CalendarGetDayEvent) ~= "function" then return nil end

        local title, hour, minute, calendarType, sequenceType, eventType,
              texture, modStatus, inviteStatus, invitedBy, difficulty,
              inviteType, sequenceIndex, numSequenceDays =
            _G.CalendarGetDayEvent(monthOffset or 0, monthDay, index)
        if not title then return nil end

        local month, year
        if type(_G.CalendarGetMonth) == "function" then
            month, year = _G.CalendarGetMonth(monthOffset or 0)
        end
        return {
            -- Holiday texture names are client-stable even when the visible
            -- title is localized, so they are the safest legacy ID key.
            eventID = resolveHolidayID(title, texture),
            title = title,
            startTime = {
                year = year, month = month, monthDay = monthDay,
                hour = hour or 0, minute = minute or 0,
            },
            calendarType = calendarType,
            sequenceType = sequenceType,
            eventType = eventType,
            iconTexture = texture,
            modStatus = modStatus,
            inviteStatus = inviteStatus,
            invitedBy = invitedBy,
            difficulty = difficulty,
            inviteType = inviteType,
            sequenceIndex = sequenceIndex,
            numSequenceDays = numSequenceDays,
        }
    end)
    def(C_Calendar, "GetHolidayInfo", function(monthOffset, monthDay,
                                                index)
        if type(_G.CalendarGetHolidayInfo) ~= "function" then return nil end
        if type(_G.CalendarOpenEvent) == "function" then
            pcall(_G.CalendarOpenEvent, monthOffset or 0, monthDay, index)
        end
        local eventIndex = type(_G.CalendarGetEventIndex) == "function" and
                               _G.CalendarGetEventIndex() or index
        local ok, name, description, texture =
            pcall(_G.CalendarGetHolidayInfo, eventIndex)
        if not ok or not name then return nil end
        return {name = name, description = description, texture = texture}
    end)

    local C_Texture = ns("C_Texture")
    def(C_Texture, "GetAtlasInfo", function() return nil end)

    local C_PartyInfo = ns("C_PartyInfo")
    def(C_PartyInfo, "LeaveParty", function() return _G.LeaveParty and _G.LeaveParty() end)

    -- Create an empty C_Map now so any file-scope indexing is safe; the
    -- Astrolabe-backed shim (libs\HBD335\*) fills in the real methods.
    ns("C_Map")
end

--=========================================================================
-- C_QuestLog  (modern questID-centric API over the 3.3.5a index-based log)
--=========================================================================
do
    local C_QuestLog = ns("C_QuestLog")

    -- Caches, refreshed by events below.
    local logIndexByQuestID = {}   -- questID -> quest log index
    local onQuest           = {}   -- questID -> true
    local completeByQuestID = {}   -- questID -> true (ready to turn in)
    local completedCache    = {}   -- questID -> true (finished, account/char)

    local function questIDFromIndex(index)
        -- AzerothCore's 3.3.5a client returns the questID as the 9th value of
        -- GetQuestLogTitle. Fall back to parsing the quest hyperlink if absent.
        local id = select(9, _G.GetQuestLogTitle(index))
        if type(id) == "number" and id > 0 then return id end
        local link = _G.GetQuestLink and _G.GetQuestLink(index)
        if link then
            local qid = link:match("quest:(%d+)")
            if qid then return tonumber(qid) end
        end
        return nil
    end

    local function rebuildLog()
        wipe(logIndexByQuestID); wipe(onQuest); wipe(completeByQuestID)
        local numEntries = _G.GetNumQuestLogEntries()
        for i = 1, numEntries do
            local _, _, _, _, isHeader, _, isComplete = _G.GetQuestLogTitle(i)
            if not legacyTrue(isHeader) then
                local qid = questIDFromIndex(i)
                if qid then
                    logIndexByQuestID[qid] = i
                    onQuest[qid] = true
                    if legacyTrue(isComplete) then
                        completeByQuestID[qid] = true
                    end
                end
            end
        end
    end

    -- GetQuestLogIndexByID returns 0 for a missing quest on many 3.3.5
    -- clients. Since 0 is truthy in Lua, callers must never use that return
    -- value as a boolean. Also verify that a positive index still identifies
    -- the requested quest before admitting it into the cache.
    local function validatedLogIndex(questID)
        questID = tonumber(questID)
        if not questID or questID <= 0 then return nil end

        local index = tonumber(logIndexByQuestID[questID])
        if index and index > 0 and questIDFromIndex(index) == questID then
            return index
        end
        logIndexByQuestID[questID] = nil
        onQuest[questID] = nil

        if _G.GetQuestLogIndexByID then
            index = tonumber(_G.GetQuestLogIndexByID(questID))
            if index and index > 0 and questIDFromIndex(index) == questID then
                logIndexByQuestID[questID] = index
                onQuest[questID] = true
                return index
            end
            -- A numeric zero is an authoritative "not in the quest log".
            if index ~= nil then return nil end
        end

        rebuildLog()
        index = tonumber(logIndexByQuestID[questID])
        return index and index > 0 and index or nil
    end

    local function rebuildCompleted()
        if _G.GetQuestsCompleted then
            wipe(completedCache)
            _G.GetQuestsCompleted(completedCache)
        end
    end

    local questFrame = CreateFrame("Frame", "RXPCompat335QuestFrame")
    questFrame:RegisterEvent("QUEST_LOG_UPDATE")
    questFrame:RegisterEvent("QUEST_QUERY_COMPLETE")
    questFrame:RegisterEvent("QUEST_ACCEPTED")
    questFrame:RegisterEvent("QUEST_TURNED_IN")
    questFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    questFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
        if event == "QUEST_LOG_UPDATE" then
            rebuildLog()
        elseif event == "QUEST_QUERY_COMPLETE" then
            rebuildCompleted()
        elseif event == "QUEST_ACCEPTED" then
            local index = tonumber(arg1)
            local qid = tonumber(arg2) or
                            (index and questIDFromIndex(index))
            if qid then
                logIndexByQuestID[qid] = index
                onQuest[qid] = true
            end
        elseif event == "QUEST_TURNED_IN" then
            local qid = tonumber(arg1)
            if qid then
                logIndexByQuestID[qid] = nil
                onQuest[qid] = nil
                completeByQuestID[qid] = nil
                completedCache[qid] = true
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            rebuildLog()
            if _G.QueryQuestsCompleted then _G.QueryQuestsCompleted() end
            rebuildCompleted()
        end
    end)

    def(C_QuestLog, "GetNumQuestLogEntries", _G.GetNumQuestLogEntries)

    def(C_QuestLog, "GetInfo", function(questLogIndex)
        local title, level, questTag, suggestedGroup, isHeader, isCollapsed,
              isComplete, isDaily = _G.GetQuestLogTitle(questLogIndex)
        if title == nil then return nil end
        local header = legacyTrue(isHeader)
        local questID = not header and questIDFromIndex(questLogIndex) or nil
        return {
            title = title,
            questLogIndex = questLogIndex,
            questID = questID,
            campaignID = nil,
            level = level,
            difficultyLevel = level,
            suggestedGroup = suggestedGroup,
            frequency = legacyTrue(isDaily) and 1 or 0,
            isHeader = header,
            isCollapsed = legacyTrue(isCollapsed),
            isComplete = legacyTrue(isComplete) or nil,
            isOnMap = nil,
            hasLocalPOI = nil,
            isTask = false,
            isBounty = false,
            isStory = false,
            isHidden = false,
            isScaling = false,
        }
    end)

    def(C_QuestLog, "GetLogIndexForQuestID", function(questID)
        return validatedLogIndex(questID)
    end)
    def(C_QuestLog, "IsOnQuest", function(questID)
        questID = tonumber(questID)
        if not questID then return false end
        if onQuest[questID] and validatedLogIndex(questID) then return true end
        return validatedLogIndex(questID) ~= nil
    end)
    def(C_QuestLog, "IsComplete", function(questID)
        questID = tonumber(questID)
        if not questID then return false end
        if completeByQuestID[questID] == true then return true end
        local index = validatedLogIndex(questID)
        if not index then return false end
        local complete = legacyTrue(select(7, _G.GetQuestLogTitle(index)))
        if complete then completeByQuestID[questID] = true end
        return complete
    end)
    def(C_QuestLog, "IsQuestFlaggedCompleted", function(questID)
        questID = tonumber(questID)
        return questID and legacyTrue(completedCache[questID]) or false
    end)
    def(C_QuestLog, "IsQuestFlaggedCompletedOnAccount", function(questID)
        questID = tonumber(questID)
        return questID and legacyTrue(completedCache[questID]) or false
    end)
    def(C_QuestLog, "GetAllCompletedQuestIDs", function()
        rebuildCompleted()
        local t = {}
        for qid in pairs(completedCache) do t[#t + 1] = qid end
        return t
    end)
    def(C_QuestLog, "RequestLoadQuestByID", function() end) -- data is local on 3.3.5a
    C_QuestLog.IsPushableQuest = function(questID)
        local index = validatedLogIndex(questID)
        if not (index and _G.SelectQuestLogEntry and _G.GetQuestLogPushable) then
            return false
        end

        local previous = _G.GetQuestLogSelection and _G.GetQuestLogSelection()
        local ok, pushable
        _G.SelectQuestLogEntry(index)
        ok, pushable = pcall(_G.GetQuestLogPushable)
        if previous ~= nil and previous ~= index then
            pcall(_G.SelectQuestLogEntry, previous)
        end
        return ok and (pushable == true or pushable == 1) or false
    end

    def(C_QuestLog, "GetTitleForQuestID", function(questID)
        local idx = validatedLogIndex(questID)
        if idx then return (_G.GetQuestLogTitle(idx)) end
        return nil
    end)
    def(C_QuestLog, "GetQuestInfo", function(questID)
        return C_QuestLog.GetTitleForQuestID(questID)
    end)

    def(C_QuestLog, "GetQuestObjectives", function(questID)
        local idx = validatedLogIndex(questID)
        if not idx then return {} end
        local objectives = {}
        local num = _G.GetNumQuestLeaderBoards(idx) or 0
        for i = 1, num do
            local text, objType, finished = _G.GetQuestLogLeaderBoard(i, idx)
            -- On 3.3.5a the fulfilled/required counts are embedded in the text
            -- ("Boar slain: 2/8"); parse them so progress (kills) can be tracked.
            local numFulfilled, numRequired
            if text then
                local have, need = text:match("(%d+)%s*/%s*(%d+)")
                numFulfilled, numRequired = tonumber(have), tonumber(need)
            end
            local isFinished = legacyTrue(finished)
            objectives[i] = {
                text = text, type = objType, finished = isFinished,
                numFulfilled = numFulfilled or (isFinished and 1 or 0),
                numRequired = numRequired or 1,
            }
        end
        return objectives
    end)

    def(C_QuestLog, "SetSelectedQuest", function(questID)
        local idx = validatedLogIndex(questID)
        if idx then _G.SelectQuestLogEntry(idx) end
    end)
    def(C_QuestLog, "SetAbandonQuest", function() return _G.SetAbandonQuest() end)
    def(C_QuestLog, "AbandonQuest", function() return _G.AbandonQuest() end)
    def(C_QuestLog, "GetQuestIDForLogIndex", function(index) return questIDFromIndex(index) end)
    def(C_QuestLog, "ReadyForTurnIn", function(questID)
        return C_QuestLog.IsComplete(questID)
    end)
end

--=========================================================================
-- C_GossipInfo  (modern gossip API over the 3.3.5a flat gossip functions).
--   3.3.5a has no gossipOptionID, so options are addressed purely by index;
--   GetOptions() reports the same integer as both gossipOptionID and orderIndex.
--=========================================================================
do
    local C_GossipInfo = ns("C_GossipInfo")

    def(C_GossipInfo, "GetNumOptions", function()
        return _G.GetNumGossipOptions and _G.GetNumGossipOptions() or 0
    end)
    def(C_GossipInfo, "GetNumActiveQuests", function()
        return _G.GetNumGossipActiveQuests and _G.GetNumGossipActiveQuests() or 0
    end)
    def(C_GossipInfo, "GetNumAvailableQuests", function()
        return _G.GetNumGossipAvailableQuests and _G.GetNumGossipAvailableQuests() or 0
    end)

    def(C_GossipInfo, "GetOptions", function()
        local options = {}
        if not _G.GetGossipOptions then return options end
        local data = { _G.GetGossipOptions() }
        local n = 0
        for i = 1, #data, 2 do
            n = n + 1
            options[n] = {
                name = data[i],
                gossipText = data[i],
                type = data[i + 1],
                gossipOptionID = n,
                orderIndex = n,
            }
        end
        return options
    end)

    -- Both selectors address options by their 1-based index on 3.3.5a.
    def(C_GossipInfo, "SelectOptionByIndex", function(index)
        if _G.SelectGossipOption then _G.SelectGossipOption(index) end
    end)
    def(C_GossipInfo, "SelectOption", function(optionID)
        if _G.SelectGossipOption then _G.SelectGossipOption(optionID) end
    end)

    -- 3.3.5a's GetGossip*Quests() returns a flat, variable-stride list and
    -- exposes NO quest IDs. RXPGuides' lookup tables are keyed by both numeric
    -- ID and title. Active quests are matched to the quest log to recover the
    -- numeric ID when possible; available quests and older private clients use
    -- the title fallback. Select*Quest still receives the explicit legacy
    -- gossip index, the only selector accepted by the 3.3.5 client.
    local floor = math.floor

    -- Split a flat gossip return into per-quest groups without assuming a fixed
    -- stride: the true stride is (#data / numQuests), computed at call time.
    local function packReturns(...)
        return {n = select("#", ...), ...}
    end

    local function gossipGroups(getFn, numFn)
        -- `#data` is undefined when a private-server client leaves a nil field
        -- inside or at the end of a gossip tuple. Preserve the exact return
        -- count so one such field cannot shift every quest after the first.
        local data = packReturns(getFn())
        local num = numFn and numFn() or 0
        local stride = 1
        if num > 0 then stride = floor(data.n / num + 0.5) end
        if stride < 1 then stride = 1 end
        return data, num, stride
    end

    -- Authoritative completion check: match the gossip title to the quest log
    -- (GetQuestLogTitle's isComplete is reliable; the gossip flag position is
    -- not, given the variable stride).
    local function questLogMatch(title)
        if not title then return false end
        local getTitle = _G.RXPCompatGetQuestLogTitle or _G.GetQuestLogTitle
        local n = _G.GetNumQuestLogEntries and _G.GetNumQuestLogEntries() or 0
        for i = 1, n do
            local t, _, _, isHeader, _, isComplete, _, questID = getTitle(i)
            if not legacyTrue(isHeader) and t == title then
                return legacyTrue(isComplete), tonumber(questID)
            end
        end
        return false
    end

    -- Find the 1-based gossip index whose title matches (for Select*Quest).
    local function gossipIndexForTitle(getFn, numFn, title)
        local data, num, stride = gossipGroups(getFn, numFn)
        for g = 0, num - 1 do
            if data[g * stride + 1] == title then return g + 1 end
        end
        return nil
    end

    def(C_GossipInfo, "GetActiveQuests", function()
        local quests = {}
        if not _G.GetGossipActiveQuests then return quests end
        local data, num, stride = gossipGroups(_G.GetGossipActiveQuests,
                                               _G.GetNumGossipActiveQuests)
        for g = 0, num - 1 do
            local i = g * stride + 1
            local title = data[i]
            local isComplete, questID = questLogMatch(title)
            quests[g + 1] = {
                title = title,
                questLevel = data[i + 1],
                isTrivial = data[i + 2],
                frequency = 1,
                isComplete = isComplete,
                -- Active quests can be matched back to the quest log, whose
                -- backported return includes the numeric ID. This avoids title
                -- collisions and locale-cache races at multi-quest NPCs. Fall
                -- back to the title for clients which omit that field.
                questID = questID or title,
                index = g + 1,
            }
        end
        return quests
    end)

    def(C_GossipInfo, "GetAvailableQuests", function()
        local quests = {}
        if not _G.GetGossipAvailableQuests then return quests end
        local data, num, stride = gossipGroups(_G.GetGossipAvailableQuests,
                                               _G.GetNumGossipAvailableQuests)
        for g = 0, num - 1 do
            local i = g * stride + 1
            local title = data[i]
            quests[g + 1] = {
                title = title,
                questLevel = data[i + 1],
                isTrivial = data[i + 2],
                frequency = 1,
                repeatable = false,
                questID = title, -- title stands in for the (absent) quest ID
                index = g + 1,
            }
        end
        return quests
    end)

    def(C_GossipInfo, "SelectActiveQuest", function(indexOrTitle)
        if not _G.SelectGossipActiveQuest then return end
        if type(indexOrTitle) == "number" then
            return _G.SelectGossipActiveQuest(indexOrTitle)
        end
        local idx = gossipIndexForTitle(_G.GetGossipActiveQuests,
                                        _G.GetNumGossipActiveQuests, indexOrTitle)
        return _G.SelectGossipActiveQuest(idx or indexOrTitle)
    end)
    def(C_GossipInfo, "SelectAvailableQuest", function(indexOrTitle)
        if not _G.SelectGossipAvailableQuest then return end
        if type(indexOrTitle) == "number" then
            return _G.SelectGossipAvailableQuest(indexOrTitle)
        end
        local idx = gossipIndexForTitle(_G.GetGossipAvailableQuests,
                                        _G.GetNumGossipAvailableQuests, indexOrTitle)
        return _G.SelectGossipAvailableQuest(idx or indexOrTitle)
    end)
    def(C_GossipInfo, "CloseGossip", function()
        if _G.CloseGossip then _G.CloseGossip() end
    end)
end

--=========================================================================
-- LibDD (LibUIDropDownMenu-4.0) minimal shim over the built-in EasyMenu.
-- RXPGuides only calls LibDD:EasyMenu and creates its own menu frames.
--=========================================================================
if _G.LibStub then
    local existing = _G.LibStub:GetLibrary("LibUIDropDownMenu-4.0", true)
    if not existing then
        local lib = _G.LibStub:NewLibrary("LibUIDropDownMenu-4.0", 999)
        if lib then
            function lib:EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
                if _G.EasyMenu then
                    return _G.EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
                end
            end
            function lib:Create_UIDropDownMenu(name, parent)
                return CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
            end
            function lib:UIDropDownMenu_AddButton(...) return _G.UIDropDownMenu_AddButton(...) end
            function lib:UIDropDownMenu_CreateInfo(...) return _G.UIDropDownMenu_CreateInfo(...) end
            function lib:CloseDropDownMenus(...) return _G.CloseDropDownMenus(...) end
        end
    end
end
