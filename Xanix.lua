--[[
  ██╗  ██╗ █████╗ ███╗   ██╗██╗██╗  ██╗
  ╚██╗██╔╝██╔══██╗████╗  ██║██║╚██╗██╔╝
   ╚███╔╝ ███████║██╔██╗ ██║██║ ╚███╔╝
   ██╔██╗ ██╔══██║██║╚██╗██║██║ ██╔██╗
  ██╔╝ ██╗██║  ██║██║ ╚████║██║██╔╝ ██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
  UI Library — Rayfield-compatible API
  
  Usage (drop-in Rayfield replacement):
    local Xanix = loadstring(game:HttpGet("RAW_URL"))()
    local Win = Xanix:CreateWindow({ Name = "My Hub" })
    local Tab = Win:CreateTab("⚔  Combat")
    Tab:CreateButton({ Name = "Do Thing", Callback = function() end })
    Tab:CreateToggle({ Name = "Aimbot", CurrentValue = false, Callback = function(v) end })
    Tab:CreateSlider({ Name = "Speed", Range = {16,500}, Increment = 1, CurrentValue = 16, Callback = function(v) end })
    Tab:CreateColorPicker({ Name = "Color", Color = Color3.fromRGB(255,0,0), Callback = function(c) end })
    Tab:CreateDropdown({ Name = "Mode", Options = {"A","B"}, CurrentOption = {"A"}, Callback = function(o) end })
    Tab:CreateInput({ Name = "Player", PlaceholderText = "name…", Callback = function(t) end })
    Tab:CreateSection("Section Header")
    Tab:CreateLabel("Info text")
    Tab:CreateKeybind({ Name = "Toggle UI", CurrentKeybind = "K", Callback = function() end })
    Xanix:Notify({ Title = "Hello", Content = "World", Duration = 4 })
]]

local Xanix  = { Flags = {} }
Xanix.__index = Xanix

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local LP           = Players.LocalPlayer
local PG           = LP:WaitForChild("PlayerGui")

-- ─── THEME ───────────────────────────────────────────────────────────────────
local T = {
    Panel        = Color3.fromRGB(0,   0,   0),
    PanelAlpha   = 0.30,
    TitleBg      = Color3.fromRGB(0,   0,   0),
    TitleAlpha   = 0.18,
    Row          = Color3.fromRGB(255, 255, 255),
    RowAlpha     = 0.93,
    RowHover     = 0.87,
    Border       = Color3.fromRGB(255, 255, 255),
    BorderAlpha  = 0.88,
    TabIdle      = Color3.fromRGB(255, 255, 255),
    TabIdleAlpha = 0.91,
    TabActAlpha  = 0.77,
    Text         = Color3.fromRGB(240, 242, 255),
    TextDim      = Color3.fromRGB(165, 167, 190),
    TextMuted    = Color3.fromRGB(110, 112, 140),
    Accent       = Color3.fromRGB(99,  102, 241),
    AccentDim    = Color3.fromRGB(67,  70,  180),
    TrackOff     = Color3.fromRGB(55,  55,  72),
    TrackOn      = Color3.fromRGB(99,  102, 241),
    NotifBg      = Color3.fromRGB(10,  10,  16),
}

-- ─── SIZES ───────────────────────────────────────────────────────────────────
local TAB_W     = 150
local CONTENT_W = 440
local CONTENT_H = 380
local SEARCH_H  = 36
local SET_H     = 40
local GAP       = 6
local TOTAL_H   = SEARCH_H + GAP + CONTENT_H

local TW_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad,        Enum.EasingDirection.Out)
local TW_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quad,        Enum.EasingDirection.Out)
local TW_EXP  = TweenInfo.new(0.40, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

-- ─── UTILS ───────────────────────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function stroke(p, col, alpha, thick, mode)
    local s = Instance.new("UIStroke")
    s.Color           = col   or T.Border
    s.Transparency    = alpha or T.BorderAlpha
    s.Thickness       = thick or 1
    s.ApplyStrokeMode = mode  or Enum.ApplyStrokeMode.Border
    s.LineJoinMode    = Enum.LineJoinMode.Round
    s.Parent          = p
    return s
end
local function pad(p, l, r, t, b)
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft=UDim.new(0,l or 0); pd.PaddingRight=UDim.new(0,r or 0)
    pd.PaddingTop=UDim.new(0,t or 0);  pd.PaddingBottom=UDim.new(0,b or 0)
    pd.Parent=p; return pd
end
local function list(p, sp)
    local l = Instance.new("UIListLayout"); l.Padding=UDim.new(0,sp or 4); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=p; return l
end
local function tw(obj, props, info)
    TweenService:Create(obj, info or TW_FAST, props):Play()
end
local function label(p, txt, sz, col, font, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency=1; l.Text=txt; l.TextSize=sz or 13
    l.Font=font or Enum.Font.GothamMedium; l.TextColor3=col or T.Text
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextYAlignment=Enum.TextYAlignment.Center
    l.TextWrapped=true; l.Size=UDim2.new(1,0,1,0); l.Parent=p; return l
end

-- ─── NOTIFICATIONS ───────────────────────────────────────────────────────────
local notifHolder  -- created once per session

local function ensureNotifHolder()
    if notifHolder and notifHolder.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name="XanixNotifs"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=PG
    local h=Instance.new("Frame")
    h.Name="Holder"; h.Size=UDim2.new(0,280,1,0)
    h.Position=UDim2.new(1,-292,0,0); h.BackgroundTransparency=1
    h.BorderSizePixel=0; h.Parent=sg
    local l=Instance.new("UIListLayout")
    l.Padding=UDim.new(0,8); l.SortOrder=Enum.SortOrder.LayoutOrder
    l.VerticalAlignment=Enum.VerticalAlignment.Bottom
    l.FillDirection=Enum.FillDirection.Vertical; l.Parent=h
    pad(h,0,0,12,12); notifHolder=h
end

function Xanix:Notify(data)
    task.spawn(function()
        ensureNotifHolder()
        data = data or {}
        local dur = data.Duration or 4

        local card = Instance.new("Frame")
        card.Size=UDim2.new(1,0,0,0); card.BackgroundColor3=T.NotifBg
        card.BackgroundTransparency=0.06; card.BorderSizePixel=0
        card.ClipsDescendants=false; card.Parent=notifHolder
        corner(card,9); stroke(card,T.Border,0.82,1,Enum.ApplyStrokeMode.Border)

        local inner=Instance.new("Frame")
        inner.Size=UDim2.new(1,-20,1,0); inner.Position=UDim2.fromOffset(12,0)
        inner.BackgroundTransparency=1; inner.Parent=card

        local titleLbl=Instance.new("TextLabel")
        titleLbl.Size=UDim2.new(1,0,0,20); titleLbl.Position=UDim2.fromOffset(0,10)
        titleLbl.BackgroundTransparency=1; titleLbl.Text=data.Title or "Notification"
        titleLbl.TextSize=13; titleLbl.Font=Enum.Font.GothamBold
        titleLbl.TextColor3=T.Text; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
        titleLbl.TextTransparency=1; titleLbl.Parent=inner

        local bodyLbl=Instance.new("TextLabel")
        bodyLbl.Size=UDim2.new(1,0,0,0); bodyLbl.Position=UDim2.fromOffset(0,32)
        bodyLbl.BackgroundTransparency=1; bodyLbl.Text=data.Content or ""
        bodyLbl.TextSize=12; bodyLbl.Font=Enum.Font.Gotham
        bodyLbl.TextColor3=T.TextDim; bodyLbl.TextXAlignment=Enum.TextXAlignment.Left
        bodyLbl.TextWrapped=true; bodyLbl.TextTransparency=1; bodyLbl.Parent=inner

        -- accent left bar
        local bar=Instance.new("Frame")
        bar.Size=UDim2.fromOffset(3,0); bar.Position=UDim2.fromOffset(-12,12)
        bar.BackgroundColor3=T.Accent; bar.BorderSizePixel=0; bar.Parent=card
        corner(bar,2)

        task.wait()
        local bounds = bodyLbl.TextBounds.Y
        local cardH  = math.max(bounds + 52, 58)
        card.Size=UDim2.new(1,0,0,cardH)
        bodyLbl.Size=UDim2.new(1,0,0,bounds+4)

        tw(bar, {Size=UDim2.fromOffset(3,cardH-24)}, TW_EXP)
        tw(card, {BackgroundTransparency=0.06}, TW_EXP)
        tw(titleLbl, {TextTransparency=0}, TW_EXP)
        task.wait(0.08)
        tw(bodyLbl, {TextTransparency=0.25}, TW_EXP)

        task.wait(dur)

        tw(card, {BackgroundTransparency=1}, TW_EXP)
        tw(titleLbl, {TextTransparency=1}, TW_EXP)
        tw(bodyLbl, {TextTransparency=1}, TW_EXP)
        tw(bar, {BackgroundTransparency=1}, TW_EXP)
        task.wait(0.45)
        card:Destroy()
    end)
end

-- ─── CREATE WINDOW ───────────────────────────────────────────────────────────
function Xanix:CreateWindow(cfg)
    cfg = cfg or {}
    local winName = cfg.Name or "Xanix"

    local sg = Instance.new("ScreenGui")
    sg.Name="Xanix"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=PG

    -- anchor — drag this, everything follows
    local anchor = Instance.new("Frame")
    anchor.Name="Anchor"
    anchor.Size=UDim2.fromOffset(1,1)
    anchor.Position=UDim2.new(0.5,-(TAB_W+GAP+CONTENT_W)/2,
                               0.5,-(TOTAL_H+GAP+SET_H)/2)
    anchor.BackgroundTransparency=1; anchor.BorderSizePixel=0; anchor.Parent=sg

    -- ┌─ SEARCH BAR ────────────────────────────────────────────────────────────
    local searchF=Instance.new("Frame")
    searchF.Size=UDim2.fromOffset(TAB_W,SEARCH_H); searchF.Position=UDim2.fromOffset(0,0)
    searchF.BackgroundColor3=T.Panel; searchF.BackgroundTransparency=T.PanelAlpha
    searchF.BorderSizePixel=0; searchF.Parent=anchor
    corner(searchF,9); stroke(searchF,T.Border,T.BorderAlpha,1,Enum.ApplyStrokeMode.Border)

    local searchIcon=Instance.new("TextLabel")
    searchIcon.Size=UDim2.fromOffset(28,SEARCH_H); searchIcon.Position=UDim2.fromOffset(6,0)
    searchIcon.BackgroundTransparency=1; searchIcon.Text="🔍"; searchIcon.TextSize=12
    searchIcon.Font=Enum.Font.Gotham; searchIcon.TextColor3=T.TextMuted
    searchIcon.TextXAlignment=Enum.TextXAlignment.Center; searchIcon.Parent=searchF

    local searchBox=Instance.new("TextBox")
    searchBox.Size=UDim2.new(1,-32,1,0); searchBox.Position=UDim2.fromOffset(28,0)
    searchBox.BackgroundTransparency=1; searchBox.Text=""
    searchBox.PlaceholderText="Search tabs…"; searchBox.TextSize=13
    searchBox.Font=Enum.Font.GothamMedium; searchBox.TextColor3=T.Text
    searchBox.PlaceholderColor3=T.TextMuted; searchBox.TextXAlignment=Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus=false; searchBox.MultiLine=false; searchBox.BorderSizePixel=0
    searchBox.Parent=searchF

    -- ┌─ TAB LIST ──────────────────────────────────────────────────────────────
    local tabSF=Instance.new("ScrollingFrame")
    tabSF.Size=UDim2.fromOffset(TAB_W,CONTENT_H); tabSF.Position=UDim2.fromOffset(0,SEARCH_H+GAP)
    tabSF.BackgroundColor3=T.Panel; tabSF.BackgroundTransparency=T.PanelAlpha
    tabSF.BorderSizePixel=0; tabSF.ClipsDescendants=true
    tabSF.ScrollBarThickness=2; tabSF.ScrollBarImageColor3=Color3.fromRGB(150,152,200)
    tabSF.CanvasSize=UDim2.new(0,0,0,0); tabSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
    tabSF.ScrollingDirection=Enum.ScrollingDirection.Y; tabSF.Parent=anchor
    corner(tabSF,9); stroke(tabSF,T.Border,T.BorderAlpha,1,Enum.ApplyStrokeMode.Border)
    list(tabSF,4); pad(tabSF,7,7,7,7)

    -- ┌─ SETTINGS BTN (below tab list) ────────────────────────────────────────
    local setBtn=Instance.new("TextButton")
    setBtn.Size=UDim2.fromOffset(TAB_W,SET_H)
    setBtn.Position=UDim2.fromOffset(0,SEARCH_H+GAP+CONTENT_H+GAP)
    setBtn.BackgroundColor3=T.Panel; setBtn.BackgroundTransparency=T.PanelAlpha
    setBtn.BorderSizePixel=0; setBtn.AutoButtonColor=false; setBtn.Text=""; setBtn.Parent=anchor
    corner(setBtn,9); stroke(setBtn,T.Border,T.BorderAlpha,1)

    local gearHolder=Instance.new("Frame"); gearHolder.Size=UDim2.fromOffset(24,24)
    gearHolder.Position=UDim2.new(0.5,-12,0.5,-12)
    gearHolder.BackgroundColor3=Color3.fromRGB(205,205,220); gearHolder.BorderSizePixel=0; gearHolder.Parent=setBtn
    corner(gearHolder,6)
    local gearImg=Instance.new("ImageLabel"); gearImg.Size=UDim2.new(0.7,0,0.7,0)
    gearImg.Position=UDim2.new(0.15,0,0.15,0); gearImg.BackgroundTransparency=1
    gearImg.Image="rbxassetid://5540166883"; gearImg.ImageColor3=Color3.fromRGB(25,25,35)
    gearImg.ScaleType=Enum.ScaleType.Fit; gearImg.Parent=gearHolder

    setBtn.MouseEnter:Connect(function() tw(setBtn,{BackgroundTransparency=T.PanelAlpha-0.12}) end)
    setBtn.MouseLeave:Connect(function() tw(setBtn,{BackgroundTransparency=T.PanelAlpha}) end)

    -- ┌─ CONTENT PANEL ─────────────────────────────────────────────────────────
    local contentF=Instance.new("Frame")
    contentF.Name="ContentPanel"; contentF.Size=UDim2.fromOffset(CONTENT_W,TOTAL_H)
    contentF.Position=UDim2.fromOffset(TAB_W+GAP,0)
    contentF.BackgroundColor3=T.Panel; contentF.BackgroundTransparency=T.PanelAlpha
    contentF.BorderSizePixel=0; contentF.ClipsDescendants=true; contentF.Parent=anchor
    corner(contentF,11); stroke(contentF,T.Border,0.86,1,Enum.ApplyStrokeMode.Border)

    -- title bar
    local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,40)
    titleBar.BackgroundColor3=T.TitleBg; titleBar.BackgroundTransparency=T.TitleAlpha
    titleBar.BorderSizePixel=0; titleBar.Parent=contentF

    -- traffic-light dots
    local dotColors={Color3.fromRGB(255,95,87),Color3.fromRGB(255,189,46),Color3.fromRGB(40,200,64)}
    for i,dc in ipairs(dotColors) do
        local d=Instance.new("Frame"); d.Size=UDim2.fromOffset(11,11)
        d.Position=UDim2.fromOffset(12+(i-1)*17,14); d.BackgroundColor3=dc
        d.BorderSizePixel=0; d.Parent=titleBar; corner(d,6)
    end

    local winTitle=Instance.new("TextLabel")
    winTitle.Size=UDim2.new(1,-120,1,0); winTitle.Position=UDim2.fromOffset(70,0)
    winTitle.BackgroundTransparency=1; winTitle.Text=winName
    winTitle.TextSize=14; winTitle.Font=Enum.Font.GothamBold
    winTitle.TextColor3=T.Text; winTitle.TextXAlignment=Enum.TextXAlignment.Left
    winTitle.Parent=titleBar

    -- accent underline
    local accentLine=Instance.new("Frame"); accentLine.Size=UDim2.new(1,0,0,1)
    accentLine.Position=UDim2.new(0,0,1,-1); accentLine.BackgroundColor3=T.Accent
    accentLine.BackgroundTransparency=0.35; accentLine.BorderSizePixel=0; accentLine.Parent=titleBar

    -- minimise button
    local minimised=false
    local minBtn=Instance.new("TextButton"); minBtn.Size=UDim2.fromOffset(26,22)
    minBtn.Position=UDim2.new(1,-34,0.5,-11)
    minBtn.BackgroundColor3=Color3.fromRGB(255,255,255); minBtn.BackgroundTransparency=0.88
    minBtn.BorderSizePixel=0; minBtn.Text="–"; minBtn.TextSize=14
    minBtn.Font=Enum.Font.GothamBold; minBtn.TextColor3=T.TextDim
    minBtn.AutoButtonColor=false; minBtn.Parent=titleBar; corner(minBtn,6)
    minBtn.MouseEnter:Connect(function() tw(minBtn,{BackgroundTransparency=0.68}) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn,{BackgroundTransparency=0.88}) end)
    minBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        tw(contentF,{Size=minimised and UDim2.fromOffset(CONTENT_W,40) or UDim2.fromOffset(CONTENT_W,TOTAL_H)},TW_MED)
    end)

    -- pages container
    local pagesC=Instance.new("Frame"); pagesC.Size=UDim2.new(1,0,1,-40)
    pagesC.Position=UDim2.fromOffset(0,40); pagesC.BackgroundTransparency=1
    pagesC.ClipsDescendants=true; pagesC.Parent=contentF

    -- ─── TAB STATE ───────────────────────────────────────────────────────────
    local tabs={}; local activeTab=nil

    local function switchTab(t)
        if activeTab==t then return end
        for _,v in ipairs(tabs) do
            v.page.Visible=false
            tw(v.btn,{BackgroundTransparency=T.TabIdleAlpha,TextColor3=T.TextDim})
            if v.bar then tw(v.bar,{BackgroundTransparency=1}) end
        end
        t.page.Visible=true
        tw(t.btn,{BackgroundTransparency=T.TabActAlpha,TextColor3=T.Text})
        if t.bar then tw(t.bar,{BackgroundTransparency=0.18}) end
        activeTab=t
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q=searchBox.Text:lower()
        for _,t in ipairs(tabs) do
            t.btn.Visible=q=="" or (t.name:lower():find(q,1,true)~=nil)
        end
    end)

    -- ─── DRAGGING ─────────────────────────────────────────────────────────────
    local dragging,dragStart,startPos=false,nil,nil
    local handles={searchF,tabSF,contentF,setBtn}
    for _,h in ipairs(handles) do
        h.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart=Vector2.new(i.Position.X,i.Position.Y); startPos=anchor.Position
            end
        end)
    end
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=Vector2.new(i.Position.X,i.Position.Y)-dragStart
            anchor.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- hide/show keybind
    local hidden=false
    local hideKey=cfg.ToggleUIKeybind or "RightControl"
    if typeof(hideKey)=="EnumItem" then hideKey=hideKey.Name end
    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        if i.KeyCode==Enum.KeyCode[tostring(hideKey)] then
            hidden=not hidden
            local a=hidden and 1 or 0
            for _,obj in ipairs({searchF,tabSF,contentF,setBtn}) do
                tw(obj,{BackgroundTransparency=hidden and 1 or T.PanelAlpha},TW_MED)
            end
        end
    end)

    -- ─── WINDOW API ──────────────────────────────────────────────────────────
    local Window={}

    function Window:CreateTab(name, _icon)
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,32); btn.BackgroundColor3=T.TabIdle
        btn.BackgroundTransparency=T.TabIdleAlpha; btn.BorderSizePixel=0
        btn.Text=name; btn.TextSize=12; btn.Font=Enum.Font.GothamMedium
        btn.TextColor3=T.TextDim; btn.TextXAlignment=Enum.TextXAlignment.Left
        btn.TextWrapped=false; btn.TextTruncate=Enum.TextTruncate.AtEnd
        btn.AutoButtonColor=false; btn.LayoutOrder=#tabs+1; btn.Parent=tabSF
        corner(btn,7); stroke(btn,T.Border,T.BorderAlpha,1,Enum.ApplyStrokeMode.Border)
        pad(btn,11,8,0,0)

        local bar=Instance.new("Frame"); bar.Size=UDim2.fromOffset(3,16)
        bar.Position=UDim2.new(0,-1,0.5,-8); bar.BackgroundColor3=T.Accent
        bar.BorderSizePixel=0; bar.BackgroundTransparency=1; bar.Parent=btn; corner(bar,2)

        local page=Instance.new("ScrollingFrame"); page.Size=UDim2.new(1,0,1,0)
        page.BackgroundTransparency=1; page.ScrollBarThickness=3
        page.ScrollBarImageColor3=Color3.fromRGB(130,132,180)
        page.CanvasSize=UDim2.new(0,0,0,0); page.AutomaticCanvasSize=Enum.AutomaticSize.Y
        page.BorderSizePixel=0; page.Visible=false; page.Parent=pagesC
        list(page,6); pad(page,12,12,10,10)

        local t={name=name,btn=btn,bar=bar,page=page}
        table.insert(tabs,t)
        btn.MouseEnter:Connect(function() if activeTab~=t then tw(btn,{BackgroundTransparency=T.TabIdleAlpha-0.06,TextColor3=T.Text}) end end)
        btn.MouseLeave:Connect(function() if activeTab~=t then tw(btn,{BackgroundTransparency=T.TabIdleAlpha,TextColor3=T.TextDim}) end end)
        btn.MouseButton1Click:Connect(function() switchTab(t) end)
        if #tabs==1 then switchTab(t) end

        -- ── ROW BASE ─────────────────────────────────────────────────────────
        local function row(h, noHover)
            local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,h or 36)
            f.BackgroundColor3=T.Row; f.BackgroundTransparency=T.RowAlpha
            f.BorderSizePixel=0; f.Parent=page; corner(f,7)
            stroke(f,T.Border,0.90,1,Enum.ApplyStrokeMode.Border)
            if not noHover then
                f.MouseEnter:Connect(function() tw(f,{BackgroundTransparency=T.RowHover}) end)
                f.MouseLeave:Connect(function() tw(f,{BackgroundTransparency=T.RowAlpha}) end)
            end
            return f
        end

        -- ── TAB API ──────────────────────────────────────────────────────────
        local Tab={}

        -- SECTION
        function Tab:CreateSection(sname)
            local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,20)
            f.BackgroundTransparency=1; f.Parent=page; pad(f,4,4,0,0)
            label(f,(sname or ""):upper(),9,T.TextMuted,Enum.Font.GothamBold)
            local sv={}; function sv:Set(n) f:FindFirstChildWhichIsA("TextLabel").Text=(n or ""):upper() end
            return sv
        end

        -- LABEL
        function Tab:CreateLabel(txt, _icon, col, _ignoreTheme)
            local f=row(32,true)
            local l=Instance.new("TextLabel")
            l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=txt or ""
            l.TextSize=12; l.Font=Enum.Font.Gotham; l.TextColor3=col or T.TextDim
            l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true; l.Parent=f
            pad(l,12,12,0,0)
            local lv={}; function lv:Set(nt,_ni,nc)
                l.Text=nt or "" if nc then l.TextColor3=nc end
            end
            return lv
        end

        -- PARAGRAPH
        function Tab:CreateParagraph(s)
            local f=row(nil,true)
            local tl=Instance.new("TextLabel")
            tl.Size=UDim2.new(1,-24,0,18); tl.Position=UDim2.fromOffset(12,6)
            tl.BackgroundTransparency=1; tl.Text=s.Title or ""
            tl.TextSize=13; tl.Font=Enum.Font.GothamBold; tl.TextColor3=T.Text
            tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=f

            local cl=Instance.new("TextLabel")
            cl.Size=UDim2.new(1,-24,0,0); cl.Position=UDim2.fromOffset(12,26)
            cl.BackgroundTransparency=1; cl.Text=s.Content or ""
            cl.TextSize=12; cl.Font=Enum.Font.Gotham; cl.TextColor3=T.TextDim
            cl.TextXAlignment=Enum.TextXAlignment.Left; cl.TextWrapped=true
            cl.AutomaticSize=Enum.AutomaticSize.Y; cl.Parent=f
            f.AutomaticSize=Enum.AutomaticSize.Y

            local pv={}; function pv:Set(ns) tl.Text=ns.Title or "" cl.Text=ns.Content or "" end
            return pv
        end

        -- BUTTON
        function Tab:CreateButton(s)
            local f=row(36)
            local pip=Instance.new("Frame"); pip.Size=UDim2.fromOffset(3,15)
            pip.Position=UDim2.new(0,0,0.5,-7); pip.BackgroundColor3=T.Accent
            pip.BackgroundTransparency=0.25; pip.BorderSizePixel=0; pip.Parent=f; corner(pip,2)

            local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,1,0)
            b.BackgroundTransparency=1; b.Text=s.Name or "Button"
            b.TextSize=13; b.Font=Enum.Font.GothamMedium; b.TextColor3=T.Text
            b.TextXAlignment=Enum.TextXAlignment.Left; b.AutoButtonColor=false; b.Parent=f
            pad(b,14,14,0,0)

            b.MouseButton1Click:Connect(function()
                tw(f,{BackgroundTransparency=T.RowHover-0.1})
                task.delay(0.16,function() tw(f,{BackgroundTransparency=T.RowAlpha}) end)
                if s.Callback then task.spawn(pcall,s.Callback) end
            end)

            local bv={}; function bv:Set(n) b.Text=n end; return bv
        end

        -- TOGGLE
        function Tab:CreateToggle(s)
            local state=s.CurrentValue==true
            local f=row(36)

            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-62,1,0)
            lbl.Position=UDim2.fromOffset(12,0); lbl.BackgroundTransparency=1
            lbl.Text=s.Name or "Toggle"; lbl.TextSize=13; lbl.Font=Enum.Font.GothamMedium
            lbl.TextColor3=T.Text; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=f

            local track=Instance.new("Frame"); track.Size=UDim2.fromOffset(42,24)
            track.Position=UDim2.new(1,-52,0.5,-12)
            track.BackgroundColor3=state and T.TrackOn or T.TrackOff
            track.BorderSizePixel=0; track.Parent=f; corner(track,12)

            local thumb=Instance.new("Frame"); thumb.Size=UDim2.fromOffset(18,18)
            thumb.Position=state and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)
            thumb.BackgroundColor3=Color3.fromRGB(255,255,255); thumb.BorderSizePixel=0
            thumb.Parent=track; corner(thumb,9)

            s.CurrentValue=state
            local function set(v)
                state=v; s.CurrentValue=v
                tw(track,{BackgroundColor3=v and T.TrackOn or T.TrackOff})
                tw(thumb,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)})
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end

            local cl=Instance.new("TextButton"); cl.Size=UDim2.new(1,0,1,0)
            cl.BackgroundTransparency=1; cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f
            cl.MouseButton1Click:Connect(function() set(not state) end)

            function s:Set(v) set(v) end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- SLIDER
        function Tab:CreateSlider(s)
            local mn=s.Range and s.Range[1] or 0
            local mx=s.Range and s.Range[2] or 100
            local inc=s.Increment or 1
            local val=math.clamp(s.CurrentValue or mn, mn, mx)
            local suf=s.Suffix and (" "..s.Suffix) or ""

            local f=row(54)

            local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(0.55,0,0,22)
            nl.Position=UDim2.fromOffset(12,4); nl.BackgroundTransparency=1
            nl.Text=s.Name or "Slider"; nl.TextSize=13; nl.Font=Enum.Font.GothamMedium
            nl.TextColor3=T.Text; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f

            local function fmt(v)
                local r=math.floor(v/inc+0.5)*inc
                return (math.floor(r)==r and tostring(math.floor(r)) or string.format("%.2f",r))..suf
            end

            local vl=Instance.new("TextLabel"); vl.Size=UDim2.new(0.45,-12,0,22)
            vl.Position=UDim2.new(0.55,0,0,4); vl.BackgroundTransparency=1; vl.Text=fmt(val)
            vl.TextSize=12; vl.Font=Enum.Font.Gotham; vl.TextColor3=T.TextDim
            vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=f; pad(vl,0,12,0,0)

            local tBg=Instance.new("Frame"); tBg.Size=UDim2.new(1,-24,0,5)
            tBg.Position=UDim2.new(0,12,1,-14); tBg.BackgroundColor3=Color3.fromRGB(255,255,255)
            tBg.BackgroundTransparency=0.82; tBg.BorderSizePixel=0; tBg.Parent=f; corner(tBg,3)

            local fill=Instance.new("Frame"); fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)
            fill.BackgroundColor3=T.Accent; fill.BorderSizePixel=0; fill.Parent=tBg; corner(fill,3)

            local knob=Instance.new("Frame"); knob.Size=UDim2.fromOffset(14,14)
            knob.Position=UDim2.new((val-mn)/(mx-mn),-7,0.5,-7)
            knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
            knob.ZIndex=2; knob.Parent=tBg; corner(knob,7)
            stroke(knob,T.Accent,0.1,2)

            s.CurrentValue=val
            local sliding=false

            local function upd(px)
                local abs=tBg.AbsolutePosition; local sz=tBg.AbsoluteSize
                local pct=math.clamp((px-abs.X)/sz.X,0,1)
                local nv=math.floor((mn+pct*(mx-mn))/inc+0.5)*inc
                nv=math.clamp(nv,mn,mx)
                s.CurrentValue=nv; vl.Text=fmt(nv)
                tw(fill,{Size=UDim2.new(pct,0,1,0)})
                tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
                if s.Callback then task.spawn(pcall,s.Callback,nv) end
            end

            tBg.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    sliding=true; upd(i.Position.X) end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)

            function s:Set(v)
                v=math.clamp(v,mn,mx); local pct=(v-mn)/(mx-mn)
                s.CurrentValue=v; vl.Text=fmt(v)
                tw(fill,{Size=UDim2.new(pct,0,1,0)}); tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- INPUT
        function Tab:CreateInput(s)
            local f=row(56)
            local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0,20)
            nl.Position=UDim2.fromOffset(12,4); nl.BackgroundTransparency=1
            nl.Text=s.Name or "Input"; nl.TextSize=11; nl.Font=Enum.Font.GothamBold
            nl.TextColor3=T.TextMuted; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f

            local ibg=Instance.new("Frame"); ibg.Size=UDim2.new(1,-24,0,24)
            ibg.Position=UDim2.fromOffset(12,26); ibg.BackgroundColor3=Color3.fromRGB(0,0,0)
            ibg.BackgroundTransparency=0.46; ibg.BorderSizePixel=0; ibg.Parent=f; corner(ibg,5)
            stroke(ibg,T.Border,0.82,1,Enum.ApplyStrokeMode.Contextual)

            local tb=Instance.new("TextBox"); tb.Size=UDim2.new(1,-16,1,0)
            tb.Position=UDim2.fromOffset(8,0); tb.BackgroundTransparency=1
            tb.Text=s.CurrentValue or ""; tb.PlaceholderText=s.PlaceholderText or "Enter text…"
            tb.TextSize=13; tb.Font=Enum.Font.Gotham; tb.TextColor3=T.Text
            tb.PlaceholderColor3=T.TextMuted; tb.TextXAlignment=Enum.TextXAlignment.Left
            tb.ClearTextOnFocus=false; tb.MultiLine=false; tb.BorderSizePixel=0; tb.Parent=ibg

            tb.FocusLost:Connect(function(enter)
                s.CurrentValue=tb.Text
                if s.Callback then task.spawn(pcall,s.Callback,tb.Text) end
                if s.RemoveTextAfterFocusLost then tb.Text="" end
            end)

            function s:Set(v) tb.Text=v; s.CurrentValue=v end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- DROPDOWN
        function Tab:CreateDropdown(s)
            local opts=s.Options or {}
            local multi=s.MultipleOptions==true
            if s.CurrentOption then
                if type(s.CurrentOption)=="string" then s.CurrentOption={s.CurrentOption} end
            else s.CurrentOption={} end
            if not multi then s.CurrentOption={s.CurrentOption[1]} end

            local open=false
            local f=row(36)

            local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(0.5,0,1,0)
            nl.Position=UDim2.fromOffset(12,0); nl.BackgroundTransparency=1
            nl.Text=s.Name or "Dropdown"; nl.TextSize=13; nl.Font=Enum.Font.GothamMedium
            nl.TextColor3=T.Text; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f

            local selBtn=Instance.new("TextButton"); selBtn.Size=UDim2.new(0.46,-8,0,24)
            selBtn.Position=UDim2.new(0.5,2,0.5,-12); selBtn.BackgroundColor3=Color3.fromRGB(0,0,0)
            selBtn.BackgroundTransparency=0.46; selBtn.BorderSizePixel=0
            selBtn.AutoButtonColor=false; selBtn.TextSize=12; selBtn.Font=Enum.Font.Gotham
            selBtn.TextColor3=T.Text; selBtn.Parent=f; corner(selBtn,5)
            stroke(selBtn,T.Border,0.82,1,Enum.ApplyStrokeMode.Contextual)

            local function selText()
                if #s.CurrentOption==0 then return "None"
                elseif #s.CurrentOption==1 then return s.CurrentOption[1]
                else return "Various" end
            end
            selBtn.Text=selText().."  ▾"

            local ddF=Instance.new("Frame"); ddF.Size=UDim2.new(0.46,-8,0,math.min(#opts,6)*26+8)
            ddF.Position=UDim2.new(0.5,2,1,4); ddF.BackgroundColor3=Color3.fromRGB(10,10,18)
            ddF.BackgroundTransparency=0.06; ddF.BorderSizePixel=0; ddF.ZIndex=20
            ddF.Visible=false; ddF.ClipsDescendants=true; ddF.Parent=f; corner(ddF,7)
            stroke(ddF,T.Border,0.82,1,Enum.ApplyStrokeMode.Contextual)

            local ddSF=Instance.new("ScrollingFrame"); ddSF.Size=UDim2.new(1,0,1,0)
            ddSF.BackgroundTransparency=1; ddSF.BorderSizePixel=0
            ddSF.ScrollBarThickness=2; ddSF.ScrollBarImageColor3=T.Accent
            ddSF.CanvasSize=UDim2.new(0,0,0,0); ddSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
            ddSF.Parent=ddF; list(ddSF,2); pad(ddSF,4,4,4,4)

            for _,opt in ipairs(opts) do
                local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,24)
                ob.BackgroundColor3=Color3.fromRGB(255,255,255); ob.BackgroundTransparency=0.88
                ob.BorderSizePixel=0; ob.Text=opt; ob.TextSize=12; ob.Font=Enum.Font.Gotham
                ob.TextColor3=T.Text; ob.AutoButtonColor=false; ob.ZIndex=21; ob.Parent=ddSF
                corner(ob,5)
                -- highlight if selected
                if table.find(s.CurrentOption,opt) then
                    ob.BackgroundTransparency=0.74; ob.TextColor3=T.Text
                end
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0.74}) end)
                ob.MouseLeave:Connect(function()
                    tw(ob,{BackgroundTransparency=table.find(s.CurrentOption,opt) and 0.74 or 0.88})
                end)
                ob.MouseButton1Click:Connect(function()
                    if not multi then
                        s.CurrentOption={opt}
                        selBtn.Text=opt.."  ▾"; open=false; ddF.Visible=false
                    else
                        if table.find(s.CurrentOption,opt) then
                            table.remove(s.CurrentOption,table.find(s.CurrentOption,opt))
                            tw(ob,{BackgroundTransparency=0.88})
                        else
                            table.insert(s.CurrentOption,opt)
                            tw(ob,{BackgroundTransparency=0.74})
                        end
                        selBtn.Text=selText().."  ▾"
                    end
                    if s.Callback then task.spawn(pcall,s.Callback,s.CurrentOption) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function() open=not open; ddF.Visible=open end)

            function s:Set(v)
                if type(v)=="string" then v={v} end
                s.CurrentOption=v; selBtn.Text=selText().."  ▾"
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            function s:Refresh(newOpts)
                s.Options=newOpts; for _,c in ipairs(ddSF:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,opt in ipairs(newOpts) do
                    local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,24)
                    ob.BackgroundColor3=Color3.fromRGB(255,255,255); ob.BackgroundTransparency=0.88
                    ob.BorderSizePixel=0; ob.Text=opt; ob.TextSize=12; ob.Font=Enum.Font.Gotham
                    ob.TextColor3=T.Text; ob.AutoButtonColor=false; ob.ZIndex=21; ob.Parent=ddSF
                    corner(ob,5)
                end
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- KEYBIND
        function Tab:CreateKeybind(s)
            local checking=false
            local f=row(36)

            local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(0.55,0,1,0)
            nl.Position=UDim2.fromOffset(12,0); nl.BackgroundTransparency=1
            nl.Text=s.Name or "Keybind"; nl.TextSize=13; nl.Font=Enum.Font.GothamMedium
            nl.TextColor3=T.Text; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f

            local kbg=Instance.new("Frame"); kbg.Size=UDim2.new(0.42,-8,0,24)
            kbg.Position=UDim2.new(0.54,2,0.5,-12); kbg.BackgroundColor3=Color3.fromRGB(0,0,0)
            kbg.BackgroundTransparency=0.46; kbg.BorderSizePixel=0; kbg.Parent=f; corner(kbg,5)
            stroke(kbg,T.Border,0.82,1,Enum.ApplyStrokeMode.Contextual)

            local ktb=Instance.new("TextBox"); ktb.Size=UDim2.new(1,-12,1,0)
            ktb.Position=UDim2.fromOffset(6,0); ktb.BackgroundTransparency=1
            ktb.Text=s.CurrentKeybind or "None"; ktb.TextSize=12; ktb.Font=Enum.Font.Gotham
            ktb.TextColor3=T.Text; ktb.TextXAlignment=Enum.TextXAlignment.Center
            ktb.ClearTextOnFocus=false; ktb.BorderSizePixel=0; ktb.Parent=kbg

            ktb.Focused:Connect(function() checking=true; ktb.Text="" end)
            ktb.FocusLost:Connect(function()
                checking=false
                if ktb.Text=="" then ktb.Text=s.CurrentKeybind or "None" end
            end)

            local conn=UIS.InputBegan:Connect(function(i,p)
                if p then return end
                if checking then
                    if i.KeyCode~=Enum.KeyCode.Unknown then
                        local kn=string.split(tostring(i.KeyCode),".")[3]
                        ktb.Text=kn; s.CurrentKeybind=kn
                        ktb:ReleaseFocus()
                        if s.CallOnChange and s.Callback then task.spawn(pcall,s.Callback,kn) end
                    end
                elseif not s.HoldToInteract and s.CurrentKeybind and i.KeyCode==Enum.KeyCode[s.CurrentKeybind] then
                    if s.Callback then task.spawn(pcall,s.Callback) end
                end
            end)

            function s:Set(v)
                s.CurrentKeybind=v; ktb.Text=v
                if s.CallOnChange and s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- COLOR PICKER
        function Tab:CreateColorPicker(s)
            local cc=s.Color or Color3.fromRGB(255,0,0)
            local h,sv_s,sv_v=Color3.toHSV(cc)
            local open=false

            local f=row(36)
            local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-60,1,0)
            nl.Position=UDim2.fromOffset(12,0); nl.BackgroundTransparency=1
            nl.Text=s.Name or "Color"; nl.TextSize=13; nl.Font=Enum.Font.GothamMedium
            nl.TextColor3=T.Text; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=f

            local swatch=Instance.new("Frame"); swatch.Size=UDim2.fromOffset(34,22)
            swatch.Position=UDim2.new(1,-44,0.5,-11); swatch.BackgroundColor3=cc
            swatch.BorderSizePixel=0; swatch.Parent=f; corner(swatch,6)
            stroke(swatch,T.Border,0.82,1)

            local pW=CONTENT_W-28
            local pp=Instance.new("Frame"); pp.Size=UDim2.fromOffset(pW,175)
            pp.Position=UDim2.new(0,0,1,5); pp.BackgroundColor3=Color3.fromRGB(10,10,18)
            pp.BackgroundTransparency=0.06; pp.BorderSizePixel=0; pp.ZIndex=15
            pp.Visible=false; pp.ClipsDescendants=false; pp.Parent=f; corner(pp,9)
            stroke(pp,T.Border,0.82,1,Enum.ApplyStrokeMode.Contextual)

            local svW=pW-44; local svH=145

            local svB=Instance.new("Frame"); svB.Size=UDim2.fromOffset(svW,svH)
            svB.Position=UDim2.fromOffset(10,15); svB.BackgroundColor3=Color3.fromHSV(h,1,1)
            svB.BorderSizePixel=0; svB.ZIndex=15; svB.Parent=pp; corner(svB,7)

            local function mkGrad(parent,rot,seq,tseq)
                local fr=Instance.new("Frame"); fr.Size=UDim2.new(1,0,1,0)
                fr.BackgroundTransparency=1; fr.BorderSizePixel=0; fr.ZIndex=16; fr.Parent=parent
                local g=Instance.new("UIGradient"); g.Color=seq; g.Rotation=rot
                if tseq then g.Transparency=tseq end; g.Parent=fr
            end
            mkGrad(svB,0,
                ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkGrad(svB,90,
                ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))

            local svCur=Instance.new("Frame"); svCur.Size=UDim2.fromOffset(12,12)
            svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); svCur.BackgroundColor3=Color3.fromRGB(255,255,255)
            svCur.BorderSizePixel=0; svCur.ZIndex=18; svCur.Parent=svB; corner(svCur,6)
            stroke(svCur,Color3.fromRGB(0,0,0),0,1)

            local hBar=Instance.new("Frame"); hBar.Size=UDim2.fromOffset(18,svH)
            hBar.Position=UDim2.fromOffset(svW+16,15); hBar.BackgroundColor3=Color3.fromRGB(255,255,255)
            hBar.BorderSizePixel=0; hBar.ZIndex=15; hBar.Parent=pp; corner(hBar,5)
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

            local hCur=Instance.new("Frame"); hCur.Size=UDim2.new(1,6,0,5)
            hCur.Position=UDim2.new(-0.15,0,h,-2); hCur.BackgroundColor3=Color3.fromRGB(255,255,255)
            hCur.BorderSizePixel=0; hCur.ZIndex=18; hCur.Parent=hBar; corner(hCur,2)
            stroke(hCur,Color3.fromRGB(0,0,0),0,1)

            local function updColor()
                cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end
            end

            local svDrag=false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svDrag=true; local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1)
                    sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); updColor()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if svDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1)
                    sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); updColor()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false end
            end)

            local hDrag=false
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hDrag=true; local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); updColor()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if hDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); updColor()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hDrag=false end
            end)

            local cl=Instance.new("TextButton"); cl.Size=UDim2.new(1,0,1,0)
            cl.BackgroundTransparency=1; cl.Text=""; cl.AutoButtonColor=false; cl.Parent=f
            cl.MouseButton1Click:Connect(function() open=not open; pp.Visible=open end)

            function s:Set(c)
                cc=c; h,sv_s,sv_v=Color3.toHSV(c); s.Color=c
                swatch.BackgroundColor3=c; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); hCur.Position=UDim2.new(-0.15,0,h,-2)
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        return Tab
    end -- CreateTab

    -- destroy
    function Window:Destroy()
        sg:Destroy()
    end

    return Window
end -- CreateWindow

function Xanix:LoadConfiguration() end  -- stub for Rayfield compat
function Xanix:SetVisibility(_) end
function Xanix:IsVisible() return true end
function Xanix:Destroy() end

return Xanix
