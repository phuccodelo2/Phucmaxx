--UI mới 
--// UI Hoàn Chỉnh PHUCMAX Hub
local UserInputService = game:GetService("UserInputService")

-- Gui chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PHUC_UI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Khung chính
local MainFrame = Instance.new("ImageLabel")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundTransparency = 1
MainFrame.Image = "rbxassetid://INSERT_IMAGE_ID_HERE" -- 👈 Thay ID ảnh tím
MainFrame.ScaleType = Enum.ScaleType.Stretch
MainFrame.Parent = ScreenGui

-- Viền
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(200, 180, 255)
UIStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(40, 20, 70)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌙 PHUCMAX | by phucmax"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Nút Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 150)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn)

-- Nút Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 90)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn)

-- Tab bar bên trái
local TabBar = Instance.new("ScrollingFrame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 120, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
TabBar.ScrollBarThickness = 4
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabBar
TabLayout.Padding = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Khung nội dung
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
ContentFrame.Parent = MainFrame
Instance.new("UICorner", ContentFrame)

-- Function tạo tab
local function createTab(name, iconId)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name
    TabBtn.Size = UDim2.new(1, -10, 0, 50)
    TabBtn.BackgroundColor3 = Color3.fromRGB(90, 70, 140)
    TabBtn.Text = "   "..name
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 16
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn)

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 10, 0.5, -12)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://"..iconId
    Icon.Parent = TabBtn

    -- Khi click TabBtn -> đổi nội dung bên ContentFrame
    TabBtn.MouseButton1Click:Connect(function()
        for _,child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        local Txt = Instance.new("TextLabel")
        Txt.Size = UDim2.new(1, 0, 1, 0)
        Txt.BackgroundTransparency = 1
        Txt.Text = "Đây là tab: "..name
        Txt.TextColor3 = Color3.fromRGB(255,255,255)
        Txt.Font = Enum.Font.GothamBold
        Txt.TextSize = 20
        Txt.Parent = ContentFrame
    end)
end

-- Tạo vài tab mẫu
createTab("Farm", 6034989564)
createTab("Fix Lag", 6031090994)
createTab("PvP", 6031265976)

-- Thu nhỏ UI
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    if not minimized then
        for _,child in pairs(MainFrame:GetChildren()) do
            if child ~= Header then child.Visible = false end
        end
        MainFrame.Size = UDim2.new(0, 250, 0, 50)
        minimized = true
    else
        for _,child in pairs(MainFrame:GetChildren()) do
            child.Visible = true
        end
        MainFrame.Size = UDim2.new(0, 600, 0, 400)
        minimized = false
    end
end)

-- Đóng UI (Confirm Yes/No)
CloseBtn.MouseButton1Click:Connect(function()
    local Confirm = Instance.new("Frame")
    Confirm.Size = UDim2.new(0, 250, 0, 140)
    Confirm.Position = UDim2.new(0.5, -125, 0.5, -70)
    Confirm.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Confirm.Parent = ScreenGui
    Instance.new("UICorner", Confirm)

    local Msg = Instance.new("TextLabel")
    Msg.Size = UDim2.new(1, -20, 0.5, 0)
    Msg.Position = UDim2.new(0, 10, 0, 10)
    Msg.Text = "Bạn có chắc muốn xóa UI?"
    Msg.TextColor3 = Color3.fromRGB(255,255,255)
    Msg.Font = Enum.Font.GothamBold
    Msg.TextSize = 16
    Msg.Parent = Confirm

    local Yes = Instance.new("TextButton")
    Yes.Size = UDim2.new(0.4, 0, 0.25, 0)
    Yes.Position = UDim2.new(0.05, 0, 0.65, 0)
    Yes.Text = "YES"
    Yes.BackgroundColor3 = Color3.fromRGB(70,150,70)
    Yes.TextColor3 = Color3.fromRGB(255,255,255)
    Yes.Parent = Confirm
    Instance.new("UICorner", Yes)

    local No = Instance.new("TextButton")
    No.Size = UDim2.new(0.4, 0, 0.25, 0)
    No.Position = UDim2.new(0.55, 0, 0.65, 0)
    No.Text = "NO"
    No.BackgroundColor3 = Color3.fromRGB(150,70,70)
    No.TextColor3 = Color3.fromRGB(255,255,255)
    No.Parent = Confirm
    Instance.new("UICorner", No)

    Yes.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    No.MouseButton1Click:Connect(function()
        Confirm:Destroy()
    end)
end)

-- Kéo thả UI
local dragging = false
local dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)