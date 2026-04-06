--[[
  FloatLib  —  Floating Transparent UI Library
  Loadstring usage:
    local FloatLib = loadstring(game:HttpGet("YOUR_RAW_URL"))()
    local Win = FloatLib:Window({ Title = "My Script" })
    local Tab = Win:Tab("Combat")
    Tab:Button({ Name = "Kill All", Callback = function() end })
    Tab:Toggle({ Name = "Aimbot", Default = false, Callback = function(v) end })
    Tab:Slider({ Name = "Speed", Min = 16, Max = 500, Default = 50, Callback = function(v) end })
    Tab:ColorPicker({ Name = "ESP Color", Default = Color3.fromRGB(255,0,0), Callback = function(c) end })
    Tab:Dropdown({ Name = "Team", Options = {"Red","Blue","Green"}, Callback = function(v) end })
    Tab:Input({ Name = "Player", Placeholder = "Enter name…", Callback = function(t) end })
    Tab:Label("Section Header")
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
    Panel      = Color3.fromRGB(0,   0,   0),
    PanelAlpha = 0.28,
    RowBg      = Color3.fromRGB(83,  83,  83),
    RowAlpha   = 0.38,
    Border     = Color3.fromRGB(60,  60,  70),
    BorderBtn  = Color3.fromRGB(83,  83,  83),
    Text       = Color3.fromRGB(250, 250, 255),
    TextMuted  = Color3.fromRGB(170, 170, 190),
    Accent     = Color3.fromRGB(99,  102, 241),
    ToggleOff  = Color3.fromRGB(55,  55,  68),
    ToggleOn   = Color3.fromRGB(99,  102, 241),
    TabInact   = Color3.fromRGB(83,  83,  83),
    TabAct     = Color3.fromRGB(100, 100, 114),
}

-- ─── LAYOUT ──────────────────────────────────────────────────────────────────
local TAB_W      = 150
local CONTENT_W  = 420
local CONTENT_H  = 360
local SEARCH_H   = 36
local SETTINGS_H = 38
local GAP        = 7

local TW = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, col, t, m)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Border
    s.Thickness = t or 1
    s.ApplyStrokeMode = m or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = p
    return s
end

local function pad(p, l, r, top, b)
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft   = UDim.new(0, l   or 0)
    pd.PaddingRight  = UDim.new(0, r   or 0)
    pd.PaddingTop    = UDim.new(0, top or 0)
    pd.PaddingBottom = UDim.new(0, b   or 0)
    pd.Parent = p
    return pd
end

local function tw(obj, props)
    TweenService:Create(obj, TW, props):Play()
end

local function listLayout(parent, spacing)
    local l = Instance.new("UIListLayout")
    l.Padding   = UDim.new(0, spacing or 4)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent    = parent
    return l
end

-- ─── WINDOW ──────────────────────────────────────────────────────────────────
function FloatLib:Window(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "FloatLib"

    local sg = Instance.new("ScreenGui")
    sg.Name           = "FloatLib"
    sg.ResetOnSpawn   = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent         = PG

    -- invisible anchor — all panels are children, so dragging anchor moves everything
    local anchor = Instance.new("Frame")
    anchor.Name                   = "Anchor"
    anchor.Size                   = UDim2.fromOffset(1, 1)
    anchor.Position               = UDim2.new(0.5, -(TAB_W + GAP + CONTENT_W) / 2,
                                               0.5, -(SEARCH_H + GAP + CONTENT_H + GAP + SETTINGS_H) / 2)
    anchor.BackgroundTransparency = 1
    anchor.BorderSizePixel        = 0
    anchor.Parent                 = sg

    -- ── SEARCH BAR ────────────────────────────────────────────────────────────
    local searchFrame = Instance.new("Frame")
    searchFrame.Size                  = UDim2.fromOffset(TAB_W, SEARCH_H)
    searchFrame.Position              = UDim2.fromOffset(0, 0)
    searchFrame.BackgroundColor3      = T.Panel
    searchFrame.BackgroundTransparency= T.PanelAlpha
    searchFrame.BorderSizePixel       = 0
    searchFrame.Parent                = anchor
    corner(searchFrame, 9)
    stroke(searchFrame, T.Border, 1, Enum.ApplyStrokeMode.Contextual)

    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size                = UDim2.fromOffset(24, SEARCH_H)
    searchIcon.Position            = UDim2.fromOffset(6, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text                = "⌕"
    searchIcon.TextSize            = 17
    searchIcon.Font                = Enum.Font.GothamMedium
    searchIcon.TextColor3          = T.TextMuted
    searchIcon.TextXAlignment      = Enum.TextXAlignment.Center
    searchIcon.Parent              = searchFrame

    local searchBox = Instance.new("TextBox")
    searchBox.Size               = UDim2.new(1, -34, 1, 0)
    searchBox.Position           = UDim2.fromOffset(28, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text               = ""
    searchBox.PlaceholderText    = "Search tabs…"
    searchBox.TextSize           = 13
    searchBox.Font               = Enum.Font.GothamMedium
    searchBox.TextColor3         = Color3.fromRGB(220, 220, 225)
    searchBox.PlaceholderColor3  = T.TextMuted
    searchBox.TextXAlignment     = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus   = false
    searchBox.MultiLine          = false
    searchBox.BorderSizePixel    = 0
    searchBox.Parent             = searchFrame

    -- ── TAB LIST ──────────────────────────────────────────────────────────────
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name                   = "TabList"
    tabList.Size                   = UDim2.fromOffset(TAB_W, CONTENT_H)
    tabList.Position               = UDim2.fromOffset(0, SEARCH_H + GAP)
    tabList.BackgroundColor3       = T.Panel
    tabList.BackgroundTransparency = T.PanelAlpha
    tabList.BorderSizePixel        = 0
    tabList.ClipsDescendants       = true
    tabList.ScrollBarThickness     = 3
    tabList.ScrollBarImageColor3   = Color3.fromRGB(100, 100, 130)
    tabList.CanvasSize             = UDim2.new(0, 0, 0, 0)
    tabList.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    tabList.ScrollingDirection     = Enum.ScrollingDirection.Y
    tabList.Parent                 = anchor
    corner(tabList, 9)
    stroke(tabList, T.Border, 1, Enum.ApplyStrokeMode.Contextual)
    listLayout(tabList, 3)
    pad(tabList, 7, 7, 7, 7)

    -- ── SETTINGS BUTTON (below tab list) ─────────────────────────────────────
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Name                   = "Settings"
    settingsBtn.Size                   = UDim2.fromOffset(TAB_W, SETTINGS_H)
    settingsBtn.Position               = UDim2.fromOffset(0, SEARCH_H + GAP + CONTENT_H + GAP)
    settingsBtn.BackgroundColor3       = T.Panel
    settingsBtn.BackgroundTransparency = T.PanelAlpha
    settingsBtn.BorderSizePixel        = 0
    settingsBtn.Text                   = "⚙  Settings"
    settingsBtn.TextSize               = 13
    settingsBtn.Font                   = Enum.Font.GothamMedium
    settingsBtn.TextColor3             = T.TextMuted
    settingsBtn.AutoButtonColor        = false
    settingsBtn.Parent                 = anchor
    corner(settingsBtn, 9)
    stroke(settingsBtn, T.Border, 1)
    settingsBtn.MouseEnter:Connect(function()
        tw(settingsBtn, { TextColor3 = T.Text, BackgroundTransparency = 0.15 })
    end)
    settingsBtn.MouseLeave:Connect(function()
        tw(settingsBtn, { TextColor3 = T.TextMuted, BackgroundTransparency = T.PanelAlpha })
    end)

    -- ── CONTENT PANEL ─────────────────────────────────────────────────────────
    -- Spans from y=0 down, so it aligns with search bar top
    local totalH = SEARCH_H + GAP + CONTENT_H
    local contentPanel = Instance.new("Frame")
    contentPanel.Name                   = "ContentPanel"
    contentPanel.Size                   = UDim2.fromOffset(CONTENT_W, totalH)
    contentPanel.Position               = UDim2.fromOffset(TAB_W + GAP, 0)
    contentPanel.BackgroundColor3       = T.Panel
    contentPanel.BackgroundTransparency = T.PanelAlpha
    contentPanel.BorderSizePixel        = 0
    contentPanel.ClipsDescendants       = true
    contentPanel.Parent                 = anchor
    corner(contentPanel, 9)
    stroke(contentPanel, T.Border, 1, Enum.ApplyStrokeMode.Contextual)

    -- title bar inside content
    local titleBar = Instance.new("Frame")
    titleBar.Size             = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BackgroundTransparency = 0.48
    titleBar.BorderSizePixel  = 0
    titleBar.Parent           = contentPanel

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size             = UDim2.new(1, -16, 1, 0)
    titleLbl.Position         = UDim2.fromOffset(14, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text             = title
    titleLbl.TextSize         = 14
    titleLbl.Font             = Enum.Font.GothamBold
    titleLbl.TextColor3       = T.Text
    titleLbl.TextXAlignment   = Enum.TextXAlignment.Left
    titleLbl.Parent           = titleBar

    local accentLine = Instance.new("Frame")
    accentLine.Size             = UDim2.new(1, 0, 0, 2)
    accentLine.Position         = UDim2.new(0, 0, 1, -2)
    accentLine.BackgroundColor3 = T.Accent
    accentLine.BorderSizePixel  = 0
    accentLine.Parent           = titleBar

    -- page container
    local pagesContainer = Instance.new("Frame")
    pagesContainer.Size               = UDim2.new(1, 0, 1, -38)
    pagesContainer.Position           = UDim2.fromOffset(0, 38)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.ClipsDescendants   = true
    pagesContainer.Parent             = contentPanel

    -- ── TAB STATE ─────────────────────────────────────────────────────────────
    local tabs      = {}
    local activeTab = nil

    local function switchTab(t)
        if activeTab == t then return end
        for _, v in ipairs(tabs) do
            v.page.Visible = false
            tw(v.btn, { BackgroundColor3 = T.TabInact, BackgroundTransparency = T.RowAlpha, TextColor3 = T.TextMuted })
        end
        t.page.Visible = true
        tw(t.btn, { BackgroundColor3 = T.TabAct, BackgroundTransparency = 0.18, TextColor3 = T.Text })
        activeTab = t
    end

    -- search filter
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower()
        for _, t in ipairs(tabs) do
            t.btn.Visible = q == "" or (t.name:lower():find(q, 1, true) ~= nil)
        end
    end)

    -- ── DRAGGING ──────────────────────────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil
    local handles = { searchFrame, tabList, contentPanel, settingsBtn }
    for _, h in ipairs(handles) do
        h.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = Vector2.new(i.Position.X, i.Position.Y)
                startPos  = anchor.Position
            end
        end)
    end
    UIS.InputChanged:Connect(function(i)
        if dragging
        and (i.UserInputType == Enum.UserInputType.MouseMovement
          or i.UserInputType == Enum.UserInputType.Touch) then
            local d = Vector2.new(i.Position.X, i.Position.Y) - dragStart
            anchor.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- ── WIN OBJECT ────────────────────────────────────────────────────────────
    local win = {}

    function win:Tab(name)
        -- Tab button
        local btn = Instance.new("TextButton")
        btn.Size                   = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3       = T.TabInact
        btn.BackgroundTransparency = T.RowAlpha
        btn.BorderSizePixel        = 0
        btn.Text                   = name
        btn.TextSize               = 13
        btn.Font                   = Enum.Font.GothamMedium
        btn.TextColor3             = T.TextMuted
        btn.TextXAlignment         = Enum.TextXAlignment.Center
        btn.TextWrapped            = true
        btn.AutoButtonColor        = false
        btn.LayoutOrder            = #tabs + 1
        btn.Parent                 = tabList
        corner(btn, 7)
        stroke(btn, T.BorderBtn, 1, Enum.ApplyStrokeMode.Border)
        pad(btn, 8, 8, 0, 0)

        -- Page
        local page = Instance.new("ScrollingFrame")
        page.Size                  = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency= 1
        page.ScrollBarThickness    = 3
        page.ScrollBarImageColor3  = Color3.fromRGB(100, 100, 130)
        page.CanvasSize            = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        page.BorderSizePixel       = 0
        page.Visible               = false
        page.Parent                = pagesContainer
        listLayout(page, 6)
        pad(page, 10, 10, 10, 10)

        local t = { name = name, btn = btn, page = page }
        table.insert(tabs, t)

        btn.MouseEnter:Connect(function()
            if activeTab ~= t then tw(btn, { BackgroundTransparency = 0.25 }) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= t then tw(btn, { BackgroundTransparency = T.RowAlpha }) end
        end)
        btn.MouseButton1Click:Connect(function() switchTab(t) end)
        if #tabs == 1 then switchTab(t) end

        -- ── WIDGET HELPERS ────────────────────────────────────────────────────
        local function rowBase(h)
            local f = Instance.new("Frame")
            f.Size                = UDim2.new(1, 0, 0, h or 36)
            f.BackgroundColor3    = T.RowBg
            f.BackgroundTransparency = T.RowAlpha
            f.BorderSizePixel     = 0
            f.Parent              = page
            corner(f, 7)
            stroke(f, T.Border, 1)

            f.MouseEnter:Connect(function() tw(f, { BackgroundTransparency = 0.24 }) end)
            f.MouseLeave:Connect(function() tw(f, { BackgroundTransparency = T.RowAlpha }) end)
            return f
        end

        local tab = {}

        -- ── LABEL ─────────────────────────────────────────────────────────────
        function tab:Label(text)
            local f = Instance.new("Frame")
            f.Size                = UDim2.new(1, 0, 0, 20)
            f.BackgroundTransparency = 1
            f.Parent              = page
            local l = Instance.new("TextLabel")
            l.Size                = UDim2.new(1, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Text                = text
            l.TextSize            = 11
            l.Font                = Enum.Font.GothamBold
            l.TextColor3          = T.TextMuted
            l.TextXAlignment      = Enum.TextXAlignment.Left
            l.Parent              = f
            pad(f, 4, 4, 0, 0)
        end

        -- ── BUTTON ────────────────────────────────────────────────────────────
        function tab:Button(cfg2)
            cfg2 = cfg2 or {}
            local f   = rowBase(36)

            local ind = Instance.new("Frame")  -- accent left bar
            ind.Size            = UDim2.fromOffset(3, 15)
            ind.Position        = UDim2.new(0, 0, 0.5, -7)
            ind.BackgroundColor3= T.Accent
            ind.BorderSizePixel = 0
            ind.Parent          = f
            corner(ind, 2)

            local btn2 = Instance.new("TextButton")
            btn2.Size               = UDim2.new(1, 0, 1, 0)
            btn2.BackgroundTransparency = 1
            btn2.Text               = cfg2.Name or "Button"
            btn2.TextSize           = 13
            btn2.Font               = Enum.Font.GothamMedium
            btn2.TextColor3         = T.Text
            btn2.TextXAlignment     = Enum.TextXAlignment.Left
            btn2.AutoButtonColor    = false
            btn2.Parent             = f
            pad(btn2, 14, 14, 0, 0)

            btn2.MouseButton1Click:Connect(function()
                tw(f, { BackgroundColor3 = Color3.fromRGB(70, 72, 180) })
                task.delay(0.18, function() tw(f, { BackgroundColor3 = T.RowBg }) end)
                if cfg2.Callback then task.spawn(cfg2.Callback) end
            end)
            return btn2
        end

        -- ── TOGGLE ────────────────────────────────────────────────────────────
        function tab:Toggle(cfg2)
            cfg2  = cfg2 or {}
            local state = cfg2.Default == true
            local f = rowBase(36)

            local lbl = Instance.new("TextLabel")
            lbl.Size              = UDim2.new(1, -60, 1, 0)
            lbl.Position          = UDim2.fromOffset(12, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text              = cfg2.Name or "Toggle"
            lbl.TextSize          = 13
            lbl.Font              = Enum.Font.GothamMedium
            lbl.TextColor3        = T.Text
            lbl.TextXAlignment    = Enum.TextXAlignment.Left
            lbl.Parent            = f

            local track = Instance.new("Frame")
            track.Size            = UDim2.fromOffset(40, 22)
            track.Position        = UDim2.new(1, -50, 0.5, -11)
            track.BackgroundColor3= state and T.ToggleOn or T.ToggleOff
            track.BorderSizePixel = 0
            track.Parent          = f
            corner(track, 11)

            local thumb = Instance.new("Frame")
            thumb.Size            = UDim2.fromOffset(16, 16)
            thumb.Position        = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
            thumb.BackgroundColor3= Color3.fromRGB(255, 255, 255)
            thumb.BorderSizePixel = 0
            thumb.Parent          = track
            corner(thumb, 8)

            local obj = { Value = state }

            local function set(v)
                state     = v
                obj.Value = v
                tw(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff })
                tw(thumb, { Position = v and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) })
                if cfg2.Callback then task.spawn(cfg2.Callback, v) end
            end

            local clickBtn = Instance.new("TextButton")
            clickBtn.Size               = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text               = ""
            clickBtn.AutoButtonColor    = false
            clickBtn.Parent             = f
            clickBtn.MouseButton1Click:Connect(function() set(not state) end)

            function obj:Set(v) set(v) end
            return obj
        end

        -- ── SLIDER ────────────────────────────────────────────────────────────
        function tab:Slider(cfg2)
            cfg2   = cfg2 or {}
            local min    = cfg2.Min     or 0
            local max    = cfg2.Max     or 100
            local val    = math.clamp(cfg2.Default or min, min, max)
            local suffix = cfg2.Suffix  or ""
            local dp     = cfg2.Decimals or 0  -- decimal places

            local f = rowBase(54)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size          = UDim2.new(0.6, 0, 0, 22)
            nameLbl.Position      = UDim2.fromOffset(12, 4)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text          = cfg2.Name or "Slider"
            nameLbl.TextSize      = 13
            nameLbl.Font          = Enum.Font.GothamMedium
            nameLbl.TextColor3    = T.Text
            nameLbl.TextXAlignment= Enum.TextXAlignment.Left
            nameLbl.Parent        = f

            local valLbl = Instance.new("TextLabel")
            valLbl.Size           = UDim2.new(0.4, -12, 0, 22)
            valLbl.Position       = UDim2.new(0.6, 0, 0, 4)
            valLbl.BackgroundTransparency = 1
            valLbl.TextSize       = 12
            valLbl.Font           = Enum.Font.Gotham
            valLbl.TextColor3     = T.TextMuted
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent         = f
            pad(valLbl, 0, 12, 0, 0)

            local function fmtVal(v)
                if dp == 0 then return tostring(math.round(v)) .. suffix end
                return string.format("%." .. dp .. "f", v) .. suffix
            end
            valLbl.Text = fmtVal(val)

            local trackBg = Instance.new("Frame")
            trackBg.Size          = UDim2.new(1, -24, 0, 6)
            trackBg.Position      = UDim2.new(0, 12, 1, -16)
            trackBg.BackgroundColor3 = T.ToggleOff
            trackBg.BorderSizePixel= 0
            trackBg.Parent        = f
            corner(trackBg, 3)

            local fill = Instance.new("Frame")
            fill.Size             = UDim2.new((val - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = T.Accent
            fill.BorderSizePixel  = 0
            fill.Parent           = trackBg
            corner(fill, 3)

            local knob = Instance.new("Frame")
            knob.Size             = UDim2.fromOffset(16, 16)
            knob.Position         = UDim2.new((val - min) / (max - min), -8, 0.5, -8)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel  = 0
            knob.ZIndex           = 2
            knob.Parent           = trackBg
            corner(knob, 8)
            stroke(knob, T.Accent, 2)

            local obj     = { Value = val }
            local sliding = false

            local function updateSlider(mx)
                local abs = trackBg.AbsolutePosition
                local sz  = trackBg.AbsoluteSize
                local pct = math.clamp((mx - abs.X) / sz.X, 0, 1)
                local newV = min + pct * (max - min)
                if dp == 0 then newV = math.round(newV) end
                obj.Value   = newV
                valLbl.Text = fmtVal(newV)
                tw(fill, { Size = UDim2.new(pct, 0, 1, 0) })
                tw(knob, { Position = UDim2.new(pct, -8, 0.5, -8) })
                if cfg2.Callback then task.spawn(cfg2.Callback, newV) end
            end

            trackBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(i.Position.X)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding
                and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(i.Position.X)
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)

            function obj:Set(v)
                v = math.clamp(v, min, max)
                local pct = (v - min) / (max - min)
                obj.Value   = v
                valLbl.Text = fmtVal(v)
                tw(fill, { Size = UDim2.new(pct, 0, 1, 0) })
                tw(knob, { Position = UDim2.new(pct, -8, 0.5, -8) })
            end
            return obj
        end

        -- ── INPUT / TEXTBOX ───────────────────────────────────────────────────
        function tab:Input(cfg2)
            cfg2 = cfg2 or {}
            local f = rowBase(56)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size          = UDim2.new(1, 0, 0, 20)
            nameLbl.Position      = UDim2.fromOffset(12, 4)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text          = cfg2.Name or "Input"
            nameLbl.TextSize      = 11
            nameLbl.Font          = Enum.Font.GothamBold
            nameLbl.TextColor3    = T.TextMuted
            nameLbl.TextXAlignment= Enum.TextXAlignment.Left
            nameLbl.Parent        = f

            local inputBg = Instance.new("Frame")
            inputBg.Size          = UDim2.new(1, -24, 0, 24)
            inputBg.Position      = UDim2.fromOffset(12, 26)
            inputBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            inputBg.BackgroundTransparency = 0.48
            inputBg.BorderSizePixel= 0
            inputBg.Parent        = f
            corner(inputBg, 5)
            stroke(inputBg, T.Border, 1, Enum.ApplyStrokeMode.Contextual)

            local tb = Instance.new("TextBox")
            tb.Size               = UDim2.new(1, -16, 1, 0)
            tb.Position           = UDim2.fromOffset(8, 0)
            tb.BackgroundTransparency = 1
            tb.Text               = cfg2.Default or ""
            tb.PlaceholderText    = cfg2.Placeholder or "Enter text…"
            tb.TextSize           = 13
            tb.Font               = Enum.Font.Gotham
            tb.TextColor3         = T.Text
            tb.PlaceholderColor3  = T.TextMuted
            tb.TextXAlignment     = Enum.TextXAlignment.Left
            tb.ClearTextOnFocus   = false
            tb.MultiLine          = false
            tb.BorderSizePixel    = 0
            tb.Parent             = inputBg

            tb.FocusLost:Connect(function(enter)
                if cfg2.Callback then task.spawn(cfg2.Callback, tb.Text, enter) end
            end)
            return tb
        end

        -- ── DROPDOWN ──────────────────────────────────────────────────────────
        function tab:Dropdown(cfg2)
            cfg2     = cfg2 or {}
            local options  = cfg2.Options or {}
            local selected = cfg2.Default or (options[1] or "None")
            local open     = false

            local f = rowBase(36)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size          = UDim2.new(0.5, 0, 1, 0)
            nameLbl.Position      = UDim2.fromOffset(12, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text          = cfg2.Name or "Dropdown"
            nameLbl.TextSize      = 13
            nameLbl.Font          = Enum.Font.GothamMedium
            nameLbl.TextColor3    = T.Text
            nameLbl.TextXAlignment= Enum.TextXAlignment.Left
            nameLbl.Parent        = f

            local selBtn = Instance.new("TextButton")
            selBtn.Size           = UDim2.new(0.46, -8, 0, 24)
            selBtn.Position       = UDim2.new(0.5, 2, 0.5, -12)
            selBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            selBtn.BackgroundTransparency = 0.48
            selBtn.BorderSizePixel= 0
            selBtn.Text           = selected .. "  ▾"
            selBtn.TextSize       = 12
            selBtn.Font           = Enum.Font.Gotham
            selBtn.TextColor3     = T.Text
            selBtn.AutoButtonColor= false
            selBtn.Parent         = f
            corner(selBtn, 5)
            stroke(selBtn, T.Border, 1, Enum.ApplyStrokeMode.Contextual)

            local ddFrame = Instance.new("Frame")
            ddFrame.Size          = UDim2.new(0.46, -8, 0, #options * 28 + 8)
            ddFrame.Position      = UDim2.new(0.5, 2, 1, 4)
            ddFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
            ddFrame.BackgroundTransparency = 0.06
            ddFrame.BorderSizePixel= 0
            ddFrame.ZIndex        = 20
            ddFrame.Visible       = false
            ddFrame.ClipsDescendants = true
            ddFrame.Parent        = f
            corner(ddFrame, 7)
            stroke(ddFrame, T.Border, 1, Enum.ApplyStrokeMode.Contextual)
            listLayout(ddFrame, 2)
            pad(ddFrame, 4, 4, 4, 4)

            local obj = { Value = selected }

            for i, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size               = UDim2.new(1, 0, 0, 24)
                ob.BackgroundColor3   = Color3.fromRGB(60, 60, 72)
                ob.BackgroundTransparency = 0.5
                ob.BorderSizePixel    = 0
                ob.Text               = opt
                ob.TextSize           = 12
                ob.Font               = Enum.Font.Gotham
                ob.TextColor3         = T.Text
                ob.AutoButtonColor    = false
                ob.ZIndex             = 21
                ob.LayoutOrder        = i
                ob.Parent             = ddFrame
                corner(ob, 5)
                ob.MouseEnter:Connect(function() tw(ob, { BackgroundTransparency = 0.2 }) end)
                ob.MouseLeave:Connect(function() tw(ob, { BackgroundTransparency = 0.5 }) end)
                ob.MouseButton1Click:Connect(function()
                    selected  = opt
                    obj.Value = opt
                    selBtn.Text = opt .. "  ▾"
                    open = false
                    ddFrame.Visible = false
                    if cfg2.Callback then task.spawn(cfg2.Callback, opt) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                ddFrame.Visible = open
            end)
            return obj
        end

        -- ── COLOR PICKER ──────────────────────────────────────────────────────
        function tab:ColorPicker(cfg2)
            cfg2 = cfg2 or {}
            local currentColor = cfg2.Default or Color3.fromRGB(255, 0, 0)
            local h, s, v = Color3.toHSV(currentColor)
            local open = false

            local f = rowBase(36)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size          = UDim2.new(1, -60, 1, 0)
            nameLbl.Position      = UDim2.fromOffset(12, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text          = cfg2.Name or "Color"
            nameLbl.TextSize      = 13
            nameLbl.Font          = Enum.Font.GothamMedium
            nameLbl.TextColor3    = T.Text
            nameLbl.TextXAlignment= Enum.TextXAlignment.Left
            nameLbl.Parent        = f

            local swatch = Instance.new("Frame")
            swatch.Size           = UDim2.fromOffset(32, 20)
            swatch.Position       = UDim2.new(1, -42, 0.5, -10)
            swatch.BackgroundColor3= currentColor
            swatch.BorderSizePixel= 0
            swatch.Parent         = f
            corner(swatch, 5)
            stroke(swatch, T.Border, 1)

            -- Picker panel
            local pickerW = CONTENT_W - 28
            local pickerPanel = Instance.new("Frame")
            pickerPanel.Size          = UDim2.fromOffset(pickerW, 160)
            pickerPanel.Position      = UDim2.new(0, 0, 1, 5)
            pickerPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
            pickerPanel.BackgroundTransparency = 0.06
            pickerPanel.BorderSizePixel= 0
            pickerPanel.ZIndex        = 15
            pickerPanel.Visible       = false
            pickerPanel.ClipsDescendants = false
            pickerPanel.Parent        = f
            corner(pickerPanel, 8)
            stroke(pickerPanel, T.Border, 1, Enum.ApplyStrokeMode.Contextual)

            local ppInnerW = pickerW - 20
            local svW      = ppInnerW - 26
            local svH      = 130

            -- SV box (saturation/value)
            local svBox = Instance.new("Frame")
            svBox.Size            = UDim2.fromOffset(svW, svH)
            svBox.Position        = UDim2.fromOffset(10, 15)
            svBox.BackgroundColor3= Color3.fromHSV(h, 1, 1)
            svBox.BorderSizePixel = 0
            svBox.ZIndex          = 15
            svBox.Parent          = pickerPanel
            corner(svBox, 6)

            local svWhite = Instance.new("Frame")
            svWhite.Size          = UDim2.new(1,0,1,0)
            svWhite.BackgroundTransparency = 1
            svWhite.BorderSizePixel= 0
            svWhite.ZIndex        = 16
            svWhite.Parent        = svBox
            local wg = Instance.new("UIGradient")
            wg.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1)) })
            wg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1) })
            wg.Rotation = 0
            wg.Parent = svWhite

            local svDark = Instance.new("Frame")
            svDark.Size           = UDim2.new(1,0,1,0)
            svDark.BackgroundTransparency = 1
            svDark.BorderSizePixel= 0
            svDark.ZIndex         = 16
            svDark.Parent         = svBox
            local dg = Instance.new("UIGradient")
            dg.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0)) })
            dg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) })
            dg.Rotation = 90
            dg.Parent = svDark

            local svCursor = Instance.new("Frame")
            svCursor.Size         = UDim2.fromOffset(12, 12)
            svCursor.Position     = UDim2.new(s, -6, 1-v, -6)
            svCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            svCursor.BorderSizePixel= 0
            svCursor.ZIndex       = 18
            svCursor.Parent       = svBox
            corner(svCursor, 6)
            stroke(svCursor, Color3.fromRGB(0,0,0), 1)

            -- Hue bar
            local hueBar = Instance.new("Frame")
            hueBar.Size           = UDim2.fromOffset(18, svH)
            hueBar.Position       = UDim2.fromOffset(svW + 16, 15)
            hueBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
            hueBar.BorderSizePixel= 0
            hueBar.ZIndex         = 15
            hueBar.Parent         = pickerPanel
            corner(hueBar, 5)

            local hueGrad = Instance.new("UIGradient")
            hueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,     Color3.fromHSV(0,     1, 1)),
                ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                ColorSequenceKeypoint.new(0.5,   Color3.fromHSV(0.5,   1, 1)),
                ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                ColorSequenceKeypoint.new(1,     Color3.fromHSV(0,     1, 1)),
            })
            hueGrad.Rotation = 90
            hueGrad.Parent   = hueBar

            local hueCursor = Instance.new("Frame")
            hueCursor.Size        = UDim2.new(1, 6, 0, 5)
            hueCursor.Position    = UDim2.new(-0.15, 0, h, -2)
            hueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            hueCursor.BorderSizePixel= 0
            hueCursor.ZIndex      = 18
            hueCursor.Parent      = hueBar
            corner(hueCursor, 2)
            stroke(hueCursor, Color3.fromRGB(0,0,0), 1)

            local obj = { Value = currentColor }

            local function updateColor()
                currentColor = Color3.fromHSV(h, s, v)
                obj.Value    = currentColor
                swatch.BackgroundColor3 = currentColor
                svBox.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
                if cfg2.Callback then task.spawn(cfg2.Callback, currentColor) end
            end

            -- SV drag
            local svDragging = false
            svBox.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svDragging = true
                    local abs = svBox.AbsolutePosition; local sz = svBox.AbsoluteSize
                    s = math.clamp((i.Position.X-abs.X)/sz.X,0,1)
                    v = 1-math.clamp((i.Position.Y-abs.Y)/sz.Y,0,1)
                    svCursor.Position = UDim2.new(s,-6,1-v,-6)
                    updateColor()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if svDragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local abs = svBox.AbsolutePosition; local sz = svBox.AbsoluteSize
                    s = math.clamp((i.Position.X-abs.X)/sz.X,0,1)
                    v = 1-math.clamp((i.Position.Y-abs.Y)/sz.Y,0,1)
                    svCursor.Position = UDim2.new(s,-6,1-v,-6)
                    updateColor()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDragging=false end
            end)

            -- Hue drag
            local hueDragging = false
            hueBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hueDragging = true
                    local abs = hueBar.AbsolutePosition; local sz = hueBar.AbsoluteSize
                    h = math.clamp((i.Position.Y-abs.Y)/sz.Y,0,1)
                    hueCursor.Position = UDim2.new(-0.15,0,h,-2)
                    updateColor()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if hueDragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local abs = hueBar.AbsolutePosition; local sz = hueBar.AbsoluteSize
                    h = math.clamp((i.Position.Y-abs.Y)/sz.Y,0,1)
                    hueCursor.Position = UDim2.new(-0.15,0,h,-2)
                    updateColor()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hueDragging=false end
            end)

            -- toggle open
            local clickLayer = Instance.new("TextButton")
            clickLayer.Size               = UDim2.new(1,0,1,0)
            clickLayer.BackgroundTransparency = 1
            clickLayer.Text               = ""
            clickLayer.AutoButtonColor    = false
            clickLayer.Parent             = f
            clickLayer.MouseButton1Click:Connect(function()
                open = not open
                pickerPanel.Visible = open
            end)

            function obj:Set(c)
                currentColor = c
                h, s, v = Color3.toHSV(c)
                swatch.BackgroundColor3 = c
                svBox.BackgroundColor3  = Color3.fromHSV(h,1,1)
                svCursor.Position = UDim2.new(s,-6,1-v,-6)
                hueCursor.Position = UDim2.new(-0.15,0,h,-2)
            end
            return obj
        end

        return tab
    end  -- win:Tab()

    return win
end  -- FloatLib:Window()

return FloatLib
