local _, addon = ...

-- Presentation-only cache. Directive evaluation and localization still run
-- before this helper; no element state or authored text is cached here.
local layout = {}
addon.guideLayout = layout
local measurements = setmetatable({}, {__mode = "k"})
local revision = 0

function layout:Invalidate()
    revision = revision + 1
end

function layout:MeasureText(textRegion, text, force, hidden)
    if not textRegion then return 8 end
    if hidden then
        if textRegion:GetText() ~= text then
            textRegion:SetText(text)
            if addon.PerfCount then addon.PerfCount("row text writes") end
        end
        return 1
    end
    local font, size, flags = textRegion:GetFont()
    local width = textRegion:GetWidth()
    local parent = textRegion.GetParent and textRegion:GetParent()
    local scale = textRegion.GetEffectiveScale and textRegion:GetEffectiveScale() or
        (parent and parent.GetEffectiveScale and parent:GetEffectiveScale()) or 1
    local spacing = textRegion.GetSpacing and textRegion:GetSpacing() or 0
    local cache = measurements[textRegion]
    local displayed = textRegion:GetText()
    local write = displayed ~= text
    if not force and cache and not write and cache.text == text and
        cache.revision == revision and cache.font == font and
        cache.size == size and cache.flags == flags and cache.width == width and
        cache.scale == scale and cache.spacing == spacing then
        if addon.PerfCount then addon.PerfCount("row measurement hits") end
        return cache.height
    end
    if write then
        textRegion:SetText(text)
        if addon.PerfCount then addon.PerfCount("row text writes") end
    end
    local height = math.ceil(textRegion:GetStringHeight() + 8)
    if addon.PerfCount then addon.PerfCount("row measurements") end
    measurements[textRegion] = {
        text = text, revision = revision, font = font, size = size, flags = flags,
        width = width, scale = scale, spacing = spacing, height = height,
    }
    return height
end

function layout:UpdateHeight(frame, height, positions, index)
    local current = frame:GetHeight()
    -- These rows use whole-unit heights (ceil(text height + padding), but the
    -- client returns single-precision frame geometry. Normalize only values
    -- very close to an integer, otherwise identical writes drift the offsets.
    local rounded = math.floor(current + 0.5)
    if math.abs(current - rounded) < 0.01 then current = rounded end
    local difference = height - current
    if difference == 0 then return end
    if addon.PerfCount then addon.PerfCount("row height changes") end
    frame:SetHeight(height)
    for n = index + 1, #positions do positions[n] = positions[n] + difference end
    positions[0] = positions[0] + difference
    if addon.PerfCount then
        addon.PerfCount("row positions shifted", #positions - index)
    end
end
