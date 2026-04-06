--[[
  ██╗  ██╗ █████╗ ███╗   ██╗██╗██╗  ██╗
  Xanix UI Library  —  Rayfield-compatible API
  
  Usage:
    local Xanix = loadstring(game:HttpGet("RAW_URL"))()
    local Win = Xanix:CreateWindow({ Name = "My Hub" })
    local Tab = Win:CreateTab("Combat")
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

-- ─── DETECT MOBILE ───────────────────────────────────────────────────────────
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ─── THEME (matches template exactly) ───────────────────────────────────────
local C = {
    Panel        = Color3.fromRGB(0,    0,    0),
    PanelAlpha   = 0,            -- fully opaque like template
    TitleBg      = Color3.fromRGB(35,   35,   48),
    TabBg        = Color3.fromRGB(0,    0,    0),
    TabBtn       = Color3.fromRGB(17,   17,   17),
    RowBg        = Color3.fromRGB(0,    0,    0),
    RowBorder    = Color3.fromRGB(55,   55,   55),
    PanelBorder  = Color3.fromRGB(166,  166,  166),
    TabBorder    = Color3.fromRGB(255,  255,  255),
    Text         = Color3.fromRGB(255,  255,  255),
    TextDim      = Color3.fromRGB(180,  180,  195),
    TextMuted    = Color3.fromRGB(120,  120,  135),
    AccentBar    = Color3.fromRGB(255,  255,  255),
    TrackOff     = Color3.fromRGB(40,   40,   40),
    TrackOn      = Color3.fromRGB(210,  210,  210),
    Fill         = Color3.fromRGB(200,  200,  200),
    InputBg      = Color3.fromRGB(0,    0,    0),
    DdBg         = Color3.fromRGB(12,   12,   18),
}

-- PC vs Mobile sizes
local PC  = { TAB_W=145, CONTENT_W=480, FULL_H=440, SET_H=38, TITLE_H=42 }
local MOB = { TAB_W=115, CONTENT_W=310, FULL_H=340, SET_H=34, TITLE_H=38 }
local S   = IS_MOBILE and MOB or PC
local GAP = 6

local TW  = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW2 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function mk(cls, p)
    local o = Instance.new(cls)
    for k,v in pairs(p or {}) do o[k]=v end
    return o
end
local function corner(p,r)
    return mk("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p})
end
local function stroke(p,col,thick,alpha,mode)
    return mk("UIStroke",{
        Color=col or C.RowBorder, Thickness=thick or 1,
        Transparency=alpha or 0,
        ApplyStrokeMode=mode or Enum.ApplyStrokeMode.Border,
        LineJoinMode=Enum.LineJoinMode.Round, Parent=p
    })
end
local function pad(p,l,r,t,b)
    return mk("UIPadding",{
        PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),
        PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),
        Parent=p
    })
end
local function llist(p,sp)
    return mk("UIListLayout",{
        Padding=UDim.new(0,sp or 4),
        SortOrder=Enum.SortOrder.LayoutOrder,Parent=p
    })
end
local function tw(o,props,info)
    TweenSvc:Create(o, info or TW, props):Play()
end

-- ─── PILL NOTIFICATIONS ───────────────────────────────────────────────────────
local _nsg, _nlist

local function ensureNotif()
    if _nsg and _nsg.Parent then return end
    _nsg = mk("ScreenGui",{
        Name="XanixNotifs",ResetOnSpawn=false,
        IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=200,Parent=PG
    })
    _nlist = mk("Frame",{
        Name="NotiList",Size=UDim2.new(0,238,0,600),
        Position=UDim2.new(1,-250,1,-620),
        BackgroundTransparency=1,BorderSizePixel=0,Parent=_nsg
    })
    local ul=mk("UIListLayout",{
        Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        FillDirection=Enum.FillDirection.Vertical,Parent=_nlist
    })
    pad(_nlist,6,6,8,8)
end

function Xanix:Notify(data)
    task.spawn(function()
        ensureNotif(); data=data or {}
        local dur=data.Duration or 4

        local pill=mk("TextLabel",{
            Name=data.Title or "Notif",
            Size=UDim2.new(0,225,0,44),
            BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=1,
            Text=(data.Title and ("✦  "..data.Title) or "")
                ..(data.Content and ("  ·  "..data.Content) or ""),
            TextScaled=false,TextSize=13,
            Font=Enum.Font.GothamMedium,
            TextColor3=C.Text,TextWrapped=false,
            TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center,
            TextTransparency=1,Visible=true,
            Parent=_nlist
        })
        corner(pill,1000)
        stroke(pill,Color3.fromRGB(255,255,255),1,0,Enum.ApplyStrokeMode.Border)

        task.wait(0.05)
        tw(pill,{BackgroundTransparency=0.44},TW2)
        tw(pill,{TextTransparency=0},TW2)
        task.wait(dur)
        tw(pill,{BackgroundTransparency=1},TW2)
        tw(pill,{TextTransparency=1},TW2)
        task.wait(0.3); pill:Destroy()
    end)
end

-- ─── CREATE WINDOW ────────────────────────────────────────────────────────────
function Xanix:CreateWindow(cfg)
    cfg=cfg or {}
    local winName=cfg.Name or "Xanix"
    local toggleKey=cfg.ToggleUIKeybind or "K"
    if typeof(toggleKey)=="EnumItem" then toggleKey=toggleKey.Name end

    local sg=mk("ScreenGui",{
        Name="Xanix",ResetOnSpawn=false,
        IgnoreGuiInset=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=100,Parent=PG
    })

    -- Anchor: invisible, sized to hold everything, centered
    local totalW = S.TAB_W+GAP+S.CONTENT_W
    local totalH = S.FULL_H
    local anchor=mk("Frame",{
        Name="Anchor",
        Size=UDim2.fromOffset(totalW,totalH),
        Position=UDim2.new(0.5,-totalW/2, 0.5,-totalH/2),
        BackgroundTransparency=1,BorderSizePixel=0,
        Parent=sg
    })

    local guiVisible=true

    -- ┌─ TAB LIST (left vertical rectangle) ───────────────────────────────────
    local tabFrame=mk("ScrollingFrame",{
        Name="TabList",
        Size=UDim2.fromOffset(S.TAB_W, S.FULL_H),
        Position=UDim2.fromOffset(0,0),
        BackgroundColor3=C.TabBg,
        BackgroundTransparency=0,
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ScrollBarImageColor3=Color3.fromRGB(80,80,80),
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ClipsDescendants=true,
        Parent=anchor
    })
    corner(tabFrame,12)
    stroke(tabFrame,C.TabBorder,1,0,Enum.ApplyStrokeMode.Border)
    llist(tabFrame,4)
    pad(tabFrame,10,10,14,14)

    -- ┌─ SETTINGS BUTTON (below tab list) ─────────────────────────────────────
    local setBtn=mk("TextButton",{
        Name="SettingsBtn",
        Size=UDim2.fromOffset(S.TAB_W, S.SET_H),
        Position=UDim2.fromOffset(0, S.FULL_H+GAP),
        BackgroundColor3=C.TabBg,
        BackgroundTransparency=0,
        BorderSizePixel=0,
        Text="⚙  Settings",
        TextSize=IS_MOBILE and 11 or 13,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.TextMuted,
        AutoButtonColor=false,
        Parent=anchor
    })
    corner(setBtn,10)
    stroke(setBtn,C.TabBorder,1,0)
    setBtn.MouseEnter:Connect(function() tw(setBtn,{TextColor3=C.Text}) end)
    setBtn.MouseLeave:Connect(function() tw(setBtn,{TextColor3=C.TextMuted}) end)

    -- ┌─ CONTENT PANEL (right big rectangle) ─────────────────────────────────
    local contentF=mk("Frame",{
        Name="ContentPanel",
        Size=UDim2.fromOffset(S.CONTENT_W, S.FULL_H),
        Position=UDim2.fromOffset(S.TAB_W+GAP,0),
        BackgroundColor3=C.Panel,
        BackgroundTransparency=0,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Parent=anchor
    })
    corner(contentF,12)
    stroke(contentF,C.PanelBorder,1,0,Enum.ApplyStrokeMode.Contextual)

    -- Title bar (dark, matches template RGB 35,35,48)
    local titleBar=mk("Frame",{
        Name="TitleBar",
        Size=UDim2.new(1,0,0,S.TITLE_H),
        BackgroundColor3=C.TitleBg,
        BackgroundTransparency=0,
        BorderSizePixel=0,
        Parent=contentF
    })
    corner(titleBar,12)  -- shares top corners with contentF
    -- white underline
    mk("Frame",{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.AccentBar,BackgroundTransparency=0,
        BorderSizePixel=0,Parent=titleBar
    })

    -- Title text
    mk("TextLabel",{
        Name="Title",
        Size=UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(14,0),
        BackgroundTransparency=1,
        Text=winName,TextSize=IS_MOBILE and 14 or 17,
        Font=Enum.Font.GothamBold,
        TextColor3=C.Text,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=titleBar
    })

    -- Minimise button (matches template: "–" text, UICorner 6, border stroke)
    local minimised=false
    local minBtn=mk("TextButton",{
        Name="MinimizeBtn",
        Size=UDim2.fromOffset(28,22),
        Position=UDim2.new(1,-36,0.5,-11),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Text="–",TextSize=19,
        Font=Enum.Font.GothamBold,
        TextColor3=C.TextMuted,
        AutoButtonColor=false,
        Parent=titleBar
    })
    corner(minBtn,6)
    stroke(minBtn,Color3.fromRGB(91,91,91),1,0)

    minBtn.MouseEnter:Connect(function() tw(minBtn,{TextColor3=C.Text}) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn,{TextColor3=C.TextMuted}) end)
    minBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        if minimised then
            -- content shrinks to title bar only; tab list + settings collapse height too
            tw(contentF,{Size=UDim2.fromOffset(S.CONTENT_W,S.TITLE_H)},TW2)
            tw(tabFrame,{Size=UDim2.fromOffset(S.TAB_W,S.TITLE_H)},TW2)
            tw(setBtn,{BackgroundTransparency=1,TextTransparency=1},TW2)
            minBtn.Text="+"
        else
            tw(contentF,{Size=UDim2.fromOffset(S.CONTENT_W,S.FULL_H)},TW2)
            tw(tabFrame,{Size=UDim2.fromOffset(S.TAB_W,S.FULL_H)},TW2)
            tw(setBtn,{BackgroundTransparency=0,TextTransparency=0},TW2)
            minBtn.Text="–"
        end
    end)

    -- Search bar (pill shape, template: UICorner=100, white stroke, search icon)
    local searchHolder=mk("Frame",{
        Name="SearchHolder",
        Size=UDim2.new(1,-20,0,IS_MOBILE and 26 or 30),
        Position=UDim2.fromOffset(10,S.TITLE_H+8),
        BackgroundColor3=C.InputBg,BackgroundTransparency=0,
        BorderSizePixel=0,Parent=contentF
    })
    corner(searchHolder,100)
    stroke(searchHolder,C.TabBorder,1,0)

    local searchIcon=mk("ImageLabel",{
        Name="SearchIcon",
        Size=UDim2.fromOffset(16,16),
        Position=UDim2.new(1,-24,0.5,-8),
        BackgroundTransparency=1,
        Image="rbxassetid://3926305904",
        ImageColor3=C.TextMuted,Parent=searchHolder
    })

    local searchBox=mk("TextBox",{
        Name="SearchBox",
        Size=UDim2.new(1,-40,1,0),Position=UDim2.fromOffset(12,0),
        BackgroundTransparency=1,Text="",
        PlaceholderText="Search tabs…",
        TextSize=IS_MOBILE and 11 or 13,Font=Enum.Font.Gotham,
        TextColor3=C.Text,PlaceholderColor3=C.TextMuted,
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false,MultiLine=false,BorderSizePixel=0,
        Parent=searchHolder
    })

    -- Pages container (below search bar)
    local pagesTopOffset = S.TITLE_H + (IS_MOBILE and 42 or 48)
    local pagesC=mk("Frame",{
        Name="PagesContainer",
        Size=UDim2.new(1,-20,1,-pagesTopOffset-8),
        Position=UDim2.fromOffset(10, pagesTopOffset),
        BackgroundColor3=Color3.fromRGB(25,25,35),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        BorderSizePixel=0,Parent=contentF
    })

    -- ─── TAB STATE ────────────────────────────────────────────────────────────
    local tabs={}; local activeTab=nil

    -- live search filter
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q=searchBox.Text:lower()
        for _,t in ipairs(tabs) do
            t.btn.Visible=q=="" or (t.name:lower():find(q,1,true)~=nil)
        end
    end)

    local function switchTab(t)
        if activeTab==t then return end
        for _,v in ipairs(tabs) do
            v.page.Visible=false
            tw(v.btn,{BackgroundColor3=C.TabBtn,TextColor3=C.TextDim})
            if v.bar then tw(v.bar,{BackgroundTransparency=1}) end
        end
        t.page.Visible=true
        tw(t.btn,{BackgroundColor3=Color3.fromRGB(30,30,30),TextColor3=C.Text})
        if t.bar then tw(t.bar,{BackgroundTransparency=0}) end
        activeTab=t
    end

    -- ─── DRAG — TITLE BAR ONLY ────────────────────────────────────────────────
    -- IMPORTANT: only drag from titleBar so sliders don't interfere
    local dragging,dragStart,startPos=false,nil,nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragStart=Vector2.new(i.Position.X,i.Position.Y)
            startPos=anchor.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
          or i.UserInputType==Enum.UserInputType.Touch) then
            local d=Vector2.new(i.Position.X,i.Position.Y)-dragStart
            anchor.Position=UDim2.new(
                startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- Also make tabFrame draggable (but only track the start position carefully)
    tabFrame.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            -- only start drag if not on a tab button
            dragging=true
            dragStart=Vector2.new(i.Position.X,i.Position.Y)
            startPos=anchor.Position
        end
    end)

    -- ─── K KEY + SHOW/HIDE ────────────────────────────────────────────────────
    local function setVisible(v)
        guiVisible=v
        anchor.Visible=v
    end

    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        local ok,kc=pcall(function() return Enum.KeyCode[toggleKey] end)
        if ok and i.KeyCode==kc then setVisible(not guiVisible) end
    end)

    -- ─── MOBILE OPEN BUTTON (pill, only for mobile) ───────────────────────────
    if IS_MOBILE then
        local mobileBtn=mk("TextButton",{
            Name="MobileOpen",
            Size=UDim2.fromOffset(110,32),
            Position=UDim2.new(0.5,-55, 0, 12),
            BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=0,
            BorderSizePixel=0,
            Text="Open "..winName,
            TextSize=13,Font=Enum.Font.GothamMedium,
            TextColor3=C.Text,
            AutoButtonColor=false,
            ZIndex=150,
            Parent=sg
        })
        corner(mobileBtn,1000)
        stroke(mobileBtn,C.TabBorder,1,0)

        mobileBtn.MouseButton1Click:Connect(function()
            local v=not guiVisible; setVisible(v)
            mobileBtn.Text=v and ("Hide "..winName) or ("Open "..winName)
        end)
        -- hide mobile button when UI is visible by default since it starts visible
    end

    -- ─── WINDOW OBJECT ───────────────────────────────────────────────────────
    local Window={}

    function Window:CreateTab(name,_icon)
        -- Tab button (matches template: dark rect, white stroke, rounded)
        local btn=mk("TextButton",{
            Name=name,
            Size=UDim2.new(1,0,0,IS_MOBILE and 28 or 32),
            BackgroundColor3=C.TabBtn,
            BackgroundTransparency=0,
            BorderSizePixel=0,
            Text=name,
            TextSize=IS_MOBILE and 11 or 13,
            Font=Enum.Font.GothamMedium,
            TextColor3=C.TextDim,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=false,
            TextTruncate=Enum.TextTruncate.AtEnd,
            AutoButtonColor=false,
            LayoutOrder=#tabs+1,
            Parent=tabFrame
        })
        corner(btn,8)
        stroke(btn,C.TabBorder,1,0,Enum.ApplyStrokeMode.Border)
        pad(btn,10,8,0,0)

        -- left accent bar
        local bar=mk("Frame",{
            Size=UDim2.fromOffset(3,14),
            Position=UDim2.new(0,-1,0.5,-7),
            BackgroundColor3=C.AccentBar,
            BackgroundTransparency=1,
            BorderSizePixel=0,Parent=btn
        })
        corner(bar,2)

        -- Page (scrollable content)
        local page=mk("ScrollingFrame",{
            Name=name,
            Size=UDim2.new(1,0,1,0),
            BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=0.5,
            ScrollBarThickness=IS_MOBILE and 2 or 4,
            ScrollBarImageColor3=Color3.fromRGB(80,80,80),
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            BorderSizePixel=0,Visible=false,
            ClipsDescendants=true,
            Parent=pagesC
        })
        corner(page,8)
        llist(page,IS_MOBILE and 4 or 5)
        pad(page,8,8,10,10)

        local t={name=name,btn=btn,bar=bar,page=page}
        table.insert(tabs,t)

        btn.MouseEnter:Connect(function()
            if activeTab~=t then tw(btn,{TextColor3=C.Text}) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab~=t then tw(btn,{TextColor3=C.TextDim}) end
        end)
        btn.MouseButton1Click:Connect(function()
            dragging=false   -- prevent drag firing after tab click
            switchTab(t)
        end)
        if #tabs==1 then switchTab(t) end

        -- ── ROW BASE ──────────────────────────────────────────────────────────
        local ROW_H = IS_MOBILE and 34 or 38
        local FS    = IS_MOBILE and 11 or 13

        local function row(h)
            local f=mk("Frame",{
                Size=UDim2.new(1,0,0,h or ROW_H),
                BackgroundColor3=C.RowBg,
                BackgroundTransparency=0,
                BorderSizePixel=0,Parent=page
            })
            corner(f,7)
            stroke(f,C.RowBorder,1,0,Enum.ApplyStrokeMode.Contextual)
            f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=Color3.fromRGB(18,18,18)}) end)
            f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.RowBg}) end)
            return f
        end

        local Tab={}

        -- SECTION ─────────────────────────────────────────────────────────────
        function Tab:CreateSection(n)
            local f=mk("Frame",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Parent=page})
            mk("TextLabel",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=(n or ""):upper(),TextSize=9,Font=Enum.Font.GothamBold,
                TextColor3=C.TextMuted,TextXAlignment=Enum.TextXAlignment.Left,
                Parent=f
            })
            pad(f,2,2,0,0)
            local sv={}; function sv:Set(x) f:FindFirstChildWhichIsA("TextLabel").Text=(x or ""):upper() end
            return sv
        end

        -- LABEL ───────────────────────────────────────────────────────────────
        function Tab:CreateLabel(txt,_icon,col)
            local f=row(IS_MOBILE and 28 or 32)
            mk("TextLabel",{
                Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1,Text=txt or "",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=col or C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                Parent=f
            })
            local lv={}; function lv:Set(s,_,c) f:FindFirstChildWhichIsA("TextLabel").Text=s or "" end
            return lv
        end

        -- PARAGRAPH ───────────────────────────────────────────────────────────
        function Tab:CreateParagraph(s)
            local f=row(nil); f.AutomaticSize=Enum.AutomaticSize.Y
            mk("TextLabel",{
                Size=UDim2.new(1,-20,0,18),Position=UDim2.fromOffset(12,6),
                BackgroundTransparency=1,Text=s.Title or "",TextSize=FS,
                Font=Enum.Font.GothamBold,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })
            local cl=mk("TextLabel",{
                Size=UDim2.new(1,-20,0,0),Position=UDim2.fromOffset(12,24),
                BackgroundTransparency=1,Text=s.Content or "",TextSize=FS-1,
                Font=Enum.Font.Gotham,TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                AutomaticSize=Enum.AutomaticSize.Y,Parent=f
            })
            local pv={}; function pv:Set(n) f:FindFirstChildWhichIsA("TextLabel").Text=n.Title or "" cl.Text=n.Content or "" end
            return pv
        end

        -- BUTTON ──────────────────────────────────────────────────────────────
        function Tab:CreateButton(s)
            local f=row(ROW_H)

            -- left accent pip
            local pip=mk("Frame",{
                Size=UDim2.fromOffset(3,13),Position=UDim2.new(0,0,0.5,-6),
                BackgroundColor3=C.AccentBar,BackgroundTransparency=0,
                BorderSizePixel=0,Parent=f
            })
            corner(pip,2)

            local lbl=mk("TextLabel",{
                Size=UDim2.new(1,-50,1,0),Position=UDim2.fromOffset(13,0),
                BackgroundTransparency=1,Text=s.Name or "Button",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            -- right arrow (Rayfield style)
            local arr=mk("TextLabel",{
                Size=UDim2.fromOffset(32,ROW_H),Position=UDim2.new(1,-36,0,0),
                BackgroundTransparency=1,Text="›",TextSize=18,
                Font=Enum.Font.GothamBold,TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Center,Parent=f
            })

            local cl=mk("TextButton",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",AutoButtonColor=false,Parent=f
            })
            cl.MouseButton1Click:Connect(function()
                tw(f,{BackgroundColor3=Color3.fromRGB(22,22,22)})
                tw(arr,{TextColor3=C.Text})
                task.delay(0.18,function()
                    tw(f,{BackgroundColor3=C.RowBg})
                    tw(arr,{TextColor3=C.TextMuted})
                end)
                if s.Callback then task.spawn(pcall,s.Callback) end
            end)

            local bv={}; function bv:Set(n) lbl.Text=n end; return bv
        end

        -- TOGGLE (Rayfield-style switch) ──────────────────────────────────────
        function Tab:CreateToggle(s)
            local state=s.CurrentValue==true
            local f=row(ROW_H)

            mk("TextLabel",{
                Size=UDim2.new(1,-65,1,0),Position=UDim2.fromOffset(13,0),
                BackgroundTransparency=1,Text=s.Name or "Toggle",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local TRK_W,TRK_H=40,22
            local track=mk("Frame",{
                Size=UDim2.fromOffset(TRK_W,TRK_H),
                Position=UDim2.new(1,-(TRK_W+10),0.5,-TRK_H/2),
                BackgroundColor3=state and C.TrackOn or C.TrackOff,
                BorderSizePixel=0,Parent=f
            })
            corner(track,11)
            local tStroke=stroke(track,
                state and Color3.fromRGB(160,160,160) or Color3.fromRGB(55,55,55),1,0)

            local thumb=mk("Frame",{
                Size=UDim2.fromOffset(16,16),
                Position=state and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3),
                BackgroundColor3=state and Color3.fromRGB(15,15,15) or Color3.fromRGB(110,110,110),
                BorderSizePixel=0,Parent=track
            })
            corner(thumb,8)

            s.CurrentValue=state
            local function setToggle(v)
                state=v; s.CurrentValue=v
                tw(track,{BackgroundColor3=v and C.TrackOn or C.TrackOff})
                tw(tStroke,{Color=v and Color3.fromRGB(160,160,160) or Color3.fromRGB(55,55,55)})
                tw(thumb,{
                    Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3),
                    BackgroundColor3=v and Color3.fromRGB(15,15,15) or Color3.fromRGB(110,110,110)
                })
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function() setToggle(not state) end)

            function s:Set(v) setToggle(v) end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- SLIDER ──────────────────────────────────────────────────────────────
        function Tab:CreateSlider(s)
            local mn=s.Range and s.Range[1] or 0
            local mx=s.Range and s.Range[2] or 100
            local inc=s.Increment or 1
            local val=math.clamp(s.CurrentValue or mn,mn,mx)
            local suf=s.Suffix and (" "..s.Suffix) or ""

            local f=row(IS_MOBILE and 52 or 58)

            mk("TextLabel",{
                Size=UDim2.new(0.58,0,0,IS_MOBILE and 18 or 22),
                Position=UDim2.fromOffset(13,IS_MOBILE and 4 or 6),
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
                Position=UDim2.new(0.58,0,0,IS_MOBILE and 4 or 6),
                BackgroundTransparency=1,Text=fmt(val),TextSize=FS-1,
                Font=Enum.Font.Gotham,TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=f
            })
            pad(vl,0,13,0,0)

            local TRACK_Y=IS_MOBILE and 36 or 40
            local tBg=mk("Frame",{
                Size=UDim2.new(1,-26,0,4),
                Position=UDim2.new(0,13,1,-TRACK_Y+30),
                BackgroundColor3=Color3.fromRGB(45,45,45),
                BackgroundTransparency=0,BorderSizePixel=0,Parent=f
            })
            corner(tBg,2)

            local fill=mk("Frame",{
                Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3=C.Fill,BorderSizePixel=0,Parent=tBg
            })
            corner(fill,2)

            local knob=mk("Frame",{
                Size=UDim2.fromOffset(14,14),
                Position=UDim2.new((val-mn)/(mx-mn),-7,0.5,-7),
                BackgroundColor3=Color3.fromRGB(255,255,255),
                BorderSizePixel=0,ZIndex=3,Parent=tBg
            })
            corner(knob,7)

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

            -- Use a transparent interact layer over the track only
            -- This is the KEY fix: the interact layer is ONLY on tBg, not the whole row
            local interact=mk("TextButton",{
                Size=UDim2.new(1,0,0,22),
                Position=UDim2.new(0,0,0.5,-11),
                BackgroundTransparency=1,Text="",
                AutoButtonColor=false,ZIndex=4,Parent=tBg
            })

            interact.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then
                    sliding=true
                    dragging=false  -- CRITICAL: stop UI drag when sliding
                    upd(i.Position.X)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement
                  or i.UserInputType==Enum.UserInputType.Touch) then
                    upd(i.Position.X)
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then
                    sliding=false
                end
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
            local f=row(IS_MOBILE and 50 or 56)

            mk("TextLabel",{
                Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(13,4),
                BackgroundTransparency=1,Text=s.Name or "Input",TextSize=9,
                Font=Enum.Font.GothamBold,TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local ibg=mk("Frame",{
                Size=UDim2.new(1,-26,0,IS_MOBILE and 22 or 26),
                Position=UDim2.fromOffset(13, IS_MOBILE and 22 or 24),
                BackgroundColor3=Color3.fromRGB(10,10,10),
                BackgroundTransparency=0,BorderSizePixel=0,Parent=f
            })
            corner(ibg,5)
            stroke(ibg,C.RowBorder,1,0)

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

        -- DROPDOWN ────────────────────────────────────────────────────────────
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
                Size=UDim2.new(0.5,0,1,0),Position=UDim2.fromOffset(13,0),
                BackgroundTransparency=1,Text=s.Name or "Dropdown",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local selBtn=mk("TextButton",{
                Size=UDim2.new(0.46,-8,0,IS_MOBILE and 22 or 26),
                Position=UDim2.new(0.52,2,0.5,-(IS_MOBILE and 11 or 13)),
                BackgroundColor3=Color3.fromRGB(12,12,12),BackgroundTransparency=0,
                BorderSizePixel=0,TextSize=FS-1,Font=Enum.Font.Gotham,
                TextColor3=C.Text,AutoButtonColor=false,Parent=f
            })
            corner(selBtn,5)
            stroke(selBtn,C.RowBorder,1,0)

            local function selTxt()
                if #s.CurrentOption==0 then return "None  ▾"
                elseif #s.CurrentOption==1 then return s.CurrentOption[1].."  ▾"
                else return "Various  ▾" end
            end
            selBtn.Text=selTxt()

            -- Dropdown list — parented to anchor so it's ALWAYS on top
            local ddH=math.min(#opts,6)*(IS_MOBILE and 24 or 27)+8
            local ddF=mk("Frame",{
                Size=UDim2.fromOffset(1,ddH),
                BackgroundColor3=C.DdBg,BackgroundTransparency=0,
                BorderSizePixel=0,ZIndex=60,Visible=false,
                ClipsDescendants=true,Parent=anchor
            })
            corner(ddF,7)
            stroke(ddF,C.TabBorder,1,0)

            local ddSF=mk("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                BorderSizePixel=0,ScrollBarThickness=2,
                ScrollBarImageColor3=Color3.fromRGB(80,80,80),
                CanvasSize=UDim2.new(0,0,0,0),
                AutomaticCanvasSize=Enum.AutomaticSize.Y,
                ZIndex=61,Parent=ddF
            })
            llist(ddSF,2); pad(ddSF,4,4,4,4)

            local function posDD()
                local abs=selBtn.AbsolutePosition
                local ancAbs=anchor.AbsolutePosition
                local w=selBtn.AbsoluteSize.X
                ddF.Size=UDim2.fromOffset(w, ddH)
                ddF.Position=UDim2.fromOffset(
                    abs.X-ancAbs.X,
                    abs.Y-ancAbs.Y+selBtn.AbsoluteSize.Y+3)
            end

            for _,opt in ipairs(opts) do
                local ob=mk("TextButton",{
                    Size=UDim2.new(1,0,0,IS_MOBILE and 24 or 27),
                    BackgroundColor3=Color3.fromRGB(20,20,20),BackgroundTransparency=0,
                    BorderSizePixel=0,Text=opt,TextSize=FS-1,Font=Enum.Font.Gotham,
                    TextColor3=C.Text,AutoButtonColor=false,ZIndex=62,Parent=ddSF
                })
                corner(ob,5)
                if table.find(s.CurrentOption,opt) then
                    ob.BackgroundColor3=Color3.fromRGB(35,35,35)
                end
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(30,30,30)}) end)
                ob.MouseLeave:Connect(function()
                    tw(ob,{BackgroundColor3=table.find(s.CurrentOption,opt) and Color3.fromRGB(35,35,35) or Color3.fromRGB(20,20,20)})
                end)
                ob.MouseButton1Click:Connect(function()
                    if not multi then
                        s.CurrentOption={opt}; selBtn.Text=selTxt()
                        open=false; ddF.Visible=false
                    else
                        if table.find(s.CurrentOption,opt) then
                            table.remove(s.CurrentOption,table.find(s.CurrentOption,opt))
                            tw(ob,{BackgroundColor3=Color3.fromRGB(20,20,20)})
                        else
                            table.insert(s.CurrentOption,opt)
                            tw(ob,{BackgroundColor3=Color3.fromRGB(35,35,35)})
                        end
                        selBtn.Text=selTxt()
                    end
                    if s.Callback then task.spawn(pcall,s.Callback,s.CurrentOption) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open=not open
                if open then posDD() end
                ddF.Visible=open
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
            local checking=false
            local f=row(ROW_H)

            mk("TextLabel",{
                Size=UDim2.new(0.55,0,1,0),Position=UDim2.fromOffset(13,0),
                BackgroundTransparency=1,Text=s.Name or "Keybind",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local kbg=mk("Frame",{
                Size=UDim2.new(0.4,-8,0,IS_MOBILE and 22 or 26),
                Position=UDim2.new(0.57,2,0.5,-(IS_MOBILE and 11 or 13)),
                BackgroundColor3=Color3.fromRGB(12,12,12),BackgroundTransparency=0,
                BorderSizePixel=0,Parent=f
            })
            corner(kbg,5)
            stroke(kbg,C.RowBorder,1,0)

            local ktb=mk("TextBox",{
                Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1,Text=s.CurrentKeybind or "None",
                TextSize=FS-1,Font=Enum.Font.Gotham,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Center,
                ClearTextOnFocus=false,BorderSizePixel=0,Parent=kbg
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
            local cc=s.Color or Color3.fromRGB(255,0,0)
            local h,sv_s,sv_v=Color3.toHSV(cc)
            local open=false

            local f=row(ROW_H); f.ClipsDescendants=false

            mk("TextLabel",{
                Size=UDim2.new(1,-55,1,0),Position=UDim2.fromOffset(13,0),
                BackgroundTransparency=1,Text=s.Name or "Color",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local swatch=mk("Frame",{
                Size=UDim2.fromOffset(IS_MOBILE and 28 or 34, IS_MOBILE and 18 or 22),
                Position=UDim2.new(1,-(IS_MOBILE and 38 or 44),0.5,-(IS_MOBILE and 9 or 11)),
                BackgroundColor3=cc,BorderSizePixel=0,Parent=f
            })
            corner(swatch,5)
            stroke(swatch,C.RowBorder,1,0)

            -- Picker panel parented to anchor, always on top
            local pW=IS_MOBILE and 260 or 310
            local pHgt=IS_MOBILE and 155 or 180
            local svW=pW-40; local svH=pHgt-30
            local pp=mk("Frame",{
                Size=UDim2.fromOffset(pW,pHgt),
                BackgroundColor3=Color3.fromRGB(8,8,12),BackgroundTransparency=0,
                BorderSizePixel=0,ZIndex=60,Visible=false,
                ClipsDescendants=false,Parent=anchor
            })
            corner(pp,10)
            stroke(pp,C.TabBorder,1,0)

            local svB=mk("Frame",{
                Size=UDim2.fromOffset(svW,svH),Position=UDim2.fromOffset(10,12),
                BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,
                ZIndex=61,Parent=pp
            })
            corner(svB,6)

            local function mkg(parent,rot,cs,ts)
                local fr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=62,Parent=parent})
                local g=Instance.new("UIGradient"); g.Color=cs; g.Rotation=rot
                if ts then g.Transparency=ts end; g.Parent=fr
            end
            mkg(svB,0,
                ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkg(svB,90,
                ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))

            local svCur=mk("Frame",{
                Size=UDim2.fromOffset(12,12),Position=UDim2.new(sv_s,-6,1-sv_v,-6),
                BackgroundColor3=C.Text,BorderSizePixel=0,ZIndex=64,Parent=svB
            })
            corner(svCur,6)

            local hBar=mk("Frame",{
                Size=UDim2.fromOffset(16,svH),Position=UDim2.fromOffset(svW+14,12),
                BackgroundColor3=C.Text,BorderSizePixel=0,ZIndex=61,Parent=pp
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

            local hCur=mk("Frame",{
                Size=UDim2.new(1,5,0,4),Position=UDim2.new(-0.15,0,h,-2),
                BackgroundColor3=C.Text,BorderSizePixel=0,ZIndex=63,Parent=hBar
            })
            corner(hCur,2)

            local function updC()
                cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end
            end
            local function posCP()
                local abs=swatch.AbsolutePosition
                local ancAbs=anchor.AbsolutePosition
                pp.Position=UDim2.fromOffset(
                    math.max(0,abs.X-ancAbs.X-pW+34),
                    abs.Y-ancAbs.Y+28)
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
            UIS.InputChanged:Connect(function(i)
                if svD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1)
                    sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-6,1-sv_v,-6); updC()
                end
                if hD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
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
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hD=true; dragging=false
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    hCur.Position=UDim2.new(-0.15,0,h,-2); updC()
                end
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

    -- Startup notification
    task.delay(0.6,function()
        Xanix:Notify({Title="Xanix",Content="Loaded "..winName,Duration=3})
    end)

    return Window
end  -- CreateWindow

-- Rayfield compat stubs
function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(_) end
function Xanix:IsVisible() return true end
function Xanix:Destroy() end

return Xanix
