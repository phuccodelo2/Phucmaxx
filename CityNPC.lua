-- PHUCMAX FOLLOW + CIRCLE ATTACK FIXED + Noclip
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Luôn luôn Noclip
RunService.Stepped:Connect(function()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- Toggle follow
local followEnabled = false

-- GUI nhỏ gọn
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PHUCMAX_Follow"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,50)
frame.Position = UDim2.new(0,10,0,10)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1,0,1,0)
btn.Text = "FARM NPC city [OFF]"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

btn.MouseButton1Click:Connect(function()
    followEnabled = not followEnabled
    btn.Text = "FARM NPC City ["..(followEnabled and "ON" or "OFF").."]"
end)

-- Tìm quái sống gần nhất
local function getNearestMonster()
    local nearest = nil
    local minDist = math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "CityNPC" and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
            local dist = (HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = obj
            end
        end
    end
    return nearest
end

-- Nhấn phím 1 lần đầu
local firstBuff = true
local function pressKeyOnce()
    if firstBuff then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        firstBuff = false
    end
end

-- Auto click
local attacking = false
local function startAutoClick()
    if attacking then return end
    attacking = true
    task.spawn(function()
        while attacking and followEnabled do
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,true)
            task.wait(0.1)
        end
        attacking = false
    end)
end
local function stopAutoClick() attacking = false end

-- Vòng tròn xung quanh quái
local angle = 0
local radius = 15.5
local circleSpeed = math.rad(120) -- 14 độ/frame
local flySpeed = 32

RunService.RenderStepped:Connect(function(dt)
    if followEnabled then
        local target = getNearestMonster()
        if target and target:FindFirstChild("HumanoidRootPart") then
            pressKeyOnce()
            startAutoClick()

            local targetPos = target.HumanoidRootPart.Position
            local distance = (HumanoidRootPart.Position - targetPos).Magnitude

            if distance > 15.5 then
                -- Bay thẳng tới 4 studs trước quái
                local dir = (targetPos - HumanoidRootPart.Position).Unit
                local newPos = HumanoidRootPart.Position + dir * flySpeed * dt
                -- Giữ mặt đất
                newPos = Vector3.new(newPos.X, targetPos.Y, newPos.Z)
                HumanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
            else
                -- Vòng xoay xung quanh quái
                angle = angle + circleSpeed * dt * 60
                local offset = Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
                local newPos = Vector3.new(targetPos.X + offset.X, targetPos.Y, targetPos.Z + offset.Z)
                HumanoidRootPart.CFrame = CFrame.new(newPos, targetPos)
            end
        else
            stopAutoClick()
        end
    else
        stopAutoClick()
    end
end)