-- PHUCMAXX UI v3 - Toàn bộ UI là một ảnh nền lớn, các thành phần nổi trên ảnh
-- Tác giả: phucmax (Copilot refactor & nền ảnh to)

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Xoá UI cũ nếu tồn tại
pcall(function() if game.CoreGui:FindFirstChild("PHUC_UI") then game.CoreGui.PHUC_UI:Destroy() end end)

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PHUC_UI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- MainFrame bằng ImageLabel, dùng làm nền lớn
local MainFrame = Instance.new("ImageLabel")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundTransparency = 1
MainFrame.Image = "rbxassetid://15150412387" -- Thay ID ảnh nền bạn muốn tại đây
MainFrame.ScaleType = Enum.ScaleType.Stretch
MainFrame.Parent = ScreenGui

-- Bo góc MainFrame
local MainUICorner = Instance.new("UICorner", MainFrame)
MainUICorner.CornerRadius = UDim.new(0, 18)

-- Đổ bóng ngoài MainFrame
local Shadow = Instance.new("ImageLabel", MainFrame)
Shadow.Name = "Shadow"
Shadow.Image = "rbxassetid://6015897843"
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.Position = UDim2.new(0, -30, 0, -30)
Shadow.BackgroundTransparency = 1
Shadow.ImageTransparency = 0.47
Shadow.ZIndex = 0

-- Header nổi trên nền
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(26, 16, 34)
Header.BackgroundTransparency = 0.15
Header.BorderSizePixel = 0
Header.ZIndex = 2
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 24, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌙 PHUCMAXX HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2

-- Nút thu nhỏ
local MinBtn = Instance.new("ImageButton", Header)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -80, 0.5, -16)
MinBtn.BackgroundTransparency = 1
MinBtn.Image = "rbxassetid://7072725342" -- icon thu nhỏ
MinBtn.ZIndex = 2

-- Nút đóng
local CloseBtn = Instance.new("ImageButton", Header)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = "rbxassetid://7072725345" -- icon đóng
CloseBtn.ZIndex = 2

-- TabBar nổi bên trái (trong suốt nhẹ)
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 130, 1, -48)
TabBar.Position = UDim2.new(0, 0, 0, 48)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 12, 24)
TabBar.BackgroundTransparency = 0.25
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 2
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabList = Instance.new("UIListLayout", TabBar)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 8)

-- ContentFrame nổi phải (trong suốt nhẹ)
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -140, 1, -60)
ContentFrame.Position = UDim2.new(0, 140, 0, 56)
ContentFrame.BackgroundColor3 = Color3.fromRGB(14, 8, 18)
ContentFrame.BackgroundTransparency = 0.17
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.ZIndex = 2
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 10)

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
    -- Xoá hết nội dung cũ
    for _,child in pairs(ContentFrame:GetChildren()) do
        if not child:IsA("UICorner") then child:Destroy() end
    end
    -- Đánh dấu tab đang chọn
    for k,v in pairs(TabButtons) do
        v.BackgroundColor3 = (k==tabName) and Color3.fromRGB(70,40,120) or Color3.fromRGB(32,22,48)
        v.BackgroundTransparency = (k==tabName) and 0.15 or 0.3
    end
    -- Nội dung mẫu (có thể tuỳ chỉnh)
    local Label = Instance.new("TextLabel", ContentFrame)
    Label.Size = UDim2.new(1, -24, 1, -24)
    Label.Position = UDim2.new(0, 12, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = "🌟 Đây là tab: "..tabName
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 22
    Label.TextColor3 = Color3.fromRGB(225,215,255)
    Label.TextWrapped = true
    Label.ZIndex = 3
end

-- Tạo tabs
for _,tab in ipairs(Tabs) do
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Name = tab.Name
    TabBtn.Size = UDim2.new(1, -18, 0, 48)
    TabBtn.BackgroundColor3 = Color3.fromRGB(32,22,48)
    TabBtn.BackgroundTransparency = 0.3
    TabBtn.Text = "     "..tab.Name
    TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 17
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex = 2
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 7)
    local Icon = Instance.new("ImageLabel", TabBtn)
    Icon.Size = UDim2.new(0, 22, 0, 22)
    Icon.Position = UDim2.new(0, 10, 0.5, -11)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://"..tab.Icon
    Icon.ZIndex = 3

    TabBtn.MouseEnter:Connect(function() if CurrentTab~=tab.Name then TabBtn.BackgroundTransparency = 0.15 end end)
    TabBtn.MouseLeave:Connect(function() if CurrentTab~=tab.Name then TabBtn.BackgroundTransparency = 0.3 end end)

    TabBtn.MouseButton1Click:Connect(function()
        CurrentTab = tab.Name
        showTab(tab.Name)
    end)
    TabButtons[tab.Name] = TabBtn
end

-- Chọn tab đầu tiên mặc định
CurrentTab = Tabs[1].Name
showTab(CurrentTab)

-- Thu nhỏ/phóng to UI (Tween)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    if not minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 250, 0, 50)
        }):Play()
        for _,v in pairs(MainFrame:GetChildren()) do
            if v~=Header and v~=Shadow then v.Visible=false end
        end
        minimized = true
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 600, 0, 400)
        }):Play()
        for _,v in pairs(MainFrame:GetChildren()) do
            v.Visible=true
        end
        minimized = false
    end
end)

-- Đóng UI (Confirm)
CloseBtn.MouseButton1Click:Connect(function()
    if ScreenGui:FindFirstChild("ConfirmBox") then return end
    local Confirm = Instance.new("Frame", ScreenGui)
    Confirm.Name = "ConfirmBox"
    Confirm.Size = UDim2.new(0, 260, 0, 120)
    Confirm.Position = UDim2.new(0.5, -130, 0.5, -60)
    Confirm.BackgroundColor3 = Color3.fromRGB(48,32,68)
    Confirm.ZIndex = 15
    Instance.new("UICorner", Confirm).CornerRadius = UDim.new(0, 10)

    local Msg = Instance.new("TextLabel", Confirm)
    Msg.Size = UDim2.new(1, 0, 0.45, 0)
    Msg.Position = UDim2.new(0, 0, 0, 10)
    Msg.BackgroundTransparency = 1
    Msg.Text = "Bạn có chắc muốn đóng giao diện?"
    Msg.TextColor3 = Color3.fromRGB(255,255,255)
    Msg.Font = Enum.Font.GothamBold
    Msg.TextSize = 17

    local Yes = Instance.new("TextButton", Confirm)
    Yes.Size = UDim2.new(0.42, 0, 0.28, 0)
    Yes.Position = UDim2.new(0.05, 0, 0.62, 0)
    Yes.Text = "Đồng ý"
    Yes.BackgroundColor3 = Color3.fromRGB(80,170,90)
    Yes.TextColor3 = Color3.fromRGB(255,255,255)
    Yes.Font = Enum.Font.GothamBold
    Yes.TextSize = 16
    Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 7)

    local No = Instance.new("TextButton", Confirm)
    No.Size = UDim2.new(0.42, 0, 0.28, 0)
    No.Position = UDim2.new(0.53, 0, 0.62, 0)
    No.Text = "Huỷ"
    No.BackgroundColor3 = Color3.fromRGB(170,80,80)
    No.TextColor3 = Color3.fromRGB(255,255,255)
    No.Font = Enum.Font.GothamBold
    No.TextSize = 16
    Instance.new("UICorner", No).CornerRadius = UDim.new(0, 7)

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

-- Hoàn tất nền ảnh to - các thành phần nổi, tối ưu cho UI đẹp mắt
