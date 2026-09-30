-- Execute the real refresh coordinator without constructing client map frames.
return function(root)
    local file = assert(io.open(root .. "/UI/Map.lua", "rb"))
    local source = file:read("*a"):gsub("\r\n", "\n")
    file:close()
    local first = assert(source:find("local lastMap\n", 1, true))
    local last = assert(source:find("\nlocal closestPoint", first, true))
    local chunk = assert(loadstring("local addon = ...\n" .. source:sub(first, last - 1)))
    local calls, labels, counts = {}, {}, {}
    local addon = {currentGuide = {}}
    local env = setmetatable({}, {__index = _G})
    env._G = env
    local function append(name) calls[#calls + 1] = name end
    env.resetMap = function() addon.updateMap = false; append("reset") end
    env.addWorldMapLines = function() append("lines") end
    env.addWorldMapPins = function() append("world") end
    env.addMiniMapPins = function() append("mini") end
    env.updateArrowData = function() append("arrow") end
    addon.DisplayLines = function(force) assert(force == true); append("visible") end
    addon.PerfInvoke = function(label, callback, ...)
        labels[#labels + 1] = label
        return callback(...)
    end
    addon.PerfCount = function(label) counts[label] = (counts[label] or 0) + 1 end
    setfenv(chunk, env)(addon)
    addon.UpdateMap()
    assert(addon.updateMap and #calls == 0, "dirty request rebuilt the map synchronously")
    addon.UpdateMap(true)
    local expected = "reset,lines,world,mini,arrow,visible"
    assert(table.concat(calls, ",") == expected and not addon.updateMap)
    assert(table.concat(labels, ",") ==
        "map reset,map lines,map world pins,map minimap pins,map arrow,map visibility")
    assert(counts["map rebuilds"] == 1)
    calls = {}
    addon.currentGuide = nil
    addon.UpdateMap(true)
    assert(#calls == 0 and counts["map rebuilds"] == 1)
    addon.currentGuide, addon.PerfInvoke, addon.PerfCount = {}, nil, nil
    addon.UpdateMap(true)
    assert(table.concat(calls, ",") == expected, "map behavior depends on the profiler")
    print("Map instrumentation preserved rebuild order and deferred dirty requests.")
end
