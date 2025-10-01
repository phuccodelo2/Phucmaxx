-- PHUCMAXX UI v3.1 - Fluent ảnh nền lớn, UI trong suốt + bóng mờ, không còn màu tím block
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
pcall(function() if game.CoreGui:FindFirstChild("PHUC_UI") then game.CoreGui.PHUC_UI:Destroy() end end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PHUC_UI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- MainFrame - ảnh nền lớn
local MainFrame = Instance.new("ImageLabel")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 410)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -205)
MainFrame.BackgroundTransparency = 1
MainFrame.Image = "rbxassetid://15150412387" -- Ảnh nền lớn
MainFrame.ScaleType = Enum.ScaleType.Stretch
MainFrame.Parent = ScreenGui

-- Bóng mờ ngoài MainFrame (blur trắng nhạt, Fluent)
local Shadow = Instance.new("ImageLabel", MainFrame)
Shadow.Name = "Shadow"
Shadow.Image = "rbxassetid://6015897843"
Shadow.Size = UDim2.new(1, 80, 1, 80)
Shadow.Position = UDim2.new(0, -40, 0, -40)
Shadow.BackgroundTransparency = 1
Shadow.ImageTransparency = 0.7
Shadow.ImageColor3 = Color3.fromRGB(255,255,255)
Shadow.ZIndex = 0

-- Header trong suốt, viền trắng mờ
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundTransparency = 1
Header.ZIndex = 2

local HeaderBorder = Instance.new("Frame", Header)
HeaderBorder.Size = UDim2.new(1, 0, 1, 0)
HeaderBorder.BackgroundTransparency = 1
HeaderBorder.BorderSizePixel = 2
HeaderBorder.BorderColor3 = Color3.fromRGB(255,255,255)
HeaderBorder.Position = UDim2.new(0, 0, 0, 0)
HeaderBorder.ZIndex = 3

-- Title
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 32, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌙 PHUCMAXX HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextStrokeTransparency = 0.8
Title.Font = Enum.Font.GothamBold
Title.TextSize = 26
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4

-- Nút thu nhỏ
local MinBtn = Instance.new("ImageButton", Header)
MinBtn.Size = UDim2.new(0, 36, 0, 36)
MinBtn.Position = UDim2.new(1, -88, 0.5, -18)
MinBtn.BackgroundTransparency = 1
MinBtn.Image = "rbxassetid://7072725342"
MinBtn.ImageColor3 = Color3.fromRGB(235,235,235)
MinBtn.ZIndex = 4

-- Nút đóng
local CloseBtn = Instance.new("ImageButton", Header)
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -18)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = "rbxassetid://7072725345"
CloseBtn.ImageColor3 = Color3.fromRGB(235,235,235)
CloseBtn.ZIndex = 4

-- TabBar Fluent: trong suốt hoàn toàn, chỉ còn viền trắng
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 110, 1, -54)
TabBar.Position = UDim2.new(0, 0, 0, 54)
TabBar.BackgroundTransparency = 1
TabBar.BorderSizePixel = 2
TabBar.BorderColor3 = Color3.fromRGB(255,255,255)
TabBar.ZIndex = 3

local TabList = Instance.new("UIListLayout", TabBar)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 10)

-- ContentFrame trong suốt hoàn toàn, có viền trắng mờ
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, -64)
ContentFrame.Position = UDim2.new(0, 120, 0, 62)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 2
ContentFrame.BorderColor3 = Color3.fromRGB(255,255,255)
ContentFrame.ClipsDescendants = true
ContentFrame.ZIndex = 3

-- Tab dữ liệu
local Tabs = {
    { Name = "Trang Chủ", Icon = 6035047409 },
    { Name = "Farm", Icon = 6034989564 },
    { Name = "Fix Lag", Icon = 6031090994 },
    { Name = "PvP", Icon = 6031265976 },
    { Name = "Cài Đặt", Icon = 6031280882 }
}
local TabButtons = {}
local CurrentTab = nil

local function showTab(tabName)
    for _,child in pairs(ContentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    for k,v in pairs(TabButtons) do
        v.BackgroundTransparency = 1
        v.BorderColor3 = Color3.fromRGB(255,255,255)
        v.BorderSizePixel = (k==tabName) and 2 or 1
    end
    local Label = Instance.new("TextLabel", ContentFrame)
    Label.Size = UDim2.new(1, -24, 1, -24)
    Label.Position = UDim2.new(0, 12, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = "🌟 Đây là tab: "..tabName
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 24
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.TextStrokeTransparency = 0.75
    Label.TextWrapped = true
    Label.ZIndex = 4
end

-- Tạo tabs Fluent: chỉ là border trắng, hover overlay trắng mờ
for _,tab in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Name = tab.Name
    TabBtn.Size = UDim2.new(1, -10, 0, 44)
    TabBtn.BackgroundTransparency = 1
    TabBtn.BorderSizePixel = 1
    TabBtn.BorderColor3 = Color3.fromRGB(255,255,255)
    TabBtn.Text = "     "..tab.Name
    TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TabBtn.TextStrokeTransparency = 0.85
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 18
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex = 4
    local Icon = Instance.new("ImageLabel", TabBtn)
    Icon.Size = UDim2.new(0, 22, 0, 22)
    Icon.Position = UDim2.new(0, 10, 0.5, -11)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://"..tab.Icon
    Icon.ImageColor3 = Color3.fromRGB(255,255,255)
    Icon.ZIndex = 5

    TabBtn.MouseEnter:Connect(function()
        if CurrentTab~=tab.Name then
            TabBtn.BackgroundTransparency = 0.2
            TabBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if CurrentTab~=tab.Name then
            TabBtn.BackgroundTransparency = 1
        end
    end)
    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tab.Name
        showTab(tab.Name)
    end)
    TabButtons[tab.Name] = TabBtn
end

CurrentTab = Tabs[1].Name
showTab(CurrentTab)

-- Thu nhỏ/phóng to UI (Tween, Fluent-style)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    if not minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 260, 0, 60)
        }):Play()
        for _,v in pairs(MainFrame:GetChildren()) do
            if v~=Header and v~=Shadow then v.Visible=false end
        end
        minimized = true
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 650, 0, 410)
        }):Play()
        for _,v in pairs(MainFrame:GetChildren()) do
            v.Visible=true
        end
        minimized = false
    end
end)

-- Đóng UI (Fluent confirm)
CloseBtn.MouseButton1Click:Connect(function()
    if ScreenGui:FindFirstChild("ConfirmBox") then return end
    local Confirm = Instance.new("Frame", ScreenGui)
    Confirm.Name = "ConfirmBox"
    Confirm.Size = UDim2.new(0, 280, 0, 120)
    Confirm.Position = UDim2.new(0.5, -140, 0.5, -60)
    Confirm.BackgroundTransparency = 0.5
    Confirm.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Confirm.BorderSizePixel = 2
    Confirm.BorderColor3 = Color3.fromRGB(255,255,255)
    Confirm.ZIndex = 15

    local Msg = Instance.new("TextLabel", Confirm)
    Msg.Size = UDim2.new(1, -20, 0.45, 0)
    Msg.Position = UDim2.new(0, 10, 0, 10)
    Msg.BackgroundTransparency = 1
    Msg.Text = "Bạn có chắc muốn đóng giao diện?"
    Msg.TextColor3 = Color3.fromRGB(255,255,255)
    Msg.TextStrokeTransparency = 0.7
    Msg.Font = Enum.Font.GothamBold
    Msg.TextSize = 18

    local Yes = Instance.new("TextButton", Confirm)
    Yes.Size = UDim2.new(0.43, 0, 0.3, 0)
    Yes.Position = UDim2.new(0.05, 0, 0.60, 0)
    Yes.Text = "Đồng ý"
    Yes.BackgroundTransparency = 0.7
    Yes.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Yes.TextColor3 = Color3.fromRGB(40,40,40)
    Yes.Font = Enum.Font.GothamBold
    Yes.TextSize = 17

    local No = Instance.new("TextButton", Confirm)
    No.Size = UDim2.new(0.43, 0, 0.3, 0)
    No.Position = UDim2.new(0.52, 0, 0.60, 0)
    No.Text = "Huỷ"
    No.BackgroundTransparency = 0.7
    No.BackgroundColor3 = Color3.fromRGB(255,255,255)
    No.TextColor3 = Color3.fromRGB(40,40,40)
    No.Font = Enum.Font.GothamBold
    No.TextSize = 17

    Yes.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    No.MouseButton1Click:Connect(function()
        Confirm:Destroy()
    end)
end)

-- Kéo thả UI
local dragging, dragInput, dragStart, startPos = false
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
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- UI giờ sẽ siêu trong, bóng mờ, không còn màu tím/xám cũ, hợp Fluent và giữ nền là ảnh lớn
