-- ╔══════════════════════════════════════╗
-- ║         OXEN UI LIBRARY v1.0         ║
-- ║   loadstring compatible module       ║
-- ╚══════════════════════════════════════╝
-- Usage:
--   local Oxen = loadstring(game:HttpGet("https://raw.githubusercontent.com/NovaXOTTIC/XanixUI/refs/heads/main/Xanix.lua"))()
--   local Window = Oxen:CreateWindow({ Title = "My Script" })
--   local Tab = Window:AddTab("Main")
--   Tab:AddLabel("Hello World")
--   Tab:AddButton({ Name = "Click Me", Callback = function() print("clicked") end })
--   Tab:AddToggle({ Name = "God Mode", Default = false, Callback = function(val) print(val) end })
--   Tab:AddSlider({ Name = "Speed", Min = 0, Max = 100, Default = 16, Callback = function(val) print(val) end })

local OxenLib = {}
OxenLib.__index = OxenLib

local Players        = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ── Mobile Detection ──────────────────────────────────────────────────────────
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ── Tween Helper ──────────────────────────────────────────────────────────────
local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

-- ── Corner / Stroke helpers ───────────────────────────────────────────────────
local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, mode)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(55, 55, 55)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = parent
    return s
end

-- ═════════════════════════════════════════════════════════════════════════════
--  CreateWindow
-- ═════════════════════════════════════════════════════════════════════════════
function OxenLib:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Oxen"

    -- ── ScreenGui ─────────────────────────────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name             = "Xanix"
    ScreenGui.ResetOnSpawn     = false
    ScreenGui.IgnoreGuiInset   = false
    ScreenGui.DisplayOrder     = 100
    ScreenGui.Parent           = PlayerGui

    -- ── Anchor (the draggable root) ───────────────────────────────────────────
    local Anchor = Instance.new("Frame")
    Anchor.Name                = "Anchor"
    Anchor.BackgroundTransparency = 1
    Anchor.BorderSizePixel     = 0
    Anchor.ZIndex              = 1
    Anchor.AnchorPoint         = Vector2.new(0, 0)
    Anchor.ClipsDescendants    = false

    if isMobile then
        -- Fits comfortably on a phone screen
        Anchor.Size     = UDim2.new(0.92, 0, 0.72, 0)
        Anchor.Position = UDim2.new(0.04, 0, 0.14, 0)
    else
        Anchor.Size     = UDim2.new(0.480961919, 0, 0.605296314, 0)
        Anchor.Position = UDim2.new(0.259519041, 0, 0.197351828, 0)
    end
    Anchor.Parent = ScreenGui

    -- ── TabList (left sidebar) ────────────────────────────────────────────────
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name               = "TabList"
    TabList.ZIndex             = 2
    TabList.Position           = UDim2.new(-0.0111111114, 0, 0.0749999657, 0)
    TabList.Size               = UDim2.new(0.25, 0, 0.925000072, 0)
    TabList.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
    TabList.BackgroundTransparency = 0
    TabList.BorderSizePixel    = 0
    TabList.ClipsDescendants   = true
    TabList.ScrollBarThickness = 4
    TabList.ScrollingEnabled   = true
    TabList.CanvasSize         = UDim2.new(0, 0, 0, 0)
    TabList.Parent             = Anchor
    addCorner(TabList, 12)
    addStroke(TabList, Color3.fromRGB(255, 255, 255), 1, Enum.ApplyStrokeMode.Border)

    local TLPadding = Instance.new("UIPadding")
    TLPadding.PaddingTop    = UDim.new(0, 16)
    TLPadding.PaddingBottom = UDim.new(0, 16)
    TLPadding.PaddingLeft   = UDim.new(0, 12)
    TLPadding.PaddingRight  = UDim.new(0, 12)
    TLPadding.Parent        = TabList

    local TLLayout = Instance.new("UIListLayout")
    TLLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    TLLayout.Padding    = UDim.new(0, 6)
    TLLayout.Parent     = TabList

    TLLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TLLayout.AbsoluteContentSize.Y + 32)
    end)

    -- ── ContentPanel (right main area) ────────────────────────────────────────
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name              = "ContentPanel"
    ContentPanel.ZIndex            = 1
    ContentPanel.Position          = UDim2.new(0.256944448, 0, 0, 0)
    ContentPanel.Size              = UDim2.new(0.945833385, 0, 1, 0)
    ContentPanel.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
    ContentPanel.BackgroundTransparency = 0
    ContentPanel.ClipsDescendants  = true
    ContentPanel.BorderSizePixel   = 0
    ContentPanel.AnchorPoint       = Vector2.new(0, 0)
    ContentPanel.Parent            = Anchor
    addCorner(ContentPanel, 12)
    addStroke(ContentPanel, Color3.fromRGB(166, 166, 166), 1, Enum.ApplyStrokeMode.Contextual)

    -- ── TitleBar ──────────────────────────────────────────────────────────────
    local TitleBar = Instance.new("Frame")
    TitleBar.Name              = "TitleBar"
    TitleBar.ZIndex            = 2
    TitleBar.Position          = UDim2.new(0, 0, 0, 0)
    TitleBar.Size              = UDim2.new(1, 0, 0.104166672, 0)
    TitleBar.BackgroundColor3  = Color3.fromRGB(35, 35, 48)
    TitleBar.BackgroundTransparency = 0
    TitleBar.ClipsDescendants  = false
    TitleBar.BorderSizePixel   = 0
    TitleBar.AnchorPoint       = Vector2.new(0, 0)
    TitleBar.Parent            = ContentPanel
    addCorner(TitleBar, 12)

    -- Bottom divider line on TitleBar
    local TBLine = Instance.new("Frame")
    TBLine.Position          = UDim2.new(0, 0, 0.98, 0)
    TBLine.Size              = UDim2.new(1, 0, 0.02, 0)
    TBLine.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
    TBLine.BackgroundTransparency = 0
    TBLine.BorderSizePixel   = 0
    TBLine.Parent            = TitleBar

    -- Title text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name            = "Title"
    TitleLabel.ZIndex          = 2
    TitleLabel.Position        = UDim2.new(0.0205580015, 0, 0, 0)
    TitleLabel.Size            = UDim2.new(0.882525682, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text            = windowTitle
    TitleLabel.TextScaled      = false
    TitleLabel.TextSize        = 18
    TitleLabel.Font            = Enum.Font.GothamBold
    TitleLabel.TextColor3      = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment  = Enum.TextYAlignment.Center
    TitleLabel.TextTransparency = 0
    TitleLabel.Parent          = TitleBar

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name                = "MinimizeBtn"
    MinBtn.ZIndex              = 3
    MinBtn.Position            = UDim2.new(0.950073421, 0, 0.280000001, 0)
    MinBtn.Size                = UDim2.new(0.0411160029, 0, 0.439999998, 0)
    MinBtn.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text                = "–"
    MinBtn.TextScaled          = false
    MinBtn.TextSize            = 20
    MinBtn.Font                = Enum.Font.GothamBold
    MinBtn.TextColor3          = Color3.fromRGB(120, 120, 135)
    MinBtn.TextXAlignment      = Enum.TextXAlignment.Center
    MinBtn.TextYAlignment      = Enum.TextYAlignment.Center
    MinBtn.TextTransparency    = 0
    MinBtn.Parent              = TitleBar
    addCorner(MinBtn, 6)
    addStroke(MinBtn, Color3.fromRGB(91, 91, 91), 1, Enum.ApplyStrokeMode.Border)

    -- ── PagesContainer ────────────────────────────────────────────────────────
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name              = "PagesContainer"
    PagesContainer.ZIndex            = 1
    PagesContainer.Position          = UDim2.new(0.0176211447, 0, 0.104166672, 0)
    PagesContainer.Size              = UDim2.new(0.96475774, 0, 0.870833337, 0)
    PagesContainer.BackgroundColor3  = Color3.fromRGB(25, 25, 35)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.ClipsDescendants  = true
    PagesContainer.BorderSizePixel   = 0
    PagesContainer.AnchorPoint       = Vector2.new(0, 0)
    PagesContainer.Parent            = ContentPanel

    -- ── Mobile Toggle Button (only shown on mobile) ───────────────────────────
    local MobileBtn = nil
    if isMobile then
        MobileBtn = Instance.new("TextButton")
        MobileBtn.Name                = "MobileButton"
        MobileBtn.ZIndex              = 10
        MobileBtn.Size                = UDim2.new(0, 50, 0, 50)
        MobileBtn.Position            = UDim2.new(1, -60, 1, -60)
        MobileBtn.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
        MobileBtn.BackgroundTransparency = 0
        MobileBtn.BorderSizePixel     = 0
        MobileBtn.Text                = "☰"
        MobileBtn.TextSize            = 22
        MobileBtn.Font                = Enum.Font.GothamBold
        MobileBtn.TextColor3          = Color3.fromRGB(255, 255, 255)
        MobileBtn.Parent              = ScreenGui
        addCorner(MobileBtn, 25)
        addStroke(MobileBtn, Color3.fromRGB(166, 166, 166), 1, Enum.ApplyStrokeMode.Border)

        MobileBtn.MouseButton1Click:Connect(function()
            Anchor.Visible = not Anchor.Visible
        end)
    end

    -- ── Dragging (TitleBar → moves Anchor only) ───────────────────────────────
    local dragging   = false
    local dragStart  = nil
    local anchorStart = nil

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            -- Don't start drag if clicking the minimize button
            dragging    = true
            dragStart   = input.Position
            anchorStart = Anchor.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    -- Stop drag if minimize button is pressed
    MinBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            Anchor.Position = UDim2.new(
                anchorStart.X.Scale,
                anchorStart.X.Offset + delta.X,
                anchorStart.Y.Scale,
                anchorStart.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ── Minimize Toggle ───────────────────────────────────────────────────────
    local minimized      = false
    local fullCPSize     = ContentPanel.Size

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized

        if minimized then
            tween(ContentPanel, { Size = UDim2.new(fullCPSize.X.Scale, 0, 0.104166672, 0) }, 0.2)
            PagesContainer.Visible = false
            TBLine.Visible         = false
            TabList.Visible        = false
            MinBtn.Text            = "+"
        else
            tween(ContentPanel, { Size = fullCPSize }, 0.2)
            PagesContainer.Visible = true
            TBLine.Visible         = true
            TabList.Visible        = true
            MinBtn.Text            = "–"
        end
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    --  Window object (returned to the user)
    -- ══════════════════════════════════════════════════════════════════════════
    local Window = {}
    Window._tabs       = {}
    Window._tabCount   = 0

    -- ── AddTab ────────────────────────────────────────────────────────────────
    function Window:AddTab(tabName)
        Window._tabCount = Window._tabCount + 1
        local tabIndex   = Window._tabCount

        -- Tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name               = "Tab_" .. tabName
        TabBtn.ZIndex             = 3
        TabBtn.Size               = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3   = Color3.fromRGB(17, 17, 17)
        TabBtn.BackgroundTransparency = 0
        TabBtn.BorderSizePixel    = 0
        TabBtn.Text               = tabName
        TabBtn.TextScaled         = false
        TabBtn.TextSize           = isMobile and 12 or 14
        TabBtn.Font               = Enum.Font.GothamMedium
        TabBtn.TextColor3         = Color3.fromRGB(200, 200, 200)
        TabBtn.TextXAlignment     = Enum.TextXAlignment.Center
        TabBtn.TextYAlignment     = Enum.TextYAlignment.Center
        TabBtn.LayoutOrder        = tabIndex
        TabBtn.Parent             = TabList
        addCorner(TabBtn, 8)
        addStroke(TabBtn, Color3.fromRGB(255, 255, 255), 1, Enum.ApplyStrokeMode.Border)

        -- Page (ScrollingFrame)
        local Page = Instance.new("ScrollingFrame")
        Page.Name               = "Page_" .. tabName
        Page.ZIndex             = 1
        Page.Position           = UDim2.new(0, 0, 0, 0)
        Page.Size               = UDim2.new(1, 0, 1, 0)
        Page.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
        Page.BackgroundTransparency = 0.5
        Page.BorderSizePixel    = 0
        Page.ClipsDescendants   = true
        Page.ScrollBarThickness = 4
        Page.ScrollingEnabled   = true
        Page.CanvasSize         = UDim2.new(0, 0, 0, 0)
        Page.Visible            = false
        Page.Parent             = PagesContainer
        addCorner(Page, 8)

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop    = UDim.new(0, 12)
        PagePad.PaddingBottom = UDim.new(0, 12)
        PagePad.PaddingLeft   = UDim.new(0, 8)
        PagePad.PaddingRight  = UDim.new(0, 8)
        PagePad.Parent        = Page

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        PageLayout.Padding    = UDim.new(0, 6)
        PageLayout.Parent     = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 24)
        end)

        -- Activate first tab automatically
        if tabIndex == 1 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            TabBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        end

        -- Tab click switches pages
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window._tabs) do
                t.Page.Visible              = false
                t.Btn.BackgroundColor3      = Color3.fromRGB(17, 17, 17)
                t.Btn.TextColor3            = Color3.fromRGB(200, 200, 200)
            end
            Page.Visible              = true
            TabBtn.BackgroundColor3   = Color3.fromRGB(35, 35, 48)
            TabBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
        end)

        -- ── Tab object ────────────────────────────────────────────────────────
        local Tab = { Page = Page, Btn = TabBtn, _count = 0 }
        table.insert(Window._tabs, Tab)

        -- Row builder helper (internal)
        local function makeRow(height)
            Tab._count = Tab._count + 1
            local Row = Instance.new("Frame")
            Row.Name               = "Row_" .. Tab._count
            Row.ZIndex             = 2
            Row.Size               = UDim2.new(1, 0, 0, height or 36)
            Row.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
            Row.BackgroundTransparency = 0
            Row.BorderSizePixel    = 0
            Row.LayoutOrder        = Tab._count
            Row.Parent             = Page
            addCorner(Row, 7)
            addStroke(Row, Color3.fromRGB(55, 55, 55), 1, Enum.ApplyStrokeMode.Contextual)
            return Row
        end

        -- ── AddLabel ──────────────────────────────────────────────────────────
        function Tab:AddLabel(text)
            local Row = makeRow(36)
            local Lbl = Instance.new("TextLabel")
            Lbl.ZIndex            = 3
            Lbl.Size              = UDim2.new(1, -10, 1, 0)
            Lbl.Position          = UDim2.new(0, 10, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text              = text
            Lbl.TextScaled        = false
            Lbl.TextSize          = 13
            Lbl.Font              = Enum.Font.GothamMedium
            Lbl.TextColor3        = Color3.fromRGB(255, 255, 255)
            Lbl.TextXAlignment    = Enum.TextXAlignment.Left
            Lbl.TextYAlignment    = Enum.TextYAlignment.Center
            Lbl.TextWrapped       = true
            Lbl.Parent            = Row
            return Row
        end

        -- ── AddButton ─────────────────────────────────────────────────────────
        function Tab:AddButton(btnConfig)
            btnConfig = btnConfig or {}
            local Row = makeRow(36)

            local NameLbl = Instance.new("TextLabel")
            NameLbl.ZIndex           = 3
            NameLbl.Size             = UDim2.new(0.6, 0, 1, 0)
            NameLbl.Position         = UDim2.new(0, 10, 0, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text             = btnConfig.Name or "Button"
            NameLbl.TextScaled       = false
            NameLbl.TextSize         = 13
            NameLbl.Font             = Enum.Font.GothamMedium
            NameLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
            NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
            NameLbl.TextYAlignment   = Enum.TextYAlignment.Center
            NameLbl.Parent           = Row

            local Btn = Instance.new("TextButton")
            Btn.ZIndex             = 3
            Btn.Size               = UDim2.new(0, 70, 0, 24)
            Btn.Position           = UDim2.new(1, -80, 0.5, -12)
            Btn.BackgroundColor3   = Color3.fromRGB(35, 35, 48)
            Btn.BorderSizePixel    = 0
            Btn.Text               = "Execute"
            Btn.TextScaled         = false
            Btn.TextSize           = 12
            Btn.Font               = Enum.Font.GothamMedium
            Btn.TextColor3         = Color3.fromRGB(255, 255, 255)
            Btn.Parent             = Row
            addCorner(Btn, 6)
            addStroke(Btn, Color3.fromRGB(166, 166, 166), 1, Enum.ApplyStrokeMode.Border)

            Btn.MouseButton1Click:Connect(function()
                tween(Btn, { BackgroundColor3 = Color3.fromRGB(60, 60, 80) }, 0.1)
                task.delay(0.15, function()
                    tween(Btn, { BackgroundColor3 = Color3.fromRGB(35, 35, 48) }, 0.1)
                end)
                if btnConfig.Callback then
                    btnConfig.Callback()
                end
            end)

            return Row
        end

        -- ── AddToggle ─────────────────────────────────────────────────────────
        function Tab:AddToggle(togConfig)
            togConfig = togConfig or {}
            local Row    = makeRow(36)
            local togVal = togConfig.Default == true

            local NameLbl = Instance.new("TextLabel")
            NameLbl.ZIndex           = 3
            NameLbl.Size             = UDim2.new(0.65, 0, 1, 0)
            NameLbl.Position         = UDim2.new(0, 10, 0, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text             = togConfig.Name or "Toggle"
            NameLbl.TextScaled       = false
            NameLbl.TextSize         = 13
            NameLbl.Font             = Enum.Font.GothamMedium
            NameLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
            NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
            NameLbl.TextYAlignment   = Enum.TextYAlignment.Center
            NameLbl.Parent           = Row

            -- Pill background
            local Pill = Instance.new("TextButton")
            Pill.ZIndex            = 3
            Pill.Size              = UDim2.new(0, 44, 0, 22)
            Pill.Position          = UDim2.new(1, -54, 0.5, -11)
            Pill.BackgroundColor3  = togVal and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(50, 50, 60)
            Pill.BorderSizePixel   = 0
            Pill.Text              = ""
            Pill.Parent            = Row
            addCorner(Pill, 11)

            -- Knob
            local Knob = Instance.new("Frame")
            Knob.ZIndex           = 4
            Knob.Size             = UDim2.new(0, 16, 0, 16)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel  = 0
            Knob.Position         = togVal
                and UDim2.new(1, -19, 0.5, -8)
                or  UDim2.new(0, 3,   0.5, -8)
            Knob.Parent           = Pill
            addCorner(Knob, 8)

            Pill.MouseButton1Click:Connect(function()
                togVal = not togVal
                tween(Pill, { BackgroundColor3 = togVal and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(50, 50, 60) })
                tween(Knob, { Position = togVal
                    and UDim2.new(1, -19, 0.5, -8)
                    or  UDim2.new(0, 3,   0.5, -8) })
                if togConfig.Callback then togConfig.Callback(togVal) end
            end)

            -- Expose a setter so scripts can update it programmatically
            local toggleObj = {}
            function toggleObj:Set(val)
                togVal = val
                tween(Pill, { BackgroundColor3 = togVal and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(50, 50, 60) })
                tween(Knob, { Position = togVal
                    and UDim2.new(1, -19, 0.5, -8)
                    or  UDim2.new(0, 3,   0.5, -8) })
            end
            function toggleObj:Get() return togVal end
            return toggleObj
        end

        -- ── AddSlider ─────────────────────────────────────────────────────────
        function Tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local Row     = makeRow(52)
            local minVal  = sliderConfig.Min     or 0
            local maxVal  = sliderConfig.Max     or 100
            local curVal  = sliderConfig.Default or minVal
            local decPlaces = sliderConfig.Decimals or 0

            local function fmtVal(v)
                if decPlaces > 0 then
                    return string.format("%." .. decPlaces .. "f", v)
                end
                return tostring(math.floor(v))
            end

            local HeaderRow = Instance.new("Frame")
            HeaderRow.ZIndex             = 3
            HeaderRow.Size               = UDim2.new(1, -10, 0, 22)
            HeaderRow.Position           = UDim2.new(0, 5, 0, 4)
            HeaderRow.BackgroundTransparency = 1
            HeaderRow.Parent             = Row

            local NameLbl = Instance.new("TextLabel")
            NameLbl.ZIndex           = 3
            NameLbl.Size             = UDim2.new(0.7, 0, 1, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text             = sliderConfig.Name or "Slider"
            NameLbl.TextScaled       = false
            NameLbl.TextSize         = 13
            NameLbl.Font             = Enum.Font.GothamMedium
            NameLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
            NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
            NameLbl.TextYAlignment   = Enum.TextYAlignment.Center
            NameLbl.Parent           = HeaderRow

            local ValLbl = Instance.new("TextLabel")
            ValLbl.ZIndex           = 3
            ValLbl.Size             = UDim2.new(0.3, 0, 1, 0)
            ValLbl.Position         = UDim2.new(0.7, 0, 0, 0)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Text             = fmtVal(curVal)
            ValLbl.TextScaled       = false
            ValLbl.TextSize         = 13
            ValLbl.Font             = Enum.Font.GothamMedium
            ValLbl.TextColor3       = Color3.fromRGB(180, 180, 200)
            ValLbl.TextXAlignment   = Enum.TextXAlignment.Right
            ValLbl.TextYAlignment   = Enum.TextYAlignment.Center
            ValLbl.Parent           = HeaderRow

            -- Track
            local Track = Instance.new("Frame")
            Track.ZIndex           = 3
            Track.Size             = UDim2.new(1, -16, 0, 6)
            Track.Position         = UDim2.new(0, 8, 1, -14)
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            Track.BorderSizePixel  = 0
            Track.Parent           = Row
            addCorner(Track, 3)

            local Fill = Instance.new("Frame")
            Fill.ZIndex           = 4
            Fill.Size             = UDim2.new((curVal - minVal) / (maxVal - minVal), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
            Fill.BorderSizePixel  = 0
            Fill.Parent           = Track
            addCorner(Fill, 3)

            local Knob = Instance.new("Frame")
            Knob.ZIndex           = 5
            Knob.Size             = UDim2.new(0, 14, 0, 14)
            Knob.Position         = UDim2.new((curVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel  = 0
            Knob.Parent           = Track
            addCorner(Knob, 7)

            -- Drag logic
            local sliding = false

            local function updateSlider(screenX)
                local trackAbs  = Track.AbsolutePosition.X
                local trackSize = Track.AbsoluteSize.X
                local relX      = math.clamp((screenX - trackAbs) / trackSize, 0, 1)
                local rawVal    = minVal + relX * (maxVal - minVal)
                if decPlaces == 0 then
                    curVal = math.floor(rawVal + 0.5)
                else
                    local mult = 10 ^ decPlaces
                    curVal = math.floor(rawVal * mult + 0.5) / mult
                end
                relX = (curVal - minVal) / (maxVal - minVal)
                Fill.Size     = UDim2.new(relX, 0, 1, 0)
                Knob.Position = UDim2.new(relX, -7, 0.5, -7)
                ValLbl.Text   = fmtVal(curVal)
                if sliderConfig.Callback then sliderConfig.Callback(curVal) end
            end

            Track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(inp.Position.X)
                end
            end)
            Knob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            local sliderObj = {}
            function sliderObj:Set(val)
                curVal = math.clamp(val, minVal, maxVal)
                local relX = (curVal - minVal) / (maxVal - minVal)
                Fill.Size     = UDim2.new(relX, 0, 1, 0)
                Knob.Position = UDim2.new(relX, -7, 0.5, -7)
                ValLbl.Text   = fmtVal(curVal)
            end
            function sliderObj:Get() return curVal end
            return sliderObj
        end

        -- ── AddTextbox ────────────────────────────────────────────────────────
        function Tab:AddTextbox(tbConfig)
            tbConfig = tbConfig or {}
            local Row = makeRow(36)

            local NameLbl = Instance.new("TextLabel")
            NameLbl.ZIndex           = 3
            NameLbl.Size             = UDim2.new(0.38, 0, 1, 0)
            NameLbl.Position         = UDim2.new(0, 10, 0, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text             = tbConfig.Name or "Textbox"
            NameLbl.TextScaled       = false
            NameLbl.TextSize         = 13
            NameLbl.Font             = Enum.Font.GothamMedium
            NameLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
            NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
            NameLbl.TextYAlignment   = Enum.TextYAlignment.Center
            NameLbl.Parent           = Row

            local Box = Instance.new("TextBox")
            Box.ZIndex             = 3
            Box.Size               = UDim2.new(0.52, 0, 0.7, 0)
            Box.Position           = UDim2.new(0.44, 0, 0.15, 0)
            Box.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
            Box.BackgroundTransparency = 0
            Box.BorderSizePixel    = 0
            Box.Text               = tbConfig.Default or ""
            Box.PlaceholderText    = tbConfig.Placeholder or "..."
            Box.PlaceholderColor3  = Color3.fromRGB(100, 100, 100)
            Box.TextScaled         = false
            Box.TextSize           = 13
            Box.Font               = Enum.Font.Gotham
            Box.TextColor3         = Color3.fromRGB(255, 255, 255)
            Box.TextXAlignment     = Enum.TextXAlignment.Center
            Box.TextYAlignment     = Enum.TextYAlignment.Center
            Box.ClearTextOnFocus   = tbConfig.ClearOnFocus ~= false
            Box.MultiLine          = false
            Box.Parent             = Row
            addCorner(Box, 100)
            addStroke(Box, Color3.fromRGB(255, 255, 255), 1, Enum.ApplyStrokeMode.Border)

            Box.FocusLost:Connect(function(enterPressed)
                if tbConfig.Callback then
                    tbConfig.Callback(Box.Text, enterPressed)
                end
            end)

            return Box
        end

        -- ── AddDropdown ───────────────────────────────────────────────────────
        function Tab:AddDropdown(ddConfig)
            ddConfig = ddConfig or {}
            local options  = ddConfig.Options  or {}
            local selected = ddConfig.Default  or (options[1] or "Select")
            local open     = false

            local Row = makeRow(36)
            Row.ClipsDescendants = false
            Row.ZIndex = 4

            local NameLbl = Instance.new("TextLabel")
            NameLbl.ZIndex           = 5
            NameLbl.Size             = UDim2.new(0.45, 0, 1, 0)
            NameLbl.Position         = UDim2.new(0, 10, 0, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text             = ddConfig.Name or "Dropdown"
            NameLbl.TextScaled       = false
            NameLbl.TextSize         = 13
            NameLbl.Font             = Enum.Font.GothamMedium
            NameLbl.TextColor3       = Color3.fromRGB(255, 255, 255)
            NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
            NameLbl.TextYAlignment   = Enum.TextYAlignment.Center
            NameLbl.Parent           = Row

            local DDBtn = Instance.new("TextButton")
            DDBtn.ZIndex           = 5
            DDBtn.Size             = UDim2.new(0.45, 0, 0.72, 0)
            DDBtn.Position         = UDim2.new(0.52, 0, 0.14, 0)
            DDBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            DDBtn.BorderSizePixel  = 0
            DDBtn.Text             = selected .. " ▾"
            DDBtn.TextScaled       = false
            DDBtn.TextSize         = 12
            DDBtn.Font             = Enum.Font.GothamMedium
            DDBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
            DDBtn.Parent           = Row
            addCorner(DDBtn, 6)
            addStroke(DDBtn, Color3.fromRGB(255, 255, 255), 1, Enum.ApplyStrokeMode.Border)

            -- Dropdown list (hidden by default)
            local ListFrame = Instance.new("ScrollingFrame")
            ListFrame.ZIndex             = 10
            ListFrame.Size               = UDim2.new(0.45, 0, 0, math.min(#options, 4) * 28)
            ListFrame.Position           = UDim2.new(0.52, 0, 1, 4)
            ListFrame.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
            ListFrame.BorderSizePixel    = 0
            ListFrame.ClipsDescendants   = true
            ListFrame.ScrollBarThickness = 2
            ListFrame.CanvasSize         = UDim2.new(0, 0, 0, #options * 28)
            ListFrame.Visible            = false
            ListFrame.Parent             = Row
            addCorner(ListFrame, 6)
            addStroke(ListFrame, Color3.fromRGB(255, 255, 255), 1, Enum.ApplyStrokeMode.Border)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent    = ListFrame

            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.ZIndex           = 11
                OptBtn.Size             = UDim2.new(1, 0, 0, 28)
                OptBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                OptBtn.BackgroundTransparency = 0
                OptBtn.BorderSizePixel  = 0
                OptBtn.Text             = opt
                OptBtn.TextScaled       = false
                OptBtn.TextSize         = 12
                OptBtn.Font             = Enum.Font.GothamMedium
                OptBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
                OptBtn.LayoutOrder      = i
                OptBtn.Parent           = ListFrame

                OptBtn.MouseButton1Click:Connect(function()
                    selected        = opt
                    DDBtn.Text      = opt .. " ▾"
                    open            = false
                    ListFrame.Visible = false
                    if ddConfig.Callback then ddConfig.Callback(opt) end
                end)
            end

            DDBtn.MouseButton1Click:Connect(function()
                open = not open
                ListFrame.Visible = open
            end)

            local ddObj = {}
            function ddObj:Get() return selected end
            function ddObj:Set(val)
                selected  = val
                DDBtn.Text = val .. " ▾"
            end
            return ddObj
        end

        -- ── AddSeparator ──────────────────────────────────────────────────────
        function Tab:AddSeparator()
            Tab._count = Tab._count + 1
            local Sep = Instance.new("Frame")
            Sep.ZIndex            = 2
            Sep.Size              = UDim2.new(1, 0, 0, 1)
            Sep.BackgroundColor3  = Color3.fromRGB(55, 55, 55)
            Sep.BorderSizePixel   = 0
            Sep.LayoutOrder       = Tab._count
            Sep.Parent            = Page
            return Sep
        end

        return Tab
    end

    -- ── Utility methods on Window ─────────────────────────────────────────────
    function Window:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return OxenLib
