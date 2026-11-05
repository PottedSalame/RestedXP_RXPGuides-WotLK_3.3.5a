-- Browser-generated exports are read as data, never executed as Lua.
local root, generated = assert(arg[1]), assert(arg[2])
local input = assert(io.open(generated, 'rb'))
local source = input:read('*a'); input:close()
local newLoader = assert(loadfile(root .. '/tests/guide-loading.lua'))()(root, true)
local expected = {accept=true, complete=true, turnin=true, goto=true, target=true}
for _, fixture in ipairs({{'WARRIOR','Orc','Horde'}, {'MAGE','Troll','Horde'}, {'WARRIOR','Human','Alliance'}}) do
    local addon, env = newLoader(fixture[1], fixture[2], nil, fixture[3], 10)
    local original = addon.functions
    addon.functions = setmetatable({}, {__index=function(_, tag)
        assert(expected[tag], 'Unregistered exported directive ' .. tag)
        return original[tag]
    end})
    local guide, failure = addon.ParseGuide(source)
    assert(guide and not failure)
    assert(guide.name == 'Browser Fixture' and guide.group == 'RXPGuides Custom Guides')
    local actions = {}
    for _, step in ipairs(guide.steps) do
        for _, element in ipairs(step.elements) do
            actions[element.tag] = (actions[element.tag] or 0) + 1
            if element.tag == 'accept' or element.tag == 'turnin' then assert(tonumber(element.first) == 4641) end
            if element.tag == 'complete' then assert(tonumber(element.first) == 788 and tonumber(element.second) == 1) end
        end
    end
    assert(actions.accept == 1 and actions.turnin == 1 and actions.goto == 1)
    assert((actions.complete == 1) == (fixture[1] == 'WARRIOR'))
    -- Exact ID-only forms emitted by the interior reference actions. Parse
    -- through the production parser with inert handlers; no quest action or
    -- uploaded Lua is run.
    local interior = assert(addon.ParseGuide([[#wotlk
#ac335
#group RXPGuides Custom Guides
#name Interior reference fixture
step
    .target 42
    .accept 101
    .turnin 102
    >>Interact with Chest (object 43).
]]))
    local found = {}
    for _, step in ipairs(interior.steps) do
        for _, element in ipairs(step.elements) do
            assert(element.tag ~= 'goto', 'Interior reference invented coordinates')
            if element.tag == 'target' then assert(tonumber(element.first) == 42); found.target = true end
            if element.tag == 'accept' then assert(tonumber(element.first) == 101); found.accept = true end
            if element.tag == 'turnin' then assert(tonumber(element.first) == 102); found.turnin = true end
        end
    end
    assert(found.target and found.accept and found.turnin)
end
print('Website source production parser: three class/race/faction profiles passed; handlers inert.')

-- Inspect real parse-time handlers, not the inert dispatcher above. Mock only
-- client services. Never execute runtime quest actions or uploaded Lua.
local forms = assert(arg[3], 'Browser-generated form fixture required')
local file = assert(io.open(forms, 'rb'))
local formSource = file:read('*a'); file:close()
local new = assert(loadfile(root .. '/tests/lazy-guides.lua'))()(root, true)
local f, addon = new()
addon.GetMapInfo = function(zone, x, y)
    assert(zone == 'Durotar'); return 1411, tonumber(x), tonumber(y)
end
addon.mapConversion = {}
addon.icons = setmetatable({}, {__index=function() return '' end})
addon.GetCreatureName = function(id) return 'Creature ' .. id end
for i = 1, 40 do
    local name, value = debug.getupvalue(addon.functions['goto'], i)
    if not name then break end
    if name == 'HBD' then value.GetWorldCoordinatesFromZone = function(_, x, y) return x, y, 1 end end
end
local guide = assert(addon.ParseGuide(formSource))
assert(#guide.steps == 11)
-- Descriptive branch metadata is inert and accepted by the real website
-- importer, with the exact same identity and no new header dialect.
f.load('Guide/CustomImport.lua')
addon.db.profile = {guides={}}
assert(addon.customImport:Analyze(source))
local plan = assert(addon.customImport:Analyze(formSource))
assert(#plan.entries == 1 and plan.entries[1].source == formSource)
assert(plan.entries[1].key == addon.BuildGuideKey(guide))
assert(formSource:find('-- Server-Realm: Warmane-Icecrown', 1, true))
assert(not guide.server and not guide.purpose and not guide.requirements)
local function element(index) return assert(guide.steps[index].elements[1]) end
local travel, nav = element(1), element(2)
assert(travel.tag == 'goto' and travel.radius == 15 and not travel.textOnly and travel.text:find('Go to',1,true))
assert(nav.tag == 'goto' and not nav.radius and nav.textOnly and (not nav.text or nav.text == ''))
assert(element(3).questId == 4641 and not element(3).textOnly)
assert(element(4).questId == 4641 and element(4).reward == 1 and not element(4).textOnly)
assert(element(5).questId == 788 and element(5).obj == 1 and element(5).objMax == 4 and not element(5).textOnly)
assert(element(6).id == 4865 and element(6).qty == 2 and not element(6).textOnly)
assert(element(7).activeItems[6948] ~= nil and element(7).textOnly)
assert(element(8).targets and element(8).textOnly)
assert(element(9).mobs and element(9).textOnly)
assert(element(10).text == 'Done!' and element(10).textOnly)
assert(element(11).text == 'Done!' and not element(11).textOnly)
-- Reproduce the reported five-step route and prove the only semantic change
-- needed is an explicit radius (plus an optional manually checkable endpoint).
local original = [[#wotlk
#ac335
#version 1
#group RXPGuides Custom Guides
#name My Guide
step
    >>Hello there! This is a test guide! Go to the next objective!
    .goto Durotar,44.31,68.20
step
    .goto Durotar,45.76,68.27
step
    .goto Durotar,45.04,65.86
step
    .goto Durotar,44.31,68.20
step
    >>Done!
]]
for _, radius in ipairs({false, true}) do
    local source = radius and original:gsub('(%.goto Durotar,[%d.]+,[%d.]+)', '%1,15') or original
    local parsed = assert(addon.ParseGuide(source)); assert(#parsed.steps == 5)
    local points = 0
    for _, step in ipairs(parsed.steps) do
        for _, item in ipairs(step.elements) do
            if item.tag == 'goto' then
                points = points + 1
                assert((not item.textOnly) == radius)
                assert(item.radius == (radius and 15 or nil))
            end
        end
    end
    assert(points == 4)
end
print('Website form semantics: all ten forms and reported route verified through production handlers.')
