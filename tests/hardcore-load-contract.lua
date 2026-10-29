-- Real production window loader for rejected/redirected selections. No copy of
-- its validation logic and no stub pretending a failed load succeeded.
return function(root,fixtures)
    local function read(path)
        local f=assert(io.open(root.."/"..path,"rb"))
        local text=f:read("*a"); f:close(); return text
    end
    local source=read("UI/GuideWindow.lua")
    local first=assert(source:find("function addon:PrepareGuideLoad335(",1,true))
    local last=assert(source:find("function addon:ReloadGuide(",first,true))
    local loader=source:sub(first,last-1)
    -- The loader binds pooled rows to these production-local input helpers.
    -- Keep them in the same lexical chunk; gesture behavior has its own suite.
    local dragStart=assert(source:find("local guideDragOwner",1,true))
    local dragEnd=assert(source:find('RXPFrame:HookScript("OnHide"',dragStart,true))
    loader=source:sub(dragStart,dragEnd-1)..loader
    local factory=assert(loadfile(root.."/tests/quest-automation-audit.lua"))
    setfenv(factory,setmetatable({arg={root,"--fixtures"}},{__index=_G}))
    local fixture=factory()
    local s=fixture()
    s.load("Guide/State.lua")
    s.load("Features/Roadmap.lua")
    s.load("Guide/Hardcore.lua")
    local a,data=s.addon,s.env.RXPCData
    local current={key="current",group="Normal",name="Current",steps={}}
    local destination={key="requested",group="RestedXP Hardcore Guides (H)",
        name="Requested",hardcore=true,steps={}}
    a.currentGuide=current
    data.currentStep,data.currentStepId=7,"seven"
    data.stepSkip,data.completedWaypoints={[3]=true},{point=true}
    a.settings.profile.hardcore=false
    a.IsGuideActive=function(g) return not g.disabled end
    a.emptyGuide=nil
    local parsed=destination
    a.FetchGuide=function() return parsed end
    local saved,applied,callbacks,cancelled=0,0,0,0
    local productionApply=a.guideState.Apply
    a.guideState.SaveCurrent=function() saved=saved+1 end
    a.guideState.Apply=function() applied=applied+1; error("Failed/redirected destination applied a checkpoint") end
    a.guideState.CancelAdvance=function() cancelled=cancelled+1 end
    a.questAutomation={ResetForGuideChange=function() end}
    local prompt
    a.comms={PrettyDebug=function() end,PrettyPrint=function() end,
        ConfirmChoice=function(_,_,_,fn) prompt=fn end}
    s.env.addon=a
    s.env.fmt=string.format
    s.env.GetMissingGuideEntryQuest=function() return {788} end
    local previous={key="previous",group=destination.group,name="Previous",hardcore=true,disabled=true}
    s.env.FindPreviousGuide=function() return previous end
    s.env.GuideContainsQuest=function() return true end
    a.GetGuideName=function(g) return g.name end
    setfenv(assert(loadstring(loader)),s.env)()
    local productionLoad=a.LoadGuide
    local function unchanged()
        assert(a.currentGuide==current and data.currentStep==7 and
            data.currentStepId=="seven" and data.stepSkip[3] and
            data.completedWaypoints.point,"Rejected load changed progression")
        assert(applied==0 and callbacks==0,"Rejected load invoked destination work")
    end
    for _,failure in ipairs({"missing","steps","identity","disabled","farm"}) do
        parsed=destination
        if failure=="missing" then parsed=nil end
        if failure=="steps" then parsed={key=destination.key,group=destination.group,name=destination.name} end
        if failure=="identity" then parsed={key="other",group=destination.group,name=destination.name,steps={}} end
        if failure=="disabled" then parsed={key=destination.key,group=destination.group,name=destination.name,steps={},disabled=true} end
        if failure=="farm" then parsed={key=destination.key,group=destination.group,name=destination.name,steps={},farm=true} end
        a.guideState:Load(destination,false,"manual",function() callbacks=callbacks+1 end)
        unchanged()
        assert(not prompt and saved==0 and cancelled==0 and not a.settings.profile.hardcore,
            "Preflight failure saved progress, cancelled work or changed mode")
    end
    parsed=destination
    a.guideState:Load(destination,false,"manual",function() callbacks=callbacks+1 end)
    assert(prompt and not a.settings.profile.hardcore)
    -- The same guide may advance while a confirmation is open.
    local stale=prompt
    data.currentStep=8
    stale()
    assert(not a.settings.profile.hardcore and saved==0)
    data.currentStep=7
    prompt=nil
    a.guideState:Load(destination,false,"manual",function() callbacks=callbacks+1 end)
    destination.sourceSignature="changed"
    prompt()
    assert(not a.settings.profile.hardcore and saved==0,"Changed source confirmation was accepted")
    destination.sourceSignature=nil
    a.guideState:Load(destination,false,"manual",function() callbacks=callbacks+1 end)
    parsed=nil
    prompt()
    assert(not a.settings.profile.hardcore and saved==0,"Failed delayed fetch changed mode")
    unchanged()
    parsed=destination
    a.guideState:Load(destination,false,"manual",function() callbacks=callbacks+1 end)
    local superseded=prompt
    a.guideState:Load({disabled=true},false,"manual")
    superseded()
    assert(not a.settings.profile.hardcore and saved==0,
        "A rejected newer selection left the previous confirmation live")
    unchanged()
    a.guideState:Load(destination,false,"manual",function() callbacks=callbacks+1 end)
    superseded=prompt
    a:LoadGuide({disabled=true})
    superseded()
    assert(not a.settings.profile.hardcore and saved==0,
        "A rejected direct load left the previous confirmation live")
    unchanged()
    -- A real loader redirect must happen before Apply, and must not inherit
    -- the originally requested destination's checkpoint/callback.
    parsed=destination
    a.settings.profile.hardcore=true
    a.guideState:Load(destination,false,"manual",function() callbacks=callbacks+1 end)
    unchanged()
    assert(a.LoadGuide==productionLoad and saved==1 and cancelled==1,
        "Fixture did not traverse the real redirected loading path")
    -- Even if an old destination is already current, nil is not a load receipt.
    a.currentGuide=destination
    a.LoadGuide=function() return nil end
    a.guideState:Load(destination,false,"selection",function() callbacks=callbacks+1 end)
    assert(callbacks==0,"Matching old display identity was mistaken for successful load")
    -- Execute the successful production loader too, with inert UI widgets.
    -- Its destination validation, checkpoint application, label setup and
    -- final load receipt are real; UI rendering/SetStep have separate suites.
    local function noop() end
    local function widget()
        local w={}
        for name in ("SetHeight ClearAllPoints SetPoint Hide EnableMouse Show SetAlpha "..
            "ClearBackdrop SetBackdrop SetScript SetFontObject SetJustifyH SetJustifyV "..
            "SetTextColor SetFont SetSize SetText RegisterForDrag HookScript"):gmatch("%S+") do w[name]=noop end
        w.GetFont=function() return "fixture",10,"" end
        w.GetStringWidth=function() return 20 end
        w.CreateFontString=widget
        return w
    end
    s.env.CreateFrame=widget
    s.env.CloseDropDownMenus=noop
    s.env.L=function(text) return text end
    s.env.IsFrameShown=function() return true end
    s.env.ApplyStepVisualState=noop
    s.env.GuideName={text=widget()}
    s.env.ScrollChild=widget()
    s.env.ScrollChild.framePool={}
    local scrollResets=0
    s.env.BottomFrame={UpdateFrame=noop,CancelScrollFollow=function(_,reset)
        assert(reset==true,"Successful guide load must invalidate previous scroll identity")
        scrollResets=scrollResets+1
    end}
    s.env.RXPFrame={backdrop={bottom={}},bottomMenu={},GenerateMenuTable=noop}
    a.RXPFrame=s.env.RXPFrame
    s.env.table=setmetatable({wipe=function(t) for k in pairs(t) do t[k]=nil end end},
        {__index=table})
    a.scheduledTasks,a.stepUpdateList={},{}
    a.settings.DetectXPRate=noop
    a.settings.profile.guideFontSize=10
    a.activeTheme={textColor={1,1,1}}
    a.UpdateBrowseModeButton=noop
    a.ProcessGuideTable=function(g) return g end
    a.ScheduleTask=noop
    a.SetStep=function(step) assert(step==data.currentStep) end
    local published=0
    a.QueueMessage=function(_,event,g)
        assert(event=="RXP_GUIDE_LOADED" and g==a.currentGuide)
        published=published+1
    end
    a.guideState.RecordLoaded=noop
    a.guideState.Apply=function(self,g,restart)
        applied=applied+1
        return productionApply(self,g,restart)
    end
    a.LoadGuide=productionLoad
    a.FetchGuide=function(_,g) return g end
    s.env.GetMissingGuideEntryQuest=function() end
    destination.steps={{id="one",elements={}},{id="two",elements={}}}
    data.guideProgress=data.guideProgress or {}
    data.guideProgress[destination.key]={step=2,stepId="two",group=destination.group,name=destination.name}
    local receipt=a.guideState:Load(destination,false,"selection",function(g)
        assert(g==destination and data.currentStep==2,
            "Successful callback ran before destination checkpoint restoration")
        callbacks=callbacks+1
    end)
    assert(receipt==destination and callbacks==1 and applied==1 and published==1)
    assert(scrollResets==1,"Successful load did not cancel the previous guide's pending scroll")
    -- A successful prerequisite redirect still is NOT success for the
    -- originally requested canonical guide, even when the names are identical.
    previous.disabled=nil
    previous.name=destination.name
    previous.steps={{id="previous-one",elements={}}}
    s.env.GetMissingGuideEntryQuest=function(g) if g==destination then return {788} end end
    receipt=a.guideState:Load(destination,true,"manual",function() callbacks=callbacks+1 end)
    assert(receipt==previous and a.currentGuide==previous and data.currentStep==1)
    assert(scrollResets==2,"Prerequisite destination did not reset scroll identity")
    assert(callbacks==1 and applied==1 and published==2,
        "Prerequisite redirect applied/acknowledged the original destination")
    assert(data.guideProgress[destination.key].step==2,"Redirect destroyed destination checkpoint")
    if fixtures then
        local function copy(value)
            if type(value)~="table" then return value end
            local result={}
            for k,v in pairs(value) do
                -- Parsed elements can point back to their step/guide.
                if k~="step" and k~="guide" then result[k]=copy(v) end
            end
            return result
        end
        local completionFirst=assert(source:find("function addon.UpdateStepCompletion()",1,true))
        local completionLast=assert(source:find("function ",completionFirst+10,true))
        -- The completion function has no nested function declarations.
        setfenv(assert(loadstring(source:sub(completionFirst,completionLast-1))),s.env)()
        return {
            addon=a,env=s.env,data=data,calls=s.calls,
            load=function(guide)
                local g=copy(guide)
                a.currentGuide=current
                data.currentStep=1
                a.guideState.Apply=productionApply
                a.guideState.SaveCurrent=noop
                s.env.GetMissingGuideEntryQuest=noop
                a.QueueMessage=noop
                assert(a:LoadGuide(g,true,"manual")==g,"Production loader did not load the requested label fixture")
                return g
            end
        }
    end
    print("Hardcore production load contract passed: rejected fetches, stale consent, actual success/restoration, redirects and no false callbacks.")
end
