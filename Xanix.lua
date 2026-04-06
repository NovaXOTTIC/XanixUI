--[[
  ██╗  ██╗ █████╗ ███╗   ██╗██╗██╗  ██╗
  ╚██╗██╔╝██╔══██╗████╗  ██║██║╚██╗██╔╝
   ╚███╔╝ ███████║██╔██╗ ██║██║ ╚███╔╝
   ██╔██╗ ██╔══██║██║╚██╗██║██║ ██╔██╗
  ██╔╝ ██╗██║  ██║██║ ╚████║██║██╔╝ ██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
  Xanix UI Library — Rayfield-compatible API
  
  Layout:  [TabList tall rect] [Big Content Panel]
                [Settings btn]

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
    Tab:CreateLabel("Info")
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

-- ─── PURE BLACK THEME ────────────────────────────────────────────────────────
local C = {
    -- panels
    Bg          = Color3.fromRGB(0,0,0),
    BgAlpha     = 0.44,   -- same as original notif
    -- rows / elements
    Row         = Color3.fromRGB(20,20,20),
    RowAlpha    = 0.50,
    RowHover    = 0.35,
    -- borders
    Border      = Color3.fromRGB(55,55,55),
    -- tabs
    TabIdle     = Color3.fromRGB(25,25,25),
    TabIdleA    = 0.52,
    TabActA     = 0.28,
    -- text
    Text        = Color3.fromRGB(255,255,255),
    TextDim     = Color3.fromRGB(175,175,185),
    TextMuted   = Color3.fromRGB(110,110,120),
    -- accent (white pill / indicator)
    Accent      = Color3.fromRGB(255,255,255),
    AccentAlpha = 0.82,
    -- toggle
    TrackOff    = Color3.fromRGB(45,45,45),
    TrackOn     = Color3.fromRGB(220,220,220),
    -- slider fill
    Fill        = Color3.fromRGB(200,200,200),
    -- notif
    NotifBg     = Color3.fromRGB(0,0,0),
    NotifBgA    = 0.44,
}

local TW = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW2= TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ─── SIZES ───────────────────────────────────────────────────────────────────
local TAB_W      = 130   -- tab list width
local CONTENT_W  = 460   -- content panel width
local FULL_H     = 420   -- full height (tablist + content panel aligned)
local SET_H      = 36    -- settings button height
local GAP        = 6

-- derived
local TOTAL_LEFT_H = FULL_H + GAP + SET_H   -- left column total height

-- ─── UTILS ───────────────────────────────────────────────────────────────────
local function mk(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k]=v end
    return o
end
local function corner(p,r)
    return mk("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p})
end
local function uistroke(p,col,alpha,thick,mode)
    return mk("UIStroke",{
        Color=col or C.Border, Transparency=alpha or 0,
        Thickness=thick or 1,
        ApplyStrokeMode=mode or Enum.ApplyStrokeMode.Border,
        LineJoinMode=Enum.LineJoinMode.Round, Parent=p
    })
end
local function padding(p,l,r,t,b)
    return mk("UIPadding",{
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
        PaddingTop=UDim.new(0,t or 0),  PaddingBottom=UDim.new(0,b or 0),
        Parent=p
    })
end
local function listlayout(p,sp)
    return mk("UIListLayout",{Padding=UDim.new(0,sp or 4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=p})
end
local function tw(o,props,info) TweenSvc:Create(o,info or TW,props):Play() end

-- ─── PILL NOTIFICATION SYSTEM ────────────────────────────────────────────────
local _notifGui, _notifList

local function ensureNotifGui()
    if _notifGui and _notifGui.Parent then return end
    _notifGui = mk("ScreenGui",{
        Name="XanixNotifs", ResetOnSpawn=false,
        IgnoreGuiInset=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=200, Parent=PG
    })
    -- list anchored bottom-right like the template
    _notifList = mk("Frame",{
        Name="NotiList",
        Size=UDim2.new(0,238,0,793),
        Position=UDim2.new(1,-250,0,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        Parent=_notifGui
    })
    local ul = mk("UIListLayout",{
        Padding=UDim.new(0,6),
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        FillDirection=Enum.FillDirection.Vertical,
        Parent=_notifList
    })
    padding(_notifList,6,6,8,8)
end

function Xanix:Notify(data)
    task.spawn(function()
        ensureNotifGui()
        data = data or {}
        local dur = data.Duration or 4

        -- pill label (matches NotiTemplate style exactly)
        local pill = mk("TextLabel",{
            Name = data.Title or "Notif",
            Size = UDim2.new(0,225,0,50),
            BackgroundColor3 = C.NotifBg,
            BackgroundTransparency = 1,  -- start hidden
            Text = (data.Title or "") .. (data.Content and ("  ·  "..data.Content) or ""),
            TextScaled = false,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTransparency = 1,
            Visible = true,
            Parent = _notifList
        })
        -- pill rounded border (CornerRadius 1000 = full pill)
        corner(pill, 1000)
        -- outer stroke (border)
        uistroke(pill, Color3.fromRGB(0,0,0), 0, 2, Enum.ApplyStrokeMode.Border)
        -- inner contextual stroke for glow
        uistroke(pill, Color3.fromRGB(60,60,60), 0, 1, Enum.ApplyStrokeMode.Contextual)

        task.wait(0.05)
        -- fade in
        tw(pill, {BackgroundTransparency=C.NotifBgA}, TW2)
        tw(pill, {TextTransparency=0}, TW2)

        task.wait(dur)

        -- fade out
        tw(pill, {BackgroundTransparency=1}, TW2)
        tw(pill, {TextTransparency=1}, TW2)
        task.wait(0.3)
        pill:Destroy()
    end)
end

-- ─── CREATE WINDOW ───────────────────────────────────────────────────────────
function Xanix:CreateWindow(cfg)
    cfg = cfg or {}
    local winName = cfg.Name or "Xanix"
    local toggleKey = cfg.ToggleUIKeybind or "K"
    if typeof(toggleKey) == "EnumItem" then toggleKey = toggleKey.Name end

    local sg = mk("ScreenGui",{
        Name="Xanix", ResetOnSpawn=false,
        IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=100, Parent=PG
    })

    -- Invisible anchor — drag moves this, all children follow
    local anchor = mk("Frame",{
        Name="Anchor",
        Size=UDim2.fromOffset(1,1),
        Position=UDim2.new(0.5,-(TAB_W+GAP+CONTENT_W)/2, 0.5,-TOTAL_LEFT_H/2),
        BackgroundTransparency=1, BorderSizePixel=0, Parent=sg
    })

    local hidden = false

    -- ┌─ LEFT COLUMN: TAB LIST (tall rectangle) ───────────────────────────────
    local tabFrame = mk("ScrollingFrame",{
        Name="TabList",
        Size=UDim2.fromOffset(TAB_W, FULL_H),
        Position=UDim2.fromOffset(0,0),
        BackgroundColor3=C.Bg,
        BackgroundTransparency=C.BgAlpha,
        BorderSizePixel=0,
        ScrollBarThickness=2,
        ScrollBarImageColor3=Color3.fromRGB(80,80,80),
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ClipsDescendants=true,
        Parent=anchor
    })
    corner(tabFrame,10)
    uistroke(tabFrame,C.Border,0,1,Enum.ApplyStrokeMode.Border)
    listlayout(tabFrame,3)
    padding(tabFrame,7,7,8,8)

    -- ┌─ SETTINGS BUTTON (below tab list) ─────────────────────────────────────
    local setBtn = mk("TextButton",{
        Name="SettingsBtn",
        Size=UDim2.fromOffset(TAB_W, SET_H),
        Position=UDim2.fromOffset(0, FULL_H+GAP),
        BackgroundColor3=C.Bg,
        BackgroundTransparency=C.BgAlpha,
        BorderSizePixel=0,
        Text="⚙  Settings",
        TextSize=13,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.TextMuted,
        AutoButtonColor=false,
        Parent=anchor
    })
    corner(setBtn,10)
    uistroke(setBtn,C.Border,0,1,Enum.ApplyStrokeMode.Border)
    setBtn.MouseEnter:Connect(function() tw(setBtn,{TextColor3=C.Text,BackgroundTransparency=C.BgAlpha-0.1}) end)
    setBtn.MouseLeave:Connect(function() tw(setBtn,{TextColor3=C.TextMuted,BackgroundTransparency=C.BgAlpha}) end)

    -- ┌─ RIGHT: CONTENT PANEL ─────────────────────────────────────────────────
    local contentF = mk("Frame",{
        Name="ContentPanel",
        Size=UDim2.fromOffset(CONTENT_W, FULL_H),
        Position=UDim2.fromOffset(TAB_W+GAP, 0),
        BackgroundColor3=C.Bg,
        BackgroundTransparency=C.BgAlpha,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Parent=anchor
    })
    corner(contentF,10)
    uistroke(contentF,C.Border,0,1,Enum.ApplyStrokeMode.Border)

    -- Title bar
    local titleBar = mk("Frame",{
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=C.Bg,
        BackgroundTransparency=C.BgAlpha-0.1,
        BorderSizePixel=0,
        Parent=contentF
    })
    -- thin bottom border on title bar
    mk("Frame",{
        Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=C.Border, BackgroundTransparency=0,
        BorderSizePixel=0, Parent=titleBar
    })

    -- window name
    local titleLbl = mk("TextLabel",{
        Size=UDim2.new(1,-80,1,0), Position=UDim2.fromOffset(14,0),
        BackgroundTransparency=1,
        Text=winName, TextSize=14,
        Font=Enum.Font.GothamBold,
        TextColor3=C.Text,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=titleBar
    })

    -- Minimise / Restore button
    local minimised = false
    local minBtn = mk("TextButton",{
        Size=UDim2.fromOffset(28,22),
        Position=UDim2.new(1,-34,0.5,-11),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BackgroundTransparency=0.88,
        BorderSizePixel=0,
        Text="–", TextSize=14,
        Font=Enum.Font.GothamBold,
        TextColor3=C.TextDim,
        AutoButtonColor=false,
        Parent=titleBar
    })
    corner(minBtn,6)
    minBtn.MouseEnter:Connect(function() tw(minBtn,{BackgroundTransparency=0.65}) end)
    minBtn.MouseLeave:Connect(function() tw(minBtn,{BackgroundTransparency=0.88}) end)
    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            -- collapse content, keep tablist + settings visible
            tw(contentF,{Size=UDim2.fromOffset(CONTENT_W,38)},TW2)
            minBtn.Text="+"
        else
            tw(contentF,{Size=UDim2.fromOffset(CONTENT_W,FULL_H)},TW2)
            minBtn.Text="–"
        end
    end)

    -- Pages container (clips below title bar)
    local pagesC = mk("Frame",{
        Size=UDim2.new(1,0,1,-38),
        Position=UDim2.fromOffset(0,38),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        Parent=contentF
    })

    -- ─── TAB STATE ───────────────────────────────────────────────────────────
    local tabs={}; local activeTab=nil

    local function switchTab(t)
        if activeTab==t then return end
        for _,v in ipairs(tabs) do
            v.page.Visible=false
            tw(v.btn,{BackgroundColor3=C.TabIdle, BackgroundTransparency=C.TabIdleA, TextColor3=C.TextDim})
            if v.bar then tw(v.bar,{BackgroundTransparency=1}) end
        end
        t.page.Visible=true
        tw(t.btn,{BackgroundColor3=Color3.fromRGB(35,35,35), BackgroundTransparency=C.TabActA, TextColor3=C.Text})
        if t.bar then tw(t.bar,{BackgroundTransparency=0}) end
        activeTab=t
    end

    -- ─── DRAGGING ─────────────────────────────────────────────────────────────
    local dragging,dragStart,startPos=false,nil,nil
    local handles={tabFrame,contentF,setBtn,titleBar}
    for _,h in ipairs(handles) do
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
            anchor.Position=UDim2.new(
                startPos.X.Scale,startPos.X.Offset+d.X,
                startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- ─── K KEY TOGGLE ─────────────────────────────────────────────────────────
    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        local ok,kc=pcall(function() return Enum.KeyCode[toggleKey] end)
        if ok and i.KeyCode==kc then
            hidden=not hidden
            local a=hidden and 1 or 0
            local panels={tabFrame,contentF,setBtn}
            for _,obj in ipairs(panels) do
                tw(obj,{BackgroundTransparency=hidden and 1 or C.BgAlpha},TW2)
            end
            -- also hide children transparency when hiding
            for _,v in ipairs(tabs) do
                tw(v.btn,{BackgroundTransparency=hidden and 1 or (activeTab==v and C.TabActA or C.TabIdleA)},TW2)
            end
            titleBar.Visible=not hidden
            pagesC.Visible=not hidden
        end
    end)

    -- ─── WINDOW OBJECT ───────────────────────────────────────────────────────
    local Window={}

    function Window:CreateTab(name, _icon)
        -- Tab button (Rayfield-style full-width rect inside scrollframe)
        local btn=mk("TextButton",{
            Size=UDim2.new(1,0,0,32),
            BackgroundColor3=C.TabIdle,
            BackgroundTransparency=C.TabIdleA,
            BorderSizePixel=0,
            Text=name,
            TextSize=12,
            Font=Enum.Font.GothamMedium,
            TextColor3=C.TextDim,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=false,
            TextTruncate=Enum.TextTruncate.AtEnd,
            AutoButtonColor=false,
            LayoutOrder=#tabs+1,
            Parent=tabFrame
        })
        corner(btn,7)
        uistroke(btn,C.Border,0,1,Enum.ApplyStrokeMode.Border)
        padding(btn,10,8,0,0)

        -- left accent bar (white pill when active)
        local bar=mk("Frame",{
            Size=UDim2.fromOffset(3,16),
            Position=UDim2.new(0,-1,0.5,-8),
            BackgroundColor3=C.Accent,
            BackgroundTransparency=1,
            BorderSizePixel=0,
            Parent=btn
        })
        corner(bar,2)

        -- Page (scrollable)
        local page=mk("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            ScrollBarThickness=3,
            ScrollBarImageColor3=Color3.fromRGB(80,80,80),
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            BorderSizePixel=0,
            Visible=false,
            Parent=pagesC
        })
        listlayout(page,5)
        padding(page,10,10,10,10)

        local t={name=name,btn=btn,bar=bar,page=page}
        table.insert(tabs,t)

        btn.MouseEnter:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundTransparency=C.TabIdleA-0.08,TextColor3=C.Text}) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundTransparency=C.TabIdleA,TextColor3=C.TextDim}) end
        end)
        btn.MouseButton1Click:Connect(function() switchTab(t) end)
        if #tabs==1 then switchTab(t) end

        -- ── ROW BASE (Rayfield style: dark rect with stroke) ─────────────────
        local function row(h)
            local f=mk("Frame",{
                Size=UDim2.new(1,0,0,h or 38),
                BackgroundColor3=C.Row,
                BackgroundTransparency=C.RowAlpha,
                BorderSizePixel=0,
                Parent=page
            })
            corner(f,7)
            uistroke(f,C.Border,0,1,Enum.ApplyStrokeMode.Border)
            f.MouseEnter:Connect(function() tw(f,{BackgroundTransparency=C.RowHover}) end)
            f.MouseLeave:Connect(function() tw(f,{BackgroundTransparency=C.RowAlpha}) end)
            return f
        end

        local function rowLabel(f,txt,sz,col,xa,xoff,yoff)
            return mk("TextLabel",{
                Size=UDim2.new(0.55,0,1,0),
                Position=UDim2.fromOffset(xoff or 14,yoff or 0),
                BackgroundTransparency=1,
                Text=txt,TextSize=sz or 13,
                Font=Enum.Font.GothamMedium,
                TextColor3=col or C.Text,
                TextXAlignment=xa or Enum.TextXAlignment.Left,
                Parent=f
            })
        end

        local Tab={}

        -- SECTION ─────────────────────────────────────────────────────────────
        function Tab:CreateSection(sname)
            local f=mk("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Parent=page})
            mk("TextLabel",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=(sname or ""):upper(),TextSize=9,Font=Enum.Font.GothamBold,
                TextColor3=C.TextMuted,TextXAlignment=Enum.TextXAlignment.Left,
                Parent=f
            })
            padding(f,4,4,0,0)
            local sv={}
            function sv:Set(n) f:FindFirstChildWhichIsA("TextLabel").Text=(n or ""):upper() end
            return sv
        end

        -- LABEL ───────────────────────────────────────────────────────────────
        function Tab:CreateLabel(txt,_icon,col)
            local f=row(32)
            mk("TextLabel",{
                Size=UDim2.new(1,-24,1,0),Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1,Text=txt or "",TextSize=12,
                Font=Enum.Font.Gotham,TextColor3=col or C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                Parent=f
            })
            local lv={}; function lv:Set(nt,_,nc) f:FindFirstChildWhichIsA("TextLabel").Text=nt or "" end
            return lv
        end

        -- PARAGRAPH ───────────────────────────────────────────────────────────
        function Tab:CreateParagraph(s)
            local f=row(nil)
            f.AutomaticSize=Enum.AutomaticSize.Y
            mk("TextLabel",{
                Size=UDim2.new(1,-24,0,18),Position=UDim2.fromOffset(12,6),
                BackgroundTransparency=1,Text=s.Title or "",TextSize=13,
                Font=Enum.Font.GothamBold,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })
            local cl=mk("TextLabel",{
                Size=UDim2.new(1,-24,0,0),Position=UDim2.fromOffset(12,26),
                BackgroundTransparency=1,Text=s.Content or "",TextSize=12,
                Font=Enum.Font.Gotham,TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                AutomaticSize=Enum.AutomaticSize.Y,Parent=f
            })
            local pv={}; function pv:Set(ns) f:FindFirstChildWhichIsA("TextLabel").Text=ns.Title or "" cl.Text=ns.Content or "" end
            return pv
        end

        -- BUTTON (Rayfield style: full row click, right arrow indicator) ──────
        function Tab:CreateButton(s)
            local f=row(38)

            -- left white pip
            local pip=mk("Frame",{
                Size=UDim2.fromOffset(3,14),Position=UDim2.new(0,0,0.5,-7),
                BackgroundColor3=C.Accent,BackgroundTransparency=0.3,
                BorderSizePixel=0,Parent=f
            })
            corner(pip,2)

            -- name label
            local lbl=mk("TextLabel",{
                Size=UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Button",TextSize=13,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            -- right indicator (like Rayfield)
            local ind=mk("TextLabel",{
                Size=UDim2.fromOffset(40,38),Position=UDim2.new(1,-44,0,0),
                BackgroundTransparency=1,Text="›",TextSize=20,
                Font=Enum.Font.GothamBold,TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Center,Parent=f
            })

            local clk=mk("TextButton",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",AutoButtonColor=false,Parent=f
            })
            clk.MouseButton1Click:Connect(function()
                tw(f,{BackgroundTransparency=C.RowHover-0.12})
                tw(ind,{TextColor3=C.Text})
                task.delay(0.18,function()
                    tw(f,{BackgroundTransparency=C.RowAlpha})
                    tw(ind,{TextColor3=C.TextMuted})
                end)
                if s.Callback then task.spawn(pcall,s.Callback) end
            end)

            local bv={}; function bv:Set(n) lbl.Text=n end; return bv
        end

        -- TOGGLE (Rayfield style switch) ──────────────────────────────────────
        function Tab:CreateToggle(s)
            local state=s.CurrentValue==true
            local f=row(38)

            mk("TextLabel",{
                Size=UDim2.new(1,-70,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Toggle",TextSize=13,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            -- switch outer track
            local track=mk("Frame",{
                Size=UDim2.fromOffset(44,24),
                Position=UDim2.new(1,-54,0.5,-12),
                BackgroundColor3=state and C.TrackOn or C.TrackOff,
                BorderSizePixel=0,Parent=f
            })
            corner(track,12)
            uistroke(track,state and Color3.fromRGB(180,180,180) or Color3.fromRGB(55,55,55),0,1)

            local thumb=mk("Frame",{
                Size=UDim2.fromOffset(18,18),
                Position=state and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3),
                BackgroundColor3=state and Color3.fromRGB(15,15,15) or Color3.fromRGB(120,120,120),
                BorderSizePixel=0,Parent=track
            })
            corner(thumb,9)

            s.CurrentValue=state
            local function set(v)
                state=v; s.CurrentValue=v
                tw(track,{BackgroundColor3=v and C.TrackOn or C.TrackOff})
                tw(track:FindFirstChildWhichIsA("UIStroke"),{Color=v and Color3.fromRGB(180,180,180) or Color3.fromRGB(55,55,55)})
                tw(thumb,{
                    Position=v and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3),
                    BackgroundColor3=v and Color3.fromRGB(15,15,15) or Color3.fromRGB(120,120,120)
                })
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function() set(not state) end)
            function s:Set(v) set(v) end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- SLIDER (Rayfield style) ─────────────────────────────────────────────
        function Tab:CreateSlider(s)
            local mn=s.Range and s.Range[1] or 0
            local mx=s.Range and s.Range[2] or 100
            local inc=s.Increment or 1
            local val=math.clamp(s.CurrentValue or mn,mn,mx)
            local suf=s.Suffix and (" "..s.Suffix) or ""

            local f=row(58)

            -- name
            mk("TextLabel",{
                Size=UDim2.new(0.58,0,0,22),Position=UDim2.fromOffset(14,4),
                BackgroundTransparency=1,Text=s.Name or "Slider",TextSize=13,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local function fmt(v)
                local r=math.floor(v/inc+0.5)*inc
                if math.floor(r)==r then return tostring(math.floor(r))..suf
                else return string.format("%.2f",r)..suf end
            end

            -- value label
            local vl=mk("TextLabel",{
                Size=UDim2.new(0.42,-14,0,22),Position=UDim2.new(0.58,0,0,4),
                BackgroundTransparency=1,Text=fmt(val),TextSize=12,
                Font=Enum.Font.Gotham,TextColor3=C.TextDim,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=f
            })
            padding(vl,0,14,0,0)

            -- track bg
            local tBg=mk("Frame",{
                Size=UDim2.new(1,-28,0,4),
                Position=UDim2.new(0,14,1,-14),
                BackgroundColor3=Color3.fromRGB(50,50,50),
                BackgroundTransparency=0,BorderSizePixel=0,Parent=f
            })
            corner(tBg,2)

            -- fill
            local fill=mk("Frame",{
                Size=UDim2.new((val-mn)/(mx-mn),0,1,0),
                BackgroundColor3=C.Fill,BorderSizePixel=0,Parent=tBg
            })
            corner(fill,2)

            -- knob
            local knob=mk("Frame",{
                Size=UDim2.fromOffset(14,14),
                Position=UDim2.new((val-mn)/(mx-mn),-7,0.5,-7),
                BackgroundColor3=Color3.fromRGB(255,255,255),
                BorderSizePixel=0,ZIndex=2,Parent=tBg
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

            -- interact layer over track
            local interact=mk("TextButton",{
                Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0.5,-10),
                BackgroundTransparency=1,Text="",AutoButtonColor=false,
                ZIndex=3,Parent=tBg
            })
            interact.InputBegan:Connect(function(i)
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
                tw(fill,{Size=UDim2.new(pct,0,1,0)})
                tw(knob,{Position=UDim2.new(pct,-7,0.5,-7)})
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- INPUT ───────────────────────────────────────────────────────────────
        function Tab:CreateInput(s)
            local f=row(58)

            mk("TextLabel",{
                Size=UDim2.new(1,0,0,18),Position=UDim2.fromOffset(14,4),
                BackgroundTransparency=1,Text=s.Name or "Input",TextSize=10,
                Font=Enum.Font.GothamBold,TextColor3=C.TextMuted,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local ibg=mk("Frame",{
                Size=UDim2.new(1,-28,0,26),Position=UDim2.fromOffset(14,26),
                BackgroundColor3=Color3.fromRGB(10,10,10),
                BackgroundTransparency=0.2,BorderSizePixel=0,Parent=f
            })
            corner(ibg,5)
            uistroke(ibg,C.Border,0,1,Enum.ApplyStrokeMode.Border)

            local tb=mk("TextBox",{
                Size=UDim2.new(1,-16,1,0),Position=UDim2.fromOffset(8,0),
                BackgroundTransparency=1,Text=s.CurrentValue or "",
                PlaceholderText=s.PlaceholderText or "Enter text…",
                TextSize=13,Font=Enum.Font.Gotham,TextColor3=C.Text,
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

        -- DROPDOWN (ZIndex 50+ so it overlays everything properly) ────────────
        function Tab:CreateDropdown(s)
            local opts=s.Options or {}
            local multi=s.MultipleOptions==true
            if s.CurrentOption then
                if type(s.CurrentOption)=="string" then s.CurrentOption={s.CurrentOption} end
            else s.CurrentOption={} end
            if not multi then s.CurrentOption={s.CurrentOption[1]} end

            local open=false
            local f=row(38)
            f.ClipsDescendants=false   -- IMPORTANT: allows dropdown to render above

            mk("TextLabel",{
                Size=UDim2.new(0.52,0,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Dropdown",TextSize=13,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local selBtn=mk("TextButton",{
                Size=UDim2.new(0.44,-8,0,26),Position=UDim2.new(0.54,2,0.5,-13),
                BackgroundColor3=Color3.fromRGB(15,15,15),BackgroundTransparency=0.3,
                BorderSizePixel=0,TextSize=12,Font=Enum.Font.Gotham,
                TextColor3=C.Text,AutoButtonColor=false,Parent=f
            })
            corner(selBtn,5)
            uistroke(selBtn,C.Border,0,1,Enum.ApplyStrokeMode.Border)

            local function selText()
                if #s.CurrentOption==0 then return "None  ▾"
                elseif #s.CurrentOption==1 then return s.CurrentOption[1].."  ▾"
                else return "Various  ▾" end
            end
            selBtn.Text=selText()

            -- Dropdown list — ZIndex=50, parented to anchor so it floats above everything
            local ddF=mk("Frame",{
                Size=UDim2.fromOffset(selBtn.AbsoluteSize.X>0 and selBtn.AbsoluteSize.X or 160,
                    math.min(#opts,7)*28+8),
                BackgroundColor3=Color3.fromRGB(12,12,12),
                BackgroundTransparency=0.08,
                BorderSizePixel=0, ZIndex=50,
                Visible=false, ClipsDescendants=true,
                Parent=anchor   -- parent to anchor so it's always on top
            })
            corner(ddF,7)
            uistroke(ddF,C.Border,0,1,Enum.ApplyStrokeMode.Border)

            local ddSF=mk("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,BorderSizePixel=0,
                ScrollBarThickness=2,ScrollBarImageColor3=Color3.fromRGB(80,80,80),
                CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
                ZIndex=50,Parent=ddF
            })
            listlayout(ddSF,2); padding(ddSF,4,4,4,4)

            -- position the dropdown frame relative to anchor each open
            local function positionDd()
                local abs=selBtn.AbsolutePosition
                local ancAbs=anchor.AbsolutePosition
                ddF.Size=UDim2.fromOffset(selBtn.AbsoluteSize.X, math.min(#opts,7)*28+8)
                ddF.Position=UDim2.fromOffset(abs.X-ancAbs.X, abs.Y-ancAbs.Y+selBtn.AbsoluteSize.Y+3)
            end

            for _,opt in ipairs(opts) do
                local ob=mk("TextButton",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.92,
                    BorderSizePixel=0,Text=opt,TextSize=12,Font=Enum.Font.Gotham,
                    TextColor3=C.Text,AutoButtonColor=false,ZIndex=51,Parent=ddSF
                })
                corner(ob,5)
                if table.find(s.CurrentOption,opt) then ob.BackgroundTransparency=0.75 end
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0.72}) end)
                ob.MouseLeave:Connect(function()
                    tw(ob,{BackgroundTransparency=table.find(s.CurrentOption,opt) and 0.75 or 0.92})
                end)
                ob.MouseButton1Click:Connect(function()
                    if not multi then
                        s.CurrentOption={opt}; selBtn.Text=selText()
                        open=false; ddF.Visible=false
                    else
                        if table.find(s.CurrentOption,opt) then
                            table.remove(s.CurrentOption,table.find(s.CurrentOption,opt))
                            tw(ob,{BackgroundTransparency=0.92})
                        else
                            table.insert(s.CurrentOption,opt); tw(ob,{BackgroundTransparency=0.75})
                        end
                        selBtn.Text=selText()
                    end
                    if s.Callback then task.spawn(pcall,s.Callback,s.CurrentOption) end
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                open=not open
                if open then positionDd() end
                ddF.Visible=open
            end)

            function s:Set(v)
                if type(v)=="string" then v={v} end
                s.CurrentOption=v; selBtn.Text=selText()
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            function s:Refresh(newOpts)
                s.Options=newOpts
                for _,c in ipairs(ddSF:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- KEYBIND ─────────────────────────────────────────────────────────────
        function Tab:CreateKeybind(s)
            local checking=false
            local f=row(38)

            mk("TextLabel",{
                Size=UDim2.new(0.55,0,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Keybind",TextSize=13,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local kbg=mk("Frame",{
                Size=UDim2.new(0.4,-8,0,26),Position=UDim2.new(0.57,2,0.5,-13),
                BackgroundColor3=Color3.fromRGB(15,15,15),BackgroundTransparency=0.3,
                BorderSizePixel=0,Parent=f
            })
            corner(kbg,5)
            uistroke(kbg,C.Border,0,1,Enum.ApplyStrokeMode.Border)

            local ktb=mk("TextBox",{
                Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1,Text=s.CurrentKeybind or "None",
                TextSize=12,Font=Enum.Font.Gotham,TextColor3=C.Text,
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
                elseif not s.HoldToInteract and s.CurrentKeybind then
                    local ok,kc=pcall(function() return Enum.KeyCode[s.CurrentKeybind] end)
                    if ok and i.KeyCode==kc and s.Callback then task.spawn(pcall,s.Callback) end
                end
            end)

            function s:Set(v) s.CurrentKeybind=v; ktb.Text=v end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- COLOR PICKER (ZIndex 50, parented to anchor) ─────────────────────
        function Tab:CreateColorPicker(s)
            local cc=s.Color or Color3.fromRGB(255,0,0)
            local h,sv_s,sv_v=Color3.toHSV(cc)
            local open=false

            local f=row(38)
            f.ClipsDescendants=false

            mk("TextLabel",{
                Size=UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(14,0),
                BackgroundTransparency=1,Text=s.Name or "Color",TextSize=13,
                Font=Enum.Font.GothamMedium,TextColor3=C.Text,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f
            })

            local swatch=mk("Frame",{
                Size=UDim2.fromOffset(34,22),Position=UDim2.new(1,-44,0.5,-11),
                BackgroundColor3=cc,BorderSizePixel=0,Parent=f
            })
            corner(swatch,5)
            uistroke(swatch,C.Border,0,1)

            -- Picker panel — parented to anchor, ZIndex 50
            local pW=320; local pHgt=180
            local pp=mk("Frame",{
                Size=UDim2.fromOffset(pW,pHgt),
                BackgroundColor3=Color3.fromRGB(10,10,10),
                BackgroundTransparency=0.06,
                BorderSizePixel=0,ZIndex=50,
                Visible=false,ClipsDescendants=false,
                Parent=anchor
            })
            corner(pp,9)
            uistroke(pp,C.Border,0,1,Enum.ApplyStrokeMode.Border)

            local svW=pW-46; local svH=150

            local svB=mk("Frame",{
                Size=UDim2.fromOffset(svW,svH),Position=UDim2.fromOffset(10,15),
                BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ZIndex=51,Parent=pp
            })
            corner(svB,7)

            local function mkgrad(parent,rot,cseq,tseq)
                local fr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=52,Parent=parent})
                local g=Instance.new("UIGradient"); g.Color=cseq; g.Rotation=rot
                if tseq then g.Transparency=tseq end; g.Parent=fr
            end
            mkgrad(svB,0,
                ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkgrad(svB,90,
                ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))

            local svCur=mk("Frame",{
                Size=UDim2.fromOffset(12,12),Position=UDim2.new(sv_s,-6,1-sv_v,-6),
                BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=54,Parent=svB
            })
            corner(svCur,6)

            local hBar=mk("Frame",{
                Size=UDim2.fromOffset(18,svH),Position=UDim2.fromOffset(svW+16,15),
                BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=51,Parent=pp
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
                Size=UDim2.new(1,6,0,5),Position=UDim2.new(-0.15,0,h,-2),
                BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=53,Parent=hBar
            })
            corner(hCur,2)

            local function updColor()
                cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end
            end

            local function posPicker()
                local abs=swatch.AbsolutePosition
                local ancAbs=anchor.AbsolutePosition
                pp.Position=UDim2.fromOffset(abs.X-ancAbs.X-pW+34, abs.Y-ancAbs.Y+30)
            end

            local svDrag=false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svDrag=true
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
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
                    hDrag=true
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
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

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function()
                open=not open
                if open then posPicker() end
                pp.Visible=open
            end)

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
    function Window.ModifyTheme(_) end  -- stub

    -- ── Boot notification ─────────────────────────────────────────────────────
    task.delay(0.5, function()
        Xanix:Notify({ Title="✦  Xanix", Content="Loaded "..winName, Duration=3 })
    end)

    return Window
end  -- CreateWindow

-- Rayfield compat stubs
function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(_) end
function Xanix:IsVisible() return true end
function Xanix:Destroy() end

return Xanix
