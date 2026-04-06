--[[
  ██╗  ██╗ █████╗ ███╗   ██╗██╗██╗  ██╗
  ╚██╗██╔╝██╔══██╗████╗  ██║██║╚██╗██╔╝
   ╚███╔╝ ███████║██╔██╗ ██║██║ ╚███╔╝
   ██╔██╗ ██╔══██║██║╚██╗██║██║ ██╔██╗
  ██╔╝ ██╗██║  ██║██║ ╚████║██║██╔╝ ██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
  v2.1  |  Built from the real GUI template

  DROP-IN RAYFIELD REPLACEMENT
  local Xanix = loadstring(game:HttpGet("RAW_URL"))()
  local Win   = Xanix:CreateWindow({ Name = "My Hub" })
  local Tab   = Win:CreateTab("Combat")
  Tab:CreateButton   ({ Name="Do Thing",   Callback=function() end })
  Tab:CreateToggle   ({ Name="Aimbot",     CurrentValue=false, Flag="abt",  Callback=function(v) end })
  Tab:CreateSlider   ({ Name="Speed",      Range={16,500},     Increment=1, CurrentValue=16,  Callback=function(v) end })
  Tab:CreateInput    ({ Name="Target",     PlaceholderText="name", Callback=function(t) end })
  Tab:CreateDropdown ({ Name="Team",       Options={"A","B"}, CurrentOption={"A"}, Callback=function(o) end })
  Tab:CreateColorPicker({ Name="Color",   Color=Color3.fromRGB(255,0,0), Callback=function(c) end })
  Tab:CreateKeybind  ({ Name="Toggle UI", CurrentKeybind="K", Callback=function() end })
  Tab:CreateSection  ("Section Title")
  Tab:CreateLabel    ("Some info text")
  Tab:CreateParagraph({ Title="About", Content="Description here." })
  Xanix:Notify({ Title="Ready", Content="Script loaded!", Duration=4 })
]]

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer
local PG           = LP:WaitForChild("PlayerGui")

local Xanix = { Flags = {} }
Xanix.__index = Xanix

local T = {
    PanelBg     = Color3.fromRGB(8,   8,   14),
    ContentBg   = Color3.fromRGB(10,  10,  16),
    RowBg       = Color3.fromRGB(20,  20,  30),
    RowHoverBg  = Color3.fromRGB(28,  28,  44),
    Border      = Color3.fromRGB(60,  60,  70),
    BorderAlpha = 0,
    AccBorder   = Color3.fromRGB(99,  102, 241),
    AccBorderA  = 0.45,
    TabBg       = Color3.fromRGB(83,  83,  83),
    TabAlpha    = 0.35,
    TabActiveA  = 0.10,
    TabActiveBg = Color3.fromRGB(99,  102, 241),
    Text        = Color3.fromRGB(240, 240, 255),
    TextDim     = Color3.fromRGB(160, 162, 200),
    TextMuted   = Color3.fromRGB(95,  97,  140),
    SecText     = Color3.fromRGB(70,  72,  115),
    Accent      = Color3.fromRGB(99,  102, 241),
    AccentLight = Color3.fromRGB(148, 151, 255),
    TrackOff    = Color3.fromRGB(38,  38,  58),
    TrackOn     = Color3.fromRGB(99,  102, 241),
    Thumb       = Color3.fromRGB(235, 237, 255),
    SliderTrack = Color3.fromRGB(25,  25,  40),
    SliderFill  = Color3.fromRGB(99,  102, 241),
    InputBg     = Color3.fromRGB(15,  15,  24),
    GearBg      = Color3.fromRGB(35,  35,  40),
    GearIcon    = Color3.fromRGB(200, 200, 210),
    DotRed      = Color3.fromRGB(255, 95,  87),
    DotYellow   = Color3.fromRGB(255, 189, 46),
    DotGreen    = Color3.fromRGB(40,  200, 64),
    NotifBg     = Color3.fromRGB(10,  10,  16),
}

local TI_FAST  = TweenInfo.new(0.13, Enum.EasingStyle.Quad,        Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.22, Enum.EasingStyle.Quad,        Enum.EasingDirection.Out)
local TI_EXP   = TweenInfo.new(0.38, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local TI_QUART = TweenInfo.new(0.26, Enum.EasingStyle.Quart,       Enum.EasingDirection.Out)

local function tw(o, p, ti) TweenService:Create(o, ti or TI_FAST, p):Play() end

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function uiStroke(p, col, alpha, thick, mode)
    local s = Instance.new("UIStroke")
    s.Color=col or T.Border; s.Transparency=alpha or T.BorderAlpha; s.Thickness=thick or 1
    s.ApplyStrokeMode=mode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode=Enum.LineJoinMode.Round; s.Parent=p; return s
end
local function uiPad(p, l, r, t, b)
    local pd=Instance.new("UIPadding")
    pd.PaddingLeft=UDim.new(0,l or 0); pd.PaddingRight=UDim.new(0,r or 0)
    pd.PaddingTop=UDim.new(0,t or 0); pd.PaddingBottom=UDim.new(0,b or 0); pd.Parent=p
end
local function uiList(p, sp)
    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,sp or 4)
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.FillDirection=Enum.FillDirection.Vertical; l.Parent=p; return l
end
local function frame(parent, bg, alpha, size, pos)
    local f=Instance.new("Frame"); f.BackgroundColor3=bg or Color3.new()
    f.BackgroundTransparency=alpha or 0; f.BorderSizePixel=0
    f.Size=size or UDim2.new(1,0,1,0); f.Position=pos or UDim2.new(); f.Parent=parent; return f
end
local function textLbl(parent, txt, size, col, font, xa)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
    l.Text=txt or ""; l.TextSize=size or 13; l.Font=font or Enum.Font.GothamMedium
    l.TextColor3=col or T.Text; l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextYAlignment=Enum.TextYAlignment.Center; l.TextWrapped=true
    l.Size=UDim2.new(1,0,1,0); l.Parent=parent; return l
end

-- NOTIFICATIONS
local _nh
local function ensureHolder()
    if _nh and _nh.Parent then return end
    local sg=Instance.new("ScreenGui"); sg.Name="XanixNotifs"; sg.ResetOnSpawn=false
    sg.IgnoreGuiInset=true; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=PG
    local h=frame(sg,Color3.new(),1,UDim2.fromOffset(285,600),UDim2.new(1,-298,0,0))
    local ll=uiList(h,8); ll.VerticalAlignment=Enum.VerticalAlignment.Bottom
    uiPad(h,0,0,8,8); _nh=h
end

function Xanix:Notify(data)
    task.spawn(function()
        ensureHolder(); data=data or {}; local dur=data.Duration or 4
        local card=frame(_nh,T.NotifBg,0.06,UDim2.new(1,0,0,0))
        card.ClipsDescendants=false; corner(card,10); uiStroke(card,T.Border,0.78,1)
        local bar=frame(card,T.Accent,0,UDim2.fromOffset(3,0),UDim2.fromOffset(-10,10)); corner(bar,2)
        local inner=frame(card,Color3.new(),1,UDim2.new(1,-24,1,0),UDim2.fromOffset(16,0))
        local tl=Instance.new("TextLabel"); tl.BackgroundTransparency=1; tl.TextTransparency=1
        tl.Size=UDim2.new(1,0,0,20); tl.Position=UDim2.fromOffset(0,10); tl.Text=data.Title or "Notification"
        tl.TextSize=13; tl.Font=Enum.Font.GothamBold; tl.TextColor3=T.Text
        tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=inner
        local bl=Instance.new("TextLabel"); bl.BackgroundTransparency=1; bl.TextTransparency=1
        bl.Size=UDim2.new(1,0,0,0); bl.Position=UDim2.fromOffset(0,33); bl.Text=data.Content or ""
        bl.TextSize=12; bl.Font=Enum.Font.Gotham; bl.TextColor3=T.TextDim
        bl.TextXAlignment=Enum.TextXAlignment.Left; bl.TextWrapped=true; bl.Parent=inner
        task.wait()
        local bh=bl.TextBounds.Y; local ch=math.max(bh+54,60)
        card.Size=UDim2.new(1,0,0,ch); bl.Size=UDim2.new(1,0,0,bh+4)
        tw(bar,{Size=UDim2.fromOffset(3,ch-20)},TI_EXP); tw(card,{BackgroundTransparency=0.06},TI_EXP)
        tw(tl,{TextTransparency=0},TI_EXP); task.wait(0.08); tw(bl,{TextTransparency=0.2},TI_EXP)
        task.wait(dur)
        tw(card,{BackgroundTransparency=1},TI_EXP); tw(tl,{TextTransparency=1},TI_EXP)
        tw(bl,{TextTransparency=1},TI_EXP); tw(bar,{BackgroundTransparency=1},TI_EXP)
        task.wait(0.45); card:Destroy()
    end)
end

function Xanix:CreateWindow(cfg)
    cfg=cfg or {}
    -- ScreenGui matching original template
    local sg=Instance.new("ScreenGui"); sg.Name="Window"; sg.ResetOnSpawn=true
    sg.IgnoreGuiInset=false; sg.DisplayOrder=100; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=PG

    -- SEARCH BAR (template pos/size)
    local searchBar=Instance.new("TextBox"); searchBar.Name="SearchBar"
    searchBar.Position=UDim2.new(0.2046,0,0.1765,0); searchBar.Size=UDim2.new(0.0709,0,0.0441,0)
    searchBar.BackgroundColor3=Color3.fromRGB(0,0,0); searchBar.BackgroundTransparency=0.30
    searchBar.Text=""; searchBar.PlaceholderText="  Search tabs"
    searchBar.TextSize=13; searchBar.Font=Enum.Font.GothamMedium
    searchBar.TextColor3=T.Text; searchBar.PlaceholderColor3=T.TextMuted
    searchBar.TextXAlignment=Enum.TextXAlignment.Left; searchBar.ClearTextOnFocus=false
    searchBar.MultiLine=false; searchBar.BorderSizePixel=0; searchBar.Parent=sg
    corner(searchBar,6); uiStroke(searchBar,T.Border,0,1,Enum.ApplyStrokeMode.Contextual); uiPad(searchBar,10,10,0,0)

    -- TAB SCROLLING FRAME (template pos/size)
    local tabSF=Instance.new("ScrollingFrame"); tabSF.Name="ScrollingFrame"
    tabSF.Position=UDim2.new(0.2053,0,0.2308,0); tabSF.Size=UDim2.new(0.0709,0,0.4136,0)
    tabSF.BackgroundColor3=Color3.fromRGB(0,0,0); tabSF.BackgroundTransparency=0.30
    tabSF.BorderSizePixel=0; tabSF.ClipsDescendants=true
    tabSF.CanvasSize=UDim2.new(0,0,0,0); tabSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
    tabSF.ScrollBarThickness=3; tabSF.ScrollBarImageColor3=T.Accent
    tabSF.ScrollingDirection=Enum.ScrollingDirection.Y; tabSF.Parent=sg
    corner(tabSF,8); uiStroke(tabSF,T.Border,0,1,Enum.ApplyStrokeMode.Contextual)
    uiList(tabSF,3); uiPad(tabSF,5,5,5,5)

    -- SETTINGS FRAME (template pos/size)
    local setF=frame(sg,Color3.fromRGB(0,0,0),0.30,UDim2.new(0.0465,0,0.0668,0),UDim2.new(0.2169,0,0.6539,0))
    setF.Name="Settings"; corner(setF,8); uiStroke(setF,T.Border,0,1)
    local gearBtn=Instance.new("ImageButton"); gearBtn.Name="ImageButton"
    gearBtn.Position=UDim2.new(0.127,0,0.075,0); gearBtn.Size=UDim2.new(0.723,0,0.849,0)
    gearBtn.BackgroundColor3=T.GearBg; gearBtn.BackgroundTransparency=0
    gearBtn.Image="rbxassetid://5540166883"; gearBtn.ScaleType=Enum.ScaleType.Fit
    gearBtn.ImageColor3=T.GearIcon; gearBtn.AutoButtonColor=false; gearBtn.Parent=setF
    corner(gearBtn,6); uiStroke(gearBtn,T.Border,0,1,Enum.ApplyStrokeMode.Contextual)
    gearBtn.MouseEnter:Connect(function() tw(gearBtn,{BackgroundColor3=T.Accent,ImageColor3=Color3.new(1,1,1)}) end)
    gearBtn.MouseLeave:Connect(function() tw(gearBtn,{BackgroundColor3=T.GearBg,ImageColor3=T.GearIcon}) end)

    -- CONTENT SCROLLING FRAME (template pos/size)
    local contentF=Instance.new("ScrollingFrame"); contentF.Name="ScrollingFrame"
    contentF.Position=UDim2.new(0.2804,0,0.1765,0); contentF.Size=UDim2.new(0.4055,0,0.5448,0)
    contentF.BackgroundColor3=Color3.fromRGB(0,0,0); contentF.BackgroundTransparency=0.30
    contentF.BorderSizePixel=0; contentF.ClipsDescendants=true
    contentF.CanvasSize=UDim2.new(0,0,0,0); contentF.AutomaticCanvasSize=Enum.AutomaticSize.None
    contentF.ScrollBarThickness=0; contentF.ScrollingEnabled=false; contentF.Parent=sg
    corner(contentF,8); uiStroke(contentF,T.Border,0,1,Enum.ApplyStrokeMode.Contextual)

    -- Title bar inside content
    local titleBar=frame(contentF,Color3.fromRGB(0,0,0),0.55,UDim2.new(1,0,0,36)); titleBar.ZIndex=2
    frame(titleBar,T.Accent,0.4,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1))
    for i,dc in ipairs({T.DotRed,T.DotYellow,T.DotGreen}) do
        local d=frame(titleBar,dc,0,UDim2.fromOffset(10,10),UDim2.fromOffset(10+(i-1)*16,13)); corner(d,5)
    end
    local winTitle=textLbl(titleBar,cfg.Name or "Xanix",13,T.Text,Enum.Font.GothamBold)
    winTitle.Size=UDim2.new(1,-100,1,0); winTitle.Position=UDim2.fromOffset(64,0)

    -- Minimise button
    local minimised=false
    local minBtn=Instance.new("TextButton"); minBtn.Size=UDim2.fromOffset(24,18)
    minBtn.Position=UDim2.new(1,-30,0.5,-9); minBtn.BackgroundColor3=Color3.new(1,1,1)
    minBtn.BackgroundTransparency=0.88; minBtn.BorderSizePixel=0; minBtn.Text="–"
    minBtn.TextSize=13; minBtn.Font=Enum.Font.GothamBold; minBtn.TextColor3=T.TextDim
    minBtn.AutoButtonColor=false; minBtn.ZIndex=3; minBtn.Parent=titleBar; corner(minBtn,4)
    minBtn.MouseEnter:Connect(function() tw(minBtn,{BackgroundTransparency=0.60}) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn,{BackgroundTransparency=0.88}) end)
    minBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        tw(contentF,{Size=minimised and UDim2.new(0.4055,0,0,36) or UDim2.new(0.4055,0,0.5448,0)},TI_MED)
    end)

    local pagesC=frame(contentF,Color3.new(),1,UDim2.new(1,0,1,-36),UDim2.fromOffset(0,36))
    pagesC.ClipsDescendants=true

    -- TAB STATE
    local tabs={}; local activeTab=nil
    local function switchTab(t)
        if activeTab==t then return end
        for _,v in ipairs(tabs) do
            v.page.Visible=false
            tw(v.btn,{BackgroundColor3=T.TabBg,BackgroundTransparency=T.TabAlpha,TextColor3=T.Text})
            if v.pip then tw(v.pip,{BackgroundTransparency=1}) end
        end
        t.page.Visible=true
        tw(t.btn,{BackgroundColor3=T.TabActiveBg,BackgroundTransparency=T.TabActiveA,TextColor3=Color3.new(1,1,1)})
        if t.pip then tw(t.pip,{BackgroundTransparency=0}) end
        activeTab=t
    end
    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local q=searchBar.Text:lower()
        for _,t in ipairs(tabs) do
            t.btn.Visible=(q=="" or t.name:lower():find(q,1,true)~=nil)
        end
    end)

    -- DRAGGING
    local dragging,dragStart,startPos=false,nil,{}
    local dragTargets={searchBar,tabSF,setF,contentF}
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=Vector2.new(i.Position.X,i.Position.Y); startPos={}
            for _,obj in ipairs(dragTargets) do startPos[obj]=obj.Position end
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local vp=sg.AbsoluteSize
            local dx=(i.Position.X-dragStart.X)/vp.X; local dy=(i.Position.Y-dragStart.Y)/vp.Y
            for _,obj in ipairs(dragTargets) do
                local sp=startPos[obj]
                obj.Position=UDim2.new(sp.X.Scale+dx,sp.X.Offset,sp.Y.Scale+dy,sp.Y.Offset)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- HIDE KEY
    local hidden=false
    local hideKey=cfg.ToggleUIKeybind or "RightControl"
    if typeof(hideKey)=="EnumItem" then hideKey=hideKey.Name end
    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        if i.KeyCode==Enum.KeyCode[tostring(hideKey)] then
            hidden=not hidden
            for _,obj in ipairs(dragTargets) do tw(obj,{BackgroundTransparency=hidden and 1 or 0.30},TI_MED) end
        end
    end)

    local Window={}

    function Window:CreateTab(name,_icon)
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,28); btn.BackgroundColor3=T.TabBg
        btn.BackgroundTransparency=T.TabAlpha; btn.BorderSizePixel=0
        btn.Text=name; btn.TextSize=12; btn.Font=Enum.Font.GothamMedium
        btn.TextColor3=T.Text; btn.TextXAlignment=Enum.TextXAlignment.Left
        btn.TextWrapped=false; btn.TextTruncate=Enum.TextTruncate.AtEnd
        btn.AutoButtonColor=false; btn.LayoutOrder=#tabs+1; btn.Parent=tabSF
        corner(btn,6); uiStroke(btn,T.Border,0,1); uiPad(btn,24,6,0,0)
        local pip=frame(btn,T.Accent,1,UDim2.fromOffset(3,13),UDim2.new(0,-1,0.5,-6))
        pip.ZIndex=2; corner(pip,2)
        local page=Instance.new("ScrollingFrame")
        page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0
        page.ScrollBarThickness=3; page.ScrollBarImageColor3=T.Accent
        page.CanvasSize=UDim2.new(0,0,0,0); page.AutomaticCanvasSize=Enum.AutomaticSize.Y
        page.ScrollingDirection=Enum.ScrollingDirection.Y; page.Visible=false; page.Parent=pagesC
        uiList(page,5); uiPad(page,8,8,8,8)
        local t={name=name,btn=btn,pip=pip,page=page}; table.insert(tabs,t)
        btn.MouseEnter:Connect(function() if activeTab~=t then tw(btn,{BackgroundTransparency=T.TabAlpha-0.10,TextColor3=Color3.new(1,1,1)}) end end)
        btn.MouseLeave:Connect(function() if activeTab~=t then tw(btn,{BackgroundTransparency=T.TabAlpha,TextColor3=T.Text}) end end)
        btn.MouseButton1Click:Connect(function() switchTab(t) end)
        if #tabs==1 then switchTab(t) end

        local function row(h,noHover)
            local f=frame(page,T.RowBg,0,UDim2.new(1,0,0,h or 36)); corner(f,6); uiStroke(f,T.Border,0,1)
            if not noHover then
                f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=T.RowHoverBg}) end)
                f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=T.RowBg}) end)
            end
            return f
        end

        local Tab={}

        function Tab:CreateSection(sname)
            local f=frame(page,Color3.new(),1,UDim2.new(1,0,0,20)); uiPad(f,4,4,0,0)
            frame(f,T.Accent,0.7,UDim2.new(0.35,-6,0,1),UDim2.fromOffset(0,10))
            frame(f,T.Accent,0.7,UDim2.new(0.35,-6,0,1),UDim2.new(0.65,6,0,10))
            local lbl=textLbl(f,(sname or ""):upper(),9,T.SecText,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            local sv={}; function sv:Set(n) lbl.Text=(n or ""):upper() end; return sv
        end

        function Tab:CreateLabel(txt,_,col)
            local f=row(30,true)
            local p2=frame(f,T.Accent,0.3,UDim2.fromOffset(3,12),UDim2.new(0,0,0.5,-6)); corner(p2,2)
            local lbl=textLbl(f,txt or "",12,col or T.TextDim,Enum.Font.Gotham)
            lbl.Size=UDim2.new(1,-16,1,0); lbl.Position=UDim2.fromOffset(10,0)
            local lv={}; function lv:Set(nt,_,nc) lbl.Text=nt or "" if nc then lbl.TextColor3=nc end end; return lv
        end

        function Tab:CreateParagraph(s)
            local f=row(nil,true); f.AutomaticSize=Enum.AutomaticSize.Y
            local p3=frame(f,T.Accent,0.3,UDim2.fromOffset(3,0),UDim2.fromOffset(0,8)); corner(p3,2)
            local tl=Instance.new("TextLabel"); tl.BackgroundTransparency=1; tl.Text=s.Title or ""
            tl.TextSize=13; tl.Font=Enum.Font.GothamBold; tl.TextColor3=T.Text
            tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Size=UDim2.new(1,-20,0,18)
            tl.Position=UDim2.fromOffset(12,7); tl.Parent=f
            local cl=Instance.new("TextLabel"); cl.BackgroundTransparency=1; cl.Text=s.Content or ""
            cl.TextSize=12; cl.Font=Enum.Font.Gotham; cl.TextColor3=T.TextDim
            cl.TextXAlignment=Enum.TextXAlignment.Left; cl.TextWrapped=true; cl.AutomaticSize=Enum.AutomaticSize.Y
            cl.Size=UDim2.new(1,-20,0,0); cl.Position=UDim2.fromOffset(12,27); cl.Parent=f
            task.wait(); p3.Size=UDim2.fromOffset(3,f.AbsoluteSize.Y-14)
            local pv={}; function pv:Set(ns) tl.Text=ns.Title or "" cl.Text=ns.Content or "" end; return pv
        end

        function Tab:CreateButton(s)
            local f=row(36)
            local bL=frame(f,T.Accent,0.25,UDim2.fromOffset(3,14),UDim2.new(0,0,0.5,-7)); corner(bL,2)
            local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,1,0); b.BackgroundTransparency=1
            b.Text=s.Name or "Button"; b.TextSize=13; b.Font=Enum.Font.GothamMedium; b.TextColor3=T.Text
            b.TextXAlignment=Enum.TextXAlignment.Left; b.AutoButtonColor=false; b.Parent=f; uiPad(b,10,10,0,0)
            b.MouseButton1Click:Connect(function()
                tw(f,{BackgroundColor3=T.Accent},TI_FAST); tw(bL,{BackgroundTransparency=0},TI_FAST)
                task.delay(0.16,function() tw(f,{BackgroundColor3=T.RowBg},TI_MED); tw(bL,{BackgroundTransparency=0.25},TI_MED) end)
                if s.Callback then task.spawn(pcall,s.Callback) end
            end)
            local bv={}; function bv:Set(n) b.Text=n end; return bv
        end

        function Tab:CreateToggle(s)
            local state=s.CurrentValue==true; local f=row(36)
            local lbl=textLbl(f,s.Name or "Toggle",13,T.Text)
            lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.fromOffset(10,0)
            local track=frame(f,state and T.TrackOn or T.TrackOff,0,UDim2.fromOffset(42,22),UDim2.new(1,-50,0.5,-11))
            corner(track,11); uiStroke(track,T.Border,0.3,1)
            local thumb=frame(track,T.Thumb,0,UDim2.fromOffset(17,17),state and UDim2.fromOffset(22,2) or UDim2.fromOffset(3,2))
            corner(thumb,9); s.CurrentValue=state
            local function setState(v)
                state=v; s.CurrentValue=v; tw(track,{BackgroundColor3=v and T.TrackOn or T.TrackOff})
                tw(thumb,{Position=v and UDim2.fromOffset(22,2) or UDim2.fromOffset(3,2)},TI_QUART)
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            local cl=Instance.new("TextButton"); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1
            cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f; cl.MouseButton1Click:Connect(function() setState(not state) end)
            function s:Set(v) setState(v) end; if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        function Tab:CreateSlider(s)
            local mn=(s.Range and s.Range[1]) or 0; local mx=(s.Range and s.Range[2]) or 100
            local inc=s.Increment or 1; local val=math.clamp(s.CurrentValue or mn,mn,mx)
            local suf=s.Suffix and (" "..s.Suffix) or ""; local f=row(52)
            local function fmt(v) local r=math.floor(v/inc+0.5)*inc
                return (math.floor(r)==r and tostring(math.floor(r)) or string.format("%.2f",r))..suf end
            local nl=textLbl(f,s.Name or "Slider",13,T.Text); nl.Size=UDim2.new(0.55,0,0,20); nl.Position=UDim2.fromOffset(10,4)
            local vl=textLbl(f,fmt(val),12,T.TextDim,Enum.Font.Gotham,Enum.TextXAlignment.Right)
            vl.Size=UDim2.new(0.43,-10,0,20); vl.Position=UDim2.new(0.55,0,0,4); uiPad(vl,0,8,0,0)
            local tBg=frame(f,T.SliderTrack,0,UDim2.new(1,-20,0,5),UDim2.new(0,10,1,-12)); corner(tBg,3)
            local p0=(val-mn)/(mx-mn)
            local fill=frame(tBg,T.SliderFill,0,UDim2.new(p0,0,1,0)); corner(fill,3)
            local knob=frame(tBg,T.Thumb,0,UDim2.fromOffset(13,13),UDim2.new(p0,-6,0.5,-6))
            knob.ZIndex=2; corner(knob,7); uiStroke(knob,T.Accent,0.2,2); s.CurrentValue=val
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

        function Tab:CreateInput(s)
            local f=row(54)
            local nl=textLbl(f,s.Name or "Input",11,T.TextMuted,Enum.Font.GothamBold)
            nl.Size=UDim2.new(1,0,0,18); nl.Position=UDim2.fromOffset(10,4)
            local ibg=frame(f,T.InputBg,0,UDim2.new(1,-20,0,22),UDim2.fromOffset(10,25))
            corner(ibg,5); uiStroke(ibg,T.AccBorder,T.AccBorderA,1,Enum.ApplyStrokeMode.Contextual)
            local tb=Instance.new("TextBox"); tb.Size=UDim2.new(1,-14,1,0); tb.Position=UDim2.fromOffset(7,0)
            tb.BackgroundTransparency=1; tb.Text=s.CurrentValue or ""; tb.PlaceholderText=s.PlaceholderText or "Enter value"
            tb.TextSize=12; tb.Font=Enum.Font.Gotham; tb.TextColor3=T.Text; tb.PlaceholderColor3=T.TextMuted
            tb.TextXAlignment=Enum.TextXAlignment.Left; tb.ClearTextOnFocus=false; tb.MultiLine=false; tb.BorderSizePixel=0; tb.Parent=ibg
            tb.Focused:Connect(function() tw(ibg,{BackgroundColor3=T.RowHoverBg}) end)
            tb.FocusLost:Connect(function() tw(ibg,{BackgroundColor3=T.InputBg}); s.CurrentValue=tb.Text
                if s.Callback then task.spawn(pcall,s.Callback,tb.Text) end
                if s.RemoveTextAfterFocusLost then tb.Text="" end
            end)
            function s:Set(v) tb.Text=v; s.CurrentValue=v end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        function Tab:CreateDropdown(s)
            local opts=s.Options or {}; local multi=s.MultipleOptions==true
            if s.CurrentOption then if type(s.CurrentOption)=="string" then s.CurrentOption={s.CurrentOption} end
            else s.CurrentOption={} end
            if not multi then s.CurrentOption={s.CurrentOption[1]} end
            local open=false; local f=row(36)
            local nl=textLbl(f,s.Name or "Dropdown",13,T.Text); nl.Size=UDim2.new(0.47,0,1,0); nl.Position=UDim2.fromOffset(10,0)
            local selBtn=Instance.new("TextButton"); selBtn.Size=UDim2.new(0.47,-8,0,22); selBtn.Position=UDim2.new(0.49,2,0.5,-11)
            selBtn.BackgroundColor3=T.InputBg; selBtn.BackgroundTransparency=0; selBtn.BorderSizePixel=0
            selBtn.AutoButtonColor=false; selBtn.TextSize=11; selBtn.Font=Enum.Font.GothamMedium; selBtn.TextColor3=T.Text; selBtn.Parent=f
            corner(selBtn,4); uiStroke(selBtn,T.AccBorder,T.AccBorderA,1,Enum.ApplyStrokeMode.Contextual)
            local function selText() if #s.CurrentOption==0 then return "None" elseif #s.CurrentOption==1 then return s.CurrentOption[1] else return "Various" end end
            selBtn.Text=selText().."  ▾"
            local ddF=frame(f,T.InputBg,0.04,UDim2.new(0.47,-8,0,math.min(#opts,5)*26+8),UDim2.new(0.49,2,1,3))
            ddF.ZIndex=20; ddF.Visible=false; ddF.ClipsDescendants=true; corner(ddF,6)
            uiStroke(ddF,T.AccBorder,T.AccBorderA,1,Enum.ApplyStrokeMode.Contextual)
            local ddSF=Instance.new("ScrollingFrame"); ddSF.Size=UDim2.new(1,0,1,0); ddSF.BackgroundTransparency=1
            ddSF.BorderSizePixel=0; ddSF.ScrollBarThickness=2; ddSF.ScrollBarImageColor3=T.Accent
            ddSF.CanvasSize=UDim2.new(0,0,0,0); ddSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; ddSF.Parent=ddF
            uiList(ddSF,2); uiPad(ddSF,4,4,4,4)
            local function buildOpts()
                for _,opt in ipairs(opts) do
                    local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,24); ob.BackgroundColor3=Color3.new(1,1,1)
                    ob.BackgroundTransparency=0.90; ob.BorderSizePixel=0; ob.Text=opt; ob.TextSize=12
                    ob.Font=Enum.Font.Gotham; ob.TextColor3=T.Text; ob.AutoButtonColor=false; ob.ZIndex=21; ob.Parent=ddSF; corner(ob,4)
                    if table.find(s.CurrentOption,opt) then ob.BackgroundTransparency=0.70; ob.TextColor3=T.AccentLight end
                    ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0.72}) end)
                    ob.MouseLeave:Connect(function() tw(ob,{BackgroundTransparency=table.find(s.CurrentOption,opt) and 0.70 or 0.90}) end)
                    ob.MouseButton1Click:Connect(function()
                        if not multi then s.CurrentOption={opt}; selBtn.Text=opt.."  ▾"; open=false; ddF.Visible=false
                        else local idx=table.find(s.CurrentOption,opt)
                            if idx then table.remove(s.CurrentOption,idx); tw(ob,{BackgroundTransparency=0.90}); ob.TextColor3=T.Text
                            else table.insert(s.CurrentOption,opt); tw(ob,{BackgroundTransparency=0.70}); ob.TextColor3=T.AccentLight end
                            selBtn.Text=selText().."  ▾"
                        end
                        if s.Callback then task.spawn(pcall,s.Callback,s.CurrentOption) end
                    end)
                end
            end
            buildOpts(); selBtn.MouseButton1Click:Connect(function() open=not open; ddF.Visible=open end)
            function s:Set(v) if type(v)=="string" then v={v} end; s.CurrentOption=v; selBtn.Text=selText().."  ▾"
                if s.Callback then task.spawn(pcall,s.Callback,v) end end
            function s:Refresh(newOpts) s.Options=newOpts; opts=newOpts
                for _,c in ipairs(ddSF:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end; buildOpts() end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        function Tab:CreateKeybind(s)
            local checking=false; local f=row(36)
            local nl=textLbl(f,s.Name or "Keybind",13,T.Text); nl.Size=UDim2.new(0.55,0,1,0); nl.Position=UDim2.fromOffset(10,0)
            local kbg=frame(f,T.InputBg,0,UDim2.new(0.38,-8,0,22),UDim2.new(0.57,2,0.5,-11))
            corner(kbg,4); uiStroke(kbg,T.AccBorder,T.AccBorderA,1,Enum.ApplyStrokeMode.Contextual)
            local ktb=Instance.new("TextBox"); ktb.Size=UDim2.new(1,-10,1,0); ktb.Position=UDim2.fromOffset(5,0)
            ktb.BackgroundTransparency=1; ktb.Text=s.CurrentKeybind or "None"; ktb.TextSize=12
            ktb.Font=Enum.Font.GothamMedium; ktb.TextColor3=T.AccentLight
            ktb.TextXAlignment=Enum.TextXAlignment.Center; ktb.ClearTextOnFocus=false; ktb.BorderSizePixel=0; ktb.Parent=kbg
            ktb.Focused:Connect(function() checking=true; ktb.Text=""; tw(kbg,{BackgroundColor3=T.RowHoverBg}) end)
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

        function Tab:CreateColorPicker(s)
            local cc=s.Color or Color3.fromRGB(255,0,0); local h,sv_s,sv_v=Color3.toHSV(cc); local open=false
            local f=row(36); local nl=textLbl(f,s.Name or "Color",13,T.Text)
            nl.Size=UDim2.new(1,-52,1,0); nl.Position=UDim2.fromOffset(10,0)
            local swatch=frame(f,cc,0,UDim2.fromOffset(32,20),UDim2.new(1,-42,0.5,-10)); corner(swatch,5); uiStroke(swatch,T.Border,0.3,1)
            local pW=220; local svW=pW-42; local svH=138
            local pp=frame(f,T.InputBg,0.04,UDim2.fromOffset(pW,168),UDim2.new(0,0,1,4))
            corner(pp,8); uiStroke(pp,T.AccBorder,T.AccBorderA,1); pp.ZIndex=15; pp.Visible=false
            local svB=frame(pp,Color3.fromHSV(h,1,1),0,UDim2.fromOffset(svW,svH),UDim2.fromOffset(10,12))
            svB.ZIndex=15; corner(svB,5)
            local function mkGrad(par,rot,cs,ts)
                local fr=frame(par,Color3.new(),1); fr.ZIndex=16
                local g=Instance.new("UIGradient"); g.Color=cs; g.Rotation=rot; if ts then g.Transparency=ts end; g.Parent=fr
            end
            mkGrad(svB,0,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkGrad(svB,90,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new()),ColorSequenceKeypoint.new(1,Color3.new())}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))
            local svCur=frame(svB,Color3.new(1,1,1),0,UDim2.fromOffset(11,11),UDim2.new(sv_s,-5,1-sv_v,-5))
            svCur.ZIndex=18; corner(svCur,6); uiStroke(svCur,Color3.new(),0,1)
            local hBar=frame(pp,Color3.new(1,1,1),0,UDim2.fromOffset(17,svH),UDim2.fromOffset(svW+15,12))
            hBar.ZIndex=15; corner(hBar,4)
            local hg=Instance.new("UIGradient"); hg.Rotation=90
            hg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(0,1,1))}); hg.Parent=hBar
            local hCur=frame(hBar,Color3.new(1,1,1),0,UDim2.new(1,6,0,5),UDim2.new(-0.18,0,h,-2)); hCur.ZIndex=18; corner(hCur,2); uiStroke(hCur,Color3.new(),0,1)
            local function updColor() cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc; swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end end
            local svDrag,hDrag=false,false
            svB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=true; local a,sz=svB.AbsolutePosition,svB.AbsoluteSize; sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updColor() end end)
            UIS.InputChanged:Connect(function(i) if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
                if svDrag then local a,sz=svB.AbsolutePosition,svB.AbsoluteSize; sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updColor() end
                if hDrag then local a,sz=hBar.AbsolutePosition,hBar.AbsoluteSize; h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.18,0,h,-2); updColor() end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false; hDrag=false end end)
            hBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hDrag=true; local a,sz=hBar.AbsolutePosition,hBar.AbsoluteSize; h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.18,0,h,-2); updColor() end end)
            local cl=Instance.new("TextButton"); cl.Size=UDim2.new(1,0,1,0); cl.BackgroundTransparency=1; cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f
            cl.MouseButton1Click:Connect(function() open=not open; pp.Visible=open end)
            function s:Set(c) cc=c; h,sv_s,sv_v=Color3.toHSV(c); s.Color=c; swatch.BackgroundColor3=c; svB.BackgroundColor3=Color3.fromHSV(h,1,1); svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); hCur.Position=UDim2.new(-0.18,0,h,-2) end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        return Tab
    end

    function Window:Destroy() sg:Destroy() end
    return Window
end

function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(_) end
function Xanix:IsVisible() return true end
function Xanix:Destroy() end

return Xanix
