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

-- Wrapping text must not derive its height from the row it is measuring.
-- A second vertical anchor (even RIGHT/CENTER) can clip native 3.3.5 text.
function layout:PrepareText(region, relative, point, x, y, width)
    local anchor, parent, relativePoint, oldX, oldY = region:GetPoint(1)
    if region:GetNumPoints() ~= 1 or anchor ~= "TOPLEFT" or parent ~= relative or
        relativePoint ~= point or oldX ~= x or oldY ~= y then
        region:ClearAllPoints()
        region:SetPoint("TOPLEFT", relative, point, x, y)
    end
    width = math.max(1, width)
    if region:GetWidth() ~= width then region:SetWidth(width) end
    -- GetHeight is the computed text extent, not the explicit height setting.
    region:SetHeight(0)
    if region.SetWordWrap then region:SetWordWrap(true) end
end

function layout:MeasureText(textRegion, text, force, hidden, padding, multiplier)
    padding = padding or 8
    multiplier = multiplier or 1
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
        cache.scale == scale and cache.spacing == spacing and cache.padding == padding and
        cache.multiplier == multiplier then
        if addon.PerfCount then addon.PerfCount("row measurement hits") end
        return cache.height
    end
    if write then
        textRegion:SetText(text)
        if addon.PerfCount then addon.PerfCount("row text writes") end
    end
    local height = math.ceil(textRegion:GetStringHeight() * multiplier + padding)
    if addon.PerfCount then addon.PerfCount("row measurements") end
    measurements[textRegion] = {
        text = text, revision = revision, font = font, size = size, flags = flags,
        width = width, scale = scale, spacing = spacing, height = height, padding = padding,
        multiplier = multiplier,
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
