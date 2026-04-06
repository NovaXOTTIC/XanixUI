--[[
  ██╗  ██╗ █████╗ ███╗   ██╗██╗██╗  ██╗
  ╚██╗██╔╝██╔══██╗████╗  ██║██║╚██╗██╔╝
   ╚███╔╝ ███████║██╔██╗ ██║██║ ╚███╔╝
   ██╔██╗ ██╔══██║██║╚██╗██║██║ ██╔██╗
  ██╔╝ ██╗██║  ██║██║ ╚████║██║██╔╝ ██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
  v2.2  |  Black theme. Clean. Full elements.

  local Xanix = loadstring(game:HttpGet("RAW_URL"))()
  local Win   = Xanix:CreateWindow({ Name = "My Hub" })
  local Tab   = Win:CreateTab("Combat")
  Tab:CreateButton({ Name="Go", Callback=function() end })
  Tab:CreateToggle({ Name="ESP", CurrentValue=false, Flag="esp", Callback=function(v) end })
  Tab:CreateSlider({ Name="Speed", Range={16,500}, Increment=1, CurrentValue=16, Callback=function(v) end })
  Tab:CreateInput({ Name="Target", PlaceholderText="name", Callback=function(t) end })
  Tab:CreateDropdown({ Name="Mode", Options={"A","B"}, CurrentOption={"A"}, Callback=function(o) end })
  Tab:CreateColorPicker({ Name="Color", Color=Color3.fromRGB(255,0,0), Callback=function(c) end })
  Tab:CreateKeybind({ Name="Toggle", CurrentKeybind="K", Callback=function() end })
  Tab:CreateSection("Header")
  Tab:CreateLabel("Info text")
  Tab:CreateParagraph({ Title="About", Content="Description." })
  Xanix:Notify({ Title="Hello", Content="World", Duration=4 })
]]

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer
local PG           = LP:WaitForChild("PlayerGui")

local Xanix = { Flags = {} }
Xanix.__index = Xanix

-- ─── THEME ── pure black, white text, gray accents ───────────────────────────
local T = {
    Panel       = Color3.fromRGB(0,   0,   0),
    PanelAlpha  = 0.30,
    Row         = Color3.fromRGB(18,  18,  18),
    RowHover    = Color3.fromRGB(26,  26,  26),
    TitleBg     = Color3.fromRGB(0,   0,   0),
    TitleAlpha  = 0.45,
    Border      = Color3.fromRGB(55,  55,  55),
    BorderAlpha = 0,
    TabBg       = Color3.fromRGB(83,  83,  83),
    TabAlpha    = 0.45,
    TabActiveA  = 0.15,
    TabActiveBg = Color3.fromRGB(200, 200, 200),
    Text        = Color3.fromRGB(240, 240, 240),
    TextDim     = Color3.fromRGB(160, 160, 165),
    TextMuted   = Color3.fromRGB(90,  90,  95),
    SecText     = Color3.fromRGB(65,  65,  70),
    Accent      = Color3.fromRGB(180, 180, 185),
    TrackOff    = Color3.fromRGB(38,  38,  40),
    TrackOn     = Color3.fromRGB(190, 190, 195),
    Thumb       = Color3.fromRGB(240, 240, 245),
    SliderTrack = Color3.fromRGB(22,  22,  24),
    SliderFill  = Color3.fromRGB(180, 180, 185),
    InputBg     = Color3.fromRGB(12,  12,  14),
    GearBg      = Color3.fromRGB(30,  30,  32),
    GearIcon    = Color3.fromRGB(180, 180, 185),
    DotRed      = Color3.fromRGB(255, 95,  87),
    DotYellow   = Color3.fromRGB(255, 189, 46),
    DotGreen    = Color3.fromRGB(40,  200, 64),
}

local TI_FAST  = TweenInfo.new(0.13, Enum.EasingStyle.Quad,        Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.22, Enum.EasingStyle.Quad,        Enum.EasingDirection.Out)
local TI_QUART = TweenInfo.new(0.24, Enum.EasingStyle.Quart,       Enum.EasingDirection.Out)
local TI_EXP   = TweenInfo.new(0.36, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function tw(o, p, ti) TweenService:Create(o, ti or TI_FAST, p):Play() end

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function stroke(p, col, alpha, thick, mode)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Border; s.Transparency = alpha or T.BorderAlpha; s.Thickness = thick or 1
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round; s.Parent = p; return s
end
local function pad(p, l, r, t, b)
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft = UDim.new(0, l or 0); pd.PaddingRight = UDim.new(0, r or 0)
    pd.PaddingTop = UDim.new(0, t or 0); pd.PaddingBottom = UDim.new(0, b or 0); pd.Parent = p
end
local function list(p, sp)
    local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0, sp or 4)
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.FillDirection = Enum.FillDirection.Vertical; l.Parent = p; return l
end
local function fr(parent, bg, alpha, size, pos)
    local f = Instance.new("Frame"); f.BackgroundColor3 = bg or Color3.new()
    f.BackgroundTransparency = alpha or 0; f.BorderSizePixel = 0
    f.Size = size or UDim2.new(1,0,1,0); f.Position = pos or UDim2.new(); f.Parent = parent; return f
end
local function lbl(parent, txt, sz, col, font, xa)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1
    l.Text = txt or ""; l.TextSize = sz or 13; l.Font = font or Enum.Font.GothamMedium
    l.TextColor3 = col or T.Text; l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center; l.TextWrapped = true
    l.Size = UDim2.new(1,0,1,0); l.Parent = parent; return l
end

-- ─── NOTIFICATION SYSTEM ─── uses exact Notii template structure ─────────────
local _notiiSg, _notiList

local function ensureNotii()
    if _notiiSg and _notiiSg.Parent then return end
    _notiiSg = Instance.new("ScreenGui")
    _notiiSg.Name = "Notii"; _notiiSg.ResetOnSpawn = true
    _notiiSg.IgnoreGuiInset = false; _notiiSg.DisplayOrder = 200; _notiiSg.Parent = PG

    _notiList = Instance.new("Frame")
    _notiList.Name = "NotiList"
    _notiList.Position = UDim2.new(0.850801468, 0, 0, 0)
    _notiList.Size = UDim2.new(0, 238, 0, 793)
    _notiList.BackgroundTransparency = 1; _notiList.BorderSizePixel = 0
    _notiList.ClipsDescendants = false; _notiList.Parent = _notiiSg
    local ll = list(_notiList, 6)
    ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

function Xanix:Notify(data)
    task.spawn(function()
        ensureNotii(); data = data or {}
        local dur = data.Duration or 4
        local text = (data.Title and data.Content)
            and (data.Title .. "  ·  " .. data.Content)
            or (data.Title or data.Content or "Notification")

        -- NotiTemplate style
        local card = Instance.new("TextLabel")
        card.Name = "NotiTemplate"
        card.Size = UDim2.new(0, 225, 0, 0)
        card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        card.BackgroundTransparency = 1
        card.Text = text
        card.TextScaled = false; card.TextSize = 14
        card.Font = Enum.Font.GothamMedium
        card.TextColor3 = Color3.fromRGB(255, 255, 255)
        card.TextTransparency = 1
        card.TextWrapped = true; card.TextXAlignment = Enum.TextXAlignment.Center
        card.TextYAlignment = Enum.TextYAlignment.Center
        card.ClipsDescendants = false; card.BorderSizePixel = 0
        card.Parent = _notiList

        -- corner radius 1000 (pill) per template
        local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(0, 1000); uc.Parent = card

        -- inner stroke (contextual)
        local s1 = Instance.new("UIStroke"); s1.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        s1.Color = Color3.new(); s1.Thickness = 2; s1.Transparency = 1; s1.Parent = card

        -- border stroke
        local s2 = Instance.new("UIStroke"); s2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s2.Color = Color3.new(); s2.Thickness = 2; s2.Transparency = 1; s2.Parent = card

        task.wait()
        -- size to content
        local th = math.max(card.TextBounds.Y + 20, 50)
        card.Size = UDim2.new(0, 225, 0, th)

        tw(card, { BackgroundTransparency = 0.45, TextTransparency = 0 }, TI_EXP)
        tw(s1,   { Transparency = 0 }, TI_EXP)
        tw(s2,   { Transparency = 0 }, TI_EXP)

        task.wait(dur)
        tw(card, { BackgroundTransparency = 1, TextTransparency = 1 }, TI_EXP)
        tw(s1,   { Transparency = 1 }, TI_EXP)
        tw(s2,   { Transparency = 1 }, TI_EXP)
        task.wait(0.40); card:Destroy()
    end)
end

-- ─── CREATE WINDOW ───────────────────────────────────────────────────────────
function Xanix:CreateWindow(cfg)
    cfg = cfg or {}

    local sg = Instance.new("ScreenGui")
    sg.Name = "Window"; sg.ResetOnSpawn = true; sg.IgnoreGuiInset = false
    sg.DisplayOrder = 100; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.Parent = PG

    -- All 4 moveable panels
    -- SEARCH BAR
    local searchBar = Instance.new("TextBox"); searchBar.Name = "SearchBar"
    searchBar.Position = UDim2.new(0.2046, 0, 0.1765, 0); searchBar.Size = UDim2.new(0.0709, 0, 0.0441, 0)
    searchBar.BackgroundColor3 = T.Panel; searchBar.BackgroundTransparency = T.PanelAlpha
    searchBar.Text = ""; searchBar.PlaceholderText = "  Search tabs"
    searchBar.TextSize = 12; searchBar.Font = Enum.Font.GothamMedium
    searchBar.TextColor3 = T.Text; searchBar.PlaceholderColor3 = T.TextMuted
    searchBar.TextXAlignment = Enum.TextXAlignment.Left; searchBar.ClearTextOnFocus = false
    searchBar.MultiLine = false; searchBar.BorderSizePixel = 0; searchBar.Parent = sg
    corner(searchBar, 6); stroke(searchBar, T.Border, T.BorderAlpha, 1, Enum.ApplyStrokeMode.Contextual)
    pad(searchBar, 10, 10, 0, 0)

    -- TAB LIST
    local tabSF = Instance.new("ScrollingFrame"); tabSF.Name = "TabList"
    tabSF.Position = UDim2.new(0.2053, 0, 0.2308, 0); tabSF.Size = UDim2.new(0.0709, 0, 0.4136, 0)
    tabSF.BackgroundColor3 = T.Panel; tabSF.BackgroundTransparency = T.PanelAlpha
    tabSF.BorderSizePixel = 0; tabSF.ClipsDescendants = true
    tabSF.CanvasSize = UDim2.new(0,0,0,0); tabSF.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabSF.ScrollBarThickness = 2; tabSF.ScrollBarImageColor3 = T.Accent
    tabSF.ScrollingDirection = Enum.ScrollingDirection.Y; tabSF.Parent = sg
    corner(tabSF, 8); stroke(tabSF, T.Border, T.BorderAlpha, 1, Enum.ApplyStrokeMode.Contextual)
    list(tabSF, 3); pad(tabSF, 5, 5, 5, 5)

    -- SETTINGS BUTTON
    local setF = fr(sg, T.Panel, T.PanelAlpha, UDim2.new(0.0465, 0, 0.0668, 0), UDim2.new(0.2169, 0, 0.6539, 0))
    setF.Name = "Settings"; corner(setF, 8); stroke(setF, T.Border, T.BorderAlpha, 1)
    local gearBtn = Instance.new("ImageButton"); gearBtn.Name = "ImageButton"
    gearBtn.Position = UDim2.new(0.127, 0, 0.075, 0); gearBtn.Size = UDim2.new(0.723, 0, 0.849, 0)
    gearBtn.BackgroundColor3 = T.GearBg; gearBtn.BackgroundTransparency = 0
    gearBtn.Image = "rbxassetid://5540166883"; gearBtn.ScaleType = Enum.ScaleType.Fit
    gearBtn.ImageColor3 = T.GearIcon; gearBtn.AutoButtonColor = false; gearBtn.Parent = setF
    corner(gearBtn, 6); stroke(gearBtn, T.Border, T.BorderAlpha, 1, Enum.ApplyStrokeMode.Contextual)
    gearBtn.MouseEnter:Connect(function() tw(gearBtn, { BackgroundColor3 = Color3.fromRGB(50,50,52), ImageColor3 = T.Text }) end)
    gearBtn.MouseLeave:Connect(function() tw(gearBtn, { BackgroundColor3 = T.GearBg, ImageColor3 = T.GearIcon }) end)

    -- CONTENT FRAME
    local contentF = Instance.new("ScrollingFrame"); contentF.Name = "Content"
    contentF.Position = UDim2.new(0.2804, 0, 0.1765, 0); contentF.Size = UDim2.new(0.4055, 0, 0.5448, 0)
    contentF.BackgroundColor3 = T.Panel; contentF.BackgroundTransparency = T.PanelAlpha
    contentF.BorderSizePixel = 0; contentF.ClipsDescendants = true
    contentF.CanvasSize = UDim2.new(0,0,0,0); contentF.AutomaticCanvasSize = Enum.AutomaticSize.None
    contentF.ScrollBarThickness = 0; contentF.ScrollingEnabled = false; contentF.Parent = sg
    corner(contentF, 8); stroke(contentF, T.Border, T.BorderAlpha, 1, Enum.ApplyStrokeMode.Contextual)

    -- Title bar
    local titleBar = fr(contentF, T.TitleBg, T.TitleAlpha, UDim2.new(1,0,0,36)); titleBar.ZIndex = 2
    fr(titleBar, T.Border, 0.4, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1))
    for i,dc in ipairs({ T.DotRed, T.DotYellow, T.DotGreen }) do
        local d = fr(titleBar, dc, 0, UDim2.fromOffset(10,10), UDim2.fromOffset(10+(i-1)*16, 13)); corner(d, 5)
    end
    local winTitleLbl = lbl(titleBar, cfg.Name or "Xanix", 13, T.Text, Enum.Font.GothamBold)
    winTitleLbl.Size = UDim2.new(1,-100,1,0); winTitleLbl.Position = UDim2.fromOffset(64,0)

    -- Minimise/expand button
    local minimised = false
    local allPanels = { searchBar, tabSF, setF, contentF }

    local minBtn = Instance.new("TextButton"); minBtn.Size = UDim2.fromOffset(24,18)
    minBtn.Position = UDim2.new(1,-30,0.5,-9); minBtn.BackgroundColor3 = Color3.new(1,1,1)
    minBtn.BackgroundTransparency = 0.88; minBtn.BorderSizePixel = 0; minBtn.Text = "–"; minBtn.TextSize = 13
    minBtn.Font = Enum.Font.GothamBold; minBtn.TextColor3 = T.TextDim
    minBtn.AutoButtonColor = false; minBtn.ZIndex = 3; minBtn.Parent = titleBar; corner(minBtn, 4)
    minBtn.MouseEnter:Connect(function() tw(minBtn, { BackgroundTransparency = 0.60 }) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn, { BackgroundTransparency = 0.88 }) end)
    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            -- Shrink content to just the title bar
            tw(contentF, { Size = UDim2.new(0.4055, 0, 0, 36) }, TI_MED)
            -- Shrink tab list and search and settings to 0 height / hidden
            tw(tabSF,      { Size = UDim2.new(0.0709, 0, 0, 0)      }, TI_MED)
            tw(searchBar,  { Size = UDim2.new(0.0709, 0, 0, 0)      }, TI_MED)
            tw(setF,       { Size = UDim2.new(0.0465, 0, 0, 0)      }, TI_MED)
            minBtn.Text = "+"
        else
            tw(contentF, { Size = UDim2.new(0.4055, 0, 0.5448, 0)   }, TI_MED)
            tw(tabSF,    { Size = UDim2.new(0.0709, 0, 0.4136, 0)   }, TI_MED)
            tw(searchBar,{ Size = UDim2.new(0.0709, 0, 0.0441, 0)   }, TI_MED)
            tw(setF,     { Size = UDim2.new(0.0465, 0, 0.0668, 0)   }, TI_MED)
            minBtn.Text = "–"
        end
    end)

    -- Pages container
    local pagesC = fr(contentF, Color3.new(), 1, UDim2.new(1,0,1,-36), UDim2.fromOffset(0,36))
    pagesC.ClipsDescendants = true

    -- ─── TAB STATE ────────────────────────────────────────────────────────────
    local tabs = {}; local activeTab = nil
    local function switchTab(t)
        if activeTab == t then return end
        for _, v in ipairs(tabs) do
            v.page.Visible = false
            tw(v.btn, { BackgroundColor3 = T.TabBg, BackgroundTransparency = T.TabAlpha, TextColor3 = T.TextDim })
            if v.pip then tw(v.pip, { BackgroundTransparency = 1 }) end
        end
        t.page.Visible = true
        tw(t.btn, { BackgroundColor3 = T.TabActiveBg, BackgroundTransparency = T.TabActiveA, TextColor3 = T.Text })
        if t.pip then tw(t.pip, { BackgroundTransparency = 0 }) end
        activeTab = t
    end
    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBar.Text:lower()
        for _, t in ipairs(tabs) do t.btn.Visible = (q == "" or t.name:lower():find(q,1,true) ~= nil) end
    end)

    -- ─── DRAGGING ─────────────────────────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, {}
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = Vector2.new(i.Position.X, i.Position.Y); startPos = {}
            for _, obj in ipairs(allPanels) do startPos[obj] = obj.Position end
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local vp = sg.AbsoluteSize
        local dx = (i.Position.X - dragStart.X) / vp.X; local dy = (i.Position.Y - dragStart.Y) / vp.Y
        for _, obj in ipairs(allPanels) do
            local sp = startPos[obj]
            obj.Position = UDim2.new(sp.X.Scale + dx, sp.X.Offset, sp.Y.Scale + dy, sp.Y.Offset)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- ─── TOGGLE KEY (K) ───────────────────────────────────────────────────────
    local hidden = false
    local toggleKey = cfg.ToggleUIKeybind or "K"
    if typeof(toggleKey) == "EnumItem" then toggleKey = toggleKey.Name end
    UIS.InputBegan:Connect(function(i, p)
        if p then return end
        local kname = string.split(tostring(i.KeyCode), ".")[3]
        if kname == tostring(toggleKey) then
            hidden = not hidden
            for _, obj in ipairs(allPanels) do
                tw(obj, { BackgroundTransparency = hidden and 1 or T.PanelAlpha }, TI_MED)
            end
            if hidden then sg.Enabled = false else sg.Enabled = true end
        end
    end)

    -- ─── WINDOW API ───────────────────────────────────────────────────────────
    local Window = {}

    function Window:CreateTab(name, _icon)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,28); btn.BackgroundColor3 = T.TabBg
        btn.BackgroundTransparency = T.TabAlpha; btn.BorderSizePixel = 0
        btn.Text = name; btn.TextSize = 11; btn.Font = Enum.Font.GothamMedium
        btn.TextColor3 = T.TextDim; btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextWrapped = false; btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.AutoButtonColor = false; btn.LayoutOrder = #tabs + 1; btn.Parent = tabSF
        corner(btn, 6); stroke(btn, T.Border, T.BorderAlpha, 1); pad(btn, 22, 6, 0, 0)

        local pip = fr(btn, T.Accent, 1, UDim2.fromOffset(2, 12), UDim2.new(0,-1,0.5,-6))
        pip.ZIndex = 2; corner(pip, 2)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
        page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = T.Accent
        page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollingDirection = Enum.ScrollingDirection.Y; page.Visible = false; page.Parent = pagesC
        list(page, 4); pad(page, 7, 7, 7, 7)

        local t = { name = name, btn = btn, pip = pip, page = page }
        table.insert(tabs, t)
        btn.MouseEnter:Connect(function()
            if activeTab ~= t then tw(btn, { BackgroundTransparency = T.TabAlpha - 0.10, TextColor3 = T.Text }) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= t then tw(btn, { BackgroundTransparency = T.TabAlpha, TextColor3 = T.TextDim }) end
        end)
        btn.MouseButton1Click:Connect(function() switchTab(t) end)
        if #tabs == 1 then switchTab(t) end

        local function row(h, noHover)
            local f = fr(page, T.Row, 0, UDim2.new(1,0,0,h or 36)); corner(f, 6); stroke(f, T.Border, T.BorderAlpha, 1)
            if not noHover then
                f.MouseEnter:Connect(function() tw(f, { BackgroundColor3 = T.RowHover }) end)
                f.MouseLeave:Connect(function() tw(f, { BackgroundColor3 = T.Row      }) end)
            end
            return f
        end

        local Tab = {}

        ---------------------------------------------------------------- SECTION
        function Tab:CreateSection(sname)
            local f = fr(page, Color3.new(), 1, UDim2.new(1,0,0,18)); pad(f, 4,4,0,0)
            fr(f, T.Border, 0.55, UDim2.new(0.32,-6,0,1), UDim2.fromOffset(0, 9))
            fr(f, T.Border, 0.55, UDim2.new(0.32,-6,0,1), UDim2.new(0.68,6,0,9))
            local lb = lbl(f, (sname or ""):upper(), 9, T.SecText, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            local sv = {}; function sv:Set(n) lb.Text = (n or ""):upper() end; return sv
        end

        ---------------------------------------------------------------- LABEL
        function Tab:CreateLabel(txt, _, col)
            local f = row(28, true)
            local lb = lbl(f, txt or "", 12, col or T.TextDim, Enum.Font.Gotham)
            lb.Size = UDim2.new(1,-16,1,0); lb.Position = UDim2.fromOffset(9,0)
            local lv = {}; function lv:Set(nt,_,nc) lb.Text=nt or "" if nc then lb.TextColor3=nc end end; return lv
        end

        ---------------------------------------------------------------- PARAGRAPH
        function Tab:CreateParagraph(s)
            local f = row(nil, true); f.AutomaticSize = Enum.AutomaticSize.Y
            local tl = Instance.new("TextLabel"); tl.BackgroundTransparency=1; tl.Text=s.Title or ""
            tl.TextSize=13; tl.Font=Enum.Font.GothamBold; tl.TextColor3=T.Text
            tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Size=UDim2.new(1,-18,0,18); tl.Position=UDim2.fromOffset(9,6); tl.Parent=f
            local cl = Instance.new("TextLabel"); cl.BackgroundTransparency=1; cl.Text=s.Content or ""
            cl.TextSize=12; cl.Font=Enum.Font.Gotham; cl.TextColor3=T.TextDim
            cl.TextXAlignment=Enum.TextXAlignment.Left; cl.TextWrapped=true; cl.AutomaticSize=Enum.AutomaticSize.Y
            cl.Size=UDim2.new(1,-18,0,0); cl.Position=UDim2.fromOffset(9,26); cl.Parent=f
            local pv = {}; function pv:Set(ns) tl.Text=ns.Title or ""; cl.Text=ns.Content or "" end; return pv
        end

        ---------------------------------------------------------------- BUTTON
        function Tab:CreateButton(s)
            local f = row(34)
            local b = Instance.new("TextButton"); b.Size=UDim2.new(1,0,1,0); b.BackgroundTransparency=1
            b.Text=s.Name or "Button"; b.TextSize=13; b.Font=Enum.Font.GothamMedium; b.TextColor3=T.Text
            b.TextXAlignment=Enum.TextXAlignment.Left; b.AutoButtonColor=false; b.Parent=f; pad(b,9,9,0,0)
            b.MouseButton1Click:Connect(function()
                tw(f, { BackgroundColor3 = Color3.fromRGB(35,35,37) }, TI_FAST)
                task.delay(0.15, function() tw(f, { BackgroundColor3 = T.Row }, TI_MED) end)
                if s.Callback then task.spawn(pcall, s.Callback) end
            end)
            local bv = {}; function bv:Set(n) b.Text=n end; return bv
        end

        ---------------------------------------------------------------- TOGGLE
        function Tab:CreateToggle(s)
            local state = s.CurrentValue == true; local f = row(34)
            local lb = lbl(f, s.Name or "Toggle", 13, T.Text)
            lb.Size = UDim2.new(1,-56,1,0); lb.Position = UDim2.fromOffset(9,0)
            local track = fr(f, state and T.TrackOn or T.TrackOff, 0, UDim2.fromOffset(40,21), UDim2.new(1,-48,0.5,-10))
            corner(track, 11); stroke(track, T.Border, 0.4, 1)
            local thumb = fr(track, T.Thumb, 0, UDim2.fromOffset(16,16), state and UDim2.fromOffset(21,2) or UDim2.fromOffset(3,2))
            corner(thumb, 9); s.CurrentValue = state
            local function setState(v)
                state=v; s.CurrentValue=v; tw(track, { BackgroundColor3=v and T.TrackOn or T.TrackOff })
                tw(thumb, { Position=v and UDim2.fromOffset(21,2) or UDim2.fromOffset(3,2) }, TI_QUART)
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            local cl=Instance.new("TextButton"); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1
            cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f; cl.MouseButton1Click:Connect(function() setState(not state) end)
            function s:Set(v) setState(v) end; if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        ---------------------------------------------------------------- SLIDER
        function Tab:CreateSlider(s)
            local mn=(s.Range and s.Range[1]) or 0; local mx=(s.Range and s.Range[2]) or 100
            local inc=s.Increment or 1; local val=math.clamp(s.CurrentValue or mn, mn, mx)
            local suf=s.Suffix and (" "..s.Suffix) or ""; local f=row(50)
            local function fmt(v) local r=math.floor(v/inc+0.5)*inc
                return (math.floor(r)==r and tostring(math.floor(r)) or string.format("%.2f",r))..suf end
            local nl=lbl(f,s.Name or "Slider",13,T.Text); nl.Size=UDim2.new(0.55,0,0,20); nl.Position=UDim2.fromOffset(9,3)
            local vl=lbl(f,fmt(val),12,T.TextDim,Enum.Font.Gotham,Enum.TextXAlignment.Right)
            vl.Size=UDim2.new(0.43,-9,0,20); vl.Position=UDim2.new(0.55,0,0,3); pad(vl,0,8,0,0)
            local tBg=fr(f,T.SliderTrack,0,UDim2.new(1,-18,0,4),UDim2.new(0,9,1,-11)); corner(tBg,2)
            local p0=(val-mn)/(mx-mn)
            local fill=fr(tBg,T.SliderFill,0,UDim2.new(p0,0,1,0)); corner(fill,2)
            local knob=fr(tBg,T.Thumb,0,UDim2.fromOffset(12,12),UDim2.new(p0,-6,0.5,-6))
            knob.ZIndex=2; corner(knob,6); stroke(knob,T.Border,0.3,1); s.CurrentValue=val
            local sliding=false
            local function upd(px)
                local abs,sz=tBg.AbsolutePosition,tBg.AbsoluteSize
                local pct=math.clamp((px-abs.X)/sz.X,0,1)
                local nv=math.floor((mn+pct*(mx-mn))/inc+0.5)*inc; nv=math.clamp(nv,mn,mx)
                s.CurrentValue=nv; vl.Text=fmt(nv); local p2=(nv-mn)/(mx-mn)
                tw(fill,{Size=UDim2.new(p2,0,1,0)}); tw(knob,{Position=UDim2.new(p2,-6,0.5,-6)})
                if s.Callback then task.spawn(pcall,s.Callback,nv) end
            end
            tBg.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true; upd(i.Position.X) end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)
            function s:Set(v) v=math.clamp(v,mn,mx); local p2=(v-mn)/(mx-mn); s.CurrentValue=v; vl.Text=fmt(v)
                tw(fill,{Size=UDim2.new(p2,0,1,0)}); tw(knob,{Position=UDim2.new(p2,-6,0.5,-6)}) end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        ---------------------------------------------------------------- INPUT
        function Tab:CreateInput(s)
            local f=row(52)
            local nl=lbl(f,s.Name or "Input",11,T.TextMuted,Enum.Font.GothamBold); nl.Size=UDim2.new(1,0,0,16); nl.Position=UDim2.fromOffset(9,4)
            local ibg=fr(f,T.InputBg,0,UDim2.new(1,-18,0,21),UDim2.fromOffset(9,24)); corner(ibg,5); stroke(ibg,T.Border,T.BorderAlpha,1,Enum.ApplyStrokeMode.Contextual)
            local tb=Instance.new("TextBox"); tb.Size=UDim2.new(1,-12,1,0); tb.Position=UDim2.fromOffset(6,0)
            tb.BackgroundTransparency=1; tb.Text=s.CurrentValue or ""; tb.PlaceholderText=s.PlaceholderText or "Enter value"
            tb.TextSize=12; tb.Font=Enum.Font.Gotham; tb.TextColor3=T.Text; tb.PlaceholderColor3=T.TextMuted
            tb.TextXAlignment=Enum.TextXAlignment.Left; tb.ClearTextOnFocus=false; tb.MultiLine=false; tb.BorderSizePixel=0; tb.Parent=ibg
            tb.Focused:Connect(function() tw(ibg,{BackgroundColor3=Color3.fromRGB(22,22,24)}) end)
            tb.FocusLost:Connect(function() tw(ibg,{BackgroundColor3=T.InputBg}); s.CurrentValue=tb.Text
                if s.Callback then task.spawn(pcall,s.Callback,tb.Text) end
                if s.RemoveTextAfterFocusLost then tb.Text="" end
            end)
            function s:Set(v) tb.Text=v; s.CurrentValue=v end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        ---------------------------------------------------------------- DROPDOWN
        -- Uses a ScreenGui overlay so it never goes behind anything
        function Tab:CreateDropdown(s)
            local opts=s.Options or {}; local multi=s.MultipleOptions==true
            if s.CurrentOption then if type(s.CurrentOption)=="string" then s.CurrentOption={s.CurrentOption} end
            else s.CurrentOption={} end
            if not multi then s.CurrentOption={s.CurrentOption[1]} end
            local open=false

            local f=row(34)
            local nl=lbl(f,s.Name or "Dropdown",13,T.Text); nl.Size=UDim2.new(0.47,0,1,0); nl.Position=UDim2.fromOffset(9,0)

            local selBtn=Instance.new("TextButton"); selBtn.Size=UDim2.new(0.47,-8,0,20); selBtn.Position=UDim2.new(0.49,2,0.5,-10)
            selBtn.BackgroundColor3=T.InputBg; selBtn.BackgroundTransparency=0; selBtn.BorderSizePixel=0
            selBtn.AutoButtonColor=false; selBtn.TextSize=11; selBtn.Font=Enum.Font.GothamMedium; selBtn.TextColor3=T.Text; selBtn.Parent=f
            corner(selBtn,4); stroke(selBtn,T.Border,T.BorderAlpha,1,Enum.ApplyStrokeMode.Contextual)

            local function selText() if #s.CurrentOption==0 then return "None" elseif #s.CurrentOption==1 then return s.CurrentOption[1] else return "Various" end end
            selBtn.Text=selText().."  ▾"

            -- Overlay ScreenGui for dropdown (renders on top of everything)
            local ddOverlaySg = Instance.new("ScreenGui"); ddOverlaySg.Name="XanixDD"
            ddOverlaySg.ResetOnSpawn=false; ddOverlaySg.IgnoreGuiInset=false
            ddOverlaySg.DisplayOrder=999; ddOverlaySg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
            ddOverlaySg.Enabled=false; ddOverlaySg.Parent=PG

            local ddF=fr(ddOverlaySg,T.InputBg,0.04,UDim2.fromOffset(0,0))
            ddF.ClipsDescendants=true; corner(ddF,6); stroke(ddF,T.Border,T.BorderAlpha,1,Enum.ApplyStrokeMode.Contextual)

            local ddSF=Instance.new("ScrollingFrame"); ddSF.Size=UDim2.new(1,0,1,0); ddSF.BackgroundTransparency=1
            ddSF.BorderSizePixel=0; ddSF.ScrollBarThickness=2; ddSF.ScrollBarImageColor3=T.Accent
            ddSF.CanvasSize=UDim2.new(0,0,0,0); ddSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; ddSF.Parent=ddF
            list(ddSF,2); pad(ddSF,4,4,4,4)

            local function closeDD() open=false; ddOverlaySg.Enabled=false end
            local function openDD()
                open=true
                -- Position overlay at the selBtn's screen position
                local abs=selBtn.AbsolutePosition; local sz=selBtn.AbsoluteSize
                local vp=sg.AbsoluteSize
                local itemH=24; local visItems=math.min(#opts,5)
                local menuH=visItems*itemH+(visItems-1)*2+8
                ddF.Size=UDim2.fromOffset(sz.X, menuH)
                local yPos=abs.Y+sz.Y+3
                if yPos+menuH > vp.Y then yPos=abs.Y-menuH-3 end
                ddF.Position=UDim2.fromOffset(abs.X, yPos)
                ddOverlaySg.Enabled=true
            end

            local function buildOpts()
                for _,c in ipairs(ddSF:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,opt in ipairs(opts) do
                    local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,24); ob.BackgroundColor3=Color3.new(1,1,1)
                    ob.BackgroundTransparency=0.90; ob.BorderSizePixel=0; ob.Text=opt; ob.TextSize=12
                    ob.Font=Enum.Font.Gotham; ob.TextColor3=T.Text; ob.AutoButtonColor=false; ob.Parent=ddSF; corner(ob,4)
                    if table.find(s.CurrentOption,opt) then ob.BackgroundTransparency=0.72; ob.TextColor3=T.Text end
                    ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0.72}) end)
                    ob.MouseLeave:Connect(function() tw(ob,{BackgroundTransparency=table.find(s.CurrentOption,opt) and 0.72 or 0.90}) end)
                    ob.MouseButton1Click:Connect(function()
                        if not multi then s.CurrentOption={opt}; selBtn.Text=opt.."  ▾"; closeDD()
                        else local idx=table.find(s.CurrentOption,opt)
                            if idx then table.remove(s.CurrentOption,idx); tw(ob,{BackgroundTransparency=0.90}); ob.TextColor3=T.Text
                            else table.insert(s.CurrentOption,opt); tw(ob,{BackgroundTransparency=0.72}); ob.TextColor3=T.Text end
                            selBtn.Text=selText().."  ▾"
                        end
                        if s.Callback then task.spawn(pcall,s.Callback,s.CurrentOption) end
                    end)
                end
            end
            buildOpts()

            selBtn.MouseButton1Click:Connect(function() if open then closeDD() else openDD() end end)
            -- Close when clicking outside
            UIS.InputBegan:Connect(function(i)
                if open and i.UserInputType==Enum.UserInputType.MouseButton1 then
                    local mp=UIS:GetMouseLocation()
                    local abs2=ddF.AbsolutePosition; local sz2=ddF.AbsoluteSize
                    if mp.X<abs2.X or mp.X>abs2.X+sz2.X or mp.Y<abs2.Y or mp.Y>abs2.Y+sz2.Y then closeDD() end
                end
            end)

            function s:Set(v) if type(v)=="string" then v={v} end; s.CurrentOption=v; selBtn.Text=selText().."  ▾"
                if s.Callback then task.spawn(pcall,s.Callback,v) end end
            function s:Refresh(newOpts) s.Options=newOpts; opts=newOpts; buildOpts() end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        ---------------------------------------------------------------- KEYBIND
        function Tab:CreateKeybind(s)
            local checking=false; local f=row(34)
            local nl=lbl(f,s.Name or "Keybind",13,T.Text); nl.Size=UDim2.new(0.55,0,1,0); nl.Position=UDim2.fromOffset(9,0)
            local kbg=fr(f,T.InputBg,0,UDim2.new(0.38,-8,0,20),UDim2.new(0.57,2,0.5,-10))
            corner(kbg,4); stroke(kbg,T.Border,T.BorderAlpha,1,Enum.ApplyStrokeMode.Contextual)
            local ktb=Instance.new("TextBox"); ktb.Size=UDim2.new(1,-10,1,0); ktb.Position=UDim2.fromOffset(5,0)
            ktb.BackgroundTransparency=1; ktb.Text=s.CurrentKeybind or "None"; ktb.TextSize=12
            ktb.Font=Enum.Font.GothamMedium; ktb.TextColor3=T.TextDim
            ktb.TextXAlignment=Enum.TextXAlignment.Center; ktb.ClearTextOnFocus=false; ktb.BorderSizePixel=0; ktb.Parent=kbg
            ktb.Focused:Connect(function() checking=true; ktb.Text=""; tw(kbg,{BackgroundColor3=Color3.fromRGB(22,22,24)}) end)
            ktb.FocusLost:Connect(function() checking=false; tw(kbg,{BackgroundColor3=T.InputBg})
                if ktb.Text=="" then ktb.Text=s.CurrentKeybind or "None" end end)
            UIS.InputBegan:Connect(function(i,p)
                if p then return end
                if checking then if i.KeyCode~=Enum.KeyCode.Unknown then
                    local kn=string.split(tostring(i.KeyCode),".")[3]; ktb.Text=kn; s.CurrentKeybind=kn; ktb:ReleaseFocus()
                    if s.CallOnChange and s.Callback then task.spawn(pcall,s.Callback,kn) end end
                elseif not s.HoldToInteract and s.CurrentKeybind and i.KeyCode==Enum.KeyCode[s.CurrentKeybind] then
                    if s.Callback then task.spawn(pcall,s.Callback) end end
            end)
            function s:Set(v) s.CurrentKeybind=v; ktb.Text=v
                if s.CallOnChange and s.Callback then task.spawn(pcall,s.Callback,v) end end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        ---------------------------------------------------------------- COLOR PICKER
        -- Uses a ScreenGui overlay so it renders above all other elements
        function Tab:CreateColorPicker(s)
            local cc=s.Color or Color3.fromRGB(255,0,0); local h,sv_s,sv_v=Color3.toHSV(cc); local open=false
            local f=row(34)
            local nl=lbl(f,s.Name or "Color",13,T.Text); nl.Size=UDim2.new(1,-48,1,0); nl.Position=UDim2.fromOffset(9,0)
            local swatch=fr(f,cc,0,UDim2.fromOffset(30,18),UDim2.new(1,-38,0.5,-9)); corner(swatch,4); stroke(swatch,T.Border,T.BorderAlpha,1)

            -- Overlay ScreenGui for color picker
            local cpSg=Instance.new("ScreenGui"); cpSg.Name="XanixCP"
            cpSg.ResetOnSpawn=false; cpSg.IgnoreGuiInset=false
            cpSg.DisplayOrder=998; cpSg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
            cpSg.Enabled=false; cpSg.Parent=PG

            local pW=210; local svW=pW-38; local svH=130
            local pp=fr(cpSg,T.InputBg,0.04,UDim2.fromOffset(pW, svH+26))
            corner(pp,8); stroke(pp,T.Border,T.BorderAlpha,1)

            local svB=fr(pp,Color3.fromHSV(h,1,1),0,UDim2.fromOffset(svW,svH),UDim2.fromOffset(8,10)); corner(svB,4)
            local function mkGrad(par,rot,cs,ts)
                local fg=fr(par,Color3.new(),1); fg.ZIndex=2
                local g=Instance.new("UIGradient"); g.Color=cs; g.Rotation=rot; if ts then g.Transparency=ts end; g.Parent=fg
            end
            mkGrad(svB,0,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkGrad(svB,90,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new()),ColorSequenceKeypoint.new(1,Color3.new())}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))
            local svCur=fr(svB,Color3.new(1,1,1),0,UDim2.fromOffset(10,10),UDim2.new(sv_s,-5,1-sv_v,-5))
            svCur.ZIndex=4; corner(svCur,5); stroke(svCur,Color3.new(),0,1)

            local hBar=fr(pp,Color3.new(1,1,1),0,UDim2.fromOffset(16,svH),UDim2.fromOffset(svW+14,10)); corner(hBar,3)
            local hg=Instance.new("UIGradient"); hg.Rotation=90
            hg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(0,1,1))}); hg.Parent=hBar
            local hCur=fr(hBar,Color3.new(1,1,1),0,UDim2.new(1,6,0,5),UDim2.new(-0.15,0,h,-2)); hCur.ZIndex=4; corner(hCur,2); stroke(hCur,Color3.new(),0,1)

            local function updColor()
                cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end
            end

            local function positionPopup()
                local abs=f.AbsolutePosition; local vp=sg.AbsoluteSize
                local yPos=abs.Y+34+4
                if yPos+svH+26 > vp.Y then yPos=abs.Y-svH-26-4 end
                pp.Position=UDim2.fromOffset(abs.X, yPos)
            end

            local cl=Instance.new("TextButton"); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1
            cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f
            cl.MouseButton1Click:Connect(function()
                open=not open; positionPopup(); cpSg.Enabled=open
            end)

            local svDrag,hDrag=false,false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svDrag=true; local a,sz2=svB.AbsolutePosition,svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz2.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz2.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updColor()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
                if svDrag then local a,sz2=svB.AbsolutePosition,svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz2.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz2.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updColor() end
                if hDrag then local a,sz2=hBar.AbsolutePosition,hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz2.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); updColor() end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false; hDrag=false end
            end)
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hDrag=true; local a,sz2=hBar.AbsolutePosition,hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz2.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); updColor() end
            end)
            -- Close when clicking outside popup
            UIS.InputBegan:Connect(function(i)
                if open and i.UserInputType==Enum.UserInputType.MouseButton1 then
                    local mp=UIS:GetMouseLocation(); local pabs=pp.AbsolutePosition; local psz=pp.AbsoluteSize
                    local fabs=f.AbsolutePosition; local fsz=f.AbsoluteSize
                    local inPopup=(mp.X>=pabs.X and mp.X<=pabs.X+psz.X and mp.Y>=pabs.Y and mp.Y<=pabs.Y+psz.Y)
                    local inRow=(mp.X>=fabs.X and mp.X<=fabs.X+fsz.X and mp.Y>=fabs.Y and mp.Y<=fabs.Y+fsz.Y)
                    if not inPopup and not inRow then open=false; cpSg.Enabled=false end
                end
            end)

            function s:Set(c)
                cc=c; h,sv_s,sv_v=Color3.toHSV(c); s.Color=c; swatch.BackgroundColor3=c
                svB.BackgroundColor3=Color3.fromHSV(h,1,1); svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5)
                hCur.Position=UDim2.new(-0.15,0,h,-2)
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        return Tab
    end -- CreateTab

    function Window:Destroy() sg:Destroy() end
    return Window
end -- CreateWindow

-- ─── AUTO-INIT: fire "loaded Xanix Hub" notification on require ──────────────
task.delay(0.5, function()
    Xanix:Notify({ Title = "Xanix Hub", Content = "loaded Xanix Hub", Duration = 4 })
end)

-- ─── STUBS ───────────────────────────────────────────────────────────────────
function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(_)   end
function Xanix:IsVisible()        return true end
function Xanix:Destroy()          end

return Xanix
