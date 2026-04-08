--[[
  Xanix UI Library — built on the exact GUI template
  
  Usage:
    local Xanix = loadstring(game:HttpGet("RAW_URL"))()
    local Win = Xanix:CreateWindow({ Name = "My Hub" })
    local Tab = Win:CreateTab("Main")
    Tab:CreateButton({ Name = "Kill All", Callback = function() end })
    Tab:CreateToggle({ Name = "ESP", CurrentValue = false, Callback = function(v) end })
    Tab:CreateSlider({ Name = "Speed", Range={16,500}, Increment=1, CurrentValue=16, Callback=function(v) end })
    Tab:CreateColorPicker({ Name = "Color", Color=Color3.fromRGB(255,0,0), Callback=function(c) end })
    Tab:CreateDropdown({ Name = "Mode", Options={"A","B"}, CurrentOption={"A"}, Callback=function(o) end })
    Tab:CreateInput({ Name = "Player", PlaceholderText="name...", Callback=function(t) end })
    Tab:CreateSection("Section")
    Tab:CreateLabel("Info")
    Tab:CreateKeybind({ Name = "Key", CurrentKeybind="E", Callback=function() end })
    Xanix:Notify({ Title="Hello", Content="World", Duration=4 })
]]

local Xanix = {}
Xanix.__index = Xanix
Xanix.Flags = {}

local Players  = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local LP       = Players.LocalPlayer
local PG       = LP:WaitForChild("PlayerGui")

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ─── THEME (pure black / white / grey) ───────────────────────────────────────
local C = {
    Bg           = Color3.fromRGB(0,   0,   0),
    BgPanel      = Color3.fromRGB(0,   0,   0),
    BgPage       = Color3.fromRGB(0,   0,   0),
    TitleGrad1   = Color3.fromRGB(28,  28,  38),
    TitleGrad2   = Color3.fromRGB(20,  20,  28),
    Row          = Color3.fromRGB(0,   0,   0),
    RowHover     = Color3.fromRGB(16,  16,  18),
    RowBorder    = Color3.fromRGB(38,  38,  40),
    TabBtn       = Color3.fromRGB(0,   0,   0),
    TabBtnAct    = Color3.fromRGB(20,  20,  22),
    TabBorder    = Color3.fromRGB(50,  50,  55),
    SearchBg     = Color3.fromRGB(0,   0,   0),
    InputBg      = Color3.fromRGB(8,   8,   10),
    DdBg         = Color3.fromRGB(10,  10,  12),
    PanelBorder  = Color3.fromRGB(60,  60,  65),
    Text         = Color3.fromRGB(255, 255, 255),
    TextDim      = Color3.fromRGB(200, 200, 200),
    TextMuted    = Color3.fromRGB(120, 120, 125),
    Underline    = Color3.fromRGB(255, 255, 255),
    TrackOff     = Color3.fromRGB(38,  38,  40),
    TrackOn      = Color3.fromRGB(210, 210, 215),
    Fill         = Color3.fromRGB(210, 210, 215),
    NotifBg      = Color3.fromRGB(0,   0,   0),
}

local TW  = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW2 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function mk(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end
local function uiStroke(p, col, thick, alpha)
    local s = Instance.new("UIStroke")
    s.Color           = col   or C.PanelBorder
    s.Thickness       = thick or 1
    s.Transparency    = alpha or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode    = Enum.LineJoinMode.Round
    s.Parent          = p
    return s
end
local function pad(p, l, r, t, b)
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft   = UDim.new(0, l or 0)
    pd.PaddingRight  = UDim.new(0, r or 0)
    pd.PaddingTop    = UDim.new(0, t or 0)
    pd.PaddingBottom = UDim.new(0, b or 0)
    pd.Parent = p
    return pd
end
local function ll(p, sp)
    local l = Instance.new("UIListLayout")
    l.Padding   = UDim.new(0, sp or 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent    = p
    return l
end
local function tw(o, props, info)
    TweenSvc:Create(o, info or TW, props):Play()
end

-- ─── NOTIFICATIONS ────────────────────────────────────────────────────────────
local _nsg, _nlist

local function ensureNotif()
    if _nsg and _nsg.Parent then return end
    _nsg = mk("ScreenGui", {
        Name="XanixNotifs", ResetOnSpawn=false, IgnoreGuiInset=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=200, Parent=PG,
    })
    _nlist = mk("Frame", {
        Size=UDim2.new(0,260,1,0), Position=UDim2.new(1,-272,0,0),
        BackgroundTransparency=1, BorderSizePixel=0, Parent=_nsg,
    })
    mk("UIListLayout", {
        Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        FillDirection=Enum.FillDirection.Vertical, Parent=_nlist,
    })
    pad(_nlist, 6, 6, 10, 10)
end

function Xanix:Notify(data)
    task.spawn(function()
        ensureNotif(); data = data or {}
        local txt = (data.Title and ("✦  " .. data.Title) or "")
                 .. (data.Content and ("  ·  " .. data.Content) or "")
        local pill = mk("TextLabel", {
            Size=UDim2.new(0,248,0,44), BackgroundColor3=C.NotifBg,
            BackgroundTransparency=1, Text=txt,
            TextSize=13, Font=Enum.Font.GothamMedium, TextColor3=C.Text,
            TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Center,
            TextTransparency=1, Parent=_nlist,
        })
        corner(pill, 1000)
        uiStroke(pill, Color3.fromRGB(60,60,65), 1, 0)
        task.wait(0.05)
        tw(pill, {BackgroundTransparency=0.40}, TW2)
        tw(pill, {TextTransparency=0}, TW2)
        task.wait(data.Duration or 4)
        tw(pill, {BackgroundTransparency=1}, TW2)
        tw(pill, {TextTransparency=1}, TW2)
        task.wait(0.35); pill:Destroy()
    end)
end

-- ─── CREATE WINDOW ────────────────────────────────────────────────────────────
function Xanix:CreateWindow(cfg)
    cfg = cfg or {}
    local winName   = cfg.Name or "Xanix"
    local toggleKey = cfg.ToggleUIKeybind or "K"
    if typeof(toggleKey) == "EnumItem" then toggleKey = toggleKey.Name end

    -- ── Root ScreenGui ────────────────────────────────────────────────────────
    local sg = mk("ScreenGui", {
        Name="Xanix", ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=100, ResetOnSpawn=false, IgnoreGuiInset=false, Parent=PG,
    })

    -- ── Anchor (matches template exactly, relative-scaled) ────────────────────
    local Anchor = mk("Frame", {
        Name="Anchor", Parent=sg,
        BackgroundColor3=C.Bg, BackgroundTransparency=1,
        BorderSizePixel=0,
        Position=UDim2.new(0.33,0, 0.22,0),
        Size=UDim2.new(0.34,0, 0.50,0),
    })
    corner(Anchor, 12)

    -- ── ContentPanel (inside Anchor, offset right like template) ─────────────
    local ContentPanel = mk("Frame", {
        Name="ContentPanel", Parent=Anchor,
        BackgroundColor3=C.BgPanel, BorderSizePixel=0,
        ClipsDescendants=true,
        Position=UDim2.new(0.240000039,0, 0,0),
        Size=UDim2.new(0.964598835,0, 1,0),
    })
    corner(ContentPanel, 12)
    uiStroke(ContentPanel, Color3.fromRGB(255,255,255), 1, 0)

    -- ── TitleBar ──────────────────────────────────────────────────────────────
    local TitleBar = mk("Frame", {
        Name="TitleBar", Parent=ContentPanel,
        BackgroundColor3=C.TitleGrad1, BorderSizePixel=0,
        Size=UDim2.new(1,0, 0.104166672,0),
    })
    corner(TitleBar, 12)
    -- gradient: dark left → darker right
    local tg = Instance.new("UIGradient")
    tg.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.TitleGrad1),
        ColorSequenceKeypoint.new(1, C.TitleGrad2),
    })
    tg.Rotation = 90; tg.Parent = TitleBar

    -- white underline at bottom of title bar
    mk("Frame", {
        Parent=TitleBar, BackgroundColor3=C.Underline, BorderSizePixel=0,
        BackgroundTransparency=0.6,
        Position=UDim2.new(0,0, 0.980000019,0),
        Size=UDim2.new(1,0, 0.0199999996,0),
    })

    -- Title text
    mk("TextLabel", {
        Name="Title", Parent=TitleBar,
        BackgroundTransparency=1,
        Position=UDim2.new(0.0205580015,0, 0,0),
        Size=UDim2.new(0.882525682,0, 1,0),
        Font=Enum.Font.GothamBold, Text=winName,
        TextColor3=C.Text, TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    -- MinimizeBtn (matches template: BackgroundTransparency=1, text "–")
    local minimised = false
    local MinimizeBtn = mk("TextButton", {
        Name="MinimizeBtn", Parent=TitleBar,
        BackgroundColor3=Color3.fromRGB(40,40,50),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Position=UDim2.new(0.949839413,0, 0.200000018,0),
        Size=UDim2.new(0.0429948084,0, 0.599999964,0),
        AutoButtonColor=false,
        Font=Enum.Font.GothamBold, Text="-",
        TextColor3=C.Text, TextSize=20,
    })
    corner(MinimizeBtn, 6)
    MinimizeBtn.MouseEnter:Connect(function()
        tw(MinimizeBtn, {BackgroundTransparency=0.5})
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        tw(MinimizeBtn, {BackgroundTransparency=1})
    end)

    -- ── PagesContainer ────────────────────────────────────────────────────────
    local PagesContainer = mk("Frame", {
        Name="PagesContainer", Parent=ContentPanel,
        BackgroundColor3=Color3.fromRGB(15,15,20),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        Position=UDim2.new(0.0199999996,0, 0.119999997,0),
        Size=UDim2.new(0.959999979,0, 0.860000014,0),
    })

    -- ── TabList (separate from ContentPanel, left side of Anchor) ─────────────
    local TabList = mk("ScrollingFrame", {
        Name="TabList", Parent=Anchor,
        BackgroundColor3=C.BgPanel, BorderSizePixel=0,
        Position=UDim2.new(0,0, 0.078,0),
        Size=UDim2.new(0.219999999,0, 0.922,0),
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3,
        ScrollBarImageColor3=Color3.fromRGB(60,60,65),
        ScrollingDirection=Enum.ScrollingDirection.Y,
    })
    corner(TabList, 12)
    uiStroke(TabList, Color3.fromRGB(255,255,255), 1, 0)
    ll(TabList, 8)
    pad(TabList, 12,12,16,16)

    -- ── Search (direct child of ScreenGui, matches template) ──────────────────
    -- Search INSIDE Anchor — moves with drag automatically
    local Search = mk("TextBox", {
        Name="Search", Parent=Anchor,
        BackgroundColor3=C.SearchBg, BorderSizePixel=0,
        -- sits at top of anchor, same width as TabList, above it
        Position=UDim2.new(0,0, 0,0),
        Size=UDim2.new(0.219999999,0, 0.065,0),
        Font=Enum.Font.GothamMedium, Text="",
        PlaceholderText="Search...",
        TextColor3=C.Text, PlaceholderColor3=C.TextMuted,
        TextSize=13,
        ClearTextOnFocus=false, MultiLine=false,
    })
    corner(Search, 1000)
    uiStroke(Search, Color3.fromRGB(255,255,255), 1, 0)
    pad(Search, 10,28,0,0)

    mk("ImageLabel", {
        Size=UDim2.new(0,14,0,14),
        Position=UDim2.new(1,-20,0.5,-7),
        BackgroundTransparency=1,
        Image="rbxassetid://3926305904",
        ImageColor3=C.TextMuted,
        Parent=Search,
    })

    -- ── MobileButton (direct child of ScreenGui, mobile only) ────────────────
    local MobileButton = mk("TextButton", {
        Name="MobileButton", Parent=sg,
        BackgroundColor3=C.Bg, BorderSizePixel=0,
        Position=UDim2.new(0.5,-70, 0.01,0),
        Size=UDim2.new(0,140, 0,34),
        Font=Enum.Font.GothamMedium,
        Text="Open " .. winName,
        TextColor3=C.Text, TextSize=13,
        Visible=IS_MOBILE,
        AutoButtonColor=false,
    })
    corner(MobileButton, 100000)
    uiStroke(MobileButton, Color3.fromRGB(255,255,255), 1, 0)

    -- ─── STATE ────────────────────────────────────────────────────────────────
    local tabs      = {}
    local activeTab = nil
    local guiVis    = true

    -- Search filter
    Search:GetPropertyChangedSignal("Text"):Connect(function()
        local q = Search.Text:lower()
        for _, t in ipairs(tabs) do
            t.btn.Visible = q == "" or (t.name:lower():find(q, 1, true) ~= nil)
        end
    end)

    local function switchTab(t)
        if activeTab == t then return end
        for _, v in ipairs(tabs) do
            v.page.Visible = false
            tw(v.btn, {BackgroundColor3=C.TabBtn, TextColor3=C.TextDim})
        end
        t.page.Visible = true
        tw(t.btn, {BackgroundColor3=C.TabBtnAct, TextColor3=C.Text})
        activeTab = t
    end

    -- ─── DRAG (title bar only) ────────────────────────────────────────────────
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = Vector2.new(i.Position.X, i.Position.Y)
            startPos  = Anchor.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            local d = Vector2.new(i.Position.X, i.Position.Y) - dragStart
            Anchor.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
            -- Search is inside Anchor, moves automatically
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Minimise
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            tw(ContentPanel, {Size = UDim2.new(0.964598835,0, 0.104166672,0)}, TW2)
            tw(TabList, {Size = UDim2.new(0.219999999,0, 0.104166672,0)}, TW2)
            MinimizeBtn.Text = "+"
        else
            tw(ContentPanel, {Size = UDim2.new(0.964598835,0, 1,0)}, TW2)
            tw(TabList, {Size = UDim2.new(0.219999999,0, 0.925000012,0)}, TW2)
            MinimizeBtn.Text = "-"
        end
    end)

    -- K toggle
    UIS.InputBegan:Connect(function(i, processed)
        if processed then return end
        local ok, kc = pcall(function() return Enum.KeyCode[toggleKey] end)
        if ok and i.KeyCode == kc then
            guiVis         = not guiVis
            Anchor.Visible = guiVis
        end
    end)

    -- Mobile button
    MobileButton.MouseButton1Click:Connect(function()
        guiVis         = not guiVis
        Anchor.Visible = guiVis
        MobileButton.Text = guiVis and ("Hide " .. winName) or ("Open " .. winName)
    end)

    -- ─── WINDOW OBJECT ────────────────────────────────────────────────────────
    local Window = {}

    function Window:CreateTab(name, _icon)
        -- Tab button — matches template style (full width, rounded 6, TextSize 14)
        local btn = mk("TextButton", {
            Name=name, Parent=TabList,
            BackgroundColor3=C.TabBtn, BorderSizePixel=0,
            Size=UDim2.new(1,0, 0,28),
            AutoButtonColor=false,
            Font=Enum.Font.GothamMedium, Text=name,
            TextColor3=C.TextDim, TextSize=14,
            TextWrapped=false, TextTruncate=Enum.TextTruncate.AtEnd,
            LayoutOrder=#tabs + 1,
        })
        corner(btn, 6)
        uiStroke(btn, C.TabBorder, 1, 0)

        -- Active indicator bar (left edge)
        local bar = mk("Frame", {
            Size=UDim2.fromOffset(3,16), Position=UDim2.new(0,-1,0.5,-8),
            BackgroundColor3=C.Text, BackgroundTransparency=1,
            BorderSizePixel=0, Parent=btn,
        })
        corner(bar, 2)

        -- Page (ScrollingFrame inside PagesContainer)
        local page = mk("ScrollingFrame", {
            Name=name, Parent=PagesContainer,
            BackgroundColor3=C.BgPage,
            BackgroundTransparency=0.5,
            BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),
            ScrollBarThickness=4,
            ScrollBarImageColor3=Color3.fromRGB(60,60,65),
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ClipsDescendants=true,
            Visible=false,
        })
        corner(page, 8)
        ll(page, 8)
        pad(page, 10,10,10,10)

        local t = { name=name, btn=btn, bar=bar, page=page }
        table.insert(tabs, t)

        btn.MouseEnter:Connect(function()
            if activeTab ~= t then
                tw(btn, {BackgroundColor3=C.RowHover, TextColor3=C.Text})
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= t then
                tw(btn, {BackgroundColor3=C.TabBtn, TextColor3=C.TextDim})
            end
        end)
        btn.MouseButton1Click:Connect(function()
            dragging = false
            switchTab(t)
        end)

        if #tabs == 1 then switchTab(t) end

        -- ── ROW ──────────────────────────────────────────────────────────────
        local FS    = IS_MOBILE and 12 or 13
        local ROW_H = IS_MOBILE and 30 or 34

        local function makeRow(h)
            local f = mk("Frame", {
                Size=UDim2.new(1,0,0, h or ROW_H),
                BackgroundColor3=C.Row,
                BackgroundTransparency=0,
                BorderSizePixel=0, Parent=page,
            })
            corner(f, 7)
            uiStroke(f, C.RowBorder, 1, 0)
            f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.RowHover}) end)
            f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.Row}) end)
            return f
        end

        local Tab = {}

        -- SECTION ─────────────────────────────────────────────────────────────
        function Tab:CreateSection(n)
            local f = mk("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Parent=page})
            mk("TextLabel",{
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text=(n or ""):upper(), TextSize=9, Font=Enum.Font.GothamBold,
                TextColor3=C.TextMuted, TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })
            pad(f,2,2,0,0)
            local sv={}; function sv:Set(x) f:FindFirstChildWhichIsA("TextLabel").Text=(x or ""):upper() end
            return sv
        end

        -- LABEL ───────────────────────────────────────────────────────────────
        function Tab:CreateLabel(txt, _icon, col)
            local f = makeRow(34)
            mk("TextLabel",{
                Size=UDim2.new(1,-20,1,0), Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1, Text=txt or "", TextSize=FS,
                Font=Enum.Font.GothamMedium, TextColor3=col or C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=f,
            })
            local lv={}; function lv:Set(s) f:FindFirstChildWhichIsA("TextLabel").Text=s or "" end
            return lv
        end

        -- PARAGRAPH ───────────────────────────────────────────────────────────
        function Tab:CreateParagraph(s)
            local f = makeRow(nil); f.AutomaticSize = Enum.AutomaticSize.Y
            mk("TextLabel",{
                Size=UDim2.new(1,-20,0,18), Position=UDim2.fromOffset(12,7),
                BackgroundTransparency=1, Text=s.Title or "", TextSize=FS,
                Font=Enum.Font.GothamBold, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })
            local cl = mk("TextLabel",{
                Size=UDim2.new(1,-20,0,0), Position=UDim2.fromOffset(12,26),
                BackgroundTransparency=1, Text=s.Content or "", TextSize=FS-1,
                Font=Enum.Font.Gotham, TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
                AutomaticSize=Enum.AutomaticSize.Y, Parent=f,
            })
            local pv={}; function pv:Set(n)
                f:FindFirstChildWhichIsA("TextLabel").Text=n.Title or ""
                cl.Text=n.Content or ""
            end
            return pv
        end

        -- BUTTON ──────────────────────────────────────────────────────────────
        function Tab:CreateButton(s)
            local f = makeRow(ROW_H)

            -- left accent pip
            local pip = mk("Frame",{
                Size=UDim2.fromOffset(3,12), Position=UDim2.new(0,0,0.5,-6),
                BackgroundColor3=C.Text, BackgroundTransparency=0,
                BorderSizePixel=0, Parent=f,
            })
            corner(pip,2)

            local lbl = mk("TextLabel",{
                Size=UDim2.new(1,-46,1,0), Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1, Text=s.Name or "Button", TextSize=FS,
                Font=Enum.Font.GothamMedium, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })

            local arr = mk("TextLabel",{
                Size=UDim2.fromOffset(28,ROW_H), Position=UDim2.new(1,-32,0,0),
                BackgroundTransparency=1, Text="›", TextSize=17,
                Font=Enum.Font.GothamBold, TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Center, Parent=f,
            })

            local cl = mk("TextButton",{
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                Text="", AutoButtonColor=false, Parent=f,
            })
            cl.MouseButton1Click:Connect(function()
                tw(f,{BackgroundColor3=Color3.fromRGB(20,20,22)})
                tw(arr,{TextColor3=C.Text})
                task.delay(0.2, function()
                    tw(f,{BackgroundColor3=C.Row})
                    tw(arr,{TextColor3=C.TextMuted})
                end)
                if s.Callback then task.spawn(pcall, s.Callback) end
            end)

            local bv={}; function bv:Set(n) lbl.Text=n end
            return bv
        end

        -- TOGGLE ──────────────────────────────────────────────────────────────
        function Tab:CreateToggle(s)
            local state = s.CurrentValue == true
            local f     = makeRow(ROW_H)

            mk("TextLabel",{
                Size=UDim2.new(1,-62,1,0), Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1, Text=s.Name or "Toggle", TextSize=FS,
                Font=Enum.Font.GothamMedium, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })

            local TW_W, TW_H = 38, 21
            local track = mk("Frame",{
                Size=UDim2.fromOffset(TW_W,TW_H),
                Position=UDim2.new(1,-(TW_W+10), 0.5,-TW_H/2),
                BackgroundColor3=state and C.TrackOn or C.TrackOff,
                BorderSizePixel=0, Parent=f,
            })
            corner(track,11)

            local thumb = mk("Frame",{
                Size=UDim2.fromOffset(15,15),
                Position=state and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3),
                BackgroundColor3=state and Color3.fromRGB(20,20,22) or Color3.fromRGB(150,150,155),
                BorderSizePixel=0, Parent=track,
            })
            corner(thumb,8)

            s.CurrentValue = state
            local function setV(v)
                state=v; s.CurrentValue=v
                tw(track, {BackgroundColor3=v and C.TrackOn or C.TrackOff})
                tw(thumb, {
                    Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3),
                    BackgroundColor3=v and Color3.fromRGB(20,20,22) or Color3.fromRGB(150,150,155),
                })
                if s.Callback then task.spawn(pcall, s.Callback, v) end
            end

            local cl = mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function() setV(not state) end)
            function s:Set(v) setV(v) end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- SLIDER ──────────────────────────────────────────────────────────────
        function Tab:CreateSlider(s)
            local mn  = s.Range and s.Range[1] or 0
            local mx  = s.Range and s.Range[2] or 100
            local inc = s.Increment or 1
            local val = math.clamp(s.CurrentValue or mn, mn, mx)
            local suf = s.Suffix and (" " .. s.Suffix) or ""
            local f   = makeRow(50)

            mk("TextLabel",{
                Size=UDim2.new(0.58,0,0,20), Position=UDim2.fromOffset(12,6),
                BackgroundTransparency=1, Text=s.Name or "Slider", TextSize=FS,
                Font=Enum.Font.GothamMedium, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })

            local function fmt(v)
                local r = math.floor(v/inc+0.5)*inc
                return (math.floor(r)==r and tostring(math.floor(r)) or string.format("%.2f",r))..suf
            end

            local vl = mk("TextLabel",{
                Size=UDim2.new(0.42,-14,0,20), Position=UDim2.new(0.58,0,0,6),
                BackgroundTransparency=1, Text=fmt(val), TextSize=FS-1,
                Font=Enum.Font.Gotham, TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Right, Parent=f,
            })
            pad(vl,0,12,0,0)

            local tBg = mk("Frame",{
                Size=UDim2.new(1,-24,0,4), Position=UDim2.new(0,12,1,-14),
                BackgroundColor3=Color3.fromRGB(35,35,38), BackgroundTransparency=0,
                BorderSizePixel=0, Parent=f,
            })
            corner(tBg,2)

            local pct0 = (val-mn)/(mx-mn)
            local fill = mk("Frame",{
                Size=UDim2.new(pct0,0,1,0),
                BackgroundColor3=C.Fill, BorderSizePixel=0, Parent=tBg,
            })
            corner(fill,2)

            local knob = mk("Frame",{
                Size=UDim2.fromOffset(14,14),
                Position=UDim2.new(pct0,-7, 0.5,-7),
                BackgroundColor3=Color3.fromRGB(255,255,255),
                BorderSizePixel=0, ZIndex=3, Parent=tBg,
            })
            corner(knob,7)

            s.CurrentValue = val
            local sliding  = false

            local function upd(px)
                local abs = tBg.AbsolutePosition
                local sz  = tBg.AbsoluteSize
                local pct = math.clamp((px-abs.X)/sz.X, 0, 1)
                local nv  = math.floor((mn+pct*(mx-mn))/inc+0.5)*inc
                nv = math.clamp(nv,mn,mx)
                s.CurrentValue=nv; vl.Text=fmt(nv)
                tw(fill,{Size=UDim2.new(pct,0,1,0)})
                tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
                if s.Callback then task.spawn(pcall,s.Callback,nv) end
            end

            local interact = mk("TextButton",{
                Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,0.5,-11),
                BackgroundTransparency=1, Text="", AutoButtonColor=false,
                ZIndex=4, Parent=tBg,
            })
            interact.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then
                    sliding=true; dragging=false; upd(i.Position.X)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if not sliding then return end
                if i.UserInputType==Enum.UserInputType.MouseMovement
                or i.UserInputType==Enum.UserInputType.Touch then upd(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)

            function s:Set(v)
                v=math.clamp(v,mn,mx); local pct=(v-mn)/(mx-mn)
                s.CurrentValue=v; vl.Text=fmt(v)
                tw(fill,{Size=UDim2.new(pct,0,1,0)})
                tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- INPUT ───────────────────────────────────────────────────────────────
        function Tab:CreateInput(s)
            local f = makeRow(48)
            mk("TextLabel",{
                Size=UDim2.new(1,0,0,15), Position=UDim2.fromOffset(12,5),
                BackgroundTransparency=1, Text=s.Name or "Input",
                TextSize=9, Font=Enum.Font.GothamBold, TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })
            local ibg = mk("Frame",{
                Size=UDim2.new(1,-24,0,24), Position=UDim2.fromOffset(12,23),
                BackgroundColor3=C.InputBg, BackgroundTransparency=0,
                BorderSizePixel=0, Parent=f,
            })
            corner(ibg,5)
            uiStroke(ibg, C.RowBorder, 1, 0)
            local tb = mk("TextBox",{
                Size=UDim2.new(1,-14,1,0), Position=UDim2.fromOffset(7,0),
                BackgroundTransparency=1, Text=s.CurrentValue or "",
                PlaceholderText=s.PlaceholderText or "Enter text...",
                TextSize=FS, Font=Enum.Font.Gotham, TextColor3=C.Text,
                PlaceholderColor3=C.TextMuted, TextXAlignment=Enum.TextXAlignment.Left,
                ClearTextOnFocus=false, MultiLine=false, BorderSizePixel=0, Parent=ibg,
            })
            tb.FocusLost:Connect(function()
                s.CurrentValue=tb.Text
                if s.Callback then task.spawn(pcall,s.Callback,tb.Text) end
                if s.RemoveTextAfterFocusLost then tb.Text="" end
            end)
            function s:Set(v) tb.Text=v; s.CurrentValue=v end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- DROPDOWN ────────────────────────────────────────────────────────────
        function Tab:CreateDropdown(s)
            local opts  = s.Options or {}
            local multi = s.MultipleOptions == true
            if s.CurrentOption then
                if type(s.CurrentOption)=="string" then s.CurrentOption={s.CurrentOption} end
            else s.CurrentOption={} end
            if not multi then s.CurrentOption={s.CurrentOption[1]} end

            local open = false
            local f    = makeRow(ROW_H); f.ClipsDescendants=false

            mk("TextLabel",{
                Size=UDim2.new(0.5,0,1,0), Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1, Text=s.Name or "Dropdown", TextSize=FS,
                Font=Enum.Font.GothamMedium, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })

            local sbH = 26
            local selBtn = mk("TextButton",{
                Size=UDim2.new(0.46,-8,0,sbH),
                Position=UDim2.new(0.52,2, 0.5,-sbH/2),
                BackgroundColor3=C.InputBg, BackgroundTransparency=0,
                BorderSizePixel=0, TextSize=FS-1, Font=Enum.Font.Gotham,
                TextColor3=C.Text, AutoButtonColor=false, Parent=f,
            })
            corner(selBtn,5); uiStroke(selBtn, C.RowBorder, 1, 0)

            local function selTxt()
                if #s.CurrentOption==0 then return "None  ▾"
                elseif #s.CurrentOption==1 then return s.CurrentOption[1].."  ▾"
                else return "Various  ▾" end
            end
            selBtn.Text = selTxt()

            local optH = 27
            local ddH  = math.min(#opts,6)*optH + 8
            -- Parent dd to sg so it always renders on top
            local ddF = mk("Frame",{
                BackgroundColor3=C.DdBg, BackgroundTransparency=0,
                BorderSizePixel=0, ZIndex=60, Visible=false,
                ClipsDescendants=true, Parent=sg,
            })
            corner(ddF,8); uiStroke(ddF, C.PanelBorder, 1, 0)

            local ddSF = mk("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                BorderSizePixel=0, ScrollBarThickness=2,
                ScrollBarImageColor3=Color3.fromRGB(55,55,58),
                CanvasSize=UDim2.new(0,0,0,0),
                AutomaticCanvasSize=Enum.AutomaticSize.Y,
                ZIndex=61, Parent=ddF,
            })
            ll(ddSF,2); pad(ddSF,4,4,4,4)

            local function posDD()
                local abs = selBtn.AbsolutePosition
                local w   = selBtn.AbsoluteSize.X
                ddF.Size     = UDim2.fromOffset(w, ddH)
                ddF.Position = UDim2.fromOffset(abs.X, abs.Y+selBtn.AbsoluteSize.Y+2)
            end

            for _, opt in ipairs(opts) do
                local ob = mk("TextButton",{
                    Size=UDim2.new(1,0,0,optH),
                    BackgroundColor3=Color3.fromRGB(14,14,16),
                    BackgroundTransparency=0, BorderSizePixel=0,
                    Text=opt, TextSize=FS-1, Font=Enum.Font.Gotham,
                    TextColor3=C.Text, AutoButtonColor=false, ZIndex=62, Parent=ddSF,
                })
                corner(ob,5)
                if table.find(s.CurrentOption,opt) then
                    ob.BackgroundColor3=Color3.fromRGB(22,22,24)
                end
                ob.MouseEnter:Connect(function()
                    tw(ob,{BackgroundColor3=Color3.fromRGB(22,22,24)})
                end)
                ob.MouseLeave:Connect(function()
                    tw(ob,{BackgroundColor3=table.find(s.CurrentOption,opt) and Color3.fromRGB(22,22,24) or Color3.fromRGB(14,14,16)})
                end)
                ob.MouseButton1Click:Connect(function()
                    if not multi then
                        s.CurrentOption={opt}; selBtn.Text=selTxt()
                        open=false; ddF.Visible=false
                    else
                        local idx=table.find(s.CurrentOption,opt)
                        if idx then
                            table.remove(s.CurrentOption,idx)
                            tw(ob,{BackgroundColor3=Color3.fromRGB(14,14,16)})
                        else
                            table.insert(s.CurrentOption,opt)
                            tw(ob,{BackgroundColor3=Color3.fromRGB(22,22,24)})
                        end
                        selBtn.Text=selTxt()
                    end
                    if s.Callback then task.spawn(pcall,s.Callback,s.CurrentOption) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open=not open; if open then posDD() end; ddF.Visible=open
            end)
            function s:Set(v)
                if type(v)=="string" then v={v} end
                s.CurrentOption=v; selBtn.Text=selTxt()
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- KEYBIND ─────────────────────────────────────────────────────────────
        function Tab:CreateKeybind(s)
            local checking = false
            local f        = makeRow(ROW_H)

            mk("TextLabel",{
                Size=UDim2.new(0.55,0,1,0), Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1, Text=s.Name or "Keybind", TextSize=FS,
                Font=Enum.Font.GothamMedium, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })

            local kbgH = 26
            local kbg  = mk("Frame",{
                Size=UDim2.new(0.4,-8,0,kbgH),
                Position=UDim2.new(0.57,2, 0.5,-kbgH/2),
                BackgroundColor3=C.InputBg, BackgroundTransparency=0,
                BorderSizePixel=0, Parent=f,
            })
            corner(kbg,5); uiStroke(kbg,C.RowBorder,1,0)

            local ktb = mk("TextBox",{
                Size=UDim2.new(1,-12,1,0), Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1, Text=s.CurrentKeybind or "None",
                TextSize=FS-1, Font=Enum.Font.Gotham, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Center,
                ClearTextOnFocus=false, BorderSizePixel=0, Parent=kbg,
            })

            ktb.Focused:Connect(function() checking=true; ktb.Text="" end)
            ktb.FocusLost:Connect(function()
                checking=false
                if ktb.Text=="" then ktb.Text=s.CurrentKeybind or "None" end
            end)
            UIS.InputBegan:Connect(function(i,p)
                if p then return end
                if checking then
                    if i.KeyCode~=Enum.KeyCode.Unknown then
                        local kn=string.split(tostring(i.KeyCode),".")[3]
                        ktb.Text=kn; s.CurrentKeybind=kn; ktb:ReleaseFocus()
                        if s.CallOnChange and s.Callback then task.spawn(pcall,s.Callback,kn) end
                    end
                elseif s.CurrentKeybind and not s.HoldToInteract then
                    local ok,kc=pcall(function() return Enum.KeyCode[s.CurrentKeybind] end)
                    if ok and i.KeyCode==kc and s.Callback then task.spawn(pcall,s.Callback) end
                end
            end)
            function s:Set(v) s.CurrentKeybind=v; ktb.Text=v end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- COLOR PICKER ────────────────────────────────────────────────────────
        function Tab:CreateColorPicker(s)
            local cc    = s.Color or Color3.fromRGB(255,0,0)
            local h, sv_s, sv_v = Color3.toHSV(cc)
            local open  = false

            local f = makeRow(ROW_H); f.ClipsDescendants=false

            mk("TextLabel",{
                Size=UDim2.new(1,-50,1,0), Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1, Text=s.Name or "Color", TextSize=FS,
                Font=Enum.Font.GothamMedium, TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=f,
            })

            local SW,SH = 32,20
            local swatch = mk("Frame",{
                Size=UDim2.fromOffset(SW,SH),
                Position=UDim2.new(1,-(SW+10), 0.5,-SH/2),
                BackgroundColor3=cc, BorderSizePixel=0, Parent=f,
            })
            corner(swatch,5); uiStroke(swatch,C.RowBorder,1,0)

            -- Picker panel parented to sg (always on top)
            local pW,pHgt = 290,165
            local svW,svH = pW-42, pHgt-30

            local pp = mk("Frame",{
                Size=UDim2.fromOffset(pW,pHgt),
                BackgroundColor3=C.DdBg, BackgroundTransparency=0,
                BorderSizePixel=0, ZIndex=60, Visible=false,
                ClipsDescendants=false, Parent=sg,
            })
            corner(pp,10); uiStroke(pp,C.PanelBorder,1,0)

            local svB = mk("Frame",{
                Size=UDim2.fromOffset(svW,svH), Position=UDim2.fromOffset(10,10),
                BackgroundColor3=Color3.fromHSV(h,1,1),
                BorderSizePixel=0, ZIndex=61, Parent=pp,
            })
            corner(svB,6)

            local function mkg(parent, rot, cs, ts)
                local fr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=62,Parent=parent})
                local g=Instance.new("UIGradient"); g.Color=cs; g.Rotation=rot
                if ts then g.Transparency=ts end; g.Parent=fr
            end
            mkg(svB,0,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkg(svB,90,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))

            local svCur = mk("Frame",{
                Size=UDim2.fromOffset(12,12), Position=UDim2.new(sv_s,-6,1-sv_v,-6),
                BackgroundColor3=C.Text, BorderSizePixel=0, ZIndex=64, Parent=svB,
            })
            corner(svCur,6)

            local hBar = mk("Frame",{
                Size=UDim2.fromOffset(16,svH), Position=UDim2.fromOffset(svW+14,10),
                BackgroundColor3=C.Text, BorderSizePixel=0, ZIndex=61, Parent=pp,
            })
            corner(hBar,5)
            local hg=Instance.new("UIGradient"); hg.Rotation=90
            hg.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1,1)),
                ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
                ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
                ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,  1,1)),
                ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
                ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV(0,    1,1)),
            }); hg.Parent=hBar

            local hCur = mk("Frame",{
                Size=UDim2.new(1,5,0,4), Position=UDim2.new(-0.15,0,h,-2),
                BackgroundColor3=C.Text, BorderSizePixel=0, ZIndex=63, Parent=hBar,
            })
            corner(hCur,2)

            local function updC()
                cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end
            end

            local function posPP()
                local abs = swatch.AbsolutePosition
                pp.Position = UDim2.fromOffset(
                    math.max(0, abs.X - pW + SW + 10),
                    abs.Y + SH + 4
                )
            end

            local svD,hD=false,false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svD=true; dragging=false
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1)
                    sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); updC()
                end
            end)
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hD=true; dragging=false
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    hCur.Position=UDim2.new(-0.15,0,h,-2); updC()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
                if svD then
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1)
                    sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); updC()
                end
                if hD then
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    hCur.Position=UDim2.new(-0.15,0,h,-2); updC()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svD=false; hD=false
                end
            end)

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function()
                open=not open; if open then posPP() end; pp.Visible=open
            end)

            function s:Set(c)
                cc=c; h,sv_s,sv_v=Color3.toHSV(c); s.Color=c
                swatch.BackgroundColor3=c; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6)
                hCur.Position=UDim2.new(-0.15,0,h,-2)
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        return Tab
    end  -- Window:CreateTab

    function Window:Destroy() sg:Destroy() end
    function Window.ModifyTheme(_) end

    task.delay(0.6, function()
        Xanix:Notify({Title="Xanix", Content="Loaded "..winName, Duration=3})
    end)
    task.delay(2, function()
        Xanix:Notify({Title="Tip", Content="Press K to open and close the UI", Duration=4})
    end)

    return Window
end  -- Xanix:CreateWindow

-- Rayfield compat stubs
function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(_)    end
function Xanix:IsVisible()         return true end
function Xanix:Destroy()           end

return Xanix
