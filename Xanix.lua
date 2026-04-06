-- Oxen UI Library (ModuleScript)
-- Clean Rayfield-style UI system

local Oxen = {}
Oxen.__index = Oxen

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- =========================
-- Blur (Acrylic Effect)
-- =========================
local function createBlur()
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = Lighting

	TweenService:Create(blur, TweenInfo.new(0.4), {Size = 18}):Play()
	return blur
end

-- =========================
-- Window
-- =========================
function Oxen:CreateWindow(config)
	local UI = {}

	-- ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "OxenUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Main Frame
	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0, 650, 0, 420)
	Main.Position = UDim2.new(0.5, -325, 0.5, -210)
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Main.Parent = ScreenGui
	Main.ClipsDescendants = true

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 14)
	Corner.Parent = Main

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(60, 60, 60)
	Stroke.Thickness = 1
	Stroke.Parent = Main

	createBlur()

	-- Top Bar
	local Top = Instance.new("Frame")
	Top.Size = UDim2.new(1, 0, 0, 40)
	Top.BackgroundTransparency = 1
	Top.Parent = Main

	local Title = Instance.new("TextLabel")
	Title.Text = config.Name or "Oxen UI"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextColor3 = Color3.fromRGB(255,255,255)
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 15, 0, 8)
	Title.Parent = Top

	-- Search Bar
	local Search = Instance.new("TextBox")
	Search.PlaceholderText = "Search..."
	Search.Size = UDim2.new(0, 180, 0, 28)
	Search.Position = UDim2.new(1, -200, 0, 6)
	Search.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Search.TextColor3 = Color3.fromRGB(255,255,255)
	Search.Font = Enum.Font.Gotham
	Search.TextSize = 14
	Search.Parent = Top

	Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 6)

	-- Sidebar
	local Side = Instance.new("Frame")
	Side.Size = UDim2.new(0, 140, 1, -50)
	Side.Position = UDim2.new(0, 10, 0, 45)
	Side.BackgroundTransparency = 1
	Side.Parent = Main

	local TabHolder = Instance.new("UIListLayout")
	TabHolder.Padding = UDim.new(0, 8)
	TabHolder.Parent = Side

	UI.Tabs = {}

	-- Content Holder
	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -160, 1, -55)
	Content.Position = UDim2.new(0, 150, 0, 45)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	-- =========================
	-- Tab System
	-- =========================
	function UI:CreateTab(name)
		local Tab = {}

		local Button = Instance.new("TextButton")
		Button.Size = UDim2.new(1, 0, 0, 35)
		Button.Text = name
		Button.Font = Enum.Font.Gotham
		Button.TextSize = 14
		Button.TextColor3 = Color3.fromRGB(255,255,255)
		Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
		Button.Parent = Side

		Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.ScrollBarThickness = 2
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.Parent = Content

		local Layout = Instance.new("UIListLayout")
		Layout.Padding = UDim.new(0, 8)
		Layout.Parent = Page

		Button.MouseButton1Click:Connect(function()
			for _, v in pairs(Content:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			Page.Visible = true
		end)

		-- Toggle
		function Tab:CreateToggle(text, callback)
			local Toggle = Instance.new("TextButton")
			Toggle.Size = UDim2.new(1, -10, 0, 35)
			Toggle.Text = text
			Toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
			Toggle.TextColor3 = Color3.fromRGB(255,255,255)
			Toggle.Parent = Page

			Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

			local state = false
			Toggle.MouseButton1Click:Connect(function()
				state = not state
				callback(state)
			end)
		end

		-- Slider
		function Tab:CreateSlider(text, min, max, callback)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, -10, 0, 50)
			SliderFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
			SliderFrame.Parent = Page

			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

			local Label = Instance.new("TextLabel")
			Label.Text = text
			Label.Size = UDim2.new(1, -10, 0, 20)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Color3.fromRGB(255,255,255)
			Label.Parent = SliderFrame

			local Bar = Instance.new("Frame")
			Bar.Size = UDim2.new(1, -20, 0, 6)
			Bar.Position = UDim2.new(0, 10, 0, 30)
			Bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
			Bar.Parent = SliderFrame

			Instance.new("UICorner", Bar)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new(0, 0, 1, 0)
			Fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Fill.Parent = Bar

			local dragging = false

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging then
					local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					Fill.Size = UDim2.new(pos, 0, 1, 0)
					callback(math.floor(min + (max - min) * pos))
				end
			end)
		end

		-- Dropdown (simple)
		function Tab:CreateDropdown(text, options, callback)
			local Drop = Instance.new("TextButton")
			Drop.Size = UDim2.new(1, -10, 0, 35)
			Drop.Text = text
			Drop.BackgroundColor3 = Color3.fromRGB(30,30,30)
			Drop.TextColor3 = Color3.fromRGB(255,255,255)
			Drop.Parent = Page

			Instance.new("UICorner", Drop).CornerRadius = UDim.new(0, 8)

			Drop.MouseButton1Click:Connect(function()
				local chosen = options[1]
				callback(chosen)
			end)
		end

		-- Keybind
		function Tab:CreateKeybind(text, callback)
			local Key = Instance.new("TextButton")
			Key.Size = UDim2.new(1, -10, 0, 35)
			Key.Text = text .. " [None]"
			Key.BackgroundColor3 = Color3.fromRGB(30,30,30)
			Key.TextColor3 = Color3.fromRGB(255,255,255)
			Key.Parent = Page

			local bound = nil

			Key.MouseButton1Click:Connect(function()
				local conn
				conn = UserInputService.InputBegan:Connect(function(input)
					bound = input.KeyCode
					Key.Text = text .. " [" .. tostring(bound.Name) .. "]"
					callback(bound)
					conn:Disconnect()
				end)
			end)
		end

		return Tab
	end

	return UI
end

return Oxen
