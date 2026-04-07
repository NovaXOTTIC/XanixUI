--[[
  Xanix UI Library — matches preview screenshot exactly
  
  Layout:
    [Search pill   ]   [                              ]
    [              ]   [  Title bar  (blue underline) ]
    [  Tab list    ]   [                              ]
    [  (floating)  ]   [    Content / Pages           ]
    [              ]   [                              ]
    
  Usage:
    local Xanix = loadstring(game:HttpGet("RAW_URL"))()
    local Win = Xanix:CreateWindow({ Name = "My Hub" })
    local Tab = Win:CreateTab("Main")
    Tab:CreateButton({ Name = "Kill All", Callback = function() end })
    Tab:CreateToggle({ Name = "ESP", CurrentValue = false, Callback = function(v) end })
    Tab:CreateSlider({ Name = "Speed", Range={16,500}, Increment=1, CurrentValue=16, Callback=function(v) end })
    Tab:CreateColorPicker({ Name = "Color", Color=Color3.fromRGB(255,0,0), Callback=function(c) end })
    Tab:CreateDropdown({ Name = "Mode", Options={"A","B"}, CurrentOption={"A"}, Callback=function(o) end })
    Tab:CreateInput({ Name = "Player", PlaceholderText="name…", Callback=function(t) end })
    Tab:CreateSection("Section")
    Tab:CreateKeybind({ Name = "Key", CurrentKeybind="E", Callback=function() end })
    Xanix:Notify({ Title="Hello", Content="World", Duration=4 })
]]

local Xanix = { Flags = {} }
Xanix.__index = Xanix

local Players  = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local LP       = Players.LocalPlayer
local PG       = LP:WaitForChild("PlayerGui")

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ─── EXACT COLOURS FROM SCREENSHOT ──────────────────────────────────────────
local C = {
    -- Deep dark backgrounds
    Bg           = Color3.fromRGB(8,   8,   12),   -- main panels
    BgTab        = Color3.fromRGB(10,  10,  14),   -- tab list bg
    BgSearch     = Color3.fromRGB(10,  10,  14),   -- search pill bg
    BgTitleBar   = Color3.fromRGB(14,  14,  20),   -- title bar slightly lighter
    BgRow        = Color3.fromRGB(14,  14,  18),   -- element rows
    BgRowHover   = Color3.fromRGB(20,  20,  26),
    BgTabBtn     = Color3.fromRGB(12,  12,  17),   -- tab button fill
    BgTabAct     = Color3.fromRGB(16,  16,  22),   -- active tab
    BgInput      = Color3.fromRGB(10,  10,  14),
    BgDd         = Color3.fromRGB(12,  12,  18),
    -- Borders — the KEY detail: blue-tinted borders matching screenshot
    BorderPanel  = Color3.fromRGB(50,  65,  120),  -- content panel outer glow (blue)
    BorderTab    = Color3.fromRGB(55,  70,  130),  -- tab list border (blue)
    BorderSearch = Color3.fromRGB(80,  80,  90),   -- search pill (subtle)
    BorderTabBtn = Color3.fromRGB(55,  75,  140),  -- tab button (blue, matches screenshot)
    BorderRow    = Color3.fromRGB(35,  35,  45),   -- row border (subtle)
    BorderInput  = Color3.fromRGB(40,  40,  55),
    -- Blue underline under title bar
    Underline    = Color3.fromRGB(60,  90,  200),
    -- Text
    Text         = Color3.fromRGB(255, 255, 255),
    TextDim      = Color3.fromRGB(160, 165, 185),
    TextMuted    = Color3.fromRGB(100, 105, 125),
    -- Toggle/Slider
    TrackOff     = Color3.fromRGB(35,  35,  45),
    TrackOn      = Color3.fromRGB(80,  110, 220),
    Fill         = Color3.fromRGB(80,  110, 220),
    -- Notif
    NotifBg      = Color3.fromRGB(10,  10,  16),
}

-- ─── LAYOUT SIZES ────────────────────────────────────────────────────────────
local PC  = { TAB_W=245, CONTENT_W=950, FULL_H=630, SEARCH_H=38, TITLE_H=52, SET_H=38, GAP=20 }
local MOB = { TAB_W=170, CONTENT_W=330, FULL_H=420, SEARCH_H=32, TITLE_H=42, SET_H=32, GAP=12 }
local S   = IS_MOBILE and MOB or PC

local TW  = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW2 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function mk(cls, p)
    local o = Instance.new(cls)
    for k,v in pairs(p or {}) do o[k]=v end
    return o
end
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function stroke(p, col, thick, alpha, mode)
    local s = Instance.new("UIStroke")
    s.Color = col or C.BorderRow; s.Thickness = thick or 1
    s.Transparency = alpha or 0
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round; s.Parent = p; return s
end
local function pad(p, l, r, t, b)
    local pd = Instance.new("UIPadding")
    pd.PaddingLeft=UDim.new(0,l or 0); pd.PaddingRight=UDim.new(0,r or 0)
    pd.PaddingTop=UDim.new(0,t or 0); pd.PaddingBottom=UDim.new(0,b or 0)
    pd.Parent = p; return pd
end
local function llist(p, sp)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, sp or 4); l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p; return l
end
local function tw(o, props, info) TweenSvc:Create(o, info or TW, props):Play() end

-- ─── NOTIFICATIONS (pill style) ──────────────────────────────────────────────
local _nsg, _nlist

local function ensureNotif()
    if _nsg and _nsg.Parent then return end
    _nsg = mk("ScreenGui",{
        Name="XanixNotifs", ResetOnSpawn=false, IgnoreGuiInset=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=200, Parent=PG
    })
    _nlist = mk("Frame",{
        Size=UDim2.new(0,260,1,0), Position=UDim2.new(1,-272,0,0),
        BackgroundTransparency=1, BorderSizePixel=0, Parent=_nsg
    })
    local ul = mk("UIListLayout",{
        Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        FillDirection=Enum.FillDirection.Vertical, Parent=_nlist
    })
    pad(_nlist,6,6,10,10)
end

function Xanix:Notify(data)
    task.spawn(function()
        ensureNotif(); data = data or {}
        local pill = mk("TextLabel",{
            Size=UDim2.new(0,248,0,46),
            BackgroundColor3=C.NotifBg, BackgroundTransparency=1,
            Text="✦  "..(data.Title or "")..(data.Content and "  ·  "..data.Content or ""),
            TextSize=IS_MOBILE and 11 or 13, Font=Enum.Font.GothamMedium,
            TextColor3=C.Text, TextWrapped=false,
            TextXAlignment=Enum.TextXAlignment.Center,
            TextTransparency=1, Visible=true, Parent=_nlist
        })
        corner(pill, 1000)
        stroke(pill, Color3.fromRGB(255,255,255), 1, 0)
        task.wait(0.05)
        tw(pill,{BackgroundTransparency=0.44},TW2); tw(pill,{TextTransparency=0},TW2)
        task.wait(data.Duration or 4)
        tw(pill,{BackgroundTransparency=1},TW2); tw(pill,{TextTransparency=1},TW2)
        task.wait(0.3); pill:Destroy()
    end)
end

-- ─── CREATE WINDOW ────────────────────────────────────────────────────────────
function Xanix:CreateWindow(cfg)
    cfg = cfg or {}
    local winName   = cfg.Name or "Xanix"
    local toggleKey = cfg.ToggleUIKeybind or "K"
    if typeof(toggleKey)=="EnumItem" then toggleKey=toggleKey.Name end

    local sg = mk("ScreenGui",{
        Name="Xanix", ResetOnSpawn=false, IgnoreGuiInset=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=100, Parent=PG
    })

    local totalW = S.TAB_W + S.GAP + S.CONTENT_W
    local totalH = S.SEARCH_H + 8 + S.FULL_H

    -- Anchor — invisible, drag from title bar moves this
    local anchor = mk("Frame",{
        Name="Anchor",
        Size=UDim2.fromOffset(totalW, totalH),
        Position=UDim2.new(0.5,-totalW/2, 0.5,-totalH/2),
        BackgroundTransparency=1, BorderSizePixel=0, Parent=sg
    })

    local guiVisible = true

    -- ┌─ SEARCH BAR (floating pill above tab list) ─────────────────────────────
    local searchPill = mk("Frame",{
        Name="SearchPill",
        Size=UDim2.fromOffset(S.TAB_W, S.SEARCH_H),
        Position=UDim2.fromOffset(0, 0),
        BackgroundColor3=C.BgSearch,
        BackgroundTransparency=0,
        BorderSizePixel=0, Parent=anchor
    })
    corner(searchPill, 100)  -- pill shape like screenshot
    stroke(searchPill, C.BorderSearch, 1, 0)

    local searchBox = mk("TextBox",{
        Name="SearchBox",
        Size=UDim2.new(1,-38,1,0), Position=UDim2.fromOffset(14,0),
        BackgroundTransparency=1, Text="",
        PlaceholderText="Search...",
        TextSize=IS_MOBILE and 11 or 13, Font=Enum.Font.GothamMedium,
        TextColor3=C.Text, PlaceholderColor3=C.TextMuted,
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false, MultiLine=false, BorderSizePixel=0,
        Parent=searchPill
    })

    local searchIcon = mk("ImageLabel",{
        Name="SearchIcon",
        Size=UDim2.fromOffset(18,18),
        Position=UDim2.new(1,-28,0.5,-9),
        BackgroundTransparency=1,
        Image="rbxassetid://3926305904",
        ImageColor3=C.TextMuted, Parent=searchPill
    })

    -- ┌─ TAB LIST (floating panel below search) ────────────────────────────────
    local tabListY = S.SEARCH_H + 8
    local tabListH = S.FULL_H

    local tabPanel = mk("Frame",{
        Name="TabPanel",
        Size=UDim2.fromOffset(S.TAB_W, tabListH),
        Position=UDim2.fromOffset(0, tabListY),
        BackgroundColor3=C.BgTab,
        BackgroundTransparency=0,
        BorderSizePixel=0, Parent=anchor
    })
    corner(tabPanel, 12)
    stroke(tabPanel, C.BorderTab, 1, 0)

    local tabSF = mk("ScrollingFrame",{
        Name="TabScrollFrame",
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        ScrollBarThickness=IS_MOBILE and 2 or 3,
        ScrollBarImageColor3=Color3.fromRGB(60,60,80),
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        BorderSizePixel=0, Parent=tabPanel
    })
    llist(tabSF, IS_MOBILE and 5 or 7)
    pad(tabSF, 12, 12, 14, 14)

    -- ┌─ CONTENT PANEL (right, full height) ────────────────────────────────────
    local contentF = mk("Frame",{
        Name="ContentPanel",
        Size=UDim2.fromOffset(S.CONTENT_W, S.FULL_H + S.SEARCH_H + 8),
        Position=UDim2.fromOffset(S.TAB_W + S.GAP, 0),
        BackgroundColor3=C.Bg,
        BackgroundTransparency=0,
        BorderSizePixel=0, ClipsDescendants=true, Parent=anchor
    })
    corner(contentF, 12)
    stroke(contentF, C.BorderPanel, 1, 0)

    -- Title bar
    local titleBar = mk("Frame",{
        Name="TitleBar",
        Size=UDim2.new(1,0,0,S.TITLE_H),
        BackgroundColor3=C.BgTitleBar,
        BackgroundTransparency=0,
        BorderSizePixel=0, Parent=contentF
    })

    -- Blue underline (key detail from screenshot)
    mk("Frame",{
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.Underline,
        BackgroundTransparency=0,
        BorderSizePixel=0, Parent=titleBar
    })

    -- Window title
    mk("TextLabel",{
        Name="WinTitle",
        Size=UDim2.new(1,-70,1,0),
        Position=UDim2.fromOffset(IS_MOBILE and 12 or 18, 0),
        BackgroundTransparency=1,
        Text=winName,
        TextSize=IS_MOBILE and 15 or 20,
        Font=Enum.Font.GothamBold,
        TextColor3=C.Text,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=titleBar
    })

    -- Minimise button (box with border, "–" text — matches screenshot)
    local minimised = false
    local minBtnF = mk("Frame",{
        Size=UDim2.fromOffset(IS_MOBILE and 30 or 36, IS_MOBILE and 24 or 28),
        Position=UDim2.new(1,-(IS_MOBILE and 42 or 52), 0.5, -(IS_MOBILE and 12 or 14)),
        BackgroundColor3=C.Bg,
        BackgroundTransparency=0,
        BorderSizePixel=0, Parent=titleBar
    })
    corner(minBtnF, 7)
    stroke(minBtnF, C.BorderSearch, 1, 0)

    local minBtn = mk("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="–", TextSize=IS_MOBILE and 14 or 17,
        Font=Enum.Font.GothamBold,
        TextColor3=C.TextDim,
        AutoButtonColor=false, Parent=minBtnF
    })
    minBtn.MouseEnter:Connect(function() tw(minBtn,{TextColor3=C.Text}) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn,{TextColor3=C.TextDim}) end)

    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            tw(contentF,{Size=UDim2.fromOffset(S.CONTENT_W,S.TITLE_H)},TW2)
            tw(tabPanel,{Size=UDim2.fromOffset(S.TAB_W,S.TITLE_H)},TW2)
            tw(tabPanel,{Position=UDim2.fromOffset(0,S.SEARCH_H+8+(S.FULL_H-S.TITLE_H)/2)},TW2)
            minBtn.Text="+"
        else
            tw(contentF,{Size=UDim2.fromOffset(S.CONTENT_W,S.FULL_H+S.SEARCH_H+8)},TW2)
            tw(tabPanel,{Size=UDim2.fromOffset(S.TAB_W,tabListH)},TW2)
            tw(tabPanel,{Position=UDim2.fromOffset(0,tabListY)},TW2)
            minBtn.Text="–"
        end
    end)

    -- Pages container
    local pagesC = mk("Frame",{
        Name="PagesContainer",
        Size=UDim2.new(1,-24,1,-S.TITLE_H-12),
        Position=UDim2.fromOffset(12, S.TITLE_H+8),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        BorderSizePixel=0, Parent=contentF
    })

    -- ─── TAB STATE ────────────────────────────────────────────────────────────
    local tabs={}, activeTab=nil

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q=searchBox.Text:lower()
        for _,t in ipairs(tabs) do
            t.btn.Visible = q=="" or (t.name:lower():find(q,1,true)~=nil)
        end
    end)

    local function switchTab(t)
        if activeTab==t then return end
        for _,v in ipairs(tabs) do
            v.page.Visible=false
            tw(v.btn,{BackgroundColor3=C.BgTabBtn,TextColor3=C.TextDim})
            if v.bar then tw(v.bar,{BackgroundTransparency=1}) end
        end
        t.page.Visible=true
        tw(t.btn,{BackgroundColor3=C.BgTabAct,TextColor3=C.Text})
        if t.bar then tw(t.bar,{BackgroundTransparency=0}) end
        activeTab=t
    end

    -- ─── DRAG (title bar only — the critical fix) ─────────────────────────────
    local dragging,dragStart,startPos=false,nil,nil

    local function beginDrag(px,py)
        dragging=true
        dragStart=Vector2.new(px,py)
        startPos=anchor.Position
    end
    local function endDrag() dragging=false end

    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            beginDrag(i.Position.X,i.Position.Y)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then
            local d=Vector2.new(i.Position.X,i.Position.Y)-dragStart
            anchor.Position=UDim2.new(
                startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then endDrag() end
    end)

    -- ─── K TOGGLE ────────────────────────────────────────────────────────────
    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        local ok,kc=pcall(function() return Enum.KeyCode[toggleKey] end)
        if ok and i.KeyCode==kc then
            guiVisible=not guiVisible; anchor.Visible=guiVisible
        end
    end)

    -- ─── MOBILE OPEN BUTTON ───────────────────────────────────────────────────
    if IS_MOBILE then
        local mob=mk("TextButton",{
            Size=UDim2.fromOffset(120,34),
            Position=UDim2.new(0.5,-60,0,10),
            BackgroundColor3=C.Bg,BackgroundTransparency=0,
            BorderSizePixel=0,Text="Open "..winName,
            TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.Text,
            AutoButtonColor=false,ZIndex=200,Parent=sg
        })
        corner(mob,1000)
        stroke(mob,C.BorderTabBtn,1,0)
        mob.MouseButton1Click:Connect(function()
            guiVisible=not guiVisible; anchor.Visible=guiVisible
            mob.Text=guiVisible and ("Hide "..winName) or ("Open "..winName)
        end)
    end

    -- ─── WINDOW API ──────────────────────────────────────────────────────────
    local Window={}

    function Window:CreateTab(name, _icon)
        local FS=IS_MOBILE and 12 or 14
        local ROW_H=IS_MOBILE and 34 or 40

        -- Tab button — matches screenshot: dark fill, blue border
        local btn=mk("TextButton",{
            Name=name,
            Size=UDim2.new(1,0,0,IS_MOBILE and 34 or 40),
            BackgroundColor3=C.BgTabBtn,
            BackgroundTransparency=0,
            BorderSizePixel=0,
            Text=name,
            TextSize=IS_MOBILE and 13 or 16,
            Font=Enum.Font.GothamMedium,
            TextColor3=C.TextDim,
            TextXAlignment=Enum.TextXAlignment.Center,
            TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,
            AutoButtonColor=false,LayoutOrder=#tabs+1,Parent=tabSF
        })
        corner(btn,9)
        -- Blue border like in screenshot
        local btnStroke=stroke(btn,C.BorderTabBtn,1,0)

        -- Left accent bar (white, shows when active)
        local bar=mk("Frame",{
            Size=UDim2.fromOffset(3,IS_MOBILE and 14 or 16),
            Position=UDim2.new(0,-1,0.5,-(IS_MOBILE and 7 or 8)),
            BackgroundColor3=Color3.fromRGB(255,255,255),
            BackgroundTransparency=1,BorderSizePixel=0,Parent=btn
        })
        corner(bar,2)

        -- Page
        local page=mk("ScrollingFrame",{
            Name=name,Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            ScrollBarThickness=IS_MOBILE and 2 or 3,
            ScrollBarImageColor3=Color3.fromRGB(50,60,90),
            CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            BorderSizePixel=0,Visible=false,ClipsDescendants=true,Parent=pagesC
        })
        llist(page,IS_MOBILE and 4 or 6)
        pad(page,0,0,6,6)

        local t={name=name,btn=btn,bar=bar,page=page}
        table.insert(tabs,t)

        btn.MouseEnter:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundColor3=Color3.fromRGB(18,18,26),TextColor3=C.Text}) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundColor3=C.BgTabBtn,TextColor3=C.TextDim}) end
        end)
        btn.MouseButton1Click:Connect(function() dragging=false; switchTab(t) end)
        if #tabs==1 then switchTab(t) end

        -- ── ROW ───────────────────────────────────────────────────────────────
        local function row(h)
            local f=mk("Frame",{
                Size=UDim2.new(1,0,0,h or ROW_H),
                BackgroundColor3=C.BgRow,BackgroundTransparency=0,
                BorderSizePixel=0,Parent=page
            })
            corner(f,8)
            stroke(f,C.BorderRow,1,0,Enum.ApplyStrokeMode.Border)
            f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.BgRowHover}) end)
            f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.BgRow}) end)
            return f
        end

        local Tab={}

        -- SECTION
        function Tab:CreateSection(n)
            local f=mk("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Parent=page})
            mk("TextLabel",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=(n or ""):upper(),TextSize=9,Font=Enum.Font.GothamBold,
                TextColor3=C.TextMuted,TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })
            pad(f,2,2,0,0)
            local sv={}; function sv:Set(x) f:FindFirstChildWhichIsA("TextLabel").Text=(x or ""):upper() end
            return sv
        end

        -- LABEL (matches "Welcome to Oxen UI" row in screenshot)
        function Tab:CreateLabel(txt,_icon,col)
            local f=row(IS_MOBILE and 32 or 38)
            mk("TextLabel",{
                Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=txt or "",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=col or C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=f
            })
            local lv={}; function lv:Set(s,_,c) f:FindFirstChildWhichIsA("TextLabel").Text=s or "" end
            return lv
        end

        -- PARAGRAPH
        function Tab:CreateParagraph(s)
            local f=row(nil); f.AutomaticSize=Enum.AutomaticSize.Y
            mk("TextLabel",{
                Size=UDim2.new(1,-20,0,18),Position=UDim2.fromOffset(14,7),
                BackgroundTransparency=1,Text=s.Title or "",TextSize=FS,
                Font=Enum.Font.GothamBold,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })
            local cl=mk("TextLabel",{
                Size=UDim2.new(1,-20,0,0),Position=UDim2.fromOffset(14,26),
                BackgroundTransparency=1,Text=s.Content or "",TextSize=FS-1,
                Font=Enum.Font.Gotham,TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                AutomaticSize=Enum.AutomaticSize.Y,Parent=f
            })
            local pv={}; function pv:Set(n) f:FindFirstChildWhichIsA("TextLabel").Text=n.Title or "" cl.Text=n.Content or "" end
            return pv
        end

        -- BUTTON
        function Tab:CreateButton(s)
            local f=row(ROW_H)

            local pip=mk("Frame",{
                Size=UDim2.fromOffset(3,13),Position=UDim2.new(0,0,0.5,-6),
                BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0,
                BorderSizePixel=0,Parent=f
            })
            corner(pip,2)

            local lbl=mk("TextLabel",{
                Size=UDim2.new(1,-50,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Button",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local arr=mk("TextLabel",{
                Size=UDim2.fromOffset(32,ROW_H),Position=UDim2.new(1,-36,0,0),
                BackgroundTransparency=1,Text="›",TextSize=17,
                Font=Enum.Font.GothamBold,TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Center,Parent=f
            })

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function()
                tw(f,{BackgroundColor3=Color3.fromRGB(22,25,35)})
                tw(arr,{TextColor3=C.Text})
                task.delay(0.2,function() tw(f,{BackgroundColor3=C.BgRow}); tw(arr,{TextColor3=C.TextMuted}) end)
                if s.Callback then task.spawn(pcall,s.Callback) end
            end)
            local bv={}; function bv:Set(n) lbl.Text=n end; return bv
        end

        -- TOGGLE
        function Tab:CreateToggle(s)
            local state=s.CurrentValue==true
            local f=row(ROW_H)

            mk("TextLabel",{
                Size=UDim2.new(1,-65,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Toggle",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local TW2x,TH=38,21
            local track=mk("Frame",{
                Size=UDim2.fromOffset(TW2x,TH),
                Position=UDim2.new(1,-(TW2x+10),0.5,-TH/2),
                BackgroundColor3=state and C.TrackOn or C.TrackOff,
                BorderSizePixel=0,Parent=f
            })
            corner(track,11)

            local thumb=mk("Frame",{
                Size=UDim2.fromOffset(15,15),
                Position=state and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3),
                BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Parent=track
            })
            corner(thumb,8)

            s.CurrentValue=state
            local function setV(v)
                state=v; s.CurrentValue=v
                tw(track,{BackgroundColor3=v and C.TrackOn or C.TrackOff})
                tw(thumb,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)})
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function() setV(not state) end)
            function s:Set(v) setV(v) end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- SLIDER
        function Tab:CreateSlider(s)
            local mn=s.Range and s.Range[1] or 0
            local mx=s.Range and s.Range[2] or 100
            local inc=s.Increment or 1
            local val=math.clamp(s.CurrentValue or mn,mn,mx)
            local suf=s.Suffix and (" "..s.Suffix) or ""
            local f=row(IS_MOBILE and 52 or 58)

            mk("TextLabel",{
                Size=UDim2.new(0.58,0,0,IS_MOBILE and 18 or 22),
                Position=UDim2.fromOffset(14,IS_MOBILE and 5 or 7),
                BackgroundTransparency=1,Text=s.Name or "Slider",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local function fmt(v)
                local r=math.floor(v/inc+0.5)*inc
                return (math.floor(r)==r and tostring(math.floor(r)) or string.format("%.2f",r))..suf
            end

            local vl=mk("TextLabel",{
                Size=UDim2.new(0.42,-14,0,IS_MOBILE and 18 or 22),
                Position=UDim2.new(0.58,0,0,IS_MOBILE and 5 or 7),
                BackgroundTransparency=1,Text=fmt(val),TextSize=FS-1,
                Font=Enum.Font.Gotham,TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=f
            })
            pad(vl,0,14,0,0)

            local tBg=mk("Frame",{
                Size=UDim2.new(1,-28,0,4),
                Position=UDim2.new(0,14,1,-(IS_MOBILE and 14 or 16)),
                BackgroundColor3=Color3.fromRGB(35,38,55),BackgroundTransparency=0,
                BorderSizePixel=0,Parent=f
            })
            corner(tBg,2)

            local fill=mk("Frame",{Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3=C.Fill,BorderSizePixel=0,Parent=tBg})
            corner(fill,2)

            local knob=mk("Frame",{
                Size=UDim2.fromOffset(14,14),
                Position=UDim2.new((val-mn)/(mx-mn),-7,0.5,-7),
                BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=3,Parent=tBg
            })
            corner(knob,7)

            s.CurrentValue=val
            local sliding=false

            local function upd(px)
                local abs=tBg.AbsolutePosition; local sz=tBg.AbsoluteSize
                local pct=math.clamp((px-abs.X)/sz.X,0,1)
                local nv=math.floor((mn+pct*(mx-mn))/inc+0.5)*inc
                nv=math.clamp(nv,mn,mx); s.CurrentValue=nv; vl.Text=fmt(nv)
                tw(fill,{Size=UDim2.new(pct,0,1,0)})
                tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
                if s.Callback then task.spawn(pcall,s.Callback,nv) end
            end

            -- Interact layer sits only on the track background — stops drag from firing
            local interact=mk("TextButton",{
                Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0.5,-11),
                BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=4,Parent=tBg
            })
            interact.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then
                    sliding=true; dragging=false; upd(i.Position.X)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
                  or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)

            function s:Set(v)
                v=math.clamp(v,mn,mx); local pct=(v-mn)/(mx-mn); s.CurrentValue=v; vl.Text=fmt(v)
                tw(fill,{Size=UDim2.new(pct,0,1,0)}); tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- INPUT
        function Tab:CreateInput(s)
            local f=row(IS_MOBILE and 50 or 56)
            mk("TextLabel",{
                Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(14,5),
                BackgroundTransparency=1,Text=s.Name or "Input",TextSize=9,
                Font=Enum.Font.GothamBold,TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })
            local ibg=mk("Frame",{
                Size=UDim2.new(1,-28,0,IS_MOBILE and 22 or 26),
                Position=UDim2.fromOffset(14,IS_MOBILE and 22 or 24),
                BackgroundColor3=C.BgInput,BackgroundTransparency=0,BorderSizePixel=0,Parent=f
            })
            corner(ibg,5); stroke(ibg,C.BorderInput,1,0)
            local tb=mk("TextBox",{
                Size=UDim2.new(1,-14,1,0),Position=UDim2.fromOffset(7,0),
                BackgroundTransparency=1,Text=s.CurrentValue or "",
                PlaceholderText=s.PlaceholderText or "Enter text…",
                TextSize=FS,Font=Enum.Font.Gotham,TextColor3=C.Text,
                PlaceholderColor3=C.TextMuted,TextXAlignment=Enum.TextXAlignment.Left,
                ClearTextOnFocus=false,MultiLine=false,BorderSizePixel=0,Parent=ibg
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

        -- DROPDOWN
        function Tab:CreateDropdown(s)
            local opts=s.Options or {}
            local multi=s.MultipleOptions==true
            if s.CurrentOption then
                if type(s.CurrentOption)=="string" then s.CurrentOption={s.CurrentOption} end
            else s.CurrentOption={} end
            if not multi then s.CurrentOption={s.CurrentOption[1]} end

            local open=false
            local f=row(ROW_H); f.ClipsDescendants=false

            mk("TextLabel",{
                Size=UDim2.new(0.5,0,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Dropdown",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local selBtn=mk("TextButton",{
                Size=UDim2.new(0.46,-8,0,IS_MOBILE and 24 or 28),
                Position=UDim2.new(0.52,2,0.5,-(IS_MOBILE and 12 or 14)),
                BackgroundColor3=C.BgInput,BackgroundTransparency=0,
                BorderSizePixel=0,TextSize=FS-1,Font=Enum.Font.Gotham,
                TextColor3=C.Text,AutoButtonColor=false,Parent=f
            })
            corner(selBtn,6); stroke(selBtn,C.BorderInput,1,0)

            local function selTxt()
                if #s.CurrentOption==0 then return "None  ▾"
                elseif #s.CurrentOption==1 then return s.CurrentOption[1].."  ▾"
                else return "Various  ▾" end
            end
            selBtn.Text=selTxt()

            local ddH=math.min(#opts,6)*(IS_MOBILE and 26 or 29)+8
            local ddF=mk("Frame",{
                BackgroundColor3=C.BgDd,BackgroundTransparency=0,
                BorderSizePixel=0,ZIndex=60,Visible=false,ClipsDescendants=true,Parent=anchor
            })
            corner(ddF,8); stroke(ddF,C.BorderPanel,1,0)

            local ddSF=mk("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
                ScrollBarThickness=2,ScrollBarImageColor3=Color3.fromRGB(60,70,100),
                CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
                ZIndex=61,Parent=ddF
            })
            llist(ddSF,2); pad(ddSF,4,4,4,4)

            local function posDD()
                local abs=selBtn.AbsolutePosition; local ancAbs=anchor.AbsolutePosition
                local w=selBtn.AbsoluteSize.X
                ddF.Size=UDim2.fromOffset(w,ddH)
                ddF.Position=UDim2.fromOffset(abs.X-ancAbs.X, abs.Y-ancAbs.Y+selBtn.AbsoluteSize.Y+3)
            end

            for _,opt in ipairs(opts) do
                local ob=mk("TextButton",{
                    Size=UDim2.new(1,0,0,IS_MOBILE and 26 or 29),
                    BackgroundColor3=Color3.fromRGB(16,16,22),BackgroundTransparency=0,
                    BorderSizePixel=0,Text=opt,TextSize=FS-1,Font=Enum.Font.Gotham,
                    TextColor3=C.Text,AutoButtonColor=false,ZIndex=62,Parent=ddSF
                })
                corner(ob,5)
                if table.find(s.CurrentOption,opt) then ob.BackgroundColor3=Color3.fromRGB(22,25,40) end
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(22,25,40)}) end)
                ob.MouseLeave:Connect(function()
                    tw(ob,{BackgroundColor3=table.find(s.CurrentOption,opt) and Color3.fromRGB(22,25,40) or Color3.fromRGB(16,16,22)})
                end)
                ob.MouseButton1Click:Connect(function()
                    if not multi then
                        s.CurrentOption={opt}; selBtn.Text=selTxt(); open=false; ddF.Visible=false
                    else
                        if table.find(s.CurrentOption,opt) then
                            table.remove(s.CurrentOption,table.find(s.CurrentOption,opt))
                            tw(ob,{BackgroundColor3=Color3.fromRGB(16,16,22)})
                        else
                            table.insert(s.CurrentOption,opt); tw(ob,{BackgroundColor3=Color3.fromRGB(22,25,40)})
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

        -- KEYBIND
        function Tab:CreateKeybind(s)
            local checking=false
            local f=row(ROW_H)
            mk("TextLabel",{
                Size=UDim2.new(0.55,0,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Keybind",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })
            local kbg=mk("Frame",{
                Size=UDim2.new(0.4,-8,0,IS_MOBILE and 24 or 28),
                Position=UDim2.new(0.57,2,0.5,-(IS_MOBILE and 12 or 14)),
                BackgroundColor3=C.BgInput,BackgroundTransparency=0,BorderSizePixel=0,Parent=f
            })
            corner(kbg,5); stroke(kbg,C.BorderInput,1,0)
            local ktb=mk("TextBox",{
                Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1,Text=s.CurrentKeybind or "None",
                TextSize=FS-1,Font=Enum.Font.Gotham,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false,
                BorderSizePixel=0,Parent=kbg
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

        -- COLOR PICKER
        function Tab:CreateColorPicker(s)
            local cc=s.Color or Color3.fromRGB(255,0,0)
            local h,sv_s,sv_v=Color3.toHSV(cc)
            local open=false

            local f=row(ROW_H); f.ClipsDescendants=false

            mk("TextLabel",{
                Size=UDim2.new(1,-55,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Color",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local SW=IS_MOBILE and 28 or 34; local SH=IS_MOBILE and 18 or 22
            local swatch=mk("Frame",{
                Size=UDim2.fromOffset(SW,SH),Position=UDim2.new(1,-(SW+10),0.5,-SH/2),
                BackgroundColor3=cc,BorderSizePixel=0,Parent=f
            })
            corner(swatch,5); stroke(swatch,C.BorderInput,1,0)

            local pW=IS_MOBILE and 260 or 310; local pHgt=IS_MOBILE and 155 or 180
            local svW=pW-42; local svH=pHgt-32

            local pp=mk("Frame",{
                Size=UDim2.fromOffset(pW,pHgt),BackgroundColor3=C.Bg,
                BackgroundTransparency=0,BorderSizePixel=0,ZIndex=60,
                Visible=false,ClipsDescendants=false,Parent=anchor
            })
            corner(pp,10); stroke(pp,C.BorderPanel,1,0)

            local svB=mk("Frame",{
                Size=UDim2.fromOffset(svW,svH),Position=UDim2.fromOffset(10,12),
                BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ZIndex=61,Parent=pp
            })
            corner(svB,6)

            local function mkg(parent,rot,cs,ts)
                local fr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=62,Parent=parent})
                local g=Instance.new("UIGradient"); g.Color=cs; g.Rotation=rot
                if ts then g.Transparency=ts end; g.Parent=fr
            end
            mkg(svB,0,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkg(svB,90,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))

            local svCur=mk("Frame",{Size=UDim2.fromOffset(12,12),Position=UDim2.new(sv_s,-6,1-sv_v,-6),BackgroundColor3=C.Text,BorderSizePixel=0,ZIndex=64,Parent=svB})
            corner(svCur,6)

            local hBar=mk("Frame",{Size=UDim2.fromOffset(16,svH),Position=UDim2.fromOffset(svW+14,12),BackgroundColor3=C.Text,BorderSizePixel=0,ZIndex=61,Parent=pp})
            corner(hBar,5)
            local hg=Instance.new("UIGradient"); hg.Rotation=90
            hg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(0,1,1))}); hg.Parent=hBar
            local hCur=mk("Frame",{Size=UDim2.new(1,5,0,4),Position=UDim2.new(-0.15,0,h,-2),BackgroundColor3=C.Text,BorderSizePixel=0,ZIndex=63,Parent=hBar})
            corner(hCur,2)

            local function updC()
                cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end
            end
            local function posCP()
                local abs=swatch.AbsolutePosition; local ancAbs=anchor.AbsolutePosition
                pp.Position=UDim2.fromOffset(math.max(0,abs.X-ancAbs.X-pW+SW+10),abs.Y-ancAbs.Y+SH+5)
            end

            local svD,hD=false,false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svD=true; dragging=false
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); updC()
                end
            end)
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hD=true; dragging=false
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); updC()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if svD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); updC()
                end
                if hD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.15,0,h,-2); updC()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svD=false; hD=false end
            end)

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function() open=not open; if open then posCP() end; pp.Visible=open end)

            function s:Set(c)
                cc=c; h,sv_s,sv_v=Color3.toHSV(c); s.Color=c
                swatch.BackgroundColor3=c; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); hCur.Position=UDim2.new(-0.15,0,h,-2)
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        return Tab
    end  -- CreateTab

    function Window:Destroy() sg:Destroy() end
    function Window.ModifyTheme(_) end

    task.delay(0.6,function()
        Xanix:Notify({Title="Xanix",Content="Loaded "..winName,Duration=3})
    end)

    return Window
end  -- CreateWindow

function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(_) end
function Xanix:IsVisible() return true end
function Xanix:Destroy() end

return Xanix
