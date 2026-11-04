return function(root)
    local new, source, slice = assert(loadfile(root.."/tests/lazy-guides.lua"))()(root,true)
    local function setup(saved)
        local f,a,e=new()
        a.db.profile={guides=saved or {}}
        a.GetCreatureName=function(id) return "Creature "..id end
        a.mapId={Durotar=1411}
        f.execute(slice("UI/Map.lua","function addon.GetMapId(zone)","addon.mapId[\"StormwindClassic\"]"))
        f.load("Guide/CustomImport.lua")
        a.comms.PrettyDebug=function() end
        return f,a,e
    end
    local f,a,e=setup()
    local text="#wotlk\n#ac335\n#version 1\n#group RXPGuides Custom Guides\n#name 1-6 Test\nstep\n.accept 788 >>Accept Cutting Teeth\n.complete 788,1\n.target Kaltunk::10176\nstep\n.turnin 788\n"
    local original=e.RXPCData.guideProgress.saved
    local plan=assert(a.customImport:Analyze(text))
    assert(#plan.entries==1 and plan.entries[1].name=="01-06 Test")
    assert(not next(a.db.profile.guides) and not next(a.guides),"analysis cannot register or persist")
    assert(a.customImport:Save(plan))
    local key=plan.entries[1].key
    assert(a.db.profile.guides[key].source==text and not next(a.guides),"saving waits for reload")
    assert(e.RXPCData.guideProgress.saved==original and original.currentStep==7)
    assert(not a.customImport:Save(plan),"confirmation is one-shot")
    local restored, restoreError=a.customImport:Restore(key,a.db.profile.guides[key])
    assert(restored,restoreError or "Restore rejected source")
    a.LoadCachedGuides()
    local loaded=assert(a.guides["RXPGuides Custom Guides||01-06 Test"])
    assert(loaded.customSource335 and loaded.imported and #loaded.steps==2,
        tostring(loaded.customSource335).."/"..tostring(loaded.imported).."/"..tostring(#loaded.steps))
    assert(loaded.steps[1].elements[1].questId==788 and loaded.steps[2].elements[1].questId==788)
    a.currentGuide=loaded
    local revised=text:gsub("Cutting Teeth","the quest")
    plan=assert(a.customImport:Analyze(revised));assert(plan.replacements==1)
    assert(a.customImport:Save(plan));assert(a.currentGuide==loaded,"replacement cannot interrupt active guide")
    local _,b=setup(a.db.profile.guides);b.LoadCachedGuides()
    assert(b.guides["RXPGuides Custom Guides||01-06 Test"].steps[1].elements[1].sourceText=="Accept the quest")
    local again=assert(b.customImport:Analyze(revised));assert(again.replacements==1)
    local _,c=setup()
    local wrapper="-- License and provenance\nRXPGuides.RegisterGuide([[\n"..text.."]])\n--[=[ comment with fake RXPGuides.RegisterGuide([[bad]]) ]=]\nRXPGuides.RegisterGuide([["..text:gsub("1%-6 Test","Second").."]]);"
    local multi=assert(c.customImport:Analyze(wrapper));assert(#multi.entries==2)
    assert(c.customImport:Save(multi));c.LoadCachedGuides()
    assert(c.guides["RXPGuides Custom Guides||Second"])
    for _,bad in ipairs({
        text..".setquestdb 788,return danger()\n",text..".macro /run danger()\n",
        text.."#include foreign\n",text.."#title = danger\n",
        text..".use 1\n.stepUnknown 1\n",text..".accept nope\n",text..".complete 788\n",text..".accept788\n",
        text..".goto Durotar,101,2\n",text..".goto Durotar,0/0,2\n",
        "if true then "..wrapper.." end", wrapper.."\ndanger()", "RXPGuides.RegisterGuide(danger())",
        "RXPGuides.RegisterGuide([["..text.."]], danger())", "--[[unclosed", "123|456:encoded|789",
        text:gsub("RXPGuides Custom Guides","RestedXP Hardcore Guides (H)"),
        text:gsub("#name 1%-6 Test","#name Test << Warrior"),text:gsub("#name 1%-6 Test","#name bad|name"),
        string.rep("x",262145),text.."\0",
    }) do assert(not c.customImport:Analyze(bad),"must reject "..bad:sub(-90)) end
    local duplicate=wrapper:gsub("#name Second","#name 1-6 Test\n#subgroup Different")
    assert(not c.customImport:Analyze(duplicate),"subgroups cannot disambiguate runtime slots")
    local _,d=setup()
    d.guides["RXPGuides Custom Guides||01-06 Test"]={key=key,bundled=true}
    assert(not d.customImport:Analyze(text),"bundled collision")
    d.guides={};d.db.profile.guides[key]={key=key,groupOrContent="encoded"}
    assert(not d.customImport:Analyze(text),"encoded collision")
    d.db.profile.guides={[key.."|9"]={groupOrContent="encoded"}}
    assert(not d.customImport:Analyze(text),"legacy suffixed encoded collision")
    d.db.profile.guides={}
    local stale=assert(d.customImport:Analyze(text));d.db.profile.guides={}
    assert(not d.customImport:Save(stale),"changed storage invalidates confirmation")
    local bom="\239\187\191"..text:gsub("\n","\r\n")
    assert(d.customImport:Analyze(bom))
    assert(d.customImport:Analyze(text..".goto Durotar,43,68,20,0\n"))
    assert(not d.customImport:Analyze(text..".goto MissingMap,43,68\n"))
    assert(not d.customImport:Analyze(text..".goto 1/0,43,68\n"))
    local huge={}
    for i=1,33 do huge[i]="RXPGuides.RegisterGuide([["..text:gsub("1%-6 Test","Guide "..i).."]])" end
    assert(not d.customImport:Analyze(table.concat(huge)),"bounded batch")
    d.db.profile.guides.saved={customSourceVersion=1,key="Other||Saved",source=string.rep("x",1048576)}
    assert(not d.customImport:Analyze(text),"bounded saved source")
    d.db.profile.guides={}
    local mixed=wrapper.."RXPGuides.RegisterGuide([["..text..".setquestdb 1,{}\n]])"
    assert(not d.customImport:Analyze(mixed) and not next(d.db.profile.guides),"failed batch must save nothing")
    -- Wrong-faction records survive a reload and become available to another
    -- character without account decoding; tampered source is never dispatched.
    local alliance="<< ac335 Alliance\n"..text
    assert(d.customImport:Save(assert(d.customImport:Analyze(alliance))))
    d.LoadCachedGuides();assert(not next(d.guides));assert(d.db.profile.guides[key])
    assert(not d.customImport.errors[key],"faction filtering is not a parsing failure")
    d.db.profile.guides[key].source=text..".setquestdb 788,{}\n"
    d.LoadCachedGuides();assert(not next(d.guides))
    assert(d.customImport.errors[key],"rejected saved sources remain visible for correction")
    -- Deletion uses the real registration/index teardown, including encoded
    -- records stored with version suffixes. It never purges progress/history.
    local df, da, de = setup()
    da.emptyGuide = {empty=true, steps={}}
    da.settings.gui = {selectedDeleteGuide=key}
    local savedPlan = assert(da.customImport:Analyze(text))
    assert(da.customImport:Save(savedPlan)); da.LoadCachedGuides()
    local target = assert(da.GetGuideTable("RXPGuides Custom Guides", "01-06 Test"))
    local checkpoint = {currentStep=2,stepSkip={[1]=true}}
    de.RXPCData.guideProgress[key] = checkpoint
    da.currentGuide=target
    assert(not da.customImport:PlanDelete(key), "active import must not be removed")
    local active = {key="Other||Active"};da.currentGuide=active
    local deletion=assert(da.customImport:PlanDelete(key))
    assert(da.db.profile.guides[key], "planning is read-only / cancellation keeps source")
    da.IsQuestRewardSettlementActive=function() return true end
    assert(not da.customImport:Delete(deletion));assert(da.db.profile.guides[key])
    da.IsQuestRewardSettlementActive=function() return false end
    de.InCombatLockdown=function() return true end
    assert(not da.customImport:Delete(deletion))
    de.InCombatLockdown=function() return false end
    da.currentGuide=target
    assert(not da.customImport:Delete(deletion),"activation after prompting blocks deletion")
    da.currentGuide=active
    local store=da.db.profile.guides
    da.db.profile.guides={[key]=store[key]}
    assert(not da.customImport:Delete(deletion),"profile replacement invalidates consent")
    da.db.profile.guides=store
    local sourceRecord=da.db.profile.guides[key]
    sourceRecord.source=sourceRecord.source.."\n"
    assert(not da.customImport:Delete(deletion), "in-place replacement invalidates consent")
    sourceRecord.source=text
    target.lowPrio="*"..target.group
    da.guideList[target.lowPrio]=da.guideList[target.group];da.guideList[target.group]=nil
    da.defaultGuide=target
    deletion=assert(da.customImport:PlanDelete(key))
    assert(da.customImport:Delete(deletion))
    assert(not da.customImport:Delete(deletion),"one-shot deletion")
    assert(not da.db.profile.guides[key] and da.customImport:IsRemoved(key))
    assert(da.GetGuideTable("RXPGuides Custom Guides", "01-06 Test") == da.emptyGuide)
    assert(da.currentGuide==active and de.RXPCData.guideProgress[key]==checkpoint)
    assert(da.settings.gui.selectedDeleteGuide=="")
    assert(not da.defaultGuide and not da.guideList[target.lowPrio],"low-priority imported group is removed too")
    -- A stale preview must not reactivate the source or clear the active route.
    df.execute(slice("UI/GuideWindow.lua","function addon:PrepareGuideLoad335(","function addon:LoadGuide("))
    df.execute(slice("UI/GuideWindow.lua","function addon:LoadGuide(","-- Loading is synchronous"))
    assert(not da:PrepareGuideLoad335(target));assert(not da:LoadGuide(target))
    assert(da.currentGuide==active)
    assert(da.customImport:Save(assert(da.customImport:Analyze(text))))
    local _, reloaded = setup(da.db.profile.guides);reloaded.LoadCachedGuides()
    assert(reloaded.GetGuideTable("RXPGuides Custom Guides", "01-06 Test"))
    assert(not reloaded.customImport:IsRemoved(key), "reimport is available after reload")
    local encodedKey="Encoded|Subgroup|Example"
    da.db.profile.guides[encodedKey.."|1"]={key=encodedKey,cache=true,groupOrContent="one"}
    da.db.profile.guides[encodedKey.."|2"]={cache=true,groupOrContent="two"}
    da.guideCache[encodedKey.."|2"]=function() error("stale parser") end
    local ep=assert(da.customImport:PlanDelete(encodedKey))
    da.db.profile.guides[encodedKey.."|3"]={key=encodedKey,cache=true,groupOrContent="three"}
    assert(not da.customImport:Delete(ep), "new version invalidates consent")
    assert(da.customImport:Delete(assert(da.customImport:PlanDelete(encodedKey))))
    assert(not da.db.profile.guides[encodedKey.."|1"] and not da.db.profile.guides[encodedKey.."|2"] and not da.db.profile.guides[encodedKey.."|3"])
    assert(not da.guideCache[encodedKey.."|2"])
    local bundled={key="Bundled||Guide",group="Bundled",name="Guide"}
    da.guides.bundled=bundled;da.db.profile.guides[bundled.key]={key=bundled.key,cache=true,groupOrContent="stale import"}
    assert(not da.customImport:PlanDelete(bundled.key),"saved records cannot authorize deleting bundled content")
    local orphan=assert(d.customImport:PlanDelete(key))
    assert(d.customImport:Delete(orphan) and not d.customImport.errors[key],"invalid/unloaded source remains deletable")
    print("Website imports: safety, persistence, parsing, deletion, stale confirmations and progress preservation passed")
end
