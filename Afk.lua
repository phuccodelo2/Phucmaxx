--// PHUCMAX ANTI AFK + FIXLAG + TELE (Sửa lỗi & FixRadius mặc định 10000)
--// UI không mất khi reset, FixLag chỉ giữ mặt đất + parts trong radius

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local FIX_RADIUS_DEFAULT = 10000          -- mặc định giữ lại trong radius (mày muốn 10000)
local GROUND_Y_THRESHOLD = 10             -- các part có Y <= giá trị này coi là 'mặt đất'
local TELEPORT_POS = Vector3.new(1658.0, 19.3, -224.0)

-- UI (ResetOnSpawn=false để không mất khi respawn)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PHUCMAX_UI"
ScreenGui.ResetOnSpawn = false
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

local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Rotation = 45
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
}

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🌌 PHUCMAX ANTI AFK 🌌"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local FpsLabel = Instance.new("TextLabel", MainFrame)
FpsLabel.Size = UDim2.new(1, 0, 0, 20)
FpsLabel.Position = UDim2.new(0, 0, 0.4, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
FpsLabel.Font = Enum.Font.Gotham
FpsLabel.TextSize = 13
FpsLabel.Text = "FPS: 0"

local BatteryLabel = Instance.new("TextLabel", MainFrame)
BatteryLabel.Size = UDim2.new(1, 0, 0, 20)
BatteryLabel.Position = UDim2.new(0, 0, 0.6, 0)
BatteryLabel.BackgroundTransparency = 1
BatteryLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
BatteryLabel.Font = Enum.Font.Gotham
BatteryLabel.TextSize = 13
BatteryLabel.Text = "Battery: ???"

-- hàm FixLag an toàn: giữ lại parts trong radius (mặc định 10000) + giữ 'mặt đất' lớn
local function FixLag(radius)
    radius = radius or FIX_RADIUS_DEFAULT
    local player = LocalPlayer
    if not player or not player.Character then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Lấy danh sách trước để tránh lỗi khi destroy giữa chừng
    local descendants = workspace:GetDescendants()
    for _, obj in ipairs(descendants) do
        -- skip nếu object bị nil hoặc destroyed
        if not obj then continue end

        -- NEVER touch player's own character parts
        if obj:IsDescendantOf(char) then
            -- giữ lại
        else
            if obj:IsA("BasePart") then
                local okToKeep = false
                -- Giữ nếu nằm trong bán kính radius
                local success, dist = pcall(function() return (obj.Position - root.Position).Magnitude end)
                if success and dist and dist <= radius then
                    okToKeep = true
                end

                -- Giữ nếu là 'mặt đất lớn' (anchored và kích thước lớn) hoặc Y <= threshold
                if obj.Anchored and (obj.Size.X > 10 or obj.Size.Z > 10) then
                    okToKeep = true
                end
                if obj.Position.Y <= GROUND_Y_THRESHOLD then
                    okToKeep = true
                end

                if okToKeep then
                    -- giảm chất lượng nhưng giữ để đứng lên
                    pcall(function()
                        obj.Transparency = 0
                        obj.CanCollide = true
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Color = Color3.fromRGB(150,150,150)
                    end)
                else
                    -- destroy các vật thể xa -> giải phóng lag
                    pcall(function() obj:Destroy() end)
                end

            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                pcall(function() obj.Enabled = false end)
            end
        end
    end

    -- Tắt hiệu ứng sáng nặng
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(128,128,128)
    end)
end

-- Hàm teleport rồi mới fixlag (khi tới rồi mới chạy FixLag)
local function TeleportToCoords()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root.CFrame = CFrame.new(TELEPORT_POS)
    task.wait(0.6)       -- đợi 1 chút cho physics settle
    FixLag(FIX_RADIUS_DEFAULT)
end

-- Anti AFK (giữ chứ không kick)
LocalPlayer.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
    end)
end)

-- FPS + battery update an toàn
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt = now - lastTime
    if dt > 0 then
        local fps = math.floor(1 / dt)
        FpsLabel.Text = "FPS: " .. tostring(fps)
    end
    lastTime = now

    local status = GuiService:GetBatteryStatus()
    if status and status.Level then
        BatteryLabel.Text = "Battery: " .. tostring(math.floor(status.Level * 100)) .. "%"
    end
end)

-- Khi respawn/character added thì tele + fixlag (UI sẽ không mất nhờ ResetOnSpawn=false)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5) -- đợi spawn xong
    TeleportToCoords()
end)

-- Chạy lần đầu
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    TeleportToCoords()
else
    LocalPlayer.CharacterAdded:Wait()
    TeleportToCoords()
end
