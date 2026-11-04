local _, addon = ...

-- Plain website sources are data, never Lua programs. Keep this deliberately
-- narrower than trusted bundled guides: parse-time expressions, includes and
-- macros are not accepted. Nothing is registered until the next reload.
local importer = {errors = {}}
addon.customImport = importer
local MAX_INPUT, MAX_TOTAL, MAX_GUIDES = 262144, 1048576, 32
local headers = {group=true, subgroup=true, name=true, version=true, wotlk=true,
    ac335=true, title=true, description=true, next=true, hardcore=true, softcore=true,
    label=true, requires=true, completewith=true, sticky=true, optional=true,
    loop=true, hidewindow=true}
local directives = {accept=true, turnin=true, complete=true, collect=true,
    use=true, target=true, mob=true, ["goto"]=true}
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local function fail(message) error(message, 0) end
local function identity(s)
    return s ~= "" and #s <= 160 and not s:find("[|\\<>%c]") and not s:find("%-%-")
end
local function integer(s, optional)
    if optional and (not s or s == "") then return true end
    local n = tonumber(s)
    return n and n > 0 and n < 2147483648 and n == math.floor(n)
end
local function split(s)
    local out = {}
    for value in (s .. ","):gmatch("(.-),") do out[#out+1] = trim(value) end
    return out
end

-- A tiny literal-wrapper reader, not a Lua interpreter. Comments are allowed
-- between registrations; external guards, extra arguments and code are not.
local function sources(input)
    if type(input) ~= "string" or #input > MAX_INPUT then fail("Import is limited to 256 KiB. Split larger files first.") end
    if input:find("[%z\1-\8\11\12\14-\31]") then fail("Binary/control characters are not guide source.") end
    input = input:gsub("^\239\187\191", "")
    local pos, result = 1, {}
    local function skip()
        while true do
            local _, last = input:find("^%s+", pos)
            if last then pos = last+1 end
            if input:sub(pos,pos+1) ~= "--" then return end
            local eq = input:sub(pos+2):match("^%[(=*)%[")
            if eq then
                local _, stop = input:find("]"..eq.."]",pos+4+#eq,true)
                if not stop then fail("Unclosed Lua comment.") end
                pos = stop+1
            else
                pos = (input:find("[\r\n]",pos+2) or #input+1)
            end
        end
    end
    skip()
    if input:sub(pos,pos) == "#" or input:sub(pos,pos+1) == "<<" then return {input} end
    while pos <= #input do
        local _, last = input:find("^RXPGuides%.RegisterGuide%s*%(",pos)
        if not last then fail("Paste guide text or literal RXPGuides.RegisterGuide wrappers only; external Lua is not executed.") end
        pos = last+1; skip()
        if input:sub(pos,pos+1) ~= "[[" then fail("Only the website's [[...]] guide wrapper is supported.") end
        local stop = input:find("]]",pos+2,true)
        if not stop then fail("Unclosed guide wrapper.") end
        result[#result+1] = input:sub(pos+2,stop-1)
        if #result > MAX_GUIDES then fail("Import at most 32 guides at once.") end
        pos = stop+2; skip()
        if input:sub(pos,pos) ~= ")" then fail("Additional registration arguments are not supported.") end
        pos = pos+1; skip()
        if input:sub(pos,pos) == ";" then pos=pos+1; skip() end
    end
    if #result == 0 then fail("Paste a guide exported by the website.") end
    return result
end

local function validate(source)
    local fields, steps, lines = {}, 0, 0
    for raw in (source.."\n"):gmatch("([^\r\n]*)[\r\n]") do
        lines=lines+1
        if lines > 8000 or #raw > 4096 then fail("Guide exceeds the line/line-length limit.") end
        local line=trim(raw)
        if line ~= "" and line:sub(1,2) ~= "--" then
            -- Production removes line comments before parsing. Validate that
            -- same effective line, including on branches not currently visible.
            line=trim(line:gsub("%-%-.*$", ""))
            local code=trim(line:match("^(.-)%s*<<") or line)
            if code == "step" then steps=steps+1
            elseif code:sub(1,1)=="#" then
                local tag,value=code:match("^#([%w]+)%s*(.*)$")
                if not headers[tag] or value:sub(1,1)=="=" then fail("Unsupported header: "..code) end
                if tag=="group" or tag=="name" or tag=="subgroup" then
                    if steps>0 or fields[tag] or code~=line or not identity(value) then fail("Use one unconditional, distinct group/name/subgroup before the steps.") end
                    fields[tag]=value
                end
            elseif code:sub(1,1)=="." then
                if steps==0 then fail("Instructions must follow a step line.") end
                code=trim(code:match("^(.-)%s*>>") or code)
                local tag,args=code:match("^%.([%a]+)%s+(.*)$")
                if not tag then tag=code:match("^%.([%a]+)$"); args="" end
                if not directives[tag] then fail("Unsupported website-import instruction: "..code) end
                local a=split(args)
                local maximum=({accept=1,turnin=2,complete=3,collect=2,use=1,["goto"]=5,target=1,mob=1})[tag]
                if #a>maximum then fail("Too many arguments: "..code) end
                if tag=="goto" then
                    local x,y,r=tonumber(a[2]),tonumber(a[3]),tonumber(a[4])
                    if a[1]=="" or not x or not y or x~=x or y~=y or x<0 or x>100 or y<0 or y>100 or
                        (a[4] and a[4]~="" and (not r or r~=r or r<0 or r>10000)) then fail("Use a zone and coordinates from 0 to 100: "..code) end
                    if a[1]:find("/",1,true) then fail("World-coordinate instructions require manual source review.") end
                    if addon.GetMapInfo then
                        local map,mx,my=addon.GetMapInfo(a[1],x,y)
                        if not map or not mx or not my then fail("Unknown map token: "..a[1]) end
                    end
                elseif tag=="target" or tag=="mob" then
                    if args=="" then fail("Missing NPC name or ID: "..code) end
                elseif not integer(a[1]) or
                    (tag=="complete" and not integer(a[2])) or
                    ((tag=="turnin" or tag=="collect") and not integer(a[2],true)) or
                    (tag=="complete" and not integer(a[3],true)) then fail("Invalid numeric argument: "..code) end
            elseif code ~= "" and code:sub(1,2) ~= ">>" and not code:match("^[+*]") then
                fail("Unsupported source line: "..code)
            end
        end
    end
    if not fields.group or not fields.name or steps==0 then fail("A guide needs #group, #name and at least one step.") end
    if fields.group~="RXPGuides Custom Guides" and not fields.group:match("^RXPGuides Custom Guides %-") then
        fail("Use the website's Save as new guide: custom groups must start with RXPGuides Custom Guides.")
    end
    fields.name=fields.name:gsub("^(%d)-(%d%d?)",addon.affix)
    fields.key=addon.BuildGuideKey(fields)
    fields.source=source
    return fields
end

local function analyze(input)
    local entries, seen, replacements = {}, {}, 0
    local saved=addon.db.profile.guides
    for _,source in ipairs(sources(input)) do
        local e=validate(source)
        local slot=e.group.."||"..e.name
        if seen[slot] then fail("Duplicate group/name in this import; subgroup differences are not sufficient.") end
        seen[slot]=true
        for key,record in pairs(saved) do
            local stored=record.key or key:match("^[^|]+|[^|]-|[^|]+") or key
            local group,_,name=stored:match("^(.-)|(.-)|(.-)$")
            if group==e.group and name==e.name and (stored~=e.key or record.customSourceVersion~=1) then fail("This identity conflicts with another saved guide. Rename the custom guide.") end
        end
        local loaded=addon.guides[slot]
        if loaded and loaded~=addon.emptyGuide and (not loaded.customSource335 or loaded.key~=e.key) then fail("Cannot replace a bundled or non-website guide. Rename the custom guide.") end
        e.previous=saved[e.key]
        if e.previous and e.previous.customSourceVersion~=1 then fail("Cannot replace an encoded import. Rename the custom guide.") end
        e.previousSource=e.previous and e.previous.source
        if e.previous then replacements=replacements+1 end
        entries[#entries+1]=e
    end
    local total=0
    for key,r in pairs(saved) do
        if r.customSourceVersion==1 then total=total+#(r.source or "") end
    end
    for _,e in ipairs(entries) do total=total+#e.source-#(e.previous and e.previous.source or "") end
    if total>MAX_TOTAL then fail("Saved website guides are limited to 1 MiB. Remove unused imports first.") end
    return {entries=entries,replacements=replacements,input=input,store=saved}
end
function importer:Analyze(input)
    local ok,result=pcall(analyze,input)
    if ok then return result end
    return nil,tostring(result)
end
function importer:Save(plan)
    local current,err=self:Analyze(plan.input)
    if not current then return nil,err end
    if current.store~=plan.store then return nil,"Import data changed. Review the import again." end
    for i,e in ipairs(current.entries) do
        if not plan.entries[i] or e.key~=plan.entries[i].key or e.previous~=plan.entries[i].previous or e.previousSource~=plan.entries[i].previousSource then return nil,"Import data changed. Review the import again." end
    end
    for _,e in ipairs(current.entries) do
        current.store[e.key]={customSourceVersion=1,key=e.key,source=e.source}
    end
    return true
end
function importer:Restore(key,record)
    self.errors[key]=nil
    if record.customSourceVersion~=1 or type(record.source)~="string" or #record.source>MAX_INPUT then self.errors[key]="Invalid saved custom guide."; return end
    local ok,entry=pcall(validate,record.source)
    if not ok or entry.key~=key then self.errors[key]="Invalid custom guide source or identity."; return end
    local parsed,guide,err=pcall(addon.ParseGuide,record.source)
    if parsed and guide and not err then
        guide.imported=true; guide.customSource335=true
        addon.AddGuide(guide)
        return guide
    end
    if parsed and guide and guide.enabledFor and not addon.applies(guide.enabledFor) then return end
    self.errors[key]="Custom guide failed to parse. Correct its source and import again."
    return nil, parsed and err or tostring(guide)
end

-- Saved imports are owned by this profile; bundled/companion sources are not.
-- Keep progress and Favorites independent of source deletion for reimporting.
local removed = {}
function importer:IsRemoved(key) return key and removed[key] == true end

function importer:PlanDelete(key)
    local L = addon.locale.Get
    if type(key) ~= "string" or key == "" then return nil, L("Select an imported guide first.") end
    local store = addon.db.profile.guides
    local records, loaded = {}, nil
    for _, guide in pairs(addon.guides or {}) do
        if guide.key == key then loaded = guide; break end
    end
    if loaded and not loaded.imported then return nil, L("Bundled and companion-addon guides cannot be deleted here.") end
    for storageKey, record in pairs(store) do
        if type(record) == "table" and (record.customSourceVersion == 1 or record.cache or type(record.groupOrContent) == "string") then
            local canonical = record.key or storageKey:match("^[^|]+|[^|]*|[^|]+") or storageKey
            if canonical == key then records[storageKey] = {record = record, source = record.source, encoded = record.groupOrContent} end
        end
    end
    if not next(records) then return nil, L("No saved import exists for this guide.") end
    if addon.currentGuide and addon.currentGuide.key == key then return nil, L("Choose another guide before deleting this import.") end
    if (_G.InCombatLockdown and _G.InCombatLockdown()) or
        (addon.IsQuestRewardSettlementActive and addon.IsQuestRewardSettlementActive()) or
        (addon.guideBodyCache and (addon.guideBodyCache.loading or 0) > 0) then
        return nil, L("Finish combat or the current guide/quest action before deleting an import.")
    end
    return {key = key, store = store, records = records, loaded = loaded}
end

function importer:Delete(plan)
    local current, problem = self:PlanDelete(plan and plan.key)
    if not current then return nil, problem end
    local function changed() return nil, addon.locale.Get("Import data changed. Review the deletion again.") end
    if current.store ~= plan.store or current.loaded ~= plan.loaded then return changed() end
    for key, value in pairs(current.records) do
        local previous = plan.records[key]
        if not previous or previous.record ~= value.record or previous.source ~= value.source or previous.encoded ~= value.encoded then return changed() end
    end
    for key in pairs(plan.records) do if not current.records[key] then return changed() end end
    if current.loaded and not addon.RemoveGuide(current.key) then return changed() end
    removed[current.key] = true -- invalidates old preview/selection payloads
    if current.loaded then current.loaded.disabled = true end
    for key in pairs(current.records) do
        current.store[key] = nil
        if addon.guideCache then addon.guideCache[key] = nil end
    end
    self.errors[current.key] = nil
    if addon.defaultGuide == current.loaded then addon.defaultGuide = nil end
    if addon.settings.gui then addon.settings.gui.selectedDeleteGuide = "" end
    if addon.guideHub and addon.guideHub.Refresh then addon.guideHub:Refresh() end
    if addon.libraryTabs then addon.libraryTabs:SettingsChanged() end
    if addon.settings.UpdateImportStatusHistory then
        addon.settings:UpdateImportStatusHistory(addon.locale.Get("Imported guide deleted. Saved progress is retained."))
    end
    return true
end
