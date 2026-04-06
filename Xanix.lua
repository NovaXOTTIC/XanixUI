-- ╔══════════════════════════════════════╗
-- ║         OXEN UI LIBRARY v1.1         ║
-- ║   All original styling preserved     ║
-- ╚══════════════════════════════════════╝
-- Usage:
--   local Oxen = loadstring(game:HttpGet("https://raw.githubusercontent.com/NovaXOTTIC/XanixUI/refs/heads/main/Xanix.lua"))()
--   local Window = Oxen:CreateWindow({ Title = "Oxen" })
--   local Tab = Window:AddTab("Main")
--   Tab:AddLabel("Welcome to Oxen UI")
--   Tab:AddButton({ Name = "God Mode", Callback = function() print("clicked") end })
--   Tab:AddToggle({ Name = "Fly", Default = false, Callback = function(val) print(val) end })
--   Tab:AddSlider({ Name = "Speed", Min = 0, Max = 100, Default = 16, Callback = function(val) print(val) end })

local OxenLib  = {}
OxenLib.__index = OxenLib

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Mobile = touch device without a keyboard (phone/tablet)
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

-- =============================================================================
function OxenLib:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Oxen"

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "Xanix"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.IgnoreGuiInset = false
    ScreenGui.DisplayOrder   = 100
    ScreenGui.Parent         = PlayerGui

    -- Anchor — the ONLY thing that moves when dragging
    local Anchor = Instance.new("Frame")
    Anchor.Name                   = "Anchor"
    Anchor.ZIndex                 = 1
    Anchor.BackgroundColor3       = Color3.fromRGB(163, 162, 165)
    Anchor.BackgroundTransparency = 1
    Anchor.BorderSizePixel        = 0
    Anchor.AnchorPoint            = Vector2.new(0, 0)
    Anchor.ClipsDescendants       = false
    if isMobile then
        Anchor.Size     = UDim2.new(0.92, 0, 0.72, 0)
        Anchor.Position = UDim2.new(0.04, 0, 0.14, 0)
    else
        Anchor.Size     = UDim2.new(0.480961919, 0, 0.605296314, 0)
        Anchor.Position = UDim2.new(0.259519041, 0, 0.197351828, 0)
    end
    Anchor.Parent = ScreenGui

    -- ContentPanel
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name                   = "ContentPanel"
    ContentPanel.ZIndex                 = 1
    ContentPanel.Position               = UDim2.new(0.256944448, 0, 0, 0)
    ContentPanel.Size                   = UDim2.new(0.945833385, 0, 1, 0)
    ContentPanel.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    ContentPanel.BackgroundTransparency = 0
    ContentPanel.ClipsDescendants       = true
    ContentPanel.BorderSizePixel        = 0
    ContentPanel.AnchorPoint            = Vector2.new(0, 0)
    ContentPanel.Parent                 = Anchor

    local CP_UICorner = Instance.new("UICorner")
    CP_UICorner.CornerRadius = UDim.new(0, 12)
    CP_UICorner.Parent       = ContentPanel

    local CP_UIStroke = Instance.new("UIStroke")
    CP_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    CP_UIStroke.Color           = Color3.fromRGB(166, 166, 166)
    CP_UIStroke.LineJoinMode    = Enum.LineJoinMode.Round
    CP_UIStroke.Thickness       = 1
    CP_UIStroke.Transparency    = 0
    CP_UIStroke.Enabled         = true
    CP_UIStroke.Parent          = ContentPanel

    -- TitleBar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name                   = "TitleBar"
    TitleBar.ZIndex                 = 1
    TitleBar.Position               = UDim2.new(0, 0, 0, 0)
    TitleBar.Size                   = UDim2.new(1, 0, 0.104166672, 0)
    TitleBar.BackgroundColor3       = Color3.fromRGB(35, 35, 48)
    TitleBar.BackgroundTransparency = 0
    TitleBar.ClipsDescendants       = false
    TitleBar.BorderSizePixel        = 0
    TitleBar.AnchorPoint            = Vector2.new(0, 0)
    TitleBar.Parent                 = ContentPanel

    local TB_UICorner = Instance.new("UICorner")
    TB_UICorner.CornerRadius = UDim.new(0, 12)
    TB_UICorner.Parent       = TitleBar

    -- White divider line (exact from template)
    local TB_Line = Instance.new("Frame")
    TB_Line.Name                   = "Frame"
    TB_Line.ZIndex                 = 1
    TB_Line.Position               = UDim2.new(0, 0, 0.980000019, 0)
    TB_Line.Size                   = UDim2.new(1, 0, 0.0199999996, 0)
    TB_Line.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    TB_Line.BackgroundTransparency = 0
    TB_Line.BorderSizePixel        = 0
    TB_Line.AnchorPoint            = Vector2.new(0, 0)
    TB_Line.ClipsDescendants       = false
    TB_Line.Parent                 = TitleBar

    -- Title label (exact from template)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name                   = "Title"
    TitleLabel.ZIndex                 = 1
    TitleLabel.Position               = UDim2.new(0.0205580015, 0, 0, 0)
    TitleLabel.Size                   = UDim2.new(0.882525682, 0, 1, 0)
    TitleLabel.BackgroundColor3       = Color3.fromRGB(163, 162, 165)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text                   = windowTitle
    TitleLabel.TextScaled             = false
    TitleLabel.TextSize               = 18
    TitleLabel.Font                   = Enum.Font.GothamBold
    TitleLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    TitleLabel.TextStrokeTransparency = 1
    TitleLabel.TextWrapped            = false
    TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment         = Enum.TextYAlignment.Center
    TitleLabel.TextTransparency       = 0
    TitleLabel.AnchorPoint            = Vector2.new(0, 0)
    TitleLabel.ClipsDescendants       = false
    TitleLabel.Parent                 = TitleBar

    -- Minimize button (exact from template)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name                   = "MinimizeBtn"
    MinBtn.ZIndex                 = 1
    MinBtn.Position               = UDim2.new(0.950073421, 0, 0.280000001, 0)
    MinBtn.Size                   = UDim2.new(0.0411160029, 0, 0.439999998, 0)
    MinBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text                   = "–"
    MinBtn.TextScaled             = false
    MinBtn.TextSize               = 20
    MinBtn.Font                   = Enum.Font.GothamBold
    MinBtn.TextColor3             = Color3.fromRGB(120, 120, 135)
    MinBtn.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    MinBtn.TextStrokeTransparency = 1
    MinBtn.TextWrapped            = false
    MinBtn.TextXAlignment         = Enum.TextXAlignment.Center
    MinBtn.TextYAlignment         = Enum.TextYAlignment.Center
    MinBtn.TextTransparency       = 0
    MinBtn.AnchorPoint            = Vector2.new(0, 0)
    MinBtn.ClipsDescendants       = false
    MinBtn.Parent                 = TitleBar

    local MinBtn_UICorner = Instance.new("UICorner")
    MinBtn_UICorner.CornerRadius = UDim.new(0, 6)
    MinBtn_UICorner.Parent       = MinBtn

    local MinBtn_UIStroke = Instance.new("UIStroke")
    MinBtn_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MinBtn_UIStroke.Color           = Color3.fromRGB(91, 91, 91)
    MinBtn_UIStroke.LineJoinMode    = Enum.LineJoinMode.Round
    MinBtn_UIStroke.Thickness       = 1
    MinBtn_UIStroke.Transparency    = 0
    MinBtn_UIStroke.Enabled         = true
    MinBtn_UIStroke.Parent          = MinBtn

    -- PagesContainer (exact from template)
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name                   = "PagesContainer"
    PagesContainer.ZIndex                 = 1
    PagesContainer.Position               = UDim2.new(0.0176211447, 0, 0.104166672, 0)
    PagesContainer.Size                   = UDim2.new(0.96475774, 0, 0.870833337, 0)
    PagesContainer.BackgroundColor3       = Color3.fromRGB(25, 25, 35)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.ClipsDescendants       = true
    PagesContainer.BorderSizePixel        = 0
    PagesContainer.AnchorPoint            = Vector2.new(0, 0)
    PagesContainer.Parent                 = ContentPanel

    -- TabList (exact from template)
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name                   = "TabList"
    TabList.ZIndex                 = 1
    TabList.Position               = UDim2.new(-0.0111111114, 0, 0.0749999657, 0)
    TabList.Size                   = UDim2.new(0.25, 0, 0.925000072, 0)
    TabList.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    TabList.BackgroundTransparency = 0
    TabList.ClipsDescendants       = true
    TabList.ScrollBarThickness     = 4
    TabList.ScrollingEnabled       = true
    TabList.CanvasSize             = UDim2.new(0, 0, 0, 0)
    TabList.BorderSizePixel        = 0
    TabList.AnchorPoint            = Vector2.new(0, 0)
    TabList.Parent                 = Anchor

    local TL_UICorner = Instance.new("UICorner")
    TL_UICorner.CornerRadius = UDim.new(0, 12)
    TL_UICorner.Parent       = TabList

    local TL_UIStroke = Instance.new("UIStroke")
    TL_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TL_UIStroke.Color           = Color3.fromRGB(255, 255, 255)
    TL_UIStroke.LineJoinMode    = Enum.LineJoinMode.Round
    TL_UIStroke.Thickness       = 1
    TL_UIStroke.Transparency    = 0
    TL_UIStroke.Enabled         = true
    TL_UIStroke.Parent          = TabList

    local TL_UIPadding = Instance.new("UIPadding")
    TL_UIPadding.PaddingBottom = UDim.new(0, 16)
    TL_UIPadding.PaddingTop    = UDim.new(0, 16)
    TL_UIPadding.PaddingLeft   = UDim.new(0, 12)
    TL_UIPadding.PaddingRight  = UDim.new(0, 12)
    TL_UIPadding.Parent        = TabList

    local TL_UIListLayout = Instance.new("UIListLayout")
    TL_UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TL_UIListLayout.Padding   = UDim.new(0, 6)
    TL_UIListLayout.Parent    = TabList

    TL_UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TL_UIListLayout.AbsoluteContentSize.Y + 32)
    end)

    -- Mobile Toggle Button — only created on mobile, bottom-right corner
    if isMobile then
        local MobileBtn = Instance.new("TextButton")
        MobileBtn.Name                   = "MobileButton"
        MobileBtn.ZIndex                 = 10
        MobileBtn.Size                   = UDim2.new(0, 50, 0, 50)
        MobileBtn.Position               = UDim2.new(1, -60, 1, -60)
        MobileBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        MobileBtn.BackgroundTransparency = 0
        MobileBtn.BorderSizePixel        = 0
        MobileBtn.Text                   = "☰"
        MobileBtn.TextSize               = 22
        MobileBtn.Font                   = Enum.Font.GothamBold
        MobileBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
        MobileBtn.Parent                 = ScreenGui

        local MB_UICorner = Instance.new("UICorner")
        MB_UICorner.CornerRadius = UDim.new(1, 0)
        MB_UICorner.Parent       = MobileBtn

        local MB_UIStroke = Instance.new("UIStroke")
        MB_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        MB_UIStroke.Color           = Color3.fromRGB(166, 166, 166)
        MB_UIStroke.Thickness       = 1
        MB_UIStroke.Parent          = MobileBtn

        MobileBtn.MouseButton1Click:Connect(function()
            Anchor.Visible = not Anchor.Visible
        end)
    end

    -- Dragging — InputBegan on TitleBar, moves Anchor only
    local dragging    = false
    local dragStart   = nil
    local anchorStart = nil

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
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

    -- Cancel drag when the minimize button is pressed
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
            local d = input.Position - dragStart
            Anchor.Position = UDim2.new(
                anchorStart.X.Scale, anchorStart.X.Offset + d.X,
                anchorStart.Y.Scale, anchorStart.Y.Offset + d.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Minimize toggle
    local minimized  = false
    local fullCPSize = ContentPanel.Size

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tw(ContentPanel, { Size = UDim2.new(fullCPSize.X.Scale, 0, 0.104166672, 0) }, 0.2)
            PagesContainer.Visible = false
            TB_Line.Visible        = false
            TabList.Visible        = false
            MinBtn.Text            = "+"
        else
            tw(ContentPanel, { Size = fullCPSize }, 0.2)
            PagesContainer.Visible = true
            TB_Line.Visible        = true
            TabList.Visible        = true
            MinBtn.Text            = "–"
        end
    end)

    -- =========================================================================
    local Window = {}
    Window._tabs     = {}
    Window._tabCount = 0

    function Window:AddTab(tabName)
        Window._tabCount = Window._tabCount + 1
        local idx = Window._tabCount

        -- Tab button — exact copy of template's TextButton (SourceSans, 21, white stroke, corner 8)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name                   = tabName
        TabBtn.ZIndex                 = 1
        TabBtn.Position               = UDim2.new(0, 0, 0, 0)
        TabBtn.Size                   = UDim2.new(0.861111104, 0, 0, 34)
        TabBtn.BackgroundColor3       = Color3.fromRGB(17, 17, 17)
        TabBtn.BackgroundTransparency = 0
        TabBtn.Text                   = tabName
        TabBtn.TextScaled             = false
        TabBtn.TextSize               = 21
        TabBtn.Font                   = Enum.Font.SourceSans
        TabBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
        TabBtn.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        TabBtn.TextStrokeTransparency = 1
        TabBtn.TextWrapped            = false
        TabBtn.TextXAlignment         = Enum.TextXAlignment.Center
        TabBtn.TextYAlignment         = Enum.TextYAlignment.Center
        TabBtn.TextTransparency       = 0
        TabBtn.AnchorPoint            = Vector2.new(0, 0)
        TabBtn.ClipsDescendants       = false
        TabBtn.LayoutOrder            = idx
        TabBtn.Parent                 = TabList

        local TabBtn_UIStroke = Instance.new("UIStroke")
        TabBtn_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabBtn_UIStroke.Color           = Color3.fromRGB(255, 255, 255)
        TabBtn_UIStroke.LineJoinMode    = Enum.LineJoinMode.Round
        TabBtn_UIStroke.Thickness       = 1
        TabBtn_UIStroke.Transparency    = 0
        TabBtn_UIStroke.Enabled         = true
        TabBtn_UIStroke.Parent          = TabBtn

        local TabBtn_UICorner = Instance.new("UICorner")
        TabBtn_UICorner.CornerRadius = UDim.new(0, 8)
        TabBtn_UICorner.Parent       = TabBtn

        -- Page — exact copy of template's Page1
        local Page = Instance.new("ScrollingFrame")
        Page.Name                   = "Page_" .. tabName
        Page.ZIndex                 = 1
        Page.Position               = UDim2.new(0, 0, 0, 0)
        Page.Size                   = UDim2.new(1, 0, 1, 0)
        Page.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        Page.BackgroundTransparency = 0.5
        Page.AnchorPoint            = Vector2.new(0, 0)
        Page.ClipsDescendants       = true
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness     = 4
        Page.ScrollingEnabled       = true
        Page.BorderSizePixel        = 0
        Page.Visible                = false
        Page.Parent                 = PagesContainer

        -- Exact UIPadding from template's Page1
        local Page_UIPadding = Instance.new("UIPadding")
        Page_UIPadding.PaddingBottom = UDim.new(0, 12)
        Page_UIPadding.PaddingTop    = UDim.new(0, 12)
        Page_UIPadding.PaddingLeft   = UDim.new(0, 8)
        Page_UIPadding.PaddingRight  = UDim.new(0, 8)
        Page_UIPadding.Parent        = Page

        local Page_UICorner = Instance.new("UICorner")
        Page_UICorner.CornerRadius = UDim.new(0, 8)
        Page_UICorner.Parent       = Page

        local Page_UIListLayout = Instance.new("UIListLayout")
        Page_UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        Page_UIListLayout.Padding   = UDim.new(0, 6)
        Page_UIListLayout.Parent    = Page

        Page_UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Page_UIListLayout.AbsoluteContentSize.Y + 24)
        end)

        if idx == 1 then
            Page.Visible            = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window._tabs) do
                t.Page.Visible            = false
                t.Btn.BackgroundColor3    = Color3.fromRGB(17, 17, 17)
            end
            Page.Visible            = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        end)

        local Tab = { Page = Page, Btn = TabBtn, _count = 0 }
        table.insert(Window._tabs, Tab)

        -- Internal: make a row that exactly matches SampleRow from the template
        local function makeRow(pixelHeight)
            Tab._count = Tab._count + 1
            local Row = Instance.new("Frame")
            Row.Name                   = "Row_" .. Tab._count
            Row.ZIndex                 = 1
            Row.Position               = UDim2.new(-0.00312012481, 0, 0, 0)
            Row.Size                   = UDim2.new(0.981279135, 0, 0, pixelHeight or 36)
            Row.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
            Row.BackgroundTransparency = 0
            Row.AnchorPoint            = Vector2.new(0, 0)
            Row.ClipsDescendants       = false
            Row.BorderSizePixel        = 0
            Row.LayoutOrder            = Tab._count
            Row.Parent                 = Page

            local Row_UICorner = Instance.new("UICorner")
            Row_UICorner.CornerRadius = UDim.new(0, 7)
            Row_UICorner.Parent       = Row

            local Row_UIStroke = Instance.new("UIStroke")
            Row_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            Row_UIStroke.Color           = Color3.fromRGB(55, 55, 55)
            Row_UIStroke.LineJoinMode    = Enum.LineJoinMode.Round
            Row_UIStroke.Thickness       = 1
            Row_UIStroke.Transparency    = 0
            Row_UIStroke.Enabled         = true
            Row_UIStroke.Parent          = Row

            return Row
        end

        -- Internal: make a TextLabel matching template's TextLabel exactly
        local function makeTextLabel(parent, text, xScale, widthScale)
            local Lbl = Instance.new("TextLabel")
            Lbl.Name                   = "TextLabel"
            Lbl.ZIndex                 = 1
            Lbl.Position               = UDim2.new(xScale or 0.0139599722, 0, 0, 0)
            Lbl.Size                   = UDim2.new(widthScale or 0.948813438, 0, 1, 0)
            Lbl.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text                   = text
            Lbl.TextScaled             = false
            Lbl.TextSize               = 13
            Lbl.Font                   = Enum.Font.GothamMedium
            Lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
            Lbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
            Lbl.TextStrokeTransparency = 1
            Lbl.TextWrapped            = false
            Lbl.TextXAlignment         = Enum.TextXAlignment.Left
            Lbl.TextYAlignment         = Enum.TextYAlignment.Center
            Lbl.TextTransparency       = 0
            Lbl.AnchorPoint            = Vector2.new(0, 0)
            Lbl.ClipsDescendants       = false
            Lbl.Parent                 = parent
            return Lbl
        end

        -- AddLabel
        function Tab:AddLabel(text)
            local Row = makeRow(36)
            makeTextLabel(Row, text)
            return Row
        end

        -- AddButton
        function Tab:AddButton(btnConfig)
            btnConfig = btnConfig or {}
            local Row = makeRow(36)
            makeTextLabel(Row, btnConfig.Name or "Button", 0.0139599722, 0.55)

            local Btn = Instance.new("TextButton")
            Btn.ZIndex                 = 1
            Btn.Position               = UDim2.new(0.58, 0, 0.12, 0)
            Btn.Size                   = UDim2.new(0.37, 0, 0.76, 0)
            Btn.BackgroundColor3       = Color3.fromRGB(17, 17, 17)
            Btn.BackgroundTransparency = 0
            Btn.Text                   = "Execute"
            Btn.TextScaled             = false
            Btn.TextSize               = 13
            Btn.Font                   = Enum.Font.GothamMedium
            Btn.TextColor3             = Color3.fromRGB(255, 255, 255)
            Btn.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
            Btn.TextStrokeTransparency = 1
            Btn.TextWrapped            = false
            Btn.TextXAlignment         = Enum.TextXAlignment.Center
            Btn.TextYAlignment         = Enum.TextYAlignment.Center
            Btn.TextTransparency       = 0
            Btn.BorderSizePixel        = 0
            Btn.Parent                 = Row

            local Btn_UICorner = Instance.new("UICorner")
            Btn_UICorner.CornerRadius = UDim.new(0, 7)
            Btn_UICorner.Parent       = Btn

            local Btn_UIStroke = Instance.new("UIStroke")
            Btn_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            Btn_UIStroke.Color           = Color3.fromRGB(55, 55, 55)
            Btn_UIStroke.LineJoinMode    = Enum.LineJoinMode.Round
            Btn_UIStroke.Thickness       = 1
            Btn_UIStroke.Parent          = Btn

            Btn.MouseButton1Click:Connect(function()
                tw(Btn, { BackgroundColor3 = Color3.fromRGB(35, 35, 48) }, 0.1)
                task.delay(0.15, function()
                    tw(Btn, { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }, 0.1)
                end)
                if btnConfig.Callback then btnConfig.Callback() end
            end)
            return Row
        end

        -- AddToggle
        function Tab:AddToggle(togConfig)
            togConfig = togConfig or {}
            local togVal = togConfig.Default == true
            local Row    = makeRow(36)
            makeTextLabel(Row, togConfig.Name or "Toggle", 0.0139599722, 0.65)

            local Pill = Instance.new("TextButton")
            Pill.ZIndex            = 1
            Pill.Size              = UDim2.new(0, 44, 0, 22)
            Pill.Position          = UDim2.new(1, -52, 0.5, -11)
            Pill.BackgroundColor3  = togVal and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(50, 50, 60)
            Pill.BorderSizePixel   = 0
            Pill.Text              = ""
            Pill.Parent            = Row

            local Pill_UICorner = Instance.new("UICorner")
            Pill_UICorner.CornerRadius = UDim.new(1, 0)
            Pill_UICorner.Parent       = Pill

            local Knob = Instance.new("Frame")
            Knob.ZIndex           = 2
            Knob.Size             = UDim2.new(0, 16, 0, 16)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel  = 0
            Knob.Position         = togVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Knob.Parent           = Pill

            local Knob_UICorner = Instance.new("UICorner")
            Knob_UICorner.CornerRadius = UDim.new(1, 0)
            Knob_UICorner.Parent       = Knob

            Pill.MouseButton1Click:Connect(function()
                togVal = not togVal
                tw(Pill, { BackgroundColor3 = togVal and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(50, 50, 60) })
                tw(Knob, { Position = togVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
                if togConfig.Callback then togConfig.Callback(togVal) end
            end)

            local obj = {}
            function obj:Set(v)
                togVal = v
                tw(Pill, { BackgroundColor3 = togVal and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(50, 50, 60) })
                tw(Knob, { Position = togVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
            end
            function obj:Get() return togVal end
            return obj
        end

        -- AddSlider
        function Tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local minVal = sliderConfig.Min     or 0
            local maxVal = sliderConfig.Max     or 100
            local curVal = sliderConfig.Default or minVal
            local Row    = makeRow(52)

            makeTextLabel(Row, sliderConfig.Name or "Slider", 0.0139599722, 0.65)

            local ValLbl = Instance.new("TextLabel")
            ValLbl.ZIndex                 = 1
            ValLbl.Size                   = UDim2.new(0.3, 0, 0, 22)
            ValLbl.Position               = UDim2.new(0.68, 0, 0, 7)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Text                   = tostring(curVal)
            ValLbl.TextScaled             = false
            ValLbl.TextSize               = 13
            ValLbl.Font                   = Enum.Font.GothamMedium
            ValLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
            ValLbl.TextXAlignment         = Enum.TextXAlignment.Right
            ValLbl.TextYAlignment         = Enum.TextYAlignment.Center
            ValLbl.Parent                 = Row

            local Track = Instance.new("Frame")
            Track.ZIndex           = 1
            Track.Size             = UDim2.new(1, -16, 0, 6)
            Track.Position         = UDim2.new(0, 8, 1, -14)
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            Track.BorderSizePixel  = 0
            Track.Parent           = Row

            local Track_UICorner = Instance.new("UICorner")
            Track_UICorner.CornerRadius = UDim.new(1, 0)
            Track_UICorner.Parent       = Track

            local Fill = Instance.new("Frame")
            Fill.ZIndex           = 2
            Fill.Size             = UDim2.new((curVal - minVal) / (maxVal - minVal), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
            Fill.BorderSizePixel  = 0
            Fill.Parent           = Track

            local Fill_UICorner = Instance.new("UICorner")
            Fill_UICorner.CornerRadius = UDim.new(1, 0)
            Fill_UICorner.Parent       = Fill

            local Knob = Instance.new("Frame")
            Knob.ZIndex           = 3
            Knob.Size             = UDim2.new(0, 14, 0, 14)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel  = 0
            Knob.Position         = UDim2.new((curVal - minVal) / (maxVal - minVal), -7, 0.5, -7)
            Knob.Parent           = Track

            local Knob_UICorner = Instance.new("UICorner")
            Knob_UICorner.CornerRadius = UDim.new(1, 0)
            Knob_UICorner.Parent       = Knob

            local sliding = false
            local function update(screenX)
                local rel = math.clamp((screenX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                curVal = math.floor(minVal + rel * (maxVal - minVal) + 0.5)
                rel    = (curVal - minVal) / (maxVal - minVal)
                Fill.Size     = UDim2.new(rel, 0, 1, 0)
                Knob.Position = UDim2.new(rel, -7, 0.5, -7)
                ValLbl.Text   = tostring(curVal)
                if sliderConfig.Callback then sliderConfig.Callback(curVal) end
            end

            Track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true; update(i.Position.X)
                end
            end)
            Knob.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)

            local obj = {}
            function obj:Set(v)
                curVal = math.clamp(v, minVal, maxVal)
                local rel = (curVal - minVal) / (maxVal - minVal)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                Knob.Position = UDim2.new(rel, -7, 0.5, -7)
                ValLbl.Text = tostring(curVal)
            end
            function obj:Get() return curVal end
            return obj
        end

        -- AddTextbox
        function Tab:AddTextbox(tbConfig)
            tbConfig = tbConfig or {}
            local Row = makeRow(36)
            makeTextLabel(Row, tbConfig.Name or "Textbox", 0.0139599722, 0.38)

            -- Exact template TextBox style
            local Box = Instance.new("TextBox")
            Box.ZIndex                  = 1
            Box.Position                = UDim2.new(0.4, 0, 0.12, 0)
            Box.Size                    = UDim2.new(0.55, 0, 0.76, 0)
            Box.BackgroundColor3        = Color3.fromRGB(0, 0, 0)
            Box.BackgroundTransparency  = 0
            Box.Text                    = tbConfig.Default or ""
            Box.PlaceholderText         = tbConfig.Placeholder or "..."
            Box.PlaceholderColor3       = Color3.fromRGB(100, 100, 100)
            Box.TextScaled              = false
            Box.TextSize                = 14
            Box.Font                    = Enum.Font.Gotham
            Box.TextColor3              = Color3.fromRGB(255, 255, 255)
            Box.TextStrokeColor3        = Color3.fromRGB(0, 0, 0)
            Box.TextStrokeTransparency  = 1
            Box.TextWrapped             = false
            Box.TextXAlignment          = Enum.TextXAlignment.Center
            Box.TextYAlignment          = Enum.TextYAlignment.Center
            Box.TextTransparency        = 0
            Box.ClearTextOnFocus        = tbConfig.ClearOnFocus ~= false
            Box.MultiLine               = false
            Box.BorderSizePixel         = 0
            Box.Parent                  = Row

            local Box_UICorner = Instance.new("UICorner")
            Box_UICorner.CornerRadius = UDim.new(0, 100)
            Box_UICorner.Parent       = Box

            local Box_UIStroke = Instance.new("UIStroke")
            Box_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Box_UIStroke.Color           = Color3.fromRGB(255, 255, 255)
            Box_UIStroke.LineJoinMode    = Enum.LineJoinMode.Round
            Box_UIStroke.Thickness       = 1
            Box_UIStroke.Parent          = Box

            Box.FocusLost:Connect(function(enter)
                if tbConfig.Callback then tbConfig.Callback(Box.Text, enter) end
            end)
            return Box
        end

        -- AddDropdown
        function Tab:AddDropdown(ddConfig)
            ddConfig = ddConfig or {}
            local options  = ddConfig.Options or {}
            local selected = ddConfig.Default or (options[1] or "Select")
            local open     = false
            local Row      = makeRow(36)
            Row.ClipsDescendants = false

            makeTextLabel(Row, ddConfig.Name or "Dropdown", 0.0139599722, 0.45)

            local DDBtn = Instance.new("TextButton")
            DDBtn.ZIndex                 = 1
            DDBtn.Position               = UDim2.new(0.46, 0, 0.12, 0)
            DDBtn.Size                   = UDim2.new(0.5, 0, 0.76, 0)
            DDBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
            DDBtn.BackgroundTransparency = 0
            DDBtn.BorderSizePixel        = 0
            DDBtn.Text                   = selected .. " ▾"
            DDBtn.TextScaled             = false
            DDBtn.TextSize               = 13
            DDBtn.Font                   = Enum.Font.GothamMedium
            DDBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
            DDBtn.TextXAlignment         = Enum.TextXAlignment.Center
            DDBtn.Parent                 = Row

            local DD_UICorner = Instance.new("UICorner")
            DD_UICorner.CornerRadius = UDim.new(0, 7)
            DD_UICorner.Parent       = DDBtn

            local DD_UIStroke = Instance.new("UIStroke")
            DD_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            DD_UIStroke.Color           = Color3.fromRGB(55, 55, 55)
            DD_UIStroke.Thickness       = 1
            DD_UIStroke.Parent          = DDBtn

            local ListFrame = Instance.new("ScrollingFrame")
            ListFrame.ZIndex             = 5
            ListFrame.Size               = UDim2.new(0.5, 0, 0, math.min(#options, 4) * 28)
            ListFrame.Position           = UDim2.new(0.46, 0, 1, 4)
            ListFrame.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
            ListFrame.BorderSizePixel    = 0
            ListFrame.ClipsDescendants   = true
            ListFrame.ScrollBarThickness = 2
            ListFrame.CanvasSize         = UDim2.new(0, 0, 0, #options * 28)
            ListFrame.Visible            = false
            ListFrame.Parent             = Row

            local LF_UICorner = Instance.new("UICorner")
            LF_UICorner.CornerRadius = UDim.new(0, 7)
            LF_UICorner.Parent       = ListFrame

            local LF_UIStroke = Instance.new("UIStroke")
            LF_UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            LF_UIStroke.Color           = Color3.fromRGB(55, 55, 55)
            LF_UIStroke.Thickness       = 1
            LF_UIStroke.Parent          = ListFrame

            local LF_UIListLayout = Instance.new("UIListLayout")
            LF_UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LF_UIListLayout.Parent    = ListFrame

            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.ZIndex                 = 6
                OptBtn.Size                   = UDim2.new(1, 0, 0, 28)
                OptBtn.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
                OptBtn.BackgroundTransparency = 0
                OptBtn.BorderSizePixel        = 0
                OptBtn.Text                   = opt
                OptBtn.TextScaled             = false
                OptBtn.TextSize               = 13
                OptBtn.Font                   = Enum.Font.GothamMedium
                OptBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
                OptBtn.LayoutOrder            = i
                OptBtn.Parent                 = ListFrame

                OptBtn.MouseButton1Click:Connect(function()
                    selected          = opt
                    DDBtn.Text        = opt .. " ▾"
                    open              = false
                    ListFrame.Visible = false
                    if ddConfig.Callback then ddConfig.Callback(opt) end
                end)
            end

            DDBtn.MouseButton1Click:Connect(function()
                open = not open
                ListFrame.Visible = open
            end)

            local obj = {}
            function obj:Get() return selected end
            function obj:Set(v) selected = v; DDBtn.Text = v .. " ▾" end
            return obj
        end

        -- AddSeparator
        function Tab:AddSeparator()
            Tab._count = Tab._count + 1
            local Sep = Instance.new("Frame")
            Sep.ZIndex           = 1
            Sep.Size             = UDim2.new(0.981279135, 0, 0, 1)
            Sep.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            Sep.BorderSizePixel  = 0
            Sep.LayoutOrder      = Tab._count
            Sep.Parent           = Page
        end

        return Tab
    end

    function Window:SetTitle(t) TitleLabel.Text = t end
    function Window:Destroy()   ScreenGui:Destroy() end

    return Window
end

return OxenLib
