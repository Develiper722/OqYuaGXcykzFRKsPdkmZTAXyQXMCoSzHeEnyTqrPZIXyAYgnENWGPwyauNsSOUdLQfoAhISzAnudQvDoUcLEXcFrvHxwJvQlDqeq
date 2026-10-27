
-- Custom UI Library (WindUI-compatible API)
-- Version 1.0

local UILib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

-- Utility Functions
local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Create Window
function UILib:CreateWindow(config)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil

    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomUI_" .. math.random(1000, 9999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Try CoreGui first, fallback to PlayerGui
    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = LP:WaitForChild("PlayerGui")
    end

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = config.Size or UDim2.fromOffset(550, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = config.Title or "UI Library"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.fromOffset(30, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, -50)
    TabContainer.Position = UDim2.new(0, 5, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabContainer

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingRight = UDim.new(0, 5)
    TabPadding.Parent = TabContainer

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -135, 1, -50)
    ContentContainer.Position = UDim2.new(0, 130, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame

    MakeDraggable(MainFrame, TitleBar)

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentContainer = ContentContainer

    function Window:Tab(config)
        local Tab = {}
        Tab.Elements = {}

        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.Text = config.Title or "Tab"
        TabButton.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.Gotham
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabContainer

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 4)
        TabButtonCorner.Parent = TabButton

        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = config.Title
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                tab.Button.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            end
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            Window.CurrentTab = Tab
        end)

        Tab.Button = TabButton
        Tab.Content = TabContent
        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            TabButton.MouseButton1Click:Fire()
        end

        function Tab:Section(config)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, 0, 0, 25)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = config.Title or "Section"
            SectionLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
            SectionLabel.TextSize = 14
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = TabContent

            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingLeft = UDim.new(0, 5)
            SectionPadding.Parent = SectionLabel
        end

        function Tab:Toggle(config)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = config.Title or "Toggle"
            ToggleLabel.TextColor3 = Color3.new(1, 1, 1)
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.fromOffset(40, 20)
            ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            ToggleButton.BackgroundColor3 = config.Value and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 65)
            ToggleButton.Text = ""
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Parent = ToggleFrame

            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
            ToggleButtonCorner.Parent = ToggleButton

            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.fromOffset(16, 16)
            ToggleCircle.Position = config.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            ToggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = ToggleCircle

            local toggled = config.Value or false

            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                Tween(ToggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                Tween(ToggleButton, {BackgroundColor3 = toggled and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 65)}, 0.2)
                if config.Callback then
                    config.Callback(toggled)
                end
            end)
        end

        function Tab:Button(config)
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
            ButtonFrame.Text = config.Title or "Button"
            ButtonFrame.TextColor3 = Color3.new(1, 1, 1)
            ButtonFrame.TextSize = 13
            ButtonFrame.Font = Enum.Font.GothamBold
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = TabContent

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame

            ButtonFrame.MouseButton1Click:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(40, 100, 180)}, 0.1)
                task.wait(0.1)
                Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(50, 120, 200)}, 0.1)
                if config.Callback then
                    config.Callback()
                end
            end)
        end

        function Tab:Slider(config)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -10, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = config.Title or "Slider"
            SliderLabel.TextColor3 = Color3.new(1, 1, 1)
            SliderLabel.TextSize = 13
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame

            local SliderValue = Instance.new("TextLabel")
            SliderValue.Size = UDim2.new(0, 60, 0, 20)
            SliderValue.Position = UDim2.new(1, -70, 0, 5)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(config.Value.Default or 0)
            SliderValue.TextColor3 = Color3.fromRGB(150, 150, 255)
            SliderValue.TextSize = 12
            SliderValue.Font = Enum.Font.GothamBold
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = SliderFrame

            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            SliderBar.Position = UDim2.new(0, 10, 1, -15)
            SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame

            local SliderBarCorner = Instance.new("UICorner")
            SliderBarCorner.CornerRadius = UDim.new(1, 0)
            SliderBarCorner.Parent = SliderBar

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new(0, 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar

            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill

            local minVal = config.Value.Min or 0
            local maxVal = config.Value.Max or 100
            local defaultVal = config.Value.Default or minVal
            local step = config.Step or 1

            local function UpdateSlider(value)
                value = math.clamp(value, minVal, maxVal)
                value = math.floor(value / step + 0.5) * step
                local percent = (value - minVal) / (maxVal - minVal)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                SliderValue.Text = tostring(value)
                if config.Callback then
                    config.Callback(value)
                end
            end

            local dragging = false

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local pos = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                    local value = minVal + (maxVal - minVal) * math.clamp(pos, 0, 1)
                    UpdateSlider(value)
                end
            end)

            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                    local value = minVal + (maxVal - minVal) * math.clamp(pos, 0, 1)
                    UpdateSlider(value)
                end
            end)

            UpdateSlider(defaultVal)
        end

        function Tab:Input(config)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, 35)
            InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            InputFrame.BorderSizePixel = 0
            InputFrame.Parent = TabContent

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 6)
            InputCorner.Parent = InputFrame

            local InputLabel = Instance.new("TextLabel")
            InputLabel.Size = UDim2.new(0, 100, 1, 0)
            InputLabel.Position = UDim2.new(0, 10, 0, 0)
            InputLabel.BackgroundTransparency = 1
            InputLabel.Text = config.Title or "Input"
            InputLabel.TextColor3 = Color3.new(1, 1, 1)
            InputLabel.TextSize = 13
            InputLabel.Font = Enum.Font.Gotham
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.Parent = InputFrame

            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(1, -120, 0, 25)
            InputBox.Position = UDim2.new(0, 110, 0.5, -12.5)
            InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            InputBox.PlaceholderText = config.Placeholder or "Enter value..."
            InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            InputBox.Text = ""
            InputBox.TextColor3 = Color3.new(1, 1, 1)
            InputBox.TextSize = 12
            InputBox.Font = Enum.Font.Gotham
            InputBox.BorderSizePixel = 0
            InputBox.ClearTextOnFocus = false
            InputBox.Parent = InputFrame

            local InputBoxCorner = Instance.new("UICorner")
            InputBoxCorner.CornerRadius = UDim.new(0, 4)
            InputBoxCorner.Parent = InputBox

            InputBox.FocusLost:Connect(function(enter)
                if enter and config.Callback then
                    config.Callback(InputBox.Text)
                end
            end)
        end

        function Tab:Dropdown(config)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            DropdownFrame.ClipsDescendants = true

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(0.5, -10, 0, 35)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = config.Title or "Dropdown"
            DropdownLabel.TextColor3 = Color3.new(1, 1, 1)
            DropdownLabel.TextSize = 13
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame

            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(0.5, -20, 0, 25)
            DropdownButton.Position = UDim2.new(0.5, 5, 0, 5)
            DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            DropdownButton.Text = config.Value or "Select..."
            DropdownButton.TextColor3 = Color3.new(1, 1, 1)
            DropdownButton.TextSize = 12
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Parent = DropdownFrame

            local DropdownButtonCorner = Instance.new("UICorner")
            DropdownButtonCorner.CornerRadius = UDim.new(0, 4)
            DropdownButtonCorner.Parent = DropdownButton

            local DropdownList = Instance.new("Frame")
            DropdownList.Size = UDim2.new(1, -20, 0, 0)
            DropdownList.Position = UDim2.new(0, 10, 0, 40)
            DropdownList.BackgroundTransparency = 1
            DropdownList.BorderSizePixel = 0
            DropdownList.Visible = false
            DropdownList.Parent = DropdownFrame

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = DropdownList

            local isOpen = false

            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                DropdownList.Visible = isOpen
                local newSize = isOpen and (35 + #(config.Values or {}) * 27 + (#(config.Values or {}) - 1) * 2) or 35
                Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, newSize)}, 0.2)
            end)

            for _, value in ipairs(config.Values or {}) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 25)
                OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                OptionButton.Text = value
                OptionButton.TextColor3 = Color3.new(1, 1, 1)
                OptionButton.TextSize = 11
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.BorderSizePixel = 0
                OptionButton.Parent = DropdownList

                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionButton

                OptionButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = value
                    isOpen = false
                    DropdownList.Visible = false
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
                    if config.Callback then
                        config.Callback(value)
                    end
                end)
            end
        end

        function Tab:Keybind(config)
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Size = UDim2.new(1, 0, 0, 35)
            KeybindFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Parent = TabContent

            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 6)
            KeybindCorner.Parent = KeybindFrame

            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Size = UDim2.new(0.6, -10, 1, 0)
            KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Text = config.Title or "Keybind"
            KeybindLabel.TextColor3 = Color3.new(1, 1, 1)
            KeybindLabel.TextSize = 13
            KeybindLabel.Font = Enum.Font.Gotham
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeybindLabel.Parent = KeybindFrame

            local KeybindButton = Instance.new("TextButton")
            KeybindButton.Size = UDim2.new(0.4, -20, 0, 25)
            KeybindButton.Position = UDim2.new(0.6, 5, 0.5, -12.5)
            KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            KeybindButton.Text = config.Value or "None"
            KeybindButton.TextColor3 = Color3.new(1, 1, 1)
            KeybindButton.TextSize = 12
            KeybindButton.Font = Enum.Font.Gotham
            KeybindButton.BorderSizePixel = 0
            KeybindButton.Parent = KeybindFrame

            local KeybindButtonCorner = Instance.new("UICorner")
            KeybindButtonCorner.CornerRadius = UDim.new(0, 4)
            KeybindButtonCorner.Parent = KeybindButton

            local currentKey = config.Value
            local listening = false

            KeybindButton.MouseButton1Click:Connect(function()
                listening = true
                KeybindButton.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening then
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        currentKey = input.KeyCode.Name
                        KeybindButton.Text = currentKey
                        listening = false
                    end
                end
                if not gpe and currentKey and input.KeyCode.Name == currentKey then
                    if config.Callback then
                        config.Callback()
                    end
                end
            end)
        end

        return Tab
    end

    function Window:Toggle()
        MainFrame.Visible = not MainFrame.Visible
    end

    return Window
end

function UILib:Notify(config)
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "Notification"
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local success = pcall(function()
        NotifGui.Parent = CoreGui
    end)
    if not success then
        NotifGui.Parent = LP:WaitForChild("PlayerGui")
    end

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.fromOffset(300, 80)
    NotifFrame.Position = UDim2.new(1, -310, 1, 100)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifGui

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = NotifFrame

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -10, 0, 25)
    NotifTitle.Position = UDim2.new(0, 10, 0, 5)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = config.Title or "Notification"
    NotifTitle.TextColor3 = Color3.new(1, 1, 1)
    NotifTitle.TextSize = 14
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = NotifFrame

    local NotifContent = Instance.new("TextLabel")
    NotifContent.Size = UDim2.new(1, -10, 1, -35)
    NotifContent.Position = UDim2.new(0, 10, 0, 30)
    NotifContent.BackgroundTransparency = 1
    NotifContent.Text = config.Content or ""
    NotifContent.TextColor3 = Color3.fromRGB(200, 200, 200)
    NotifContent.TextSize = 12
    NotifContent.Font = Enum.Font.Gotham
    NotifContent.TextXAlignment = Enum.TextXAlignment.Left
    NotifContent.TextYAlignment = Enum.TextYAlignment.Top
    NotifContent.TextWrapped = true
    NotifContent.Parent = NotifFrame

    Tween(NotifFrame, {Position = UDim2.new(1, -310, 1, -90)}, 0.3)

    task.delay(config.Duration or 3, function()
        Tween(NotifFrame, {Position = UDim2.new(1, -310, 1, 100)}, 0.3)
        task.wait(0.3)
        NotifGui:Destroy()
    end)
end

return UILib
