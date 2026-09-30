-- Exercise the actual legacy line factory and map renderer with mock regions.
-- Compare batched and ordinary setters: final pixels/styles must be identical.
return function(root)
    local function read(path)
        local file = assert(io.open(root .. "/" .. path, "rb"))
        local source = file:read("*a"):gsub("\r\n", "\n")
        file:close()
        return source
    end
    local bootstrap = read("Compat/Bootstrap.lua")
    local first = assert(bootstrap:find("        CreateLine = function", 1, true))
    local last = assert(bootstrap:find("            return line\n        end,", first, true))
    local factorySource = bootstrap:sub(first, last + #"            return line\n        end" - 1)
    local counters = {}
    local addon = {colors = {mapPins = {0.7, 0.3, 1, 0.8}}, PerfCount = function(name, count)
        counters[name] = (counters[name] or 0) + (count or 1)
    end}
    local env = setmetatable({addon = addon, abs = math.abs, max = math.max, min = math.min,
        PinOnEnter = function() end, PinOnLeave = function() end}, {__index = _G})
    env._G = env
    local factoryChunk = assert(loadstring("return {" .. factorySource .. "}"))
    local factory = setfenv(factoryChunk, env)().CreateLine
    local canvas = {width = 800, height = 600}
    function canvas:GetWidth() return self.width end
    function canvas:GetHeight() return self.height end
    function canvas:GetFrameStrata() return "HIGH" end
    env.WorldMapFrame = {GetCanvas = function() return canvas end}

    local function frame()
        local f = {scripts = {}}
        function f:CreateTexture()
            local tile = {}
            function tile:SetTexture(value) self.texture = value end
            function tile:SetVertexColor(...) self.color = {...} end
            function tile:SetAlpha(value) self.alpha = value end
            function tile:SetDrawLayer(...) self.layer = {...} end
            function tile:ClearAllPoints() self.point = nil end
            function tile:SetWidth(value) self.width = value end
            function tile:SetHeight(value) self.height = value end
            function tile:SetPoint(anchor, parent, relativePoint, x, y)
                self.point = {anchor, relativePoint, x, y}
            end
            function tile:Show() self.shown = true end
            function tile:Hide() self.shown = false end
            return tile
        end
        function f:CreateLine() return factory(self) end
        function f:SetWidth(value) self.width = value end
        function f:SetHeight(value) self.height = value end
        function f:SetAlpha(value) self.alpha = value end
        function f:SetParent(value) self.parent = value end
        function f:SetFrameStrata(value) self.strata = value end
        function f:SetFrameLevel(value) self.level = value end
        function f:ClearAllPoints() self.point = nil end
        function f:SetPoint(anchor, parent, relativePoint, x, y)
            self.point = {anchor, relativePoint, x, y}
        end
        function f:EnableMouse(value) self.mouse = value end
        function f:SetScript(name, callback) self.scripts[name] = callback end
        function f:Hide() self.shown = false end
        function f:Show() self.shown = true end
        return f
    end
    env.CreateFrame = frame
    local map = read("UI/Map.lua")
    first = assert(map:find("MapLinePool.creationFunc = function", 1, true))
    last = assert(map:find("\nworldMapFramePool =", first, true))
    local renderer = assert(loadstring("local MapLinePool = {}\n" ..
        map:sub(first, last - 1) .. "\nreturn MapLinePool"))
    local pool = setfenv(renderer, env)()
    local batched, ordinary = pool.creationFunc(), pool.creationFunc()
    -- A native/foreign line object with no private batching API remains valid.
    for _, line in ipairs({ordinary.line, ordinary.border}) do
        line.__RXPBeginUpdate, line.__RXPEndUpdate = nil, nil
    end
    local function snapshot(f)
        local values = {tostring(f.width), tostring(f.height), tostring(f.alpha),
            tostring(f.shown), tostring(f.strata), tostring(f.level)}
        for _, value in ipairs(f.point or {}) do values[#values + 1] = tostring(value) end
        for _, line in ipairs({f.line, f.border}) do
            for index, tile in ipairs(line.__tiles) do
                if tile.shown then
                    values[#values + 1] = tostring(index)
                    values[#values + 1] = tile.texture
                    values[#values + 1] = tostring(tile.width)
                    values[#values + 1] = tostring(tile.height)
                    values[#values + 1] = tostring(tile.alpha)
                    for _, field in ipairs({tile.point, tile.color, tile.layer}) do
                        for _, value in ipairs(field) do values[#values + 1] = tostring(value) end
                    end
                end
            end
        end
        return table.concat(values, "/")
    end
    local coords = {sX = 10, sY = 20, fX = 20, fY = 30, linethickness = 2, lineAlpha = 1}
    local function compare()
        batched:render(coords)
        ordinary:render(coords)
        assert(snapshot(batched) == snapshot(ordinary), "batched line changed final geometry/style")
    end
    compare()
    local before = counters["line tile redraws"]
    for _ = 1, 100 do batched:render(coords) end
    assert(counters["line tile redraws"] == before, "unchanged geometry was redrawn")
    coords.sX, coords.sY, coords.fX, coords.fY = 2, 50, 85, 22
    coords.linethickness = 3
    addon.colors.mapPins = {0.2, 0.8, 0.4, 1}
    before = counters["line tile redraws"]
    batched:render(coords)
    assert(counters["line tile redraws"] - before == 2, "foreground/border redrew more than once")
    before = counters["line tile redraws"]
    ordinary:render(coords)
    local unbatchedRedraws = counters["line tile redraws"] - before
    assert(unbatchedRedraws > 2 and snapshot(batched) == snapshot(ordinary))

    -- Reuse of a pooled frame preserves tiles, but all frame/tooltip state
    -- still follows the current guide element and canvas.
    pool.resetterFunc(nil, batched)
    pool.resetterFunc(nil, ordinary)
    compare()
    canvas.width, canvas.height = 0, 0
    assert(batched:render(coords) == false and batched.pendingLineRender)
    assert(ordinary:render(coords) == false and ordinary.pendingLineRender)
    canvas.width, canvas.height = 1000, 700
    compare()
    for _, points in ipairs({{5, 5, 95, 5}, {5, 5, 5, 95}, {95, 95, 5, 5},
        {50, 50, 50, 50}, {0, 0, 100000, 100000}}) do
        coords.sX, coords.sY, coords.fX, coords.fY = unpack(points)
        coords.linethickness = 0.1
        compare()
        assert(#batched.line.__tiles <= 512 and #batched.border.__tiles <= 512)
    end
    coords.lineAlpha = 0
    compare()
    coords.lineAlpha, coords.sX, coords.fX = 1, 10, 30
    compare()
    batched.line:Hide(); batched.line:Show()
    ordinary.line:Hide(); ordinary.line:Show()
    assert(snapshot(batched) == snapshot(ordinary))
    print("Line rendering passed: changed foreground/border " .. unbatchedRedraws ..
        " redraws -> 2; 100 unchanged renders -> 0; geometry/style/512-tile limit preserved.")
end
