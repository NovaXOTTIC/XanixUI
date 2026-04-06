--[[
  FloatLib  —  Clean Floating UI Library
  Usage:
    local FloatLib = loadstring(game:HttpGet("RAW_URL"))()
    local Win = FloatLib:Window({ Title = "My Script" })
    local Tab = Win:Tab("⚔  Combat")
    Tab:Button({ Name = "Kill All",  Callback = function() end })
    Tab:Toggle({ Name = "Aimbot",    Default = false, Callback = function(v) end })
    Tab:Slider({ Name = "WalkSpeed", Min=16, Max=500, Default=50, Callback = function(v) end })
    Tab:ColorPicker({ Name = "Color",Default = Color3.fromRGB(255,0,0), Callback = function(c) end })
    Tab:Dropdown({ Name = "Team",    Options={"Red","Blue"}, Callback = function(v) end })
    Tab:Input({ Name = "Player",     Placeholder="name…", Callback = function(t) end })
    Tab:Label("─── Section ───")
]]

local FloatLib = {}
FloatLib.__index = FloatLib

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer
local PG           = LP:WaitForChild("PlayerGui")

-- ─── THEME ───────────────────────────────────────────────────────────────────
local T = {
    -- Panels  (pure black, semi-transparent — sky shows through naturally)
    Panel        = Color3.fromRGB(0, 0, 0),
    PanelAlpha   = 0.32,

    -- Title bar slightly more opaque
    TitleBg      = Color3.fromRGB(0, 0, 0),
    TitleAlpha   = 0.18,

    -- Rows inside content
    Row          = Color3.fromRGB(255, 255, 255),
    RowAlpha     = 0.93,          -- near-white but very faint

    -- Borders
    Border       = Color3.fromRGB(255, 255, 255),
    BorderAlpha  = 0.92,          -- 1-0.08 → subtle white border

    -- Tabs
    TabIdle      = Color3.fromRGB(255, 255, 255),
    TabIdleAlpha = 0.90,
    TabHover     = Color3.fromRGB(255, 255, 255),
    TabHoverAlpha= 0.84,
    TabActive    = Color3.fromRGB(255, 255, 255),
    TabActAlpha  = 0.78,

    -- Text
    Text         = Color3.fromRGB(240, 242, 255),
    TextDim      = Color3.fromRGB(160, 162, 185),
    TextMuted    = Color3.fromRGB(110, 112, 140),

    -- Accent (indigo)
    Accent       = Color3.fromRGB(99,  102, 241),
    AccentDim    = Color3.fromRGB(67,  70,  180),

    -- Toggle
    TrackOff     = Color3.fromRGB(55, 55, 70),
    TrackOn      = Color3.fromRGB(99, 102, 241),
}

-- Sizes
local TAB_W      = 148
local CONTENT_W  = 440
local CONTENT_H  = 370
local SEARCH_H   = 34
local SET_H      = 38
local GAP        = 6

local TW_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW_MED  = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─── UTILS ───────────────────────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p; return c
end
local function uiStroke(p, col, alpha, thick, mode)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(255,255,255)
    s.Transparency = alpha or 0.88
    s.Thickness = thick or 1
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = p; return s
end
local function pad(p, l, r, t, b)
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft=UDim.new(0,l or 0); pd.PaddingRight=UDim.new(0,r or 0)
    pd.PaddingTop=UDim.new(0,t or 0);  pd.PaddingBottom=UDim.new(0,b or 0)
    pd.Parent=p; return pd
end
local function list(p, sp, axis)
    local l = Instance.new("UIListLayout")
    l.Padding   = UDim.new(0, sp or 4)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    if axis then l.FillDirection = axis end
    l.Parent = p; return l
end
local function tw(o, props, speed)
    TweenService:Create(o, speed or TW_FAST, props):Play()
end

-- ─── WINDOW ──────────────────────────────────────────────────────────────────
function FloatLib:Window(cfg)
    cfg = cfg or {}
    local winTitle = cfg.Title or "FloatLib"

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = "FloatLib"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = PG

    -- Anchor (invisible — dragging moves this, children follow)
    local anchor = Instance.new("Frame")
    anchor.Name = "Anchor"
    anchor.Size = UDim2.fromOffset(1,1)
    anchor.Position = UDim2.new(0.5, -(TAB_W+GAP+CONTENT_W)/2,
                                  0.5, -(SEARCH_H+GAP+CONTENT_H+GAP+SET_H)/2)
    anchor.BackgroundTransparency = 1
    anchor.BorderSizePixel = 0
    anchor.Parent = sg

    -- ┌─ SEARCH BAR ────────────────────────────────────────────────────────────
    local searchF = Instance.new("Frame")
    searchF.Size = UDim2.fromOffset(TAB_W, SEARCH_H)
    searchF.Position = UDim2.fromOffset(0, 0)
    searchF.BackgroundColor3 = T.Panel
    searchF.BackgroundTransparency = T.PanelAlpha
    searchF.BorderSizePixel = 0
    searchF.Parent = anchor
    corner(searchF, 9)
    uiStroke(searchF, T.Border, 0.88, 1, Enum.ApplyStrokeMode.Border)

    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.fromOffset(28, SEARCH_H)
    searchIcon.Position = UDim2.fromOffset(5, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"; searchIcon.TextSize = 12
    searchIcon.Font = Enum.Font.Gotham
    searchIcon.TextColor3 = T.TextMuted
    searchIcon.TextXAlignment = Enum.TextXAlignment.Center
    searchIcon.Parent = searchF

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1,-32,1,0)
    searchBox.Position = UDim2.fromOffset(28,0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""; searchBox.PlaceholderText = "Search tabs…"
    searchBox.TextSize = 13; searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextColor3 = T.Text; searchBox.PlaceholderColor3 = T.TextMuted
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false; searchBox.MultiLine = false
    searchBox.BorderSizePixel = 0; searchBox.Parent = searchF

    -- ┌─ TAB LIST ──────────────────────────────────────────────────────────────
    local tabSF = Instance.new("ScrollingFrame")
    tabSF.Name = "TabList"
    tabSF.Size = UDim2.fromOffset(TAB_W, CONTENT_H)
    tabSF.Position = UDim2.fromOffset(0, SEARCH_H+GAP)
    tabSF.BackgroundColor3 = T.Panel
    tabSF.BackgroundTransparency = T.PanelAlpha
    tabSF.BorderSizePixel = 0
    tabSF.ClipsDescendants = true
    tabSF.ScrollBarThickness = 2
    tabSF.ScrollBarImageColor3 = Color3.fromRGB(150,152,200)
    tabSF.CanvasSize = UDim2.new(0,0,0,0)
    tabSF.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabSF.ScrollingDirection = Enum.ScrollingDirection.Y
    tabSF.Parent = anchor
    corner(tabSF, 9)
    uiStroke(tabSF, T.Border, 0.88, 1, Enum.ApplyStrokeMode.Border)
    list(tabSF, 4)
    pad(tabSF, 7, 7, 7, 7)

    -- ┌─ SETTINGS BUTTON (below tab list) ─────────────────────────────────────
    local setBtn = Instance.new("TextButton")
    setBtn.Name = "SettingsBtn"
    setBtn.Size = UDim2.fromOffset(TAB_W, SET_H)
    setBtn.Position = UDim2.fromOffset(0, SEARCH_H+GAP+CONTENT_H+GAP)
    setBtn.BackgroundColor3 = T.Panel
    setBtn.BackgroundTransparency = T.PanelAlpha
    setBtn.BorderSizePixel = 0
    setBtn.AutoButtonColor = false
    setBtn.Text = ""
    setBtn.Parent = anchor
    corner(setBtn, 9)
    uiStroke(setBtn, T.Border, 0.88, 1, Enum.ApplyStrokeMode.Border)

    -- gear icon inside settings button
    local gearHolder = Instance.new("Frame")
    gearHolder.Size = UDim2.fromOffset(26,26)
    gearHolder.Position = UDim2.new(0.5,-13,0.5,-13)
    gearHolder.BackgroundColor3 = Color3.fromRGB(200,200,215)
    gearHolder.BackgroundTransparency = 0
    gearHolder.BorderSizePixel = 0
    gearHolder.Parent = setBtn
    corner(gearHolder, 7)

    local gearImg = Instance.new("ImageLabel")
    gearImg.Size = UDim2.new(0.72,0,0.72,0)
    gearImg.Position = UDim2.new(0.14,0,0.14,0)
    gearImg.BackgroundTransparency = 1
    gearImg.Image = "rbxassetid://5540166883"
    gearImg.ImageColor3 = Color3.fromRGB(30,30,40)
    gearImg.ScaleType = Enum.ScaleType.Fit
    gearImg.Parent = gearHolder

    setBtn.MouseEnter:Connect(function()
        tw(setBtn, {BackgroundTransparency = T.PanelAlpha - 0.12})
        tw(gearHolder, {BackgroundColor3 = Color3.fromRGB(220,222,255)})
    end)
    setBtn.MouseLeave:Connect(function()
        tw(setBtn, {BackgroundTransparency = T.PanelAlpha})
        tw(gearHolder, {BackgroundColor3 = Color3.fromRGB(200,200,215)})
    end)

    -- ┌─ CONTENT PANEL ─────────────────────────────────────────────────────────
    local totalH = SEARCH_H + GAP + CONTENT_H  -- aligns top with search bar

    local contentF = Instance.new("Frame")
    contentF.Name = "Content"
    contentF.Size = UDim2.fromOffset(CONTENT_W, totalH)
    contentF.Position = UDim2.fromOffset(TAB_W+GAP, 0)
    contentF.BackgroundColor3 = T.Panel
    contentF.BackgroundTransparency = T.PanelAlpha
    contentF.BorderSizePixel = 0
    contentF.ClipsDescendants = true
    contentF.Parent = anchor
    corner(contentF, 11)
    uiStroke(contentF, T.Border, 0.86, 1, Enum.ApplyStrokeMode.Border)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,40)
    titleBar.BackgroundColor3 = T.TitleBg
    titleBar.BackgroundTransparency = T.TitleAlpha
    titleBar.BorderSizePixel = 0
    titleBar.Parent = contentF

    -- thin accent line at bottom of title bar
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1,0,0,1)
    accentLine.Position = UDim2.new(0,0,1,-1)
    accentLine.BackgroundColor3 = T.Accent
    accentLine.BorderSizePixel = 0
    accentLine.BackgroundTransparency = 0.3
    accentLine.Parent = titleBar

    -- dot cluster (decorative, top-left)
    for i=1,3 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(10,10)
        dot.Position = UDim2.fromOffset(12+(i-1)*16, 15)
        dot.BackgroundColor3 = ({
            Color3.fromRGB(255, 95, 87),
            Color3.fromRGB(255, 189, 46),
            Color3.fromRGB(40, 200, 64),
        })[i]
        dot.BorderSizePixel = 0
        dot.Parent = titleBar
        corner(dot, 5)
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1,-120,1,0)
    titleLbl.Position = UDim2.fromOffset(64,0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = winTitle
    titleLbl.TextSize = 14
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextColor3 = T.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = titleBar

    -- Minimise button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(26,22)
    minBtn.Position = UDim2.new(1,-34,0.5,-11)
    minBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    minBtn.BackgroundTransparency = 0.88
    minBtn.BorderSizePixel = 0
    minBtn.Text = "–"
    minBtn.TextSize = 14
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextColor3 = T.TextDim
    minBtn.AutoButtonColor = false
    minBtn.Parent = titleBar
    corner(minBtn, 6)
    local minimised = false
    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        tw(contentF, {Size = minimised and UDim2.fromOffset(CONTENT_W,40) or UDim2.fromOffset(CONTENT_W,totalH)}, TW_MED)
    end)
    minBtn.MouseEnter:Connect(function() tw(minBtn,{BackgroundTransparency=0.70}) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn,{BackgroundTransparency=0.88}) end)

    -- Pages container
    local pagesC = Instance.new("Frame")
    pagesC.Size = UDim2.new(1,0,1,-40)
    pagesC.Position = UDim2.fromOffset(0,40)
    pagesC.BackgroundTransparency = 1
    pagesC.ClipsDescendants = true
    pagesC.Parent = contentF

    -- ─── TAB SYSTEM ──────────────────────────────────────────────────────────
    local tabs = {}
    local activeTab = nil

    local function switchTab(t)
        if activeTab == t then return end
        for _, v in ipairs(tabs) do
            v.page.Visible = false
            tw(v.btn, {BackgroundTransparency=T.TabIdleAlpha, TextColor3=T.TextDim})
            if v.bar then tw(v.bar, {BackgroundTransparency=1}) end
        end
        t.page.Visible = true
        tw(t.btn, {BackgroundTransparency=T.TabActAlpha, TextColor3=T.Text})
        if t.bar then tw(t.bar, {BackgroundTransparency=0.2}) end
        activeTab = t
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower()
        for _, t in ipairs(tabs) do
            t.btn.Visible = q=="" or (t.name:lower():find(q,1,true)~=nil)
        end
    end)

    -- ─── DRAGGING ────────────────────────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil
    local handles = {searchF, tabSF, contentF, setBtn}
    for _, h in ipairs(handles) do
        h.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true
                dragStart=Vector2.new(i.Position.X,i.Position.Y)
                startPos=anchor.Position
            end
        end)
    end
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch) then
            local d=Vector2.new(i.Position.X,i.Position.Y)-dragStart
            anchor.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                       startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- ─── WIN OBJECT ──────────────────────────────────────────────────────────
    local win = {}

    function win:Tab(name)
        -- Tab button
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,32)
        btn.BackgroundColor3 = T.TabIdle
        btn.BackgroundTransparency = T.TabIdleAlpha
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamMedium
        btn.TextColor3 = T.TextDim
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextWrapped = false
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.AutoButtonColor = false
        btn.LayoutOrder = #tabs+1
        btn.Parent = tabSF
        corner(btn,7)
        uiStroke(btn, T.Border, 0.88, 1, Enum.ApplyStrokeMode.Border)
        pad(btn,11,8,0,0)

        -- left accent bar (shown when active)
        local bar = Instance.new("Frame")
        bar.Size = UDim2.fromOffset(3,18)
        bar.Position = UDim2.new(0,-1,0.5,-9)
        bar.BackgroundColor3 = T.Accent
        bar.BorderSizePixel = 0
        bar.BackgroundTransparency = 1
        bar.Parent = btn
        corner(bar,2)

        -- Page
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(130,132,180)
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.BorderSizePixel = 0
        page.Visible = false
        page.Parent = pagesC
        list(page,6)
        pad(page,12,12,12,12)

        local t = {name=name, btn=btn, bar=bar, page=page}
        table.insert(tabs,t)

        btn.MouseEnter:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundTransparency=T.TabHoverAlpha,TextColor3=T.Text}) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundTransparency=T.TabIdleAlpha,TextColor3=T.TextDim}) end
        end)
        btn.MouseButton1Click:Connect(function() switchTab(t) end)
        if #tabs==1 then switchTab(t) end

        -- ── WIDGETS ──────────────────────────────────────────────────────────
        local function rowF(h, noHover)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1,0,0,h or 36)
            f.BackgroundColor3 = Color3.fromRGB(255,255,255)
            f.BackgroundTransparency = 0.93
            f.BorderSizePixel = 0
            f.Parent = page
            corner(f,7)
            uiStroke(f, Color3.fromRGB(255,255,255), 0.90, 1, Enum.ApplyStrokeMode.Border)
            if not noHover then
                f.MouseEnter:Connect(function() tw(f,{BackgroundTransparency=0.88}) end)
                f.MouseLeave:Connect(function() tw(f,{BackgroundTransparency=0.93}) end)
            end
            return f
        end

        local tab = {}

        -- LABEL
        function tab:Label(text)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1,0,0,18)
            f.BackgroundTransparency = 1
            f.Parent = page
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1,0,1,0)
            l.BackgroundTransparency = 1
            l.Text = text; l.TextSize = 10
            l.Font = Enum.Font.GothamBold
            l.TextColor3 = T.TextMuted
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = f
            pad(f,4,4,0,0)
        end

        -- BUTTON
        function tab:Button(cfg2)
            cfg2 = cfg2 or {}
            local f = rowF(36)

            -- accent left pip
            local pip = Instance.new("Frame")
            pip.Size = UDim2.fromOffset(3,16)
            pip.Position = UDim2.new(0,0,0.5,-8)
            pip.BackgroundColor3 = T.Accent
            pip.BackgroundTransparency = 0.3
            pip.BorderSizePixel = 0
            pip.Parent = f
            corner(pip,2)

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,1,0)
            b.BackgroundTransparency = 1
            b.Text = cfg2.Name or "Button"
            b.TextSize = 13; b.Font = Enum.Font.GothamMedium
            b.TextColor3 = T.Text
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.AutoButtonColor = false
            b.Parent = f
            pad(b,14,14,0,0)

            b.MouseButton1Click:Connect(function()
                tw(f,{BackgroundTransparency=0.80})
                task.delay(0.16,function() tw(f,{BackgroundTransparency=0.93}) end)
                if cfg2.Callback then task.spawn(cfg2.Callback) end
            end)
            return b
        end

        -- TOGGLE
        function tab:Toggle(cfg2)
            cfg2 = cfg2 or {}
            local state = cfg2.Default==true
            local f = rowF(36)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-62,1,0)
            lbl.Position = UDim2.fromOffset(12,0)
            lbl.BackgroundTransparency=1
            lbl.Text = cfg2.Name or "Toggle"
            lbl.TextSize=13; lbl.Font=Enum.Font.GothamMedium
            lbl.TextColor3=T.Text
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            lbl.Parent=f

            local track = Instance.new("Frame")
            track.Size = UDim2.fromOffset(42,24)
            track.Position = UDim2.new(1,-52,0.5,-12)
            track.BackgroundColor3 = state and T.TrackOn or T.TrackOff
            track.BorderSizePixel=0; track.Parent=f
            corner(track,12)

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.fromOffset(18,18)
            thumb.Position = state and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)
            thumb.BackgroundColor3=Color3.fromRGB(255,255,255)
            thumb.BorderSizePixel=0; thumb.Parent=track
            corner(thumb,9)

            local obj={Value=state}
            local function set(v)
                state=v; obj.Value=v
                tw(track,{BackgroundColor3=v and T.TrackOn or T.TrackOff})
                tw(thumb,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)})
                if cfg2.Callback then task.spawn(cfg2.Callback,v) end
            end
            local cl=Instance.new("TextButton")
            cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1
            cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f
            cl.MouseButton1Click:Connect(function() set(not state) end)
            function obj:Set(v) set(v) end
            return obj
        end

        -- SLIDER
        function tab:Slider(cfg2)
            cfg2=cfg2 or {}
            local mn=cfg2.Min or 0; local mx=cfg2.Max or 100
            local val=math.clamp(cfg2.Default or mn,mn,mx)
            local suf=cfg2.Suffix or ""
            local dp=cfg2.Decimals or 0

            local f = rowF(56)

            local nameLbl=Instance.new("TextLabel")
            nameLbl.Size=UDim2.new(0.55,0,0,22); nameLbl.Position=UDim2.fromOffset(12,4)
            nameLbl.BackgroundTransparency=1; nameLbl.Text=cfg2.Name or "Slider"
            nameLbl.TextSize=13; nameLbl.Font=Enum.Font.GothamMedium
            nameLbl.TextColor3=T.Text; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
            nameLbl.Parent=f

            local function fmt(v) return dp==0 and (tostring(math.round(v))..suf) or (string.format("%."..dp.."f",v)..suf) end

            local valLbl=Instance.new("TextLabel")
            valLbl.Size=UDim2.new(0.45,-12,0,22); valLbl.Position=UDim2.new(0.55,0,0,4)
            valLbl.BackgroundTransparency=1; valLbl.Text=fmt(val)
            valLbl.TextSize=12; valLbl.Font=Enum.Font.Gotham
            valLbl.TextColor3=T.TextDim; valLbl.TextXAlignment=Enum.TextXAlignment.Right
            valLbl.Parent=f; pad(valLbl,0,12,0,0)

            local trackBg=Instance.new("Frame")
            trackBg.Size=UDim2.new(1,-24,0,5); trackBg.Position=UDim2.new(0,12,1,-14)
            trackBg.BackgroundColor3=Color3.fromRGB(255,255,255)
            trackBg.BackgroundTransparency=0.82; trackBg.BorderSizePixel=0; trackBg.Parent=f
            corner(trackBg,3)

            local fill=Instance.new("Frame")
            fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)
            fill.BackgroundColor3=T.Accent; fill.BorderSizePixel=0; fill.Parent=trackBg
            corner(fill,3)

            local knob=Instance.new("Frame")
            knob.Size=UDim2.fromOffset(14,14)
            knob.Position=UDim2.new((val-mn)/(mx-mn),-7,0.5,-7)
            knob.BackgroundColor3=Color3.fromRGB(255,255,255)
            knob.BorderSizePixel=0; knob.ZIndex=2; knob.Parent=trackBg
            corner(knob,7)
            uiStroke(knob, T.Accent, 0.1, 2)

            local obj={Value=val}; local sliding=false

            local function upd(mx2)
                local abs=trackBg.AbsolutePosition; local sz=trackBg.AbsoluteSize
                local pct=math.clamp((mx2-abs.X)/sz.X,0,1)
                local nv=mn+pct*(mx-mn)
                if dp==0 then nv=math.round(nv) end
                obj.Value=nv; valLbl.Text=fmt(nv)
                tw(fill,{Size=UDim2.new(pct,0,1,0)})
                tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
                if cfg2.Callback then task.spawn(cfg2.Callback,nv) end
            end

            trackBg.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    sliding=true; upd(i.Position.X) end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)

            function obj:Set(v)
                v=math.clamp(v,mn,mx); local pct=(v-mn)/(mx-mn)
                obj.Value=v; valLbl.Text=fmt(v)
                tw(fill,{Size=UDim2.new(pct,0,1,0)}); tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
            end
            return obj
        end

        -- INPUT
        function tab:Input(cfg2)
            cfg2=cfg2 or {}
            local f=rowF(56)

            local nl=Instance.new("TextLabel")
            nl.Size=UDim2.new(1,0,0,20); nl.Position=UDim2.fromOffset(12,4)
            nl.BackgroundTransparency=1; nl.Text=cfg2.Name or "Input"
            nl.TextSize=11; nl.Font=Enum.Font.GothamBold
            nl.TextColor3=T.TextMuted; nl.TextXAlignment=Enum.TextXAlignment.Left
            nl.Parent=f

            local ibg=Instance.new("Frame")
            ibg.Size=UDim2.new(1,-24,0,24); ibg.Position=UDim2.fromOffset(12,26)
            ibg.BackgroundColor3=Color3.fromRGB(0,0,0); ibg.BackgroundTransparency=0.45
            ibg.BorderSizePixel=0; ibg.Parent=f
            corner(ibg,5)
            uiStroke(ibg, T.Border, 0.82, 1, Enum.ApplyStrokeMode.Contextual)

            local tb=Instance.new("TextBox")
            tb.Size=UDim2.new(1,-16,1,0); tb.Position=UDim2.fromOffset(8,0)
            tb.BackgroundTransparency=1; tb.Text=cfg2.Default or ""
            tb.PlaceholderText=cfg2.Placeholder or "Enter text…"
            tb.TextSize=13; tb.Font=Enum.Font.Gotham
            tb.TextColor3=T.Text; tb.PlaceholderColor3=T.TextMuted
            tb.TextXAlignment=Enum.TextXAlignment.Left
            tb.ClearTextOnFocus=false; tb.MultiLine=false; tb.BorderSizePixel=0
            tb.Parent=ibg

            tb.FocusLost:Connect(function(enter)
                if cfg2.Callback then task.spawn(cfg2.Callback,tb.Text,enter) end
            end)
            return tb
        end

        -- DROPDOWN
        function tab:Dropdown(cfg2)
            cfg2=cfg2 or {}
            local opts=cfg2.Options or {}
            local sel=cfg2.Default or (opts[1] or "—")
            local open=false

            local f=rowF(36)

            local nl=Instance.new("TextLabel")
            nl.Size=UDim2.new(0.5,0,1,0); nl.Position=UDim2.fromOffset(12,0)
            nl.BackgroundTransparency=1; nl.Text=cfg2.Name or "Dropdown"
            nl.TextSize=13; nl.Font=Enum.Font.GothamMedium
            nl.TextColor3=T.Text; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f

            local selB=Instance.new("TextButton")
            selB.Size=UDim2.new(0.46,-8,0,24); selB.Position=UDim2.new(0.5,2,0.5,-12)
            selB.BackgroundColor3=Color3.fromRGB(0,0,0); selB.BackgroundTransparency=0.46
            selB.BorderSizePixel=0; selB.Text=sel.."  ▾"
            selB.TextSize=12; selB.Font=Enum.Font.Gotham
            selB.TextColor3=T.Text; selB.AutoButtonColor=false; selB.Parent=f
            corner(selB,5)
            uiStroke(selB, T.Border, 0.82, 1, Enum.ApplyStrokeMode.Contextual)

            local ddF=Instance.new("Frame")
            ddF.Size=UDim2.new(0.46,-8,0,#opts*26+8); ddF.Position=UDim2.new(0.5,2,1,4)
            ddF.BackgroundColor3=Color3.fromRGB(10,10,16); ddF.BackgroundTransparency=0.08
            ddF.BorderSizePixel=0; ddF.ZIndex=20; ddF.Visible=false
            ddF.ClipsDescendants=true; ddF.Parent=f
            corner(ddF,7)
            uiStroke(ddF, T.Border, 0.82, 1, Enum.ApplyStrokeMode.Contextual)
            list(ddF,2); pad(ddF,4,4,4,4)

            local obj={Value=sel}
            for i,o in ipairs(opts) do
                local ob=Instance.new("TextButton")
                ob.Size=UDim2.new(1,0,0,22); ob.BackgroundColor3=Color3.fromRGB(255,255,255)
                ob.BackgroundTransparency=0.88; ob.BorderSizePixel=0; ob.Text=o
                ob.TextSize=12; ob.Font=Enum.Font.Gotham; ob.TextColor3=T.Text
                ob.AutoButtonColor=false; ob.ZIndex=21; ob.LayoutOrder=i; ob.Parent=ddF
                corner(ob,5)
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0.76}) end)
                ob.MouseLeave:Connect(function() tw(ob,{BackgroundTransparency=0.88}) end)
                ob.MouseButton1Click:Connect(function()
                    sel=o; obj.Value=o; selB.Text=o.."  ▾"; open=false; ddF.Visible=false
                    if cfg2.Callback then task.spawn(cfg2.Callback,o) end
                end)
            end
            selB.MouseButton1Click:Connect(function() open=not open; ddF.Visible=open end)
            return obj
        end

        -- COLOR PICKER
        function tab:ColorPicker(cfg2)
            cfg2=cfg2 or {}
            local cc=cfg2.Default or Color3.fromRGB(255,0,0)
            local h,s,v=Color3.toHSV(cc)
            local open=false

            local f=rowF(36)

            local nl=Instance.new("TextLabel")
            nl.Size=UDim2.new(1,-60,1,0); nl.Position=UDim2.fromOffset(12,0)
            nl.BackgroundTransparency=1; nl.Text=cfg2.Name or "Color"
            nl.TextSize=13; nl.Font=Enum.Font.GothamMedium
            nl.TextColor3=T.Text; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f

            local swatch=Instance.new("Frame")
            swatch.Size=UDim2.fromOffset(34,22); swatch.Position=UDim2.new(1,-44,0.5,-11)
            swatch.BackgroundColor3=cc; swatch.BorderSizePixel=0; swatch.Parent=f
            corner(swatch,6)
            uiStroke(swatch, T.Border, 0.82, 1)

            local pW=CONTENT_W-28
            local pp=Instance.new("Frame")
            pp.Size=UDim2.fromOffset(pW,170); pp.Position=UDim2.new(0,0,1,5)
            pp.BackgroundColor3=Color3.fromRGB(10,10,16); pp.BackgroundTransparency=0.06
            pp.BorderSizePixel=0; pp.ZIndex=15; pp.Visible=false
            pp.ClipsDescendants=false; pp.Parent=f
            corner(pp,9)
            uiStroke(pp, T.Border, 0.82, 1, Enum.ApplyStrokeMode.Contextual)

            local svW=pW-40; local svH=140

            local svB=Instance.new("Frame")
            svB.Size=UDim2.fromOffset(svW,svH); svB.Position=UDim2.fromOffset(10,15)
            svB.BackgroundColor3=Color3.fromHSV(h,1,1); svB.BorderSizePixel=0
            svB.ZIndex=15; svB.Parent=pp
            corner(svB,7)

            local function ovl(parent, rot, ...)
                local fr=Instance.new("Frame")
                fr.Size=UDim2.new(1,0,1,0); fr.BackgroundTransparency=1
                fr.BorderSizePixel=0; fr.ZIndex=16; fr.Parent=parent
                local g=Instance.new("UIGradient")
                g.Rotation=rot
                local kp={}; local args={...}
                for i=1,#args,3 do table.insert(kp,ColorSequenceKeypoint.new(args[i],args[i+1])) end
                g.Color=ColorSequence.new(kp)
                if args[#args-1] then  -- transparency seq
                    local tp={}
                    for i=1,#args[#args],2 do table.insert(tp,NumberSequenceKeypoint.new(args[#args][i],args[#args][i+1])) end
                    g.Transparency=NumberSequence.new(tp)
                end
                g.Parent=fr; return fr
            end

            local wf=Instance.new("Frame"); wf.Size=UDim2.new(1,0,1,0); wf.BackgroundTransparency=1; wf.BorderSizePixel=0; wf.ZIndex=16; wf.Parent=svB
            local wg=Instance.new("UIGradient"); wg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}); wg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); wg.Rotation=0; wg.Parent=wf
            local df=Instance.new("Frame"); df.Size=UDim2.new(1,0,1,0); df.BackgroundTransparency=1; df.BorderSizePixel=0; df.ZIndex=16; df.Parent=svB
            local dg=Instance.new("UIGradient"); dg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}); dg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}); dg.Rotation=90; dg.Parent=df

            local svCur=Instance.new("Frame"); svCur.Size=UDim2.fromOffset(12,12); svCur.Position=UDim2.new(s,-6,1-v,-6); svCur.BackgroundColor3=Color3.fromRGB(255,255,255); svCur.BorderSizePixel=0; svCur.ZIndex=18; svCur.Parent=svB; corner(svCur,6); uiStroke(svCur,Color3.fromRGB(0,0,0),0,1)

            local hBar=Instance.new("Frame"); hBar.Size=UDim2.fromOffset(18,svH); hBar.Position=UDim2.fromOffset(svW+16,15); hBar.BackgroundColor3=Color3.fromRGB(255,255,255); hBar.BorderSizePixel=0; hBar.ZIndex=15; hBar.Parent=pp; corner(hBar,5)
            local hg=Instance.new("UIGradient"); hg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(0,1,1))}); hg.Rotation=90; hg.Parent=hBar
            local hCur=Instance.new("Frame"); hCur.Size=UDim2.new(1,6,0,5); hCur.Position=UDim2.new(-0.15,0,h,-2); hCur.BackgroundColor3=Color3.fromRGB(255,255,255); hCur.BorderSizePixel=0; hCur.ZIndex=18; hCur.Parent=hBar; corner(hCur,2); uiStroke(hCur,Color3.fromRGB(0,0,0),0,1)

            local obj={Value=cc}
            local function upd()
                cc=Color3.fromHSV(h,s,v); obj.Value=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if cfg2.Callback then task.spawn(cfg2.Callback,cc) end
            end

            local svDrag=false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svDrag=true; local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    s=math.clamp((i.Position.X-a.X)/sz.X,0,1); v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(s,-6,1-v,-6); upd() end
            end)
            UIS.InputChanged:Connect(function(i)
                if svDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    s=math.clamp((i.Position.X-a.X)/sz.X,0,1); v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(s,-6,1-v,-6); upd() end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false end
            end)

            local hDrag=false
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hDrag=true; local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); upd() end
            end)
            UIS.InputChanged:Connect(function(i)
                if hDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); upd() end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hDrag=false end
            end)

            local cl=Instance.new("TextButton"); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1; cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f
            cl.MouseButton1Click:Connect(function() open=not open; pp.Visible=open end)

            function obj:Set(c) cc=c; h,s,v=Color3.toHSV(c); swatch.BackgroundColor3=c; svB.BackgroundColor3=Color3.fromHSV(h,1,1); svCur.Position=UDim2.new(s,-6,1-v,-6); hCur.Position=UDim2.new(-0.15,0,h,-2) end
            return obj
        end

        return tab
    end

    return win
end

return FloatLib
