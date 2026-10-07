-- Artifact-only CI: no claim of source freshness or translation coverage.
-- lua5.1 tools/validate-locale-artifacts.lua <locale-root> <runtime-root>
local source, runtime = assert(arg[1]), assert(arg[2])
assert(_VERSION == "Lua 5.1", "Use Lua 5.1")
dofile(runtime .. "/libs/LibStub/LibStub.lua")
dofile(runtime .. "/libs/LibDeflate/LibDeflate.lua")
local deflate, FS, RS = LibStub("LibDeflate"), string.char(31), string.char(30)
local function read(path)
    local f = assert(io.open(path, "rb"), "Missing artifact: " .. path)
    local s = f:read("*a"); f:close()
    assert(#s <= 24*1024*1024, "Oversized artifact")
    return s
end
local function utf8(s)
    local i = 1
    while i <= #s do
        local b = s:byte(i)
        if b < 128 then i = i+1 else
            local n = b >= 194 and b <= 223 and 2 or b >= 224 and b <= 239 and 3 or b >= 240 and b <= 244 and 4
            assert(n and i+n-1 <= #s, "Invalid UTF-8")
            for j = 1,n-1 do local c = s:byte(i+j); assert(c >= 128 and c <= 191, "Invalid UTF-8 continuation") end
            local c = s:byte(i+1)
            assert(not (b == 224 and c < 160 or b == 237 and c > 159 or b == 240 and c < 144 or b == 244 and c > 143), "Invalid code point")
            i = i+n
        end
    end
end
local function split(s, sep)
    local t, at = {}, 1
    while true do
        local p = s:find(sep,at,true)
        if not p then t[#t+1] = s:sub(at); return t end
        t[#t+1] = s:sub(at,p-1); at = p+1
    end
end
local function serviceFor(locale)
    local a = {locale = {}}
    local env = setmetatable({GetLocale = function() return locale end}, {__index = _G})
    local chunk = assert(loadfile(runtime .. "/Guide/Localization.lua"))
    setfenv(chunk,env); chunk("RXPGuides",a)
    return a.guideLocalization
end
local function validate(payload, service)
    assert(type(payload) == "string" and #payload > 0 and #payload <= 16*1024*1024, "Invalid decompressed size")
    utf8(payload)
    local records = split(payload,RS)
    if records[#records] == "" then table.remove(records) end
    local h = split(records[1],FS)
    assert(#h == 7 and h[1] == "H" and h[2] == "1" and h[3] ~= "" and h[4] ~= "", "Invalid header")
    local seen, count = {}, 0
    for i = 2,#records do
        local f = split(records[i],FS)
        assert(#f == 7, "Invalid field count")
        local kind,status,key,english,text,signature,tokenized = unpack(f)
        assert(kind == "G" or kind == "C" or kind == "U", "Invalid kind")
        assert(status == "R" or status == "M", "Invalid status")
        assert(key ~= "" and text ~= "" and (tokenized == "0" or tokenized == "1"), "Invalid fields")
        english = kind == "C" and english or key
        assert(english ~= "" and signature == service.HashSource(english), "Source signature mismatch")
        local id = kind .. FS .. status .. FS .. key
        assert(not seen[id], "Duplicate translation"); seen[id] = true
        if tokenized == "1" then
            local _,_,expected = service:Tokenize(english)
            local names = {}
            for name in text:gmatch("{([%a_]+)}") do names[#names+1] = name end
            table.sort(names)
            assert(table.concat(names,FS) == expected, "Missing, extra or duplicated token")
        end
        count = count+1
    end
    assert(count > 0, "Empty pack")
    return count
end
local function execute(text, locale, service)
    utf8(text)
    local chunk = assert(loadstring(text,"@locale-artifact"))
    -- The pack has no IO, os, require, client globals or mutable addon state.
    setfenv(chunk,{GetLocale = function() return locale end, table = {concat = table.concat}})
    chunk("RXPGuides",{guideLocalization = service})
end
for _,locale in ipairs({"deDE","esES","frFR","koKR","ruRU","zhCN","zhTW"}) do
    local text = read(source .. "/locale/GuidePack." .. locale .. ".lua")
    local calls,count,service = 0,0,serviceFor(locale)
    local capture = {RegisterCompressedPack = function(_,code,encoded)
        assert(code == locale and type(encoded) == "string" and #encoded > 0, "Invalid locale/payload")
        calls = calls+1
        local compressed = assert(deflate:DecodeForPrint(encoded), "Invalid encoding")
        count = validate(assert(deflate:DecompressDeflate(compressed), "Invalid compression"),service)
        assert(service:RegisterCompressedPack(code,encoded), "Production loader rejected pack")
    end}
    execute(text,"enUS",capture); assert(calls == 0, "Inactive locale loaded")
    execute(text,locale,capture); assert(calls == 1, "Expected exactly one registration")
    print(locale .. ": " .. count .. " records; schema/signatures/tokens/loader/locale gating passed")
end
local calls = 0
local exact = read(source .. "/locale/GuideExact.zhCN.lua")
local capture = {RegisterExactCatalog = function(_,code,entries,attribution)
    assert(code == "zhCN" and type(entries) == "table" and type(attribution) == "string" and attribution ~= "", "Invalid reviewed catalog")
    local count = 0
    for key,value in pairs(entries) do
        assert(type(key) == "string" and key ~= "" and type(value) == "string" and value ~= "", "Invalid reviewed entry")
        utf8(key); utf8(value); count = count+1
    end
    assert(count > 0, "Empty reviewed catalog"); calls = calls+1
end}
execute(exact,"enUS",capture); assert(calls == 0)
execute(exact,"zhCN",capture); assert(calls == 1)
local service = serviceFor("deDE")
local h = table.concat({"H","1","fixture","test","","",""},FS)
local row = table.concat({"G","M","Hello","","Hallo",service.HashSource("Hello"),"0"},FS)
assert(validate(h .. RS .. row,service) == 1)
for _,bad in ipairs({h,h .. RS .. row .. RS .. row,
    h .. RS .. row:gsub("Hallo",string.char(255)),
    h .. RS .. row:gsub(service.HashSource("Hello"),"00000000"),
    h .. RS .. table.concat({"U","M","%d copper","","Kupfer",service.HashSource("%d copper"),"1"},FS)}) do
    assert(not pcall(validate,bad,service), "Malformed fixture accepted")
end
print("Artifact checks passed. Source freshness, translation quality and 99% coverage are NOT certified without catalogs.")
