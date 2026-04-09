--[[
  Xanix UI Library — clean black & white
  
  local Xanix = loadstring(game:HttpGet("RAW_URL"))()
  local Win = Xanix:CreateWindow({ Name = "My Hub" })
  local Tab = Win:CreateTab("Combat")
  Tab:CreateButton({ Name = "Kill All", Callback = function() end })
  Tab:CreateToggle({ Name = "ESP", CurrentValue = false, Callback = function(v) end })
  Tab:CreateSlider({ Name = "Speed", Range={16,500}, Increment=1, CurrentValue=16, Callback=function(v) end })
  Tab:CreateColorPicker({ Name = "Color", Color=Color3.fromRGB(255,0,0), Callback=function(c) end })
  Tab:CreateDropdown({ Name = "Mode", Options={"A","B"}, CurrentOption={"A"}, Callback=function(o) end })
  Tab:CreateInput({ Name = "Player", PlaceholderText="name...", Callback=function(t) end })
  Tab:CreateSection("Section")
  Tab:CreateLabel("Info text")
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

-- ── Colours ──────────────────────────────────────────────────────────────────
local BG      = Color3.fromRGB(6,  6,  8)    -- deepest black
local BG2     = Color3.fromRGB(11, 11, 14)   -- panel bg
local BG3     = Color3.fromRGB(16, 16, 20)   -- row bg
local BG4     = Color3.fromRGB(22, 22, 26)   -- row hover / input bg
local BORDER  = Color3.fromRGB(38, 38, 44)   -- subtle inner borders
local WBORDER = Color3.fromRGB(255,255,255)  -- white outer borders
local TITLE   = Color3.fromRGB(14, 14, 18)   -- title bar
local TEXT    = Color3.fromRGB(255,255,255)
local TEXTD   = Color3.fromRGB(190,190,195)
local TEXTM   = Color3.fromRGB(100,100,108)
local TRACK0  = Color3.fromRGB(38, 38, 44)
local TRACK1  = Color3.fromRGB(215,215,220)
local FILL    = Color3.fromRGB(215,215,220)

local TW  = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TW2 = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function mk(cls, p)
    local o = Instance.new(cls)
    for k,v in pairs(p or {}) do o[k]=v end
    return o
end
local function crn(p,r)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c
end
local function stk(p,col,thick,alpha)
    local s=Instance.new("UIStroke")
    s.Color=col or BORDER; s.Thickness=thick or 1; s.Transparency=alpha or 0
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.LineJoinMode=Enum.LineJoinMode.Round; s.Parent=p; return s
end
local function pdg(p,l,r,t,b)
    local pd=Instance.new("UIPadding")
    pd.PaddingLeft=UDim.new(0,l or 0); pd.PaddingRight=UDim.new(0,r or 0)
    pd.PaddingTop=UDim.new(0,t or 0); pd.PaddingBottom=UDim.new(0,b or 0)
    pd.Parent=p; return pd
end
local function llay(p,sp)
    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,sp or 6)
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=p; return l
end
local function tw(o,props,info) TweenSvc:Create(o,info or TW,props):Play() end

-- ── Notifications ─────────────────────────────────────────────────────────────
local _nsg,_nlist
local function ensureNotif()
    if _nsg and _nsg.Parent then return end
    _nsg=mk("ScreenGui",{Name="XanixNotifs",ResetOnSpawn=false,
        IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=200,Parent=PG})
    _nlist=mk("Frame",{Size=UDim2.new(0,260,1,0),Position=UDim2.new(1,-272,0,0),
        BackgroundTransparency=1,BorderSizePixel=0,Parent=_nsg})
    mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        FillDirection=Enum.FillDirection.Vertical,Parent=_nlist})
    pdg(_nlist,6,6,10,10)
end
function Xanix:Notify(data)
    task.spawn(function()
        ensureNotif(); data=data or {}
        local txt=(data.Title and data.Title or "")..(data.Content and ("  —  "..data.Content) or "")
        local pill=mk("TextLabel",{Size=UDim2.new(0,248,0,42),
            BackgroundColor3=BG,BackgroundTransparency=1,
            Text=txt,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=TEXT,
            TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Center,
            TextTransparency=1,Parent=_nlist})
        crn(pill,1000); stk(pill,WBORDER,1,0)
        task.wait(0.05)
        tw(pill,{BackgroundTransparency=0.35},TW2)
        tw(pill,{TextTransparency=0},TW2)
        task.wait(data.Duration or 4)
        tw(pill,{BackgroundTransparency=1},TW2)
        tw(pill,{TextTransparency=1},TW2)
        task.wait(0.3); pill:Destroy()
    end)
end

-- ── CreateWindow ──────────────────────────────────────────────────────────────
function Xanix:CreateWindow(cfg)
    cfg=cfg or {}
    local winName=cfg.Name or "Xanix"
    local toggleKey=cfg.ToggleUIKeybind or "K"
    if typeof(toggleKey)=="EnumItem" then toggleKey=toggleKey.Name end

    local sg=mk("ScreenGui",{Name="Xanix",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=100,ResetOnSpawn=false,IgnoreGuiInset=false,Parent=PG})

    -- Sizes
    local ANC_X, ANC_Y = 0.28, 0.12         -- anchor position (scaled)
    local ANC_W, ANC_H = 0.44, 0.74         -- anchor size (scaled)
    local TAB_W = 0.20                        -- tab list width (of anchor)
    local GAP   = 0.01                        -- gap between tab list & content
    local SRCH_H= 0.055                       -- search height (of anchor)

    local Anchor=mk("Frame",{Name="Anchor",Parent=sg,
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(ANC_X,0,ANC_Y,0),
        Size=UDim2.new(ANC_W,0,ANC_H,0)})

    -- ── Search pill (inside Anchor, top-left above tab list) ─────────────────
    local Search=mk("TextBox",{Name="Search",Parent=Anchor,
        BackgroundColor3=BG,BorderSizePixel=0,
        Position=UDim2.new(0,0,0,0),
        Size=UDim2.new(TAB_W,0,SRCH_H,0),
        Font=Enum.Font.GothamMedium,Text="",PlaceholderText="Search...",
        TextColor3=TEXT,PlaceholderColor3=TEXTM,TextSize=12,
        ClearTextOnFocus=false,MultiLine=false})
    crn(Search,100); stk(Search,WBORDER,1,0); pdg(Search,10,28,0,0)
    mk("ImageLabel",{Size=UDim2.new(0,13,0,13),Position=UDim2.new(1,-20,0.5,-6),
        BackgroundTransparency=1,Image="rbxassetid://3926305904",
        ImageColor3=TEXTM,Parent=Search})

    -- ── Tab list panel ────────────────────────────────────────────────────────
    local tabListY = SRCH_H+0.008
    local TabPanel=mk("Frame",{Name="TabPanel",Parent=Anchor,
        BackgroundColor3=BG2,BorderSizePixel=0,
        Position=UDim2.new(0,0,tabListY,0),
        Size=UDim2.new(TAB_W,0,1-tabListY,0)})
    crn(TabPanel,10); stk(TabPanel,WBORDER,1,0)

    local TabSF=mk("ScrollingFrame",{Name="TabSF",Parent=TabPanel,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),
        ScrollBarThickness=2,ScrollBarImageColor3=BORDER,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y})
    llay(TabSF,5); pdg(TabSF,8,8,10,10)

    -- ── Content panel ─────────────────────────────────────────────────────────
    local ContentPanel=mk("Frame",{Name="ContentPanel",Parent=Anchor,
        BackgroundColor3=BG2,BorderSizePixel=0,
        ClipsDescendants=true,
        Position=UDim2.new(TAB_W+GAP,0,0,0),
        Size=UDim2.new(1-TAB_W-GAP,0,1,0)})
    crn(ContentPanel,10); stk(ContentPanel,WBORDER,1,0)

    -- Title bar
    local TITLE_H=0.10
    local TitleBar=mk("Frame",{Name="TitleBar",Parent=ContentPanel,
        BackgroundColor3=TITLE,BorderSizePixel=0,
        Size=UDim2.new(1,0,TITLE_H,0)})
    crn(TitleBar,10)
    -- thin separator line
    mk("Frame",{Parent=TitleBar,BackgroundColor3=BORDER,BorderSizePixel=0,
        Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1)})

    -- Title text
    mk("TextLabel",{Name="WinTitle",Parent=TitleBar,
        BackgroundTransparency=1,
        Position=UDim2.new(0,14,0,0),Size=UDim2.new(1,-50,1,0),
        Font=Enum.Font.GothamBold,Text=winName,TextColor3=TEXT,
        TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})

    -- Minimise button (small square, top-right)
    local minimised=false
    local MinBox=mk("Frame",{Parent=TitleBar,BackgroundColor3=BG3,
        BorderSizePixel=0,Position=UDim2.new(1,-36,0.5,-11),
        Size=UDim2.new(0,26,0,22)})
    crn(MinBox,6); stk(MinBox,BORDER,1,0)
    local MinBtn=mk("TextButton",{Parent=MinBox,BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),Text="-",TextSize=16,
        Font=Enum.Font.GothamBold,TextColor3=TEXTD,AutoButtonColor=false})

    MinBtn.MouseEnter:Connect(function() tw(MinBox,{BackgroundColor3=BG4}) end)
    MinBtn.MouseLeave:Connect(function() tw(MinBox,{BackgroundColor3=BG3}) end)
    MinBtn.MouseButton1Click:Connect(function()
        minimised=not minimised
        if minimised then
            tw(ContentPanel,{Size=UDim2.new(1-TAB_W-GAP,0,TITLE_H,0)},TW2)
            tw(TabPanel,{BackgroundTransparency=0.5},TW2)
            tw(Search,{BackgroundTransparency=0.6},TW2)
            MinBtn.Text="+"
        else
            tw(ContentPanel,{Size=UDim2.new(1-TAB_W-GAP,0,1,0)},TW2)
            tw(TabPanel,{BackgroundTransparency=0},TW2)
            tw(Search,{BackgroundTransparency=0},TW2)
            MinBtn.Text="-"
        end
    end)

    -- Pages container
    local PagesC=mk("Frame",{Name="PagesC",Parent=ContentPanel,
        BackgroundTransparency=1,ClipsDescendants=true,BorderSizePixel=0,
        Position=UDim2.new(0,0,TITLE_H,0),
        Size=UDim2.new(1,0,1-TITLE_H,0)})

    -- ── Tab state ─────────────────────────────────────────────────────────────
    local tabs={}
    local activeTab=nil

    Search:GetPropertyChangedSignal("Text"):Connect(function()
        local q=Search.Text:lower()
        for _,t in ipairs(tabs) do
            t.btn.Visible=q=="" or (t.name:lower():find(q,1,true)~=nil)
        end
    end)

    local function switchTab(t)
        if activeTab==t then return end
        for _,v in ipairs(tabs) do
            v.page.Visible=false
            tw(v.btn,{BackgroundColor3=BG,TextColor3=TEXTD})
            if v.bar then tw(v.bar,{BackgroundTransparency=1}) end
        end
        t.page.Visible=true
        tw(t.btn,{BackgroundColor3=BG3,TextColor3=TEXT})
        if t.bar then tw(t.bar,{BackgroundTransparency=0}) end
        activeTab=t
    end

    -- ── Drag (title bar only) ─────────────────────────────────────────────────
    local dragging=false; local dragStart=nil; local startPos=nil
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragStart=Vector2.new(i.Position.X,i.Position.Y)
            startPos=Anchor.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then
            local d=Vector2.new(i.Position.X,i.Position.Y)-dragStart
            Anchor.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                       startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- ── K toggle ──────────────────────────────────────────────────────────────
    local guiVis=true
    UIS.InputBegan:Connect(function(i,p)
        if p then return end
        local ok,kc=pcall(function() return Enum.KeyCode[toggleKey] end)
        if ok and i.KeyCode==kc then
            guiVis=not guiVis; Anchor.Visible=guiVis
        end
    end)

    -- ── Mobile button ─────────────────────────────────────────────────────────
    if IS_MOBILE then
        local mob=mk("TextButton",{Name="MobileBtn",Parent=sg,
            BackgroundColor3=BG,BorderSizePixel=0,
            Position=UDim2.new(0.5,-70,0.01,0),Size=UDim2.new(0,140,0,32),
            Font=Enum.Font.GothamMedium,Text="Open "..winName,
            TextColor3=TEXT,TextSize=12,AutoButtonColor=false})
        crn(mob,1000); stk(mob,WBORDER,1,0)
        mob.MouseButton1Click:Connect(function()
            guiVis=not guiVis; Anchor.Visible=guiVis
            mob.Text=guiVis and ("Hide "..winName) or ("Open "..winName)
        end)
    end

    -- ── Startup notifs ────────────────────────────────────────────────────────
    task.delay(0.6,function()
        Xanix:Notify({Title="Xanix",Content="Loaded "..winName,Duration=3})
    end)
    task.delay(2.4,function()
        Xanix:Notify({Title="Tip",Content="Press "..toggleKey.." to open and close the UI",Duration=4})
    end)

    -- ── Window object ─────────────────────────────────────────────────────────
    local Window={}

    function Window:CreateTab(name)
        local FS    = IS_MOBILE and 11 or 12
        local ROW_H = IS_MOBILE and 30 or 34

        -- Tab button
        local btn=mk("TextButton",{Name=name,Parent=TabSF,
            BackgroundColor3=BG,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,IS_MOBILE and 28 or 32),
            AutoButtonColor=false,Font=Enum.Font.GothamMedium,Text=name,
            TextColor3=TEXTD,TextSize=IS_MOBILE and 12 or 13,
            TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,
            LayoutOrder=#tabs+1})
        crn(btn,7); stk(btn,BORDER,1,0)
        pdg(btn,10,6,0,0)

        -- left active indicator
        local bar=mk("Frame",{Size=UDim2.fromOffset(2,14),
            Position=UDim2.new(0,-1,0.5,-7),
            BackgroundColor3=WBORDER,BackgroundTransparency=1,
            BorderSizePixel=0,Parent=btn})
        crn(bar,1)

        -- Page
        local page=mk("ScrollingFrame",{Name=name,Parent=PagesC,
            BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),Visible=false,
            ScrollBarThickness=2,ScrollBarImageColor3=BORDER,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ClipsDescendants=true})
        llay(page,5); pdg(page,10,10,10,10)

        local t={name=name,btn=btn,bar=bar,page=page}
        table.insert(tabs,t)

        btn.MouseEnter:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundColor3=BG3,TextColor3=TEXT}) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab~=t then tw(btn,{BackgroundColor3=BG,TextColor3=TEXTD}) end
        end)
        btn.MouseButton1Click:Connect(function() dragging=false; switchTab(t) end)
        if #tabs==1 then switchTab(t) end

        -- ── Row helper ────────────────────────────────────────────────────────
        local function row(h)
            local f=mk("Frame",{Size=UDim2.new(1,0,0,h or ROW_H),
                BackgroundColor3=BG3,BackgroundTransparency=0,
                BorderSizePixel=0,Parent=page})
            crn(f,7); stk(f,BORDER,1,0)
            f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=BG4}) end)
            f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=BG3}) end)
            return f
        end

        local Tab={}

        -- SECTION
        function Tab:CreateSection(n)
            local f=mk("Frame",{Size=UDim2.new(1,0,0,14),
                BackgroundTransparency=1,Parent=page})
            mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=(n or ""):upper(),TextSize=8,Font=Enum.Font.GothamBold,
                TextColor3=TEXTM,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            pdg(f,2,2,0,0)
            local sv={}; function sv:Set(x) f:FindFirstChildWhichIsA("TextLabel").Text=(x or ""):upper() end
            return sv
        end

        -- LABEL
        function Tab:CreateLabel(txt,_,col)
            local f=row(IS_MOBILE and 30 or 34)
            mk("TextLabel",{Size=UDim2.new(1,-18,1,0),Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1,Text=txt or "",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=col or TEXTD,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=f})
            local lv={}; function lv:Set(s) f:FindFirstChildWhichIsA("TextLabel").Text=s or "" end
            return lv
        end

        -- PARAGRAPH
        function Tab:CreateParagraph(s)
            local f=row(nil); f.AutomaticSize=Enum.AutomaticSize.Y
            mk("TextLabel",{Size=UDim2.new(1,-18,0,16),Position=UDim2.fromOffset(12,8),
                BackgroundTransparency=1,Text=s.Title or "",TextSize=FS,
                Font=Enum.Font.GothamBold,TextColor3=TEXT,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local cl=mk("TextLabel",{Size=UDim2.new(1,-18,0,0),Position=UDim2.fromOffset(12,24),
                BackgroundTransparency=1,Text=s.Content or "",TextSize=FS-1,
                Font=Enum.Font.Gotham,TextColor3=TEXTD,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                AutomaticSize=Enum.AutomaticSize.Y,Parent=f})
            local pv={}; function pv:Set(n)
                f:FindFirstChildWhichIsA("TextLabel").Text=n.Title or ""; cl.Text=n.Content or ""
            end
            return pv
        end

        -- BUTTON
        function Tab:CreateButton(s)
            local f=row(ROW_H)

            local pip=mk("Frame",{Size=UDim2.fromOffset(2,12),
                Position=UDim2.new(0,0,0.5,-6),
                BackgroundColor3=WBORDER,BorderSizePixel=0,Parent=f})
            crn(pip,1)

            local lbl=mk("TextLabel",{Size=UDim2.new(1,-44,1,0),
                Position=UDim2.fromOffset(12,0),BackgroundTransparency=1,
                Text=s.Name or "Button",TextSize=FS,Font=Enum.Font.GothamMedium,
                TextColor3=TEXT,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})

            local arr=mk("TextLabel",{Size=UDim2.fromOffset(26,ROW_H),
                Position=UDim2.new(1,-30,0,0),BackgroundTransparency=1,
                Text="›",TextSize=16,Font=Enum.Font.GothamBold,
                TextColor3=TEXTM,TextXAlignment=Enum.TextXAlignment.Center,Parent=f})

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function()
                tw(f,{BackgroundColor3=Color3.fromRGB(24,24,28)})
                tw(arr,{TextColor3=TEXT})
                task.delay(0.18,function()
                    tw(f,{BackgroundColor3=BG3}); tw(arr,{TextColor3=TEXTM})
                end)
                if s.Callback then task.spawn(pcall,s.Callback) end
            end)
            local bv={}; function bv:Set(n) lbl.Text=n end; return bv
        end

        -- TOGGLE
        function Tab:CreateToggle(s)
            local state=s.CurrentValue==true
            local f=row(ROW_H)

            mk("TextLabel",{Size=UDim2.new(1,-60,1,0),Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1,Text=s.Name or "Toggle",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=TEXT,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})

            local TW=36; local TH=20
            local track=mk("Frame",{Size=UDim2.fromOffset(TW,TH),
                Position=UDim2.new(1,-(TW+10),0.5,-TH/2),
                BackgroundColor3=state and TRACK1 or TRACK0,
                BorderSizePixel=0,Parent=f})
            crn(track,10); stk(track,BORDER,1,0)

            local thumb=mk("Frame",{Size=UDim2.fromOffset(14,14),
                Position=state and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3),
                BackgroundColor3=state and Color3.fromRGB(20,20,24) or Color3.fromRGB(130,130,138),
                BorderSizePixel=0,Parent=track})
            crn(thumb,7)

            s.CurrentValue=state
            local function setV(v)
                state=v; s.CurrentValue=v
                tw(track,{BackgroundColor3=v and TRACK1 or TRACK0})
                tw(thumb,{
                    Position=v and UDim2.fromOffset(19,3) or UDim2.fromOffset(3,3),
                    BackgroundColor3=v and Color3.fromRGB(20,20,24) or Color3.fromRGB(130,130,138)
                })
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
            local f=row(IS_MOBILE and 48 or 52)

            mk("TextLabel",{Size=UDim2.new(0.58,0,0,IS_MOBILE and 17 or 19),
                Position=UDim2.fromOffset(12,IS_MOBILE and 5 or 6),
                BackgroundTransparency=1,Text=s.Name or "Slider",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=TEXT,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})

            local function fmt(v)
                local r=math.floor(v/inc+0.5)*inc
                return (math.floor(r)==r and tostring(math.floor(r)) or string.format("%.2f",r))..suf
            end

            local vl=mk("TextLabel",{Size=UDim2.new(0.42,-12,0,IS_MOBILE and 17 or 19),
                Position=UDim2.new(0.58,0,0,IS_MOBILE and 5 or 6),
                BackgroundTransparency=1,Text=fmt(val),TextSize=FS-1,
                Font=Enum.Font.Gotham,TextColor3=TEXTD,
                TextXAlignment=Enum.TextXAlignment.Right,Parent=f})
            pdg(vl,0,12,0,0)

            local tBg=mk("Frame",{Size=UDim2.new(1,-24,0,3),
                Position=UDim2.new(0,12,1,IS_MOBILE and -13 or -14),
                BackgroundColor3=Color3.fromRGB(32,32,38),BorderSizePixel=0,Parent=f})
            crn(tBg,2)

            local pct0=(val-mn)/(mx-mn)
            local fill=mk("Frame",{Size=UDim2.new(pct0,0,1,0),
                BackgroundColor3=FILL,BorderSizePixel=0,Parent=tBg})
            crn(fill,2)

            local knob=mk("Frame",{Size=UDim2.fromOffset(12,12),
                Position=UDim2.new(pct0,-6,0.5,-6),
                BackgroundColor3=WBORDER,BorderSizePixel=0,ZIndex=3,Parent=tBg})
            crn(knob,6)

            s.CurrentValue=val
            local sliding=false

            local function upd(px)
                local abs=tBg.AbsolutePosition; local sz=tBg.AbsoluteSize
                local pct=math.clamp((px-abs.X)/sz.X,0,1)
                local nv=math.floor((mn+pct*(mx-mn))/inc+0.5)*inc
                nv=math.clamp(nv,mn,mx); s.CurrentValue=nv; vl.Text=fmt(nv)
                tw(fill,{Size=UDim2.new(pct,0,1,0)})
                tw(knob,{Position=UDim2.new(pct,-6,0.5,-6)})
                if s.Callback then task.spawn(pcall,s.Callback,nv) end
            end

            local interact=mk("TextButton",{Size=UDim2.new(1,0,0,20),
                Position=UDim2.new(0,0,0.5,-10),
                BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=4,Parent=tBg})
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
                tw(knob,{Position=UDim2.new(pct,-6,0.5,-6)})
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        -- INPUT
        function Tab:CreateInput(s)
            local f=row(IS_MOBILE and 46 or 50)
            mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.fromOffset(12,5),
                BackgroundTransparency=1,Text=s.Name or "Input",TextSize=8,
                Font=Enum.Font.GothamBold,TextColor3=TEXTM,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local ibg=mk("Frame",{Size=UDim2.new(1,-24,0,IS_MOBILE and 20 or 22),
                Position=UDim2.fromOffset(12,IS_MOBILE and 20 or 22),
                BackgroundColor3=BG4,BorderSizePixel=0,Parent=f})
            crn(ibg,5); stk(ibg,BORDER,1,0)
            local tb=mk("TextBox",{Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1,Text=s.CurrentValue or "",
                PlaceholderText=s.PlaceholderText or "Enter text...",
                TextSize=FS,Font=Enum.Font.Gotham,TextColor3=TEXT,
                PlaceholderColor3=TEXTM,TextXAlignment=Enum.TextXAlignment.Left,
                ClearTextOnFocus=false,MultiLine=false,BorderSizePixel=0,Parent=ibg})
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

            mk("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1,Text=s.Name or "Dropdown",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=TEXT,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})

            local sbH=IS_MOBILE and 22 or 24
            local selBtn=mk("TextButton",{Size=UDim2.new(0.46,-8,0,sbH),
                Position=UDim2.new(0.52,2,0.5,-sbH/2),
                BackgroundColor3=BG4,BorderSizePixel=0,TextSize=FS-1,
                Font=Enum.Font.Gotham,TextColor3=TEXT,AutoButtonColor=false,Parent=f})
            crn(selBtn,5); stk(selBtn,BORDER,1,0)

            local function selTxt()
                if #s.CurrentOption==0 then return "None  ▾"
                elseif #s.CurrentOption==1 then return s.CurrentOption[1].."  ▾"
                else return "Various  ▾" end
            end
            selBtn.Text=selTxt()

            local optH=IS_MOBILE and 24 or 26
            local ddH=math.min(#opts,6)*optH+8
            local ddF=mk("Frame",{BackgroundColor3=BG2,BorderSizePixel=0,
                ZIndex=60,Visible=false,ClipsDescendants=true,Parent=sg})
            crn(ddF,8); stk(ddF,WBORDER,1,0)

            local ddSF=mk("ScrollingFrame",{Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,
                ScrollBarImageColor3=BORDER,CanvasSize=UDim2.new(0,0,0,0),
                AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=61,Parent=ddF})
            llay(ddSF,2); pdg(ddSF,4,4,4,4)

            local function posDD()
                local abs=selBtn.AbsolutePosition
                local w=selBtn.AbsoluteSize.X
                ddF.Size=UDim2.fromOffset(w,ddH)
                ddF.Position=UDim2.fromOffset(abs.X,abs.Y+selBtn.AbsoluteSize.Y+2)
            end

            for _,opt in ipairs(opts) do
                local ob=mk("TextButton",{Size=UDim2.new(1,0,0,optH),
                    BackgroundColor3=BG3,BorderSizePixel=0,
                    Text=opt,TextSize=FS-1,Font=Enum.Font.Gotham,
                    TextColor3=TEXT,AutoButtonColor=false,ZIndex=62,Parent=ddSF})
                crn(ob,5)
                if table.find(s.CurrentOption,opt) then ob.BackgroundColor3=BG4 end
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=BG4}) end)
                ob.MouseLeave:Connect(function()
                    tw(ob,{BackgroundColor3=table.find(s.CurrentOption,opt) and BG4 or BG3})
                end)
                ob.MouseButton1Click:Connect(function()
                    if not multi then
                        s.CurrentOption={opt}; selBtn.Text=selTxt()
                        open=false; ddF.Visible=false
                    else
                        local idx=table.find(s.CurrentOption,opt)
                        if idx then table.remove(s.CurrentOption,idx); tw(ob,{BackgroundColor3=BG3})
                        else table.insert(s.CurrentOption,opt); tw(ob,{BackgroundColor3=BG4}) end
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
            mk("TextLabel",{Size=UDim2.new(0.55,0,1,0),Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1,Text=s.Name or "Keybind",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=TEXT,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
            local kbgH=IS_MOBILE and 22 or 24
            local kbg=mk("Frame",{Size=UDim2.new(0.4,-8,0,kbgH),
                Position=UDim2.new(0.57,2,0.5,-kbgH/2),
                BackgroundColor3=BG4,BorderSizePixel=0,Parent=f})
            crn(kbg,5); stk(kbg,BORDER,1,0)
            local ktb=mk("TextBox",{Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1,Text=s.CurrentKeybind or "None",
                TextSize=FS-1,Font=Enum.Font.Gotham,TextColor3=TEXT,
                TextXAlignment=Enum.TextXAlignment.Center,
                ClearTextOnFocus=false,BorderSizePixel=0,Parent=kbg})
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

            mk("TextLabel",{Size=UDim2.new(1,-50,1,0),Position=UDim2.fromOffset(12,0),
                BackgroundTransparency=1,Text=s.Name or "Color",TextSize=FS,
                Font=Enum.Font.GothamMedium,TextColor3=TEXT,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=f})

            local SW,SH=30,18
            local swatch=mk("Frame",{Size=UDim2.fromOffset(SW,SH),
                Position=UDim2.new(1,-(SW+10),0.5,-SH/2),
                BackgroundColor3=cc,BorderSizePixel=0,Parent=f})
            crn(swatch,5); stk(swatch,BORDER,1,0)

            local pW,pHgt=280,158; local svW=pW-40; local svH=pHgt-28
            local pp=mk("Frame",{Size=UDim2.fromOffset(pW,pHgt),
                BackgroundColor3=BG2,BorderSizePixel=0,ZIndex=60,
                Visible=false,ClipsDescendants=false,Parent=sg})
            crn(pp,10); stk(pp,WBORDER,1,0)

            local svB=mk("Frame",{Size=UDim2.fromOffset(svW,svH),Position=UDim2.fromOffset(10,10),
                BackgroundColor3=Color3.fromHSV(h,1,1),BorderSizePixel=0,ZIndex=61,Parent=pp})
            crn(svB,6)

            local function mkg(parent,rot,cs,ts)
                local fr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                    BorderSizePixel=0,ZIndex=62,Parent=parent})
                local g=Instance.new("UIGradient"); g.Color=cs; g.Rotation=rot
                if ts then g.Transparency=ts end; g.Parent=fr
            end
            mkg(svB,0,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))
            mkg(svB,90,ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}),
                NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))

            local svCur=mk("Frame",{Size=UDim2.fromOffset(11,11),
                Position=UDim2.new(sv_s,-5,1-sv_v,-5),
                BackgroundColor3=WBORDER,BorderSizePixel=0,ZIndex=64,Parent=svB})
            crn(svCur,6)

            local hBar=mk("Frame",{Size=UDim2.fromOffset(14,svH),
                Position=UDim2.fromOffset(svW+14,10),
                BackgroundColor3=WBORDER,BorderSizePixel=0,ZIndex=61,Parent=pp})
            crn(hBar,4)
            local hg=Instance.new("UIGradient"); hg.Rotation=90
            hg.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1,1)),
                ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
                ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
                ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,  1,1)),
                ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
                ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV(0,    1,1))}); hg.Parent=hBar

            local hCur=mk("Frame",{Size=UDim2.new(1,5,0,4),
                Position=UDim2.new(-0.18,0,h,-2),
                BackgroundColor3=WBORDER,BorderSizePixel=0,ZIndex=63,Parent=hBar})
            crn(hCur,2)

            local function updC()
                cc=Color3.fromHSV(h,sv_s,sv_v); s.Color=cc
                swatch.BackgroundColor3=cc; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                if s.Callback then task.spawn(pcall,s.Callback,cc) end
            end
            local function posPP()
                local abs=swatch.AbsolutePosition
                pp.Position=UDim2.fromOffset(math.max(0,abs.X-pW+SW+10),abs.Y+SH+4)
            end

            local svD,hD=false,false
            svB.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svD=true; dragging=false
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1)
                    sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updC()
                end
            end)
            hBar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    hD=true; dragging=false
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    hCur.Position=UDim2.new(-0.18,0,h,-2); updC()
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
                if svD then
                    local a=svB.AbsolutePosition; local sz=svB.AbsoluteSize
                    sv_s=math.clamp((i.Position.X-a.X)/sz.X,0,1)
                    sv_v=1-math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5); updC()
                end
                if hD then
                    local a=hBar.AbsolutePosition; local sz=hBar.AbsoluteSize
                    h=math.clamp((i.Position.Y-a.Y)/sz.Y,0,1)
                    hCur.Position=UDim2.new(-0.18,0,h,-2); updC()
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    svD=false; hD=false
                end
            end)

            local cl=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",AutoButtonColor=false,Parent=f})
            cl.MouseButton1Click:Connect(function()
                open=not open; if open then posPP() end; pp.Visible=open
            end)

            function s:Set(c)
                cc=c; h,sv_s,sv_v=Color3.toHSV(c); s.Color=c
                swatch.BackgroundColor3=c; svB.BackgroundColor3=Color3.fromHSV(h,1,1)
                svCur.Position=UDim2.new(sv_s,-5,1-sv_v,-5)
                hCur.Position=UDim2.new(-0.18,0,h,-2)
            end
            if s.Flag then Xanix.Flags[s.Flag]=s end
            return s
        end

        return Tab
    end -- CreateTab

    function Window:Destroy() sg:Destroy() end
    function Window.ModifyTheme(_) end

    return Window
end -- CreateWindow

function Xanix:LoadConfiguration() end
function Xanix:SetVisibility(_)    end
function Xanix:IsVisible()         return true end
function Xanix:Destroy()           end

return Xanix
