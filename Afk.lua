--// PHUCMAX ANTI AFK + FIXLAG + TELE
--// Phiên bản tối ưu, UI không mất khi reset

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

-- Hàm Fix Lag (xóa tất cả, chỉ giữ lại mặt đất)
local function FixLag(10000)
local function FixLag(radius)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local dist = (obj.Position - root.Position).Magnitude
            if obj.Position.Y < 5 or dist <= radius then
                -- giữ lại mặt đất và những part trong bán kính radius
                obj.Transparency = 0
            else
                obj:Destroy()
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") 
            or obj:IsA("ParticleEmitter") or obj:IsA("Smoke") 
            or obj:IsA("Fire") or obj:IsA("Explosion") then
            obj:Destroy()
        end
    end

    -- giảm hiệu ứng ánh sáng
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
    
-- Hàm Tele tới tọa độ
local function TeleportToCoords()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root.CFrame = CFrame.new(1658.0, 19.3, -224.0)
    FixLag()
end

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    game.VirtualUser:CaptureController()
    game.VirtualUser:ClickButton2(Vector2.new())
end)

-- Hàm Auto Rejoin
local function AutoRejoin()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

-- FPS + Battery hiển thị
local fps = 0
local lastTime = tick()

-- Tạo UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PHUCMAX_UI"
ScreenGui.ResetOnSpawn = false -- Giữ lại khi reset
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 120)
MainFrame.Position = UDim2.new(0.75, 0, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.2
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.AutomaticSize = Enum.AutomaticSize.None
MainFrame.Parent = ScreenGui
MainFrame.Name = "MainUI"
MainFrame:SetAttribute("GradientStep", 0)

-- Hiệu ứng Gradient Loop
local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Rotation = 45
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
}

-- Text Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🌌 PHUCMAX ANTI AFK 🌌"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Label FPS
local FpsLabel = Instance.new("TextLabel", MainFrame)
FpsLabel.Size = UDim2.new(1, 0, 0, 20)
FpsLabel.Position = UDim2.new(0, 0, 0.4, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
FpsLabel.Font = Enum.Font.Gotham
FpsLabel.TextSize = 13
FpsLabel.Text = "FPS: 0"

-- Label Battery
local BatteryLabel = Instance.new("TextLabel", MainFrame)
BatteryLabel.Size = UDim2.new(1, 0, 0, 20)
BatteryLabel.Position = UDim2.new(0, 0, 0.6, 0)
BatteryLabel.BackgroundTransparency = 1
BatteryLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
BatteryLabel.Font = Enum.Font.Gotham
BatteryLabel.TextSize = 13
BatteryLabel.Text = "Battery: ???"

-- Nút bật tắt Auto Rejoin
local Toggle = Instance.new("TextButton", MainFrame)
Toggle.Size = UDim2.new(1, 0, 0, 25)
Toggle.Position = UDim2.new(0, 0, 0.8, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.Text = "🔄 Auto Rejoin: OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 13

local AutoRejoinEnabled = false
Toggle.MouseButton1Click:Connect(function()
    AutoRejoinEnabled = not AutoRejoinEnabled
    Toggle.Text = AutoRejoinEnabled and "🔄 Auto Rejoin: ON" or "🔄 Auto Rejoin: OFF"
end)

-- Cập nhật FPS và Pin
RunService.RenderStepped:Connect(function()
    fps = math.floor(1 / (tick() - lastTime))
    lastTime = tick()
    FpsLabel.Text = "FPS: " .. tostring(fps)

    if GuiService:GetBatteryStatus() then
        local battery = GuiService:GetBatteryStatus().Level or 0
        BatteryLabel.Text = "Battery: " .. tostring(math.floor(battery * 100)) .. "%"
    end
end)

-- Auto rejoin khi văng
Players.LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Failed and AutoRejoinEnabled then
        AutoRejoin()
    end
end)

-- Auto Tele + FixLag khi vào
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    TeleportToCoords()
end)

-- Chạy lần đầu
TeleportToCoords()
