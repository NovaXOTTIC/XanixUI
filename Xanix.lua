-- ╔══════════════════════════════════════╗
-- ║         OXEN UI LIBRARY v2.0         ║
-- ║   Cleaner styling + new components   ║
-- ╚══════════════════════════════════════╝
-- Components:
--   Tab:AddLabel(text)
--   Tab:AddButton({ Name, Callback })          -- full-row clickable button
--   Tab:AddToggle({ Name, Default, Callback })
--   Tab:AddSlider({ Name, Min, Max, Default, Callback })
--   Tab:AddTextbox({ Name, Default, Placeholder, ClearOnFocus, Callback })
--   Tab:AddDropdown({ Name, Options, Default, Callback })
--   Tab:AddColorPicker({ Name, Default, Callback })  -- Default = Color3
--   Tab:AddSeparator()

local OxenLib  = {}
OxenLib.__index = OxenLib

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

-- ── Palette ──────────────────────────────────────────────────────────────────
local C = {
    Black       = Color3.fromRGB(0,   0,   0),
    PanelBg     = Color3.fromRGB(12,  12,  12),
    RowBg       = Color3.fromRGB(17,  17,  17),
    RowBgHover  = Color3.fromRGB(24,  24,  24),
    TitleBar    = Color3.fromRGB(0,   0,   0),
    White       = Color3.fromRGB(255, 255, 255),
    TextPrimary = Color3.fromRGB(218, 218, 218),
    TextMuted   = Color3.fromRGB(100, 100, 100),
    Border      = Color3.fromRGB(35,  35,  35),
    BorderLight = Color3.fromRGB(55,  55,  55),
    PillOff     = Color3.fromRGB(50,  50,  60),
    PillOn      = Color3.fromRGB(232, 232, 232),
    TrackBg     = Color3.fromRGB(40,  40,  50),
    TrackFill   = Color3.fromRGB(166, 166, 166),
}

-- =============================================================================
function OxenLib:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Oxen"

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "OxenUI"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.IgnoreGuiInset = false
    ScreenGui.DisplayOrder   = 100
    ScreenGui.Parent         = PlayerGui

    -- Anchor
    local Anchor = Instance.new("Frame")
    Anchor.Name                   = "Anchor"
    Anchor.BackgroundTransparency = 1
    Anchor.BorderSizePixel        = 0
    Anchor.ClipsDescendants       = false
    if isMobile then
        Anchor.Size     = UDim2.new(0.92, 0, 0.72, 0)
        Anchor.Position = UDim2.new(0.04, 0, 0.14, 0)
    else
        Anchor.Size     = UDim2.new(0.50, 0, 0.62, 0)
        Anchor.Position = UDim2.new(0.25, 0, 0.19, 0)
    end
    Anchor.Parent = ScreenGui

    -- ── Tab Sidebar ───────────────────────────────────────────────────────────
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name                   = "TabList"
    TabList.Position               = UDim2.new(0, 0, 0.075, 0)
    TabList.Size                   = UDim2.new(0.22, 0, 0.92, 0)
    TabList.BackgroundColor3       = C.PanelBg
    TabList.BackgroundTransparency = 0
    TabList.BorderSizePixel        = 0
    TabList.ClipsDescendants       = true
    TabList.ScrollBarThickness     = 3
    TabList.ScrollingEnabled       = true
    TabList.CanvasSize             = UDim2.new(0, 0, 0, 0)
    TabList.Parent                 = Anchor

    local TL_Corner = Instance.new("UICorner")
    TL_Corner.CornerRadius = UDim.new(0, 12)
    TL_Corner.Parent       = TabList

    local TL_Stroke = Instance.new("UIStroke")
    TL_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TL_Stroke.Color           = C.BorderLight
    TL_Stroke.Thickness       = 1
    TL_Stroke.Transparency    = 0.7
    TL_Stroke.Parent          = TabList

    local TL_Pad = Instance.new("UIPadding")
    TL_Pad.PaddingTop    = UDim.new(0, 12)
    TL_Pad.PaddingBottom = UDim.new(0, 12)
    TL_Pad.PaddingLeft   = UDim.new(0, 10)
    TL_Pad.PaddingRight  = UDim.new(0, 10)
    TL_Pad.Parent        = TabList

    local TL_List = Instance.new("UIListLayout")
    TL_List.SortOrder = Enum.SortOrder.LayoutOrder
    TL_List.Padding   = UDim.new(0, 4)
    TL_List.Parent    = TabList

    TL_List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TL_List.AbsoluteContentSize.Y + 24)
    end)

    -- ── Content Panel ─────────────────────────────────────────────────────────
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name                   = "ContentPanel"
    ContentPanel.Position               = UDim2.new(0.24, 0, 0, 0)
    ContentPanel.Size                   = UDim2.new(0.76, 0, 1, 0)
    ContentPanel.BackgroundColor3       = C.PanelBg
    ContentPanel.BackgroundTransparency = 0
    ContentPanel.BorderSizePixel        = 0
    ContentPanel.ClipsDescendants       = true
    ContentPanel.Parent                 = Anchor

    local CP_Corner = Instance.new("UICorner")
    CP_Corner.CornerRadius = UDim.new(0, 12)
    CP_Corner.Parent       = ContentPanel

    local CP_Stroke = Instance.new("UIStroke")
    CP_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    CP_Stroke.Color           = C.BorderLight
    CP_Stroke.Thickness       = 1
    CP_Stroke.Transparency    = 0.7
    CP_Stroke.Parent          = ContentPanel

    -- ── Title Bar ─────────────────────────────────────────────────────────────
    local TitleBar = Instance.new("Frame")
    TitleBar.Name                   = "TitleBar"
    TitleBar.Position               = UDim2.new(0, 0, 0, 0)
    TitleBar.Size                   = UDim2.new(1, 0, 0.11, 0)
    TitleBar.BackgroundColor3       = C.TitleBar
    TitleBar.BorderSizePixel        = 0
    TitleBar.Parent                 = ContentPanel

    local TB_Corner = Instance.new("UICorner")
    TB_Corner.CornerRadius = UDim.new(0, 12)
    TB_Corner.Parent       = TitleBar

    -- White bottom border on title bar
    local TB_Line = Instance.new("Frame")
    TB_Line.Name                   = "Divider"
    TB_Line.Position               = UDim2.new(0, 0, 1, -1)
    TB_Line.Size                   = UDim2.new(1, 0, 0, 1)
    TB_Line.BackgroundColor3       = C.White
    TB_Line.BackgroundTransparency = 0
    TB_Line.BorderSizePixel        = 0
    TB_Line.Parent                 = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name                  = "Title"
    TitleLabel.Position              = UDim2.new(0.02, 0, 0, 0)
    TitleLabel.Size                  = UDim2.new(0.85, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text                  = windowTitle
    TitleLabel.TextScaled            = false
    TitleLabel.TextSize              = 16
    TitleLabel.Font                  = Enum.Font.GothamBold
    TitleLabel.TextColor3            = C.White
    TitleLabel.TextXAlignment        = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment        = Enum.TextYAlignment.Center
    TitleLabel.Parent                = TitleBar

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name                   = "MinBtn"
    MinBtn.Position               = UDim2.new(1, -34, 0.25, 0)
    MinBtn.Size                   = UDim2.new(0, 22, 0, 22)
    MinBtn.BackgroundColor3       = C.Black
    MinBtn.BackgroundTransparency = 1
    MinBtn.BorderSizePixel        = 0
    MinBtn.Text                   = "–"
    MinBtn.TextSize               = 18
    MinBtn.Font                   = Enum.Font.GothamBold
    MinBtn.TextColor3             = Color3.fromRGB(90, 90, 105)
    MinBtn.Parent                 = TitleBar

    local MinBtn_Corner = Instance.new("UICorner")
    MinBtn_Corner.CornerRadius = UDim.new(0, 6)
    MinBtn_Corner.Parent       = MinBtn

    local MinBtn_Stroke = Instance.new("UIStroke")
    MinBtn_Stroke.Color       = Color3.fromRGB(70, 70, 70)
    MinBtn_Stroke.Thickness   = 1
    MinBtn_Stroke.Transparency = 0.2
    MinBtn_Stroke.Parent      = MinBtn

    -- ── Pages Container ───────────────────────────────────────────────────────
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name                   = "Pages"
    PagesContainer.Position               = UDim2.new(0.015, 0, 0.11, 0)
    PagesContainer.Size                   = UDim2.new(0.97, 0, 0.875, 0)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.BorderSizePixel        = 0
    PagesContainer.ClipsDescendants       = true
    PagesContainer.Parent                 = ContentPanel

    -- ── Mobile toggle ─────────────────────────────────────────────────────────
    if isMobile then
        local MobileBtn = Instance.new("TextButton")
        MobileBtn.Size                   = UDim2.new(0, 48, 0, 48)
        MobileBtn.Position               = UDim2.new(1, -60, 1, -60)
        MobileBtn.BackgroundColor3       = C.Black
        MobileBtn.BorderSizePixel        = 0
        MobileBtn.Text                   = "☰"
        MobileBtn.TextSize               = 20
        MobileBtn.Font                   = Enum.Font.GothamBold
        MobileBtn.TextColor3             = C.White
        MobileBtn.Parent                 = ScreenGui
        local MB_C = Instance.new("UICorner"); MB_C.CornerRadius = UDim.new(1, 0); MB_C.Parent = MobileBtn
        local MB_S = Instance.new("UIStroke"); MB_S.Color = C.BorderLight; MB_S.Thickness = 1; MB_S.Parent = MobileBtn
        MobileBtn.MouseButton1Click:Connect(function() Anchor.Visible = not Anchor.Visible end)
    end

    -- ── Dragging ──────────────────────────────────────────────────────────────
    local dragging, dragStart, anchorStart = false, nil, nil
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging    = true
            dragStart   = input.Position
            anchorStart = Anchor.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MinBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            Anchor.Position = UDim2.new(
                anchorStart.X.Scale, anchorStart.X.Offset + d.X,
                anchorStart.Y.Scale, anchorStart.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- ── Minimize ──────────────────────────────────────────────────────────────
    local minimized   = false
    local fullCPSize  = ContentPanel.Size

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tw(ContentPanel, { Size = UDim2.new(fullCPSize.X.Scale, 0, 0.11, 0) }, 0.2)
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
    local Window = { _tabs = {}, _tabCount = 0 }

    function Window:AddTab(tabName)
        Window._tabCount = Window._tabCount + 1
        local idx = Window._tabCount

        -- Tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name                   = tabName
        TabBtn.Size                   = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3       = C.Black
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel        = 0
        TabBtn.Text                   = tabName
        TabBtn.TextSize               = 12
        TabBtn.Font                   = Enum.Font.GothamMedium
        TabBtn.TextColor3             = Color3.fromRGB(115, 115, 115)
        TabBtn.TextXAlignment         = Enum.TextXAlignment.Center
        TabBtn.LayoutOrder            = idx
        TabBtn.Parent                 = TabList

        local TabBtn_Corner = Instance.new("UICorner")
        TabBtn_Corner.CornerRadius = UDim.new(0, 7)
        TabBtn_Corner.Parent       = TabBtn

        local TabBtn_Stroke = Instance.new("UIStroke")
        TabBtn_Stroke.Color       = C.BorderLight
        TabBtn_Stroke.Thickness   = 1
        TabBtn_Stroke.Transparency = 1   -- hidden when inactive
        TabBtn_Stroke.Parent      = TabBtn

        -- Page (scrolling)
        local Page = Instance.new("ScrollingFrame")
        Page.Name                   = "Page_" .. tabName
        Page.Size                   = UDim2.new(1, 0, 1, 0)
        Page.Position               = UDim2.new(0, 0, 0, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel        = 0
        Page.ClipsDescendants       = true
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness     = 3
        Page.ScrollingEnabled       = true
        Page.Visible                = false
        Page.Parent                 = PagesContainer

        local Page_Pad = Instance.new("UIPadding")
        Page_Pad.PaddingTop    = UDim.new(0, 10)
        Page_Pad.PaddingBottom = UDim.new(0, 10)
        Page_Pad.PaddingLeft   = UDim.new(0, 8)
        Page_Pad.PaddingRight  = UDim.new(0, 8)
        Page_Pad.Parent        = Page

        local Page_List = Instance.new("UIListLayout")
        Page_List.SortOrder = Enum.SortOrder.LayoutOrder
        Page_List.Padding   = UDim.new(0, 5)
        Page_List.Parent    = Page

        Page_List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Page_List.AbsoluteContentSize.Y + 20)
        end)

        -- First tab is active by default
        if idx == 1 then
            Page.Visible                = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3     = Color3.fromRGB(28, 28, 28)
            TabBtn.TextColor3           = C.White
            TabBtn_Stroke.Transparency  = 0.5
        end

        local function setActive()
            for _, t in ipairs(Window._tabs) do
                t.Page.Visible                = false
                t.Btn.BackgroundTransparency  = 1
                t.Btn.BackgroundColor3        = C.Black
                t.Btn.TextColor3              = Color3.fromRGB(115, 115, 115)
                t.BtnStroke.Transparency      = 1
            end
            Page.Visible                = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3     = Color3.fromRGB(28, 28, 28)
            TabBtn.TextColor3           = C.White
            TabBtn_Stroke.Transparency  = 0.5
        end

        TabBtn.MouseButton1Click:Connect(setActive)

        -- ── Internal helpers ──────────────────────────────────────────────────
        local Tab = { Page = Page, Btn = TabBtn, BtnStroke = TabBtn_Stroke, _count = 0 }
        table.insert(Window._tabs, Tab)

        local function makeRow(h)
            Tab._count = Tab._count + 1
            local Row = Instance.new("Frame")
            Row.Name                   = "Row_" .. Tab._count
            Row.Size                   = UDim2.new(1, 0, 0, h or 38)
            Row.BackgroundColor3       = C.RowBg
            Row.BackgroundTransparency = 0
            Row.BorderSizePixel        = 0
            Row.LayoutOrder            = Tab._count
            Row.ClipsDescendants       = false
            Row.Parent                 = Page

            local R_Corner = Instance.new("UICorner")
            R_Corner.CornerRadius = UDim.new(0, 8)
            R_Corner.Parent       = Row

            local R_Stroke = Instance.new("UIStroke")
            R_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            R_Stroke.Color           = C.BorderLight
            R_Stroke.Thickness       = 1
            R_Stroke.Transparency    = 0.6
            R_Stroke.Parent          = Row

            return Row
        end

        local function makeLabel(parent, text, xScale, wScale, size)
            local L = Instance.new("TextLabel")
            L.Position               = UDim2.new(xScale or 0.015, 0, 0, 0)
            L.Size                   = UDim2.new(wScale or 0.6, 0, 1, 0)
            L.BackgroundTransparency = 1
            L.Text                   = text
            L.TextScaled             = false
            L.TextSize               = size or 12
            L.Font                   = Enum.Font.GothamMedium
            L.TextColor3             = C.TextPrimary
            L.TextXAlignment         = Enum.TextXAlignment.Left
            L.TextYAlignment         = Enum.TextYAlignment.Center
            L.Parent                 = parent
            return L
        end

        -- ── AddLabel ──────────────────────────────────────────────────────────
        function Tab:AddLabel(text)
            local Row = makeRow(38)
            makeLabel(Row, text, 0.015, 0.97)
            return Row
        end

        -- ── AddSeparator ──────────────────────────────────────────────────────
        function Tab:AddSeparator()
            Tab._count = Tab._count + 1
            local Sep = Instance.new("Frame")
            Sep.Size             = UDim2.new(1, 0, 0, 1)
            Sep.BackgroundColor3 = C.BorderLight
            Sep.BackgroundTransparency = 0.5
            Sep.BorderSizePixel  = 0
            Sep.LayoutOrder      = Tab._count
            Sep.Parent           = Page
            return Sep
        end

        -- ── AddButton (full-row clickable) ────────────────────────────────────
        function Tab:AddButton(btnConfig)
            btnConfig = btnConfig or {}
            Tab._count = Tab._count + 1

            local Btn = Instance.new("TextButton")
            Btn.Name                   = "Btn_" .. Tab._count
            Btn.Size                   = UDim2.new(1, 0, 0, 38)
            Btn.BackgroundColor3       = C.RowBg
            Btn.BackgroundTransparency = 0
            Btn.BorderSizePixel        = 0
            Btn.AutoButtonColor        = false
            Btn.Text                   = ""
            Btn.LayoutOrder            = Tab._count
            Btn.ClipsDescendants       = false
            Btn.Parent                 = Page

            local Btn_Corner = Instance.new("UICorner")
            Btn_Corner.CornerRadius = UDim.new(0, 8)
            Btn_Corner.Parent       = Btn

            local Btn_Stroke = Instance.new("UIStroke")
            Btn_Stroke.Color       = C.BorderLight
            Btn_Stroke.Thickness   = 1
            Btn_Stroke.Transparency = 0.6
            Btn_Stroke.Parent      = Btn

            -- Name label
            local NameLbl = Instance.new("TextLabel")
            NameLbl.Position               = UDim2.new(0.015, 0, 0, 0)
            NameLbl.Size                   = UDim2.new(0.85, 0, 1, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text                   = btnConfig.Name or "Button"
            NameLbl.TextSize               = 12
            NameLbl.Font                   = Enum.Font.GothamMedium
            NameLbl.TextColor3             = C.TextPrimary
            NameLbl.TextXAlignment         = Enum.TextXAlignment.Left
            NameLbl.TextYAlignment         = Enum.TextYAlignment.Center
            NameLbl.Parent                 = Btn

            -- Arrow indicator
            local Arrow = Instance.new("TextLabel")
            Arrow.Position               = UDim2.new(1, -24, 0, 0)
            Arrow.Size                   = UDim2.new(0, 16, 1, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text                   = "▶"
            Arrow.TextSize               = 9
            Arrow.Font                   = Enum.Font.GothamMedium
            Arrow.TextColor3             = Color3.fromRGB(70, 70, 80)
            Arrow.TextXAlignment         = Enum.TextXAlignment.Center
            Arrow.TextYAlignment         = Enum.TextYAlignment.Center
            Arrow.Parent                 = Btn

            Btn.MouseEnter:Connect(function()
                tw(Btn, { BackgroundColor3 = C.RowBgHover }, 0.1)
                tw(Btn_Stroke, { Transparency = 0.3 }, 0.1)
                tw(Arrow, { TextColor3 = Color3.fromRGB(140, 140, 155) }, 0.1)
            end)
            Btn.MouseLeave:Connect(function()
                tw(Btn, { BackgroundColor3 = C.RowBg }, 0.1)
                tw(Btn_Stroke, { Transparency = 0.6 }, 0.1)
                tw(Arrow, { TextColor3 = Color3.fromRGB(70, 70, 80) }, 0.1)
            end)
            Btn.MouseButton1Click:Connect(function()
                tw(Btn, { BackgroundColor3 = Color3.fromRGB(30, 30, 40) }, 0.05)
                task.delay(0.12, function()
                    tw(Btn, { BackgroundColor3 = C.RowBg }, 0.1)
                end)
                if btnConfig.Callback then btnConfig.Callback() end
            end)

            return Btn
        end

        -- ── AddToggle ─────────────────────────────────────────────────────────
        function Tab:AddToggle(togConfig)
            togConfig = togConfig or {}
            local val = togConfig.Default == true
            local Row = makeRow(38)
            makeLabel(Row, togConfig.Name or "Toggle", 0.015, 0.65)

            local Pill = Instance.new("TextButton")
            Pill.Size              = UDim2.new(0, 40, 0, 20)
            Pill.Position          = UDim2.new(1, -50, 0.5, -10)
            Pill.BackgroundColor3  = val and C.PillOn or C.PillOff
            Pill.BorderSizePixel   = 0
            Pill.Text              = ""
            Pill.AutoButtonColor   = false
            Pill.Parent            = Row

            local Pill_Corner = Instance.new("UICorner")
            Pill_Corner.CornerRadius = UDim.new(1, 0)
            Pill_Corner.Parent       = Pill

            local Knob = Instance.new("Frame")
            Knob.Size             = UDim2.new(0, 14, 0, 14)
            Knob.BackgroundColor3 = C.White
            Knob.BorderSizePixel  = 0
            Knob.Position         = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            Knob.Parent           = Pill

            local Knob_Corner = Instance.new("UICorner")
            Knob_Corner.CornerRadius = UDim.new(1, 0)
            Knob_Corner.Parent       = Knob

            Pill.MouseButton1Click:Connect(function()
                val = not val
                tw(Pill, { BackgroundColor3 = val and C.PillOn or C.PillOff })
                tw(Knob, {
                    Position  = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = val and Color3.fromRGB(30, 30, 30) or C.White,
                })
                if togConfig.Callback then togConfig.Callback(val) end
            end)

            local obj = {}
            function obj:Set(v)
                val = v
                tw(Pill, { BackgroundColor3 = val and C.PillOn or C.PillOff })
                tw(Knob, { Position = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
                if togConfig.Callback then togConfig.Callback(val) end
            end
            function obj:Get() return val end
            return obj
        end

        -- ── AddSlider ─────────────────────────────────────────────────────────
        function Tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local minV = sliderConfig.Min     or 0
            local maxV = sliderConfig.Max     or 100
            local curV = sliderConfig.Default or minV
            local Row  = makeRow(54)

            -- Top row: name + value
            local TopRow = Instance.new("Frame")
            TopRow.Size               = UDim2.new(1, -28, 0, 22)
            TopRow.Position           = UDim2.new(0, 14, 0, 8)
            TopRow.BackgroundTransparency = 1
            TopRow.Parent             = Row

            local NameL = Instance.new("TextLabel")
            NameL.Size               = UDim2.new(0.7, 0, 1, 0)
            NameL.BackgroundTransparency = 1
            NameL.Text               = sliderConfig.Name or "Slider"
            NameL.TextSize           = 12
            NameL.Font               = Enum.Font.GothamMedium
            NameL.TextColor3         = C.TextPrimary
            NameL.TextXAlignment     = Enum.TextXAlignment.Left
            NameL.TextYAlignment     = Enum.TextYAlignment.Center
            NameL.Parent             = TopRow

            local ValL = Instance.new("TextLabel")
            ValL.Size               = UDim2.new(0.3, 0, 1, 0)
            ValL.Position           = UDim2.new(0.7, 0, 0, 0)
            ValL.BackgroundTransparency = 1
            ValL.Text               = tostring(curV)
            ValL.TextSize           = 11
            ValL.Font               = Enum.Font.GothamMedium
            ValL.TextColor3         = C.TextMuted
            ValL.TextXAlignment     = Enum.TextXAlignment.Right
            ValL.TextYAlignment     = Enum.TextYAlignment.Center
            ValL.Parent             = TopRow

            -- Track
            local Track = Instance.new("Frame")
            Track.Size             = UDim2.new(1, -28, 0, 4)
            Track.Position         = UDim2.new(0, 14, 1, -14)
            Track.BackgroundColor3 = C.TrackBg
            Track.BorderSizePixel  = 0
            Track.Parent           = Row

            local Track_Corner = Instance.new("UICorner")
            Track_Corner.CornerRadius = UDim.new(1, 0)
            Track_Corner.Parent       = Track

            local rel0 = (curV - minV) / (maxV - minV)
            local Fill = Instance.new("Frame")
            Fill.Size             = UDim2.new(rel0, 0, 1, 0)
            Fill.BackgroundColor3 = C.TrackFill
            Fill.BorderSizePixel  = 0
            Fill.Parent           = Track

            local Fill_Corner = Instance.new("UICorner")
            Fill_Corner.CornerRadius = UDim.new(1, 0)
            Fill_Corner.Parent       = Fill

            local Knob2 = Instance.new("Frame")
            Knob2.Size             = UDim2.new(0, 12, 0, 12)
            Knob2.BackgroundColor3 = C.White
            Knob2.BorderSizePixel  = 0
            Knob2.Position         = UDim2.new(rel0, -6, 0.5, -6)
            Knob2.Parent           = Track

            local Knob2_Corner = Instance.new("UICorner")
            Knob2_Corner.CornerRadius = UDim.new(1, 0)
            Knob2_Corner.Parent       = Knob2

            local sliding = false
            local function updateSlider(screenX)
                local rel = math.clamp((screenX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                curV = math.floor(minV + rel * (maxV - minV) + 0.5)
                rel  = (curV - minV) / (maxV - minV)
                Fill.Size      = UDim2.new(rel, 0, 1, 0)
                Knob2.Position = UDim2.new(rel, -6, 0.5, -6)
                ValL.Text      = tostring(curV)
                if sliderConfig.Callback then sliderConfig.Callback(curV) end
            end

            Track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true; updateSlider(i.Position.X)
                end
            end)
            Knob2.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)

            local obj = {}
            function obj:Set(v)
                curV = math.clamp(v, minV, maxV)
                local rel = (curV - minV) / (maxV - minV)
                Fill.Size      = UDim2.new(rel, 0, 1, 0)
                Knob2.Position = UDim2.new(rel, -6, 0.5, -6)
                ValL.Text      = tostring(curV)
            end
            function obj:Get() return curV end
            return obj
        end

        -- ── AddTextbox ────────────────────────────────────────────────────────
        function Tab:AddTextbox(tbConfig)
            tbConfig = tbConfig or {}
            local Row = makeRow(38)
            makeLabel(Row, tbConfig.Name or "Textbox", 0.015, 0.38)

            local Box = Instance.new("TextBox")
            Box.Position               = UDim2.new(0.4, 0, 0.12, 0)
            Box.Size                   = UDim2.new(0.57, 0, 0.76, 0)
            Box.BackgroundColor3       = Color3.fromRGB(8, 8, 8)
            Box.BackgroundTransparency = 0
            Box.BorderSizePixel        = 0
            Box.Text                   = tbConfig.Default or ""
            Box.PlaceholderText        = tbConfig.Placeholder or "..."
            Box.PlaceholderColor3      = C.TextMuted
            Box.TextScaled             = false
            Box.TextSize               = 12
            Box.Font                   = Enum.Font.GothamMedium
            Box.TextColor3             = C.White
            Box.TextXAlignment         = Enum.TextXAlignment.Center
            Box.ClearTextOnFocus       = tbConfig.ClearOnFocus ~= false
            Box.MultiLine              = false
            Box.Parent                 = Row

            local Box_Corner = Instance.new("UICorner")
            Box_Corner.CornerRadius = UDim.new(0, 7)
            Box_Corner.Parent       = Box

            local Box_Stroke = Instance.new("UIStroke")
            Box_Stroke.Color       = C.BorderLight
            Box_Stroke.Thickness   = 1
            Box_Stroke.Transparency = 0.5
            Box_Stroke.Parent      = Box

            Box.Focused:Connect(function()
                tw(Box_Stroke, { Transparency = 0 }, 0.1)
            end)
            Box.FocusLost:Connect(function(enter)
                tw(Box_Stroke, { Transparency = 0.5 }, 0.1)
                if tbConfig.Callback then tbConfig.Callback(Box.Text, enter) end
            end)
            return Box
        end

        -- ── AddDropdown ───────────────────────────────────────────────────────
        function Tab:AddDropdown(ddConfig)
            ddConfig  = ddConfig or {}
            local options  = ddConfig.Options or {}
            local selected = ddConfig.Default or (options[1] or "Select")
            local open     = false
            local Row      = makeRow(38)
            Row.ClipsDescendants = false

            makeLabel(Row, ddConfig.Name or "Dropdown", 0.015, 0.45)

            local DDBtn = Instance.new("TextButton")
            DDBtn.Position               = UDim2.new(0.47, 0, 0.12, 0)
            DDBtn.Size                   = UDim2.new(0.5, 0, 0.76, 0)
            DDBtn.BackgroundColor3       = Color3.fromRGB(8, 8, 8)
            DDBtn.BackgroundTransparency = 0
            DDBtn.BorderSizePixel        = 0
            DDBtn.Text                   = selected .. " ▾"
            DDBtn.TextScaled             = false
            DDBtn.TextSize               = 12
            DDBtn.Font                   = Enum.Font.GothamMedium
            DDBtn.TextColor3             = C.TextPrimary
            DDBtn.TextXAlignment         = Enum.TextXAlignment.Center
            DDBtn.AutoButtonColor        = false
            DDBtn.Parent                 = Row

            local DD_Corner = Instance.new("UICorner")
            DD_Corner.CornerRadius = UDim.new(0, 7)
            DD_Corner.Parent       = DDBtn

            local DD_Stroke = Instance.new("UIStroke")
            DD_Stroke.Color       = C.BorderLight
            DD_Stroke.Thickness   = 1
            DD_Stroke.Transparency = 0.5
            DD_Stroke.Parent      = DDBtn

            -- Dropdown list
            local ListH = math.min(#options, 5) * 28
            local ListFrame = Instance.new("ScrollingFrame")
            ListFrame.ZIndex             = 5
            ListFrame.Size               = UDim2.new(0.5, 0, 0, ListH)
            ListFrame.Position           = UDim2.new(0.47, 0, 1, 5)
            ListFrame.BackgroundColor3   = Color3.fromRGB(14, 14, 14)
            ListFrame.BorderSizePixel    = 0
            ListFrame.ClipsDescendants   = true
            ListFrame.ScrollBarThickness = 2
            ListFrame.CanvasSize         = UDim2.new(0, 0, 0, #options * 28)
            ListFrame.Visible            = false
            ListFrame.Parent             = Row

            local LF_Corner = Instance.new("UICorner")
            LF_Corner.CornerRadius = UDim.new(0, 8)
            LF_Corner.Parent       = ListFrame

            local LF_Stroke = Instance.new("UIStroke")
            LF_Stroke.Color       = C.BorderLight
            LF_Stroke.Thickness   = 1
            LF_Stroke.Transparency = 0.4
            LF_Stroke.Parent      = ListFrame

            local LF_List = Instance.new("UIListLayout")
            LF_List.SortOrder = Enum.SortOrder.LayoutOrder
            LF_List.Parent    = ListFrame

            for i, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.ZIndex                 = 6
                OptBtn.Size                   = UDim2.new(1, 0, 0, 28)
                OptBtn.BackgroundColor3       = Color3.fromRGB(14, 14, 14)
                OptBtn.BackgroundTransparency = 0
                OptBtn.BorderSizePixel        = 0
                OptBtn.Text                   = opt
                OptBtn.TextScaled             = false
                OptBtn.TextSize               = 12
                OptBtn.Font                   = Enum.Font.GothamMedium
                OptBtn.TextColor3             = opt == selected and C.White or C.TextMuted
                OptBtn.AutoButtonColor        = false
                OptBtn.LayoutOrder            = i
                OptBtn.Parent                 = ListFrame

                OptBtn.MouseEnter:Connect(function()
                    tw(OptBtn, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }, 0.08)
                    tw(OptBtn, { TextColor3 = C.White }, 0.08)
                end)
                OptBtn.MouseLeave:Connect(function()
                    tw(OptBtn, { BackgroundColor3 = Color3.fromRGB(14, 14, 14) }, 0.08)
                    if opt ~= selected then
                        tw(OptBtn, { TextColor3 = C.TextMuted }, 0.08)
                    end
                end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected          = opt
                    DDBtn.Text        = opt .. " ▾"
                    open              = false
                    ListFrame.Visible = false
                    if ddConfig.Callback then ddConfig.Callback(opt) end
                end)
            end

            DDBtn.MouseButton1Click:Connect(function()
                open              = not open
                ListFrame.Visible = open
            end)

            local obj = {}
            function obj:Get() return selected end
            function obj:Set(v)
                selected   = v
                DDBtn.Text = v .. " ▾"
            end
            return obj
        end

        -- ── AddColorPicker ────────────────────────────────────────────────────
        --   Returns an object with :Get() → Color3, :Set(Color3)
        function Tab:AddColorPicker(cpConfig)
            cpConfig = cpConfig or {}
            local defaultColor = cpConfig.Default or Color3.fromRGB(255, 255, 255)
            local r = math.floor(defaultColor.R * 255)
            local g = math.floor(defaultColor.G * 255)
            local b = math.floor(defaultColor.B * 255)

            local Row = makeRow(38)
            Row.ClipsDescendants = false
            makeLabel(Row, cpConfig.Name or "Color", 0.015, 0.5)

            -- Color swatch button
            local Swatch = Instance.new("TextButton")
            Swatch.Position               = UDim2.new(1, -90, 0.5, -10)
            Swatch.Size                   = UDim2.new(0, 28, 0, 20)
            Swatch.BackgroundColor3       = defaultColor
            Swatch.BorderSizePixel        = 0
            Swatch.Text                   = ""
            Swatch.AutoButtonColor        = false
            Swatch.Parent                 = Row

            local Sw_Corner = Instance.new("UICorner")
            Sw_Corner.CornerRadius = UDim.new(0, 5)
            Sw_Corner.Parent       = Swatch

            local Sw_Stroke = Instance.new("UIStroke")
            Sw_Stroke.Color       = C.BorderLight
            Sw_Stroke.Thickness   = 1
            Sw_Stroke.Transparency = 0.3
            Sw_Stroke.Parent      = Swatch

            -- Hex label next to swatch
            local HexLbl = Instance.new("TextLabel")
            HexLbl.Position               = UDim2.new(1, -58, 0.5, -9)
            HexLbl.Size                   = UDim2.new(0, 56, 0, 18)
            HexLbl.BackgroundTransparency = 1
            HexLbl.Text                   = string.format("#%02X%02X%02X", r, g, b)
            HexLbl.TextScaled             = false
            HexLbl.TextSize               = 10
            HexLbl.Font                   = Enum.Font.GothamMedium
            HexLbl.TextColor3             = C.TextMuted
            HexLbl.TextXAlignment         = Enum.TextXAlignment.Left
            HexLbl.TextYAlignment         = Enum.TextYAlignment.Center
            HexLbl.Parent                 = Row

            -- Popover frame
            local Pop = Instance.new("Frame")
            Pop.ZIndex                 = 10
            Pop.Size                   = UDim2.new(0, 180, 0, 170)
            Pop.Position               = UDim2.new(1, -182, 1, 6)
            Pop.BackgroundColor3       = Color3.fromRGB(14, 14, 14)
            Pop.BorderSizePixel        = 0
            Pop.ClipsDescendants       = false
            Pop.Visible                = false
            Pop.Parent                 = Row

            local Pop_Corner = Instance.new("UICorner")
            Pop_Corner.CornerRadius = UDim.new(0, 10)
            Pop_Corner.Parent       = Pop

            local Pop_Stroke = Instance.new("UIStroke")
            Pop_Stroke.Color       = C.BorderLight
            Pop_Stroke.Thickness   = 1
            Pop_Stroke.Transparency = 0.3
            Pop_Stroke.Parent      = Pop

            -- Saturation/Value canvas (ImageLabel gradient trick)
            local Canvas = Instance.new("ImageLabel")
            Canvas.Position               = UDim2.new(0, 8, 0, 8)
            Canvas.Size                   = UDim2.new(1, -16, 0, 100)
            Canvas.BackgroundColor3       = Color3.fromHSV(0, 1, 1)
            Canvas.BorderSizePixel        = 0
            Canvas.Image                  = "rbxassetid://4155801252"  -- white→transparent left-right
            Canvas.Parent                 = Pop

            local CV_Corner = Instance.new("UICorner")
            CV_Corner.CornerRadius = UDim.new(0, 6)
            CV_Corner.Parent       = Canvas

            -- Dark overlay (top transparent → bottom black)
            local DarkOverlay = Instance.new("ImageLabel")
            DarkOverlay.Size              = UDim2.new(1, 0, 1, 0)
            DarkOverlay.BackgroundTransparency = 1
            DarkOverlay.Image             = "rbxassetid://4155801252"
            DarkOverlay.ImageColor3       = Color3.fromRGB(0, 0, 0)
            DarkOverlay.Rotation          = 90
            DarkOverlay.Parent            = Canvas

            -- Canvas cursor
            local CanvasCursor = Instance.new("Frame")
            CanvasCursor.Size             = UDim2.new(0, 10, 0, 10)
            CanvasCursor.BackgroundColor3 = C.White
            CanvasCursor.BorderSizePixel  = 0
            CanvasCursor.Position         = UDim2.new(1, -5, 0, -5)
            CanvasCursor.ZIndex           = 11
            CanvasCursor.Parent           = Canvas

            local CC_Corner = Instance.new("UICorner")
            CC_Corner.CornerRadius = UDim.new(1, 0)
            CC_Corner.Parent       = CanvasCursor

            local CC_Stroke = Instance.new("UIStroke")
            CC_Stroke.Color     = C.Black
            CC_Stroke.Thickness = 1
            CC_Stroke.Parent    = CanvasCursor

            -- Hue bar
            local HueBar = Instance.new("ImageLabel")
            HueBar.Position = UDim2.new(0, 8, 0, 114)
            HueBar.Size     = UDim2.new(1, -16, 0, 10)
            HueBar.Image    = "rbxassetid://4155801252"  -- hue gradient approximation
            HueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            HueBar.BorderSizePixel  = 0
            -- Use a rainbow gradient image; Roblox doesn't have one built-in so we
            -- tile UIGradient across the bar
            HueBar.BackgroundTransparency = 1
            HueBar.Parent = Pop

            local HB_Corner = Instance.new("UICorner")
            HB_Corner.CornerRadius = UDim.new(1, 0)
            HB_Corner.Parent       = HueBar

            local HueGrad = Instance.new("UIGradient")
            HueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,   1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1, 1)),
                ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50,1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1, 1)),
                ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,   1, 1)),
            })
            HueGrad.Parent = HueBar

            -- Hue knob
            local HueKnob = Instance.new("Frame")
            HueKnob.Size             = UDim2.new(0, 12, 0, 12)
            HueKnob.BackgroundColor3 = C.White
            HueKnob.BorderSizePixel  = 0
            HueKnob.Position         = UDim2.new(0, -6, 0.5, -6)
            HueKnob.ZIndex           = 11
            HueKnob.Parent           = HueBar

            local HK_Corner = Instance.new("UICorner")
            HK_Corner.CornerRadius = UDim.new(1, 0)
            HK_Corner.Parent       = HueKnob

            local HK_Stroke = Instance.new("UIStroke")
            HK_Stroke.Color     = C.Black
            HK_Stroke.Thickness = 1
            HK_Stroke.Parent    = HueKnob

            -- RGB inputs
            local InputRow = Instance.new("Frame")
            InputRow.Position               = UDim2.new(0, 8, 0, 132)
            InputRow.Size                   = UDim2.new(1, -16, 0, 28)
            InputRow.BackgroundTransparency = 1
            InputRow.Parent                 = Pop

            local IR_List = Instance.new("UIListLayout")
            IR_List.FillDirection = Enum.FillDirection.Horizontal
            IR_List.SortOrder     = Enum.SortOrder.LayoutOrder
            IR_List.Padding       = UDim.new(0, 4)
            IR_List.Parent        = InputRow

            local function makeInput(lbl, val, order)
                local F = Instance.new("Frame")
                F.Size               = UDim2.new(0.3, -3, 1, 0)
                F.BackgroundColor3   = Color3.fromRGB(8, 8, 8)
                F.BackgroundTransparency = 0
                F.BorderSizePixel    = 0
                F.LayoutOrder        = order
                F.Parent             = InputRow

                local FC = Instance.new("UICorner")
                FC.CornerRadius = UDim.new(0, 5)
                FC.Parent       = F

                local FS = Instance.new("UIStroke")
                FS.Color       = C.BorderLight
                FS.Thickness   = 1
                FS.Transparency = 0.5
                FS.Parent      = F

                local TB = Instance.new("TextBox")
                TB.Size               = UDim2.new(1, 0, 1, 0)
                TB.BackgroundTransparency = 1
                TB.Text               = tostring(val)
                TB.TextScaled         = false
                TB.TextSize           = 11
                TB.Font               = Enum.Font.GothamMedium
                TB.TextColor3         = C.TextPrimary
                TB.TextXAlignment     = Enum.TextXAlignment.Center
                TB.ClearTextOnFocus   = true
                TB.PlaceholderText    = lbl
                TB.PlaceholderColor3  = C.TextMuted
                TB.Parent             = F
                return TB
            end

            local RIn = makeInput("R", r, 1)
            local GIn = makeInput("G", g, 2)
            local BIn = makeInput("B", b, 3)

            -- Internal state
            local hue, sat, val2 = Color3.toHSV(defaultColor)
            local currentColor = defaultColor

            local function updateFromHSV()
                currentColor = Color3.fromHSV(hue, sat, val2)
                local nr = math.floor(currentColor.R * 255)
                local ng = math.floor(currentColor.G * 255)
                local nb = math.floor(currentColor.B * 255)
                Swatch.BackgroundColor3 = currentColor
                HexLbl.Text = string.format("#%02X%02X%02X", nr, ng, nb)
                RIn.Text = tostring(nr)
                GIn.Text = tostring(ng)
                BIn.Text = tostring(nb)
                Canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                -- Cursor position: sat = X, 1-val = Y
                CanvasCursor.Position = UDim2.new(sat, -5, 1 - val2, -5)
                -- Hue knob position
                HueKnob.Position = UDim2.new(hue, -6, 0.5, -6)
                if cpConfig.Callback then cpConfig.Callback(currentColor) end
            end

            -- Canvas drag
            local draggingCanvas = false
            Canvas.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    draggingCanvas = true
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingCanvas and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    local ap = Canvas.AbsolutePosition
                    local as = Canvas.AbsoluteSize
                    sat  = math.clamp((input.Position.X - ap.X) / as.X, 0, 1)
                    val2 = 1 - math.clamp((input.Position.Y - ap.Y) / as.Y, 0, 1)
                    updateFromHSV()
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    draggingCanvas = false
                end
            end)

            -- Hue bar drag
            local draggingHue = false
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    hue = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                    updateFromHSV()
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = false
                end
            end)

            -- RGB input
            local function onRGBInput()
                local nr = math.clamp(tonumber(RIn.Text) or 0, 0, 255)
                local ng = math.clamp(tonumber(GIn.Text) or 0, 0, 255)
                local nb = math.clamp(tonumber(BIn.Text) or 0, 0, 255)
                local c  = Color3.fromRGB(nr, ng, nb)
                hue, sat, val2 = Color3.toHSV(c)
                currentColor = c
                Swatch.BackgroundColor3 = c
                HexLbl.Text = string.format("#%02X%02X%02X", nr, ng, nb)
                Canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                CanvasCursor.Position   = UDim2.new(sat, -5, 1 - val2, -5)
                HueKnob.Position        = UDim2.new(hue, -6, 0.5, -6)
                if cpConfig.Callback then cpConfig.Callback(currentColor) end
            end
            RIn.FocusLost:Connect(onRGBInput)
            GIn.FocusLost:Connect(onRGBInput)
            BIn.FocusLost:Connect(onRGBInput)

            -- Toggle popover
            Swatch.MouseButton1Click:Connect(function()
                Pop.Visible = not Pop.Visible
            end)

            -- init cursor
            CanvasCursor.Position = UDim2.new(sat, -5, 1 - val2, -5)
            HueKnob.Position      = UDim2.new(hue, -6, 0.5, -6)
            Canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

            local obj = {}
            function obj:Get() return currentColor end
            function obj:Set(c)
                hue, sat, val2 = Color3.toHSV(c)
                currentColor = c
                updateFromHSV()
            end
            return obj
        end

        return Tab
    end

    function Window:SetTitle(t) TitleLabel.Text = t end
    function Window:Destroy()   ScreenGui:Destroy() end

    return Window
end

return OxenLib
