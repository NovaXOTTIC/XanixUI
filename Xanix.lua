--[[
  Xanix UI Library — full featured
  
  local Xanix = loadstring(game:HttpGet("URL"))()
  local Win = Xanix:CreateWindow({ Name = "Hub" })
  local Tab = Win:CreateTab("Main")
  Tab:CreateButton({ Name = "Go", Callback = function() end })
  Tab:CreateButton({ Name = "Danger", Style = "danger", Callback = function() end })
  Tab:CreateToggle({ Name = "ESP", CurrentValue = false, Callback = function(v) end })
  Tab:CreateSlider({ Name = "Speed", Range={16,500}, Increment=1, CurrentValue=16, Callback=function(v) end })
  Tab:CreateColorPicker({ Name = "Color", Color=Color3.fromRGB(255,0,0), Callback=function(c) end })
  Tab:CreateDropdown({ Name = "Mode", Options={"A","B"}, CurrentOption={"A"}, Callback=function(o) end })
  Tab:CreateInput({ Name = "Player", PlaceholderText="name", Callback=function(t) end })
  Tab:CreateSection("Header")
  Tab:CreateDivider()
  Tab:CreateLabel("Info")
  Tab:CreateKeybind({ Name = "Key", CurrentKeybind="E", Callback=function() end })
  Tab:CreateProgressBar({ Name = "Loading", Value = 0.6 })
  Xanix:Notify({ Title="Hi", Content="World", Duration=3 })
]]

local Xanix = {}; Xanix.__index = Xanix; Xanix.Flags = {}
local Players  = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- colours
local K = {
    bg    = Color3.fromRGB(10, 10, 13),
    bg2   = Color3.fromRGB(15, 15, 19),
    bg3   = Color3.fromRGB(20, 20, 25),
    bg4   = Color3.fromRGB(26, 26, 32),
    bdr   = Color3.fromRGB(40, 40, 50),
    wbdr  = Color3.fromRGB(255,255,255),
    title = Color3.fromRGB(12, 12, 16),
    txt   = Color3.fromRGB(255,255,255),
    txtd  = Color3.fromRGB(185,185,192),
    txtm  = Color3.fromRGB(90, 90,102),
    tr0   = Color3.fromRGB(35, 35, 44),
    tr1   = Color3.fromRGB(225,225,230),
    fill  = Color3.fromRGB(225,225,230),
    red   = Color3.fromRGB(200, 55, 55),
    redhv = Color3.fromRGB(170, 40, 40),
    green = Color3.fromRGB(50, 190, 100),
}

-- pixel sizes
local TAB_W   = IS_MOBILE and 108 or 132
local CONT_W  = IS_MOBILE and 272 or 430
local WIN_H   = IS_MOBILE and 295 or 370
local SRCH_H  = IS_MOBILE and 27  or 29
local TITLE_H = IS_MOBILE and 35  or 38
local GAP     = 6
local ROW_H   = IS_MOBILE and 28  or 32
local FS      = IS_MOBILE and 11  or 12

local TW  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW2 = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW3 = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWBACK = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function mk(c,p) local o=Instance.new(c) for k,v in pairs(p or {}) do o[k]=v end return o end
local function crn(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 7) c.Parent=p return c end
local function stk(p,col,t,a) local s=Instance.new("UIStroke") s.Color=col or K.bdr s.Thickness=t or 1 s.Transparency=a or 0 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.LineJoinMode=Enum.LineJoinMode.Round s.Parent=p return s end
local function pdg(p,l,r,t,b) local d=Instance.new("UIPadding") d.PaddingLeft=UDim.new(0,l or 0) d.PaddingRight=UDim.new(0,r or 0) d.PaddingTop=UDim.new(0,t or 0) d.PaddingBottom=UDim.new(0,b or 0) d.Parent=p return d end
local function ll(p,sp) local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,sp or 5) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=p return l end
local function tw(o,pr,i) TweenSvc:Create(o,i or TW,pr):Play() end

-- blur effect
local _blur = nil
local function ensureBlur()
    if _blur then return _blur end
    _blur = mk("BlurEffect",{Size=0, Parent=Lighting})
    return _blur
end
local function blurIn()
    local b=ensureBlur()
    TweenSvc:Create(b, TW3, {Size=12}):Play()
end
local function blurOut()
    local b=ensureBlur()
    TweenSvc:Create(b, TW2, {Size=0}):Play()
end

-- notifs
local _ns, _nl
local function ensureN()
    if _ns and _ns.Parent then return end
    _ns=mk("ScreenGui",{Name="XNotif",ResetOnSpawn=false,IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=201,Parent=PG})
    _nl=mk("Frame",{Size=UDim2.new(0,240,1,0),Position=UDim2.new(1,-252,0,0),BackgroundTransparency=1,BorderSizePixel=0,Parent=_ns})
    mk("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,FillDirection=Enum.FillDirection.Vertical,Parent=_nl})
    pdg(_nl,5,5,8,8)
end

function Xanix:Notify(d)
    task.spawn(function()
        ensureN(); d=d or {}
        local icon = d.Type=="success" and "✓" or d.Type=="error" and "✗" or d.Type=="warning" and "!" or "•"
        local bCol = d.Type=="success" and K.green or d.Type=="error" and K.red or K.bg
        local txt = icon.."  "..(d.Title or "")..(d.Content and ("  —  "..d.Content) or "")
        local p=mk("TextLabel",{Size=UDim2.new(0,230,0,38),BackgroundColor3=bCol,BackgroundTransparency=1,Text=txt,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=K.txt,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Center,TextTransparency=1,Parent=_nl})
        crn(p,999); stk(p,K.wbdr,1,0)
        -- slide in from right
        p.Position=UDim2.new(1,10,0,0)
        task.wait(0.05)
        tw(p,{BackgroundTransparency=0.28},TW2)
        tw(p,{TextTransparency=0},TW2)
        tw(p,{Position=UDim2.new(0,0,0,0)},TWBACK)
        task.wait(d.Duration or 3)
        tw(p,{BackgroundTransparency=1},TW2); tw(p,{TextTransparency=1},TW2)
        tw(p,{Size=UDim2.new(0,230,0,0)},TW2)
        task.wait(0.25); p:Destroy()
    end)
end

function Xanix:CreateWindow(cfg)
    cfg=cfg or {}
    local name=cfg.Name or "Xanix"
    local key=cfg.ToggleUIKeybind or "K"
    if typeof(key)=="EnumItem" then key=key.Name end

    local sg=mk("ScreenGui",{Name="Xanix",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=100,ResetOnSpawn=false,IgnoreGuiInset=false,Parent=PG})

    -- background overlay (dark tint behind UI when open)
    local overlay=mk("Frame",{Name="Overlay",Parent=sg,
        Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=0})

    local totalW = TAB_W+GAP+CONT_W
    local totalH = SRCH_H+GAP+WIN_H

    -- anchor
    local anchor=mk("Frame",{Name="Anchor",Parent=sg,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromOffset(totalW,totalH),
        Position=UDim2.new(0.5,-totalW/2, 0.5,-totalH/2)})

    -- search pill
    local search=mk("TextBox",{Name="Search",Parent=anchor,BackgroundColor3=K.bg,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(TAB_W,SRCH_H),
        Font=Enum.Font.GothamMedium,Text="",PlaceholderText="Search...",
        TextColor3=K.txt,PlaceholderColor3=K.txtm,TextSize=FS,
        ClearTextOnFocus=false,MultiLine=false})
    crn(search,999); stk(search,K.wbdr,1,0); pdg(search,9,26,0,0)
    mk("ImageLabel",{Size=UDim2.fromOffset(12,12),Position=UDim2.new(1,-19,0.5,-6),BackgroundTransparency=1,Image="rbxassetid://3926305904",ImageColor3=K.txtm,Parent=search})

    -- tab panel
    local tabY=SRCH_H+GAP
    local tabPanel=mk("Frame",{Name="TabPanel",Parent=anchor,BackgroundColor3=K.bg2,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,tabY),Size=UDim2.fromOffset(TAB_W,WIN_H)})
    crn(tabPanel,10); stk(tabPanel,K.wbdr,1,0)
    local tabSF=mk("ScrollingFrame",{Parent=tabPanel,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),ScrollBarThickness=2,ScrollBarImageColor3=K.bdr,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y})
    ll(tabSF,4); pdg(tabSF,7,7,8,8)

    -- content panel
    local contPanel=mk("Frame",{Name="ContentPanel",Parent=anchor,BackgroundColor3=K.bg2,BorderSizePixel=0,
        ClipsDescendants=true,
        Position=UDim2.fromOffset(TAB_W+GAP,0),
        Size=UDim2.fromOffset(CONT_W,totalH)})
    crn(contPanel,10); stk(contPanel,K.wbdr,1,0)

    -- title bar
    local titleBar=mk("Frame",{Name="TitleBar",Parent=contPanel,BackgroundColor3=K.title,BorderSizePixel=0,
        Size=UDim2.fromOffset(CONT_W,TITLE_H)})
    crn(titleBar,10)

    -- title gradient
    local tg=Instance.new("UIGradient")
    tg.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(11,11,15)),
    }); tg.Rotation=90; tg.Parent=titleBar

    -- separator line under title
    mk("Frame",{Parent=titleBar,BackgroundColor3=K.bdr,BorderSizePixel=0,
        Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1)})

    -- title dot cluster (decorative)
    local dotColors={Color3.fromRGB(255,95,87),Color3.fromRGB(255,189,46),Color3.fromRGB(40,200,64)}
    for i,dc in ipairs(dotColors) do
        local d=mk("Frame",{Parent=titleBar,BackgroundColor3=dc,BorderSizePixel=0,
            Position=UDim2.fromOffset(10+(i-1)*14,TITLE_H/2-4),Size=UDim2.fromOffset(8,8)})
        crn(d,4)
    end

    mk("TextLabel",{Parent=titleBar,BackgroundTransparency=1,
        Position=UDim2.fromOffset(54,0),Size=UDim2.new(1,-88,1,0),
        Font=Enum.Font.GothamBold,Text=name,TextColor3=K.txt,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left})

    -- minimise button
    local minimised=false
    local minBox=mk("Frame",{Parent=titleBar,BackgroundColor3=K.bg3,BorderSizePixel=0,
        Position=UDim2.new(1,-32,0.5,-10),Size=UDim2.fromOffset(22,20)})
    crn(minBox,5); stk(minBox,K.bdr,1,0)
    local minBtn=mk("TextButton",{Parent=minBox,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Text="-",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=K.txtd,AutoButtonColor=false})
    minBtn.MouseEnter:Connect(function() tw(minBox,{BackgroundColor3=K.bg4}) end)
    minBtn.MouseLeave:Connect(function() tw(minBox,{BackgroundColor3=K.bg3}) end)
    minBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        if minimised then
            tw(contPanel,{Size=UDim2.fromOffset(CONT_W,TITLE_H)},TW2)
            tw(tabPanel,{BackgroundTransparency=0.6},TW2)
            tw(search,{BackgroundTransparency=0.6},TW2)
            minBtn.Text="+"
        else
            tw(contPanel,{Size=UDim2.fromOffset(CONT_W,totalH)},TW2)
            tw(tabPanel,{BackgroundTransparency=0},TW2)
            tw(search,{BackgroundTransparency=0},TW2)
            minBtn.Text="-"
        end
    end)

    -- pages container
    local pagesC=mk("Frame",{Name="PagesC",Parent=contPanel,BackgroundTransparency=1,
        ClipsDescendants=true,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,TITLE_H),
        Size=UDim2.fromOffset(CONT_W,totalH-TITLE_H)})

    -- ── TAB STATE ──────────────────────────────────────────────────────────────
    local tabs={}; local activeTab=nil

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local q=search.Text:lower()
        for _,t in ipairs(tabs) do
            t.btn.Visible=q=="" or (t.name:lower():find(q,1,true)~=nil)
        end
    end)

    local function switchTab(t)
        if activeTab==t then return end
        for _,v in ipairs(tabs) do
            v.page.Visible=false
            tw(v.btn,{BackgroundColor3=K.bg,TextColor3=K.txtd})
            if v.bar then tw(v.bar,{BackgroundTransparency=1}) end
        end
        t.page.Visible=true
        tw(t.btn,{BackgroundColor3=K.bg3,TextColor3=K.txt})
        if t.bar then tw(t.bar,{BackgroundTransparency=0}) end
        activeTab=t
    end

    -- ── DRAG (title bar only) ─────────────────────────────────────────────────
    local dragging=false; local ds=nil; local dp=nil
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; ds=Vector2.new(i.Position.X,i.Position.Y); dp=anchor.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=Vector2.new(i.Position.X,i.Position.Y)-ds
            anchor.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- ── OPEN / CLOSE with animation + blur ───────────────────────────────────
    local vis=true

    local function openUI()
        vis=true
        blurIn()
        tw(overlay,{BackgroundTransparency=0.72},TW2)
        anchor.Visible=true
        anchor.Position=UDim2.new(0.5,-totalW/2, 0.5,-totalH/2-20)
        anchor.GroupTransparency=1
        tw(anchor,{GroupTransparency=0},TW2)
        tw(anchor,{Position=UDim2.new(0.5,-totalW/2, 0.5,-totalH/2)},TWBACK)
    end

    local function closeUI()
        vis=false
        blurOut()
        tw(overlay,{BackgroundTransparency=1},TW2)
        tw(anchor,{GroupTransparency=1},TW2)
        tw(anchor,{Position=UDim2.new(0.5,-totalW/2, 0.5,-totalH/2+16)},TW2)
        task.delay(0.22, function() anchor.Visible=false end)
    end

    -- initial open animation
    task.delay(0.1, openUI)

    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        local ok,kc=pcall(function() return Enum.KeyCode[key] end)
        if ok and i.KeyCode==kc then
            if vis then closeUI() else openUI() end
        end
    end)

    -- overlay click to close
    overlay.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if vis then closeUI() end
        end
    end)

    -- mobile button
    if IS_MOBILE then
        local mob=mk("TextButton",{Parent=sg,BackgroundColor3=K.bg,BorderSizePixel=0,
            Position=UDim2.new(0.5,-60,0.01,0),Size=UDim2.fromOffset(120,29),
            Font=Enum.Font.GothamMedium,Text="Open "..name,TextColor3=K.txt,TextSize=11,AutoButtonColor=false,ZIndex=10})
        crn(mob,999); stk(mob,K.wbdr,1,0)
        mob.MouseButton1Click:Connect(function()
            if vis then closeUI(); mob.Text="Open "..name
            else openUI(); mob.Text="Hide "..name end
        end)
    end

    -- startup notifs
    task.delay(0.6, function() Xanix:Notify({Title="Xanix",Content="Loaded "..name,Duration=3}) end)
    task.delay(2.5, function() Xanix:Notify({Title="Tip",Content="Press "..key.." to toggle the UI",Duration=4}) end)

    local Window={}

    function Window:CreateTab(tabName)
        local btn=mk("TextButton",{Name=tabName,Parent=tabSF,
            BackgroundColor3=K.bg,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,ROW_H),AutoButtonColor=false,
            Font=Enum.Font.GothamMedium,Text=tabName,TextColor3=K.txtd,
            TextSize=FS,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,
            LayoutOrder=#tabs+1})
        crn(btn,6); stk(btn,K.bdr,1,0); pdg(btn,8,5,0,0)

        local bar=mk("Frame",{Size=UDim2.fromOffset(2,12),Position=UDim2.new(0,-1,0.5,-6),
            BackgroundColor3=K.wbdr,BackgroundTransparency=1,BorderSizePixel=0,Parent=btn})
        crn(bar,1)

        local page=mk("ScrollingFrame",{Name=tabName,Parent=pagesC,
            BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),Visible=false,
            ScrollBarThickness=2,ScrollBarImageColor3=K.bdr,
            CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ClipsDescendants=true})
        ll(page,4); pdg(page,8,8,8,8)

        local t={name=tabName,btn=btn,bar=bar,page=page}
        table.insert(tabs,t)

        btn.MouseEnter:Connect(function() if activeTab~=t then tw(btn,{BackgroundColor3=K.bg3,TextColor3=K.txt}) end end)
        btn.MouseLeave:Connect(function() if activeTab~=t then tw(btn,{BackgroundColor3=K.bg,TextColor3=K.txtd}) end end)
        btn.MouseButton1Click:Connect(function() dragging=false; switchTab(t) end)
        if #tabs==1 then switchTab(t) end

        local function row(h)
            local f=mk("Frame",{Size=UDim2.new(1,0,0,h or ROW_H),BackgroundColor3=K.bg3,BorderSizePixel=0,Parent=page})
            crn(f,6); stk(f,K.bdr,1,0)
            f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=K.bg4}) end)
            f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=K.bg3}) end)
            return f
        end

        local Tab={}

        -- SECTION
        function Tab:CreateSection(n)
            local f=mk("Frame",{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Parent=page})
            mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=(n or ""):upper(),
                TextSize=8,Font=Enum.Font.GothamBold,TextColor3=K.txtm,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            pdg(f,2,2,0,0)
            local sv={}; function sv:Set(x) f:FindFirstChildWhichIsA("TextLabel").Text=(x or ""):upper() end; return sv
        end

        -- DIVIDER
        function Tab:CreateDivider()
            local f=mk("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=K.bdr,BorderSizePixel=0,Parent=page})
            local dv={}; function dv:SetVisible(v) f.Visible=v end; return dv
        end

        -- LABEL
        function Tab:CreateLabel(txt,_,col)
            local f=row(ROW_H)
            local lbl=mk("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,
                Text=txt or "",TextSize=FS,Font=Enum.Font.GothamMedium,TextColor3=col or K.txtd,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=f})
            local lv={}; function lv:Set(s,_,c) lbl.Text=s or ""; if c then lbl.TextColor3=c end end; return lv
        end

        -- PARAGRAPH
        function Tab:CreateParagraph(s)
            local f=row(nil); f.AutomaticSize=Enum.AutomaticSize.Y
            mk("TextLabel",{Size=UDim2.new(1,-16,0,14),Position=UDim2.fromOffset(10,7),BackgroundTransparency=1,
                Text=s.Title or "",TextSize=FS,Font=Enum.Font.GothamBold,TextColor3=K.txt,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local cl=mk("TextLabel",{Size=UDim2.new(1,-16,0,0),Position=UDim2.fromOffset(10,22),BackgroundTransparency=1,
                Text=s.Content or "",TextSize=FS-1,Font=Enum.Font.Gotham,TextColor3=K.txtd,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,Parent=f})
            local pv={}; function pv:Set(n) f:FindFirstChildWhichIsA("TextLabel").Text=n.Title or ""; cl.Text=n.Content or "" end; return pv
        end

        -- PROGRESS BAR
        function Tab:CreateProgressBar(s)
            local f=row(IS_MOBILE and 40 or 44)
            mk("TextLabel",{Size=UDim2.new(0.6,0,0,15),Position=UDim2.fromOffset(10,5),BackgroundTransparency=1,
                Text=s.Name or "Progress",TextSize=FS,Font=Enum.Font.GothamMedium,TextColor3=K.txt,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local val=math.clamp(s.Value or 0, 0, 1)
            local pct=mk("TextLabel",{Size=UDim2.new(0.4,-10,0,15),Position=UDim2.new(0.6,0,0,5),BackgroundTransparency=1,
                Text=math.floor(val*100).."%",TextSize=FS-1,Font=Enum.Font.Gotham,TextColor3=K.txtd,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=f})
            pdg(pct,0,10,0,0)
            local tBg=mk("Frame",{Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,1,-12),
                BackgroundColor3=Color3.fromRGB(30,30,38),BorderSizePixel=0,Parent=f}); crn(tBg,2)
            local fill=mk("Frame",{Size=UDim2.new(val,0,1,0),BackgroundColor3=K.fill,BorderSizePixel=0,Parent=tBg}); crn(fill,2)

            -- animated fill on appear
            fill.Size=UDim2.new(0,0,1,0)
            task.wait(0.1); tw(fill,{Size=UDim2.new(val,0,1,0)},TW3)

            local bv={}
            function bv:Set(v)
                v=math.clamp(v,0,1)
                pct.Text=math.floor(v*100).."%"
                tw(fill,{Size=UDim2.new(v,0,1,0)},TW2)
            end
            return bv
        end

        -- BUTTON (supports Style = "default" | "danger" | "success")
        function Tab:CreateButton(s)
            local style=s.Style or "default"
            local bgCol = style=="danger" and K.red or style=="success" and K.green or K.bg3
            local bgHov = style=="danger" and K.redhv or style=="success" and Color3.fromRGB(35,160,78) or K.bg4
            local bdrCol = style=="danger" and Color3.fromRGB(210,65,65) or style=="success" and Color3.fromRGB(50,200,105) or K.bdr

            local f=mk("Frame",{Size=UDim2.new(1,0,0,ROW_H),BackgroundColor3=bgCol,BorderSizePixel=0,Parent=page})
            crn(f,6); stk(f,bdrCol,1,0)
            f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=bgHov}) end)
            f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=bgCol}) end)

            -- left pip
            if style=="default" then
                local pip=mk("Frame",{Size=UDim2.fromOffset(2,10),Position=UDim2.new(0,0,0.5,-5),
                    BackgroundColor3=K.wbdr,BorderSizePixel=0,Parent=f}); crn(pip,1)
            end

            local lbl=mk("TextLabel",{Size=UDim2.new(1,-36,1,0),Position=UDim2.fromOffset(style=="default" and 10 or 12,0),
                BackgroundTransparency=1,Text=s.Name or "Button",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=K.txt,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local arr=mk("TextLabel",{Size=UDim2.fromOffset(24,ROW_H),Position=UDim2.new(1,-26,0,0),
                BackgroundTransparency=1,Text="›",TextSize=14,Font=Enum.Font.GothamBold,
                TextColor3=style~="default" and K.txt or K.txtm,TextXAlignment=Enum.TextXAlignment.Center,Parent=f})

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function()
                -- ripple flash
                tw(f,{BackgroundColor3=style=="danger" and Color3.fromRGB(220,70,70) or style=="success" and Color3.fromRGB(55,210,115) or K.bg4})
                tw(arr,{TextColor3=K.txt})
                task.delay(0.18,function()
                    tw(f,{BackgroundColor3=bgCol}); tw(arr,{TextColor3=style~="default" and K.txt or K.txtm})
                end)
                if s.Callback then task.spawn(pcall,s.Callback) end
            end)
            local bv={}; function bv:Set(n) lbl.Text=n end; return bv
        end

        -- TOGGLE
        function Tab:CreateToggle(s)
            local state=s.CurrentValue==true
            local f=row(ROW_H)
            mk("TextLabel",{Size=UDim2.new(1,-54,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,
                Text=s.Name or "Toggle",TextSize=FS,Font=Enum.Font.GothamMedium,TextColor3=K.txt,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local TW_W,TH=33,17
            local track=mk("Frame",{Size=UDim2.fromOffset(TW_W,TH),Position=UDim2.new(1,-(TW_W+8),0.5,-TH/2),
                BackgroundColor3=state and K.tr1 or K.tr0,BorderSizePixel=0,Parent=f}); crn(track,9)
            local thumb=mk("Frame",{Size=UDim2.fromOffset(11,11),
                Position=state and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3),
                BackgroundColor3=state and Color3.fromRGB(18,18,22) or Color3.fromRGB(105,105,118),
                BorderSizePixel=0,Parent=track}); crn(thumb,6)
            s.CurrentValue=state
            local function setV(v)
                state=v; s.CurrentValue=v
                tw(track,{BackgroundColor3=v and K.tr1 or K.tr0})
                tw(thumb,{Position=v and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3),
                    BackgroundColor3=v and Color3.fromRGB(18,18,22) or Color3.fromRGB(105,105,118)})
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function() setV(not state) end)
            function s:Set(v) setV(v) end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        -- SLIDER
        function Tab:CreateSlider(s)
            local mn=s.Range and s.Range[1] or 0; local mx=s.Range and s.Range[2] or 100
            local inc=s.Increment or 1; local val=math.clamp(s.CurrentValue or mn,mn,mx)
            local suf=s.Suffix and (" "..s.Suffix) or ""
            local f=row(IS_MOBILE and 44 or 48)
            mk("TextLabel",{Size=UDim2.new(0.6,0,0,15),Position=UDim2.fromOffset(10,5),BackgroundTransparency=1,
                Text=s.Name or "Slider",TextSize=FS,Font=Enum.Font.GothamMedium,TextColor3=K.txt,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local function fmt(v) local r=math.floor(v/inc+0.5)*inc; return (math.floor(r)==r and tostring(math.floor(r)) or string.format("%.2f",r))..suf end
            local vl=mk("TextLabel",{Size=UDim2.new(0.4,-10,0,15),Position=UDim2.new(0.6,0,0,5),
                BackgroundTransparency=1,Text=fmt(val),TextSize=FS-1,Font=Enum.Font.Gotham,TextColor3=K.txtd,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=f}); pdg(vl,0,10,0,0)
            local tBg=mk("Frame",{Size=UDim2.new(1,-20,0,3),Position=UDim2.new(0,10,1,-11),
                BackgroundColor3=Color3.fromRGB(30,30,38),BorderSizePixel=0,Parent=f}); crn(tBg,2)
            local p0=(val-mn)/(mx-mn)
            local fill=mk("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=K.fill,BorderSizePixel=0,Parent=tBg}); crn(fill,2)
            local knob=mk("Frame",{Size=UDim2.fromOffset(11,11),Position=UDim2.new(p0,-5,0.5,-5),
                BackgroundColor3=K.wbdr,BorderSizePixel=0,ZIndex=3,Parent=tBg}); crn(knob,6)
            s.CurrentValue=val; local sliding=false
            local function upd(px)
                local a=tBg.AbsolutePosition; local sz=tBg.AbsoluteSize
                local pct=math.clamp((px-a.X)/sz.X,0,1)
                local nv=math.floor((mn+pct*(mx-mn))/inc+0.5)*inc; nv=math.clamp(nv,mn,mx)
                s.CurrentValue=nv; vl.Text=fmt(nv)
                tw(fill,{Size=UDim2.new(pct,0,1,0)}); tw(knob,{Position=UDim2.new(pct,-5,0.5,-5)})
                if s.Callback then task.spawn(pcall,s.Callback,nv) end
            end
            local ia=mk("TextButton",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0.5,-9),
                BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=4,Parent=tBg})
            ia.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    sliding=true; dragging=false; upd(i.Position.X) end
            end)
            UIS.InputChanged:Connect(function(i)
                if not sliding then return end
                if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then upd(i.Position.X) end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)
            function s:Set(v)
                v=math.clamp(v,mn,mx); local pct=(v-mn)/(mx-mn); s.CurrentValue=v; vl.Text=fmt(v)
                tw(fill,{Size=UDim2.new(pct,0,1,0)}); tw(knob,{Position=UDim2.new(pct,-5,0.5,-5)})
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        -- INPUT
        function Tab:CreateInput(s)
            local f=row(IS_MOBILE and 42 or 46)
            mk("TextLabel",{Size=UDim2.new(1,0,0,13),Position=UDim2.fromOffset(10,4),BackgroundTransparency=1,
                Text=s.Name or "Input",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=K.txtm,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local ibg=mk("Frame",{Size=UDim2.new(1,-20,0,IS_MOBILE and 19 or 21),
                Position=UDim2.fromOffset(10,IS_MOBILE and 19 or 20),
                BackgroundColor3=K.bg4,BorderSizePixel=0,Parent=f}); crn(ibg,5); stk(ibg,K.bdr,1,0)
            -- focus glow
            ibg.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    stk(ibg,K.wbdr,1,0.6)
                end
            end)
            local tb=mk("TextBox",{Size=UDim2.new(1,-10,1,0),Position=UDim2.fromOffset(5,0),
                BackgroundTransparency=1,Text=s.CurrentValue or "",
                PlaceholderText=s.PlaceholderText or "Enter text...",
                TextSize=FS,Font=Enum.Font.Gotham,TextColor3=K.txt,PlaceholderColor3=K.txtm,
                TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,MultiLine=false,BorderSizePixel=0,Parent=ibg})
            tb.Focused:Connect(function()
                tw(ibg:FindFirstChildWhichIsA("UIStroke"),{Color=K.wbdr,Transparency=0.5})
            end)
            tb.FocusLost:Connect(function()
                tw(ibg:FindFirstChildWhichIsA("UIStroke"),{Color=K.bdr,Transparency=0})
                s.CurrentValue=tb.Text
                if s.Callback then task.spawn(pcall,s.Callback,tb.Text) end
                if s.RemoveTextAfterFocusLost then tb.Text="" end
            end)
            function s:Set(v) tb.Text=v; s.CurrentValue=v end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        -- DROPDOWN
        function Tab:CreateDropdown(s)
            local opts=s.Options or {}; local multi=s.MultipleOptions==true
            if s.CurrentOption then if type(s.CurrentOption)=="string" then s.CurrentOption={s.CurrentOption} end else s.CurrentOption={} end
            if not multi then s.CurrentOption={s.CurrentOption[1]} end
            local open=false; local f=row(ROW_H); f.ClipsDescendants=false
            mk("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,
                Text=s.Name or "Dropdown",TextSize=FS,Font=Enum.Font.GothamMedium,TextColor3=K.txt,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local sbH=IS_MOBILE and 20 or 22
            local selBtn=mk("TextButton",{Size=UDim2.new(0.46,-6,0,sbH),Position=UDim2.new(0.52,2,0.5,-sbH/2),
                BackgroundColor3=K.bg4,BorderSizePixel=0,TextSize=FS-1,Font=Enum.Font.Gotham,
                TextColor3=K.txt,AutoButtonColor=false,Parent=f}); crn(selBtn,5); stk(selBtn,K.bdr,1,0)
            local function selTxt()
                if #s.CurrentOption==0 then return "None  ▾"
                elseif #s.CurrentOption==1 then return s.CurrentOption[1].."  ▾"
                else return "Various  ▾" end
            end
            selBtn.Text=selTxt()
            local optH=IS_MOBILE and 22 or 24; local ddH=math.min(#opts,6)*optH+6
            local ddF=mk("Frame",{BackgroundColor3=K.bg2,BorderSizePixel=0,ZIndex=60,Visible=false,ClipsDescendants=true,Parent=sg})
            crn(ddF,7); stk(ddF,K.wbdr,1,0)
            local ddSF=mk("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
                ScrollBarThickness=2,ScrollBarImageColor3=K.bdr,
                CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=61,Parent=ddF})
            ll(ddSF,2); pdg(ddSF,4,4,4,4)
            local function posDD()
                local a=selBtn.AbsolutePosition; local w=selBtn.AbsoluteSize.X
                ddF.Size=UDim2.fromOffset(w,ddH)
                ddF.Position=UDim2.fromOffset(a.X,a.Y+selBtn.AbsoluteSize.Y+2)
            end
            for _,opt in ipairs(opts) do
                local ob=mk("TextButton",{Size=UDim2.new(1,0,0,optH),BackgroundColor3=K.bg3,BorderSizePixel=0,
                    Text=opt,TextSize=FS-1,Font=Enum.Font.Gotham,TextColor3=K.txt,AutoButtonColor=false,ZIndex=62,Parent=ddSF})
                crn(ob,5)
                if table.find(s.CurrentOption,opt) then ob.BackgroundColor3=K.bg4 end
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=K.bg4}) end)
                ob.MouseLeave:Connect(function()
                    tw(ob,{BackgroundColor3=table.find(s.CurrentOption,opt) and K.bg4 or K.bg3})
                end)
                ob.MouseButton1Click:Connect(function()
                    if not multi then s.CurrentOption={opt}; selBtn.Text=selTxt(); open=false; ddF.Visible=false
                    else local idx=table.find(s.CurrentOption,opt)
                        if idx then table.remove(s.CurrentOption,idx); tw(ob,{BackgroundColor3=K.bg3})
                        else table.insert(s.CurrentOption,opt); tw(ob,{BackgroundColor3=K.bg4}) end
                        selBtn.Text=selTxt()
                    end
                    if s.Callback then task.spawn(pcall,s.Callback,s.CurrentOption) end
                end)
            end
            selBtn.MouseButton1Click:Connect(function() open=not open; if open then posDD() end; ddF.Visible=open end)
            function s:Set(v)
                if type(v)=="string" then v={v} end; s.CurrentOption=v; selBtn.Text=selTxt()
                if s.Callback then task.spawn(pcall,s.Callback,v) end
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        -- KEYBIND
        function Tab:CreateKeybind(s)
            local checking=false; local f=row(ROW_H)
            mk("TextLabel",{Size=UDim2.new(0.55,0,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,
                Text=s.Name or "Keybind",TextSize=FS,Font=Enum.Font.GothamMedium,TextColor3=K.txt,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local kbgH=IS_MOBILE and 20 or 22
            local kbg=mk("Frame",{Size=UDim2.new(0.4,-6,0,kbgH),Position=UDim2.new(0.57,2,0.5,-kbgH/2),
                BackgroundColor3=K.bg4,BorderSizePixel=0,Parent=f}); crn(kbg,5); stk(kbg,K.bdr,1,0)
            local ktb=mk("TextBox",{Size=UDim2.new(1,-10,1,0),Position=UDim2.fromOffset(5,0),
                BackgroundTransparency=1,Text=s.CurrentKeybind or "None",TextSize=FS-1,Font=Enum.Font.Gotham,
                TextColor3=K.txt,TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false,BorderSizePixel=0,Parent=kbg})
            ktb.Focused:Connect(function() checking=true; ktb.Text="..." end)
            ktb.FocusLost:Connect(function()
                checking=false; if ktb.Text=="..." or ktb.Text=="" then ktb.Text=s.CurrentKeybind or "None" end
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
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        -- COLOR PICKER
        function Tab:CreateColorPicker(s)
            local cc=s.Color or Color3.fromRGB(255,0,0); local h,sv_s,sv_v=Color3.toHSV(cc); local open=false
            local f=row(ROW_H); f.ClipsDescendants=false
            mk("TextLabel",{Size=UDim2.new(1,-44,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,
                Text=s.Name or "Color",TextSize=FS,Font=Enum.Font.GothamMedium,TextColor3=K.txt,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local SW,SH=28,16
            local swatch=mk("Frame",{Size=UDim2.fromOffset(SW,SH),Position=UDim2.new(1,-(SW+8),0.5,-SH/2),
                BackgroundColor3=cc,BorderSizePixel=0,Parent=f}); crn(swatch,5); stk(swatch,K.bdr,1,0)
            local pW,pHgt=258,146; local svW=pW-36; local svH=pHgt-24
            local pp=mk("Frame",{Size=UDim2.fromOffset(pW,pHgt),BackgroundColor3=K.bg2,BorderSizePixel=0,
                ZIndex=60,Visible=false,ClipsDescendants=false,Parent=sg}); crn(pp,9); stk(pp,K.wbdr,1,0)
            local svB=mk("Frame",{Size=UDim2.fromOffset(svW,svH),Position=UDim2.fromOffset(9,9),
                BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ZIndex=61,Parent=pp}); crn(svB,5)
            local function mkg(par,rot,cs,ts)
                local fr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=62,Parent=par})
                local g=Instance.new("UIGradient"); g.Color=cs; g.Rotation=rot; if ts then g.Transparency=ts end; g.Parent=fr
            end
            mkg(svB,0,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkg(svB,90,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))
            local svCur=mk("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.new(sv_s,-5,1-sv_v,-5),
                BackgroundColor3=K.wbdr,BorderSizePixel=0,ZIndex=64,Parent=svB}); crn(svCur,5)
            local hBar=mk("Frame",{Size=UDim2.fromOffset(12,svH),Position=UDim2.fromOffset(svW+11,9),
                BackgroundColor3=K.wbdr,BorderSizePixel=0,ZIndex=61,Parent=pp}); crn(hBar,4)
            local hg=Instance.new("UIGradient"); hg.Rotation=90
            hg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(0,1,1))}); hg.Parent=hBar
            local hCur=mk("Frame",{Size=UDim2.new(1,5,0,3),Position=UDim2.new(-0.2,0,h,-1),
                BackgroundColor3=K.wbdr,BorderSizePixel=0,ZIndex=63,Parent=hBar}); crn(hCur,2)
            local function updC() cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc; swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1); if s.Callback then task.spawn(pcall,s.Callback,cc) end end
            local function posPP() local a=swatch.AbsolutePosition; pp.Position=UDim2.fromOffset(math.max(0,a.X-pW+SW+8),a.Y+SH+3) end
            local svD,hD=false,false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svD=true; dragging=false; local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updC()
                end
            end)
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hD=true; dragging=false; local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.2,0,h,-1); updC()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
                if svD then local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize; sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1); sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updC() end
                if hD then local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize; h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1); hCur.Position=UDim2.new(-0.2,0,h,-1); updC() end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svD=false; hD=false end
            end)
            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function() open=not open; if open then posPP() end; pp.Visible=open end)
            function s:Set(c) cc=c; h,sv_s,sv_v=Color3.toHSV(c); s.Color=c; swatch.BackgroundColor3=c; svB.BackgroundColor3=Color3.fromHSV(h,1,1); svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); hCur.Position=UDim2.new(-0.2,0,h,-1) end
            if s.Flag then Xanix.Flags[s.Flag]=s end; return s
        end

        return Tab
    end

    function Window:Destroy() blurOut(); sg:Destroy() end
    function Window.ModifyTheme(_) end
    function Window:SetVisible(v) if v then openUI() else closeUI() end end
    return Window
end

function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(v) end
function Xanix:IsVisible() return true end
function Xanix:Destroy() end

return Xanix
