--// Dịch vụ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FarmBossUI"
gui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- Bo góc
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 15)

-- Rainbow viền
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Rainbow update
task.spawn(function()
	while task.wait() do
		local hue = tick() % 5 / 5
		stroke.Color = ColorSequence.new(Color3.fromHSV(hue, 1, 1))
	end
end)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "PHUCMAX FARM BOSS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Toggle Button
local toggle = Instance.new("TextButton", mainFrame)
toggle.Size = UDim2.new(0.9, 0, 0, 30)
toggle.Position = UDim2.new(0.05, 0, 0, 40)
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.Text = "Bật Farm Boss"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.Gotham
toggle.TextSize = 16
Instance.new("UICorner", toggle)

-- Khoảng cách input
local disInput = Instance.new("TextBox", mainFrame)
disInput.Size = UDim2.new(0.4, 0, 0, 30)
disInput.Position = UDim2.new(0.05, 0, 0, 80)
disInput.PlaceholderText = "Khoảng cách"
disInput.Text = "Khoảng cách"
disInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
disInput.TextColor3 = Color3.fromRGB(255, 255, 255)
disInput.Font = Enum.Font.Gotham
disInput.TextSize = 14
Instance.new("UICorner", disInput)

-- Góc xoay input
local angleInput = Instance.new("TextBox", mainFrame)
angleInput.Size = UDim2.new(0.4, 0, 0, 30)
angleInput.Position = UDim2.new(0.55, 0, 0, 80)
angleInput.PlaceholderText = "Độ xoay"
angleInput.Text = " xoay"
angleInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
angleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
angleInput.Font = Enum.Font.Gotham
angleInput.TextSize = 14
Instance.new("UICorner", angleInput)

-- Label hiển thị máu NPC
local healthLabel = Instance.new("TextLabel")
healthLabel.Size = UDim2.new(0, 220, 0, 30)
healthLabel.Position = UDim2.new(1, -230, 0, 10)
healthLabel.AnchorPoint = Vector2.new(0, 0)
healthLabel.BackgroundTransparency = 1
healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
healthLabel.Font = Enum.Font.GothamBold
healthLabel.TextSize = 16
healthLabel.Text = "Máu boss: ???"
healthLabel.TextXAlignment = Enum.TextXAlignment.Right
healthLabel.Parent = gui

-- Auto Farm Logic
local farming = false
toggle.MouseButton1Click:Connect(function()
	farming = not farming
	toggle.Text = farming and "Tắt Farm Boss" or "Bật Farm Boss"

	while farming do
		local dis = tonumber(disInput.Text) or 5
		local angle = tonumber(angleInput.Text) or 3
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local npc = nil

		-- Tìm NPC2
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name == "NPC2" then
				npc = v
				break
			end
		end

		if root and npc and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
			local npcRoot = npc.HumanoidRootPart
			local humanoid = npc.Humanoid
			local tickAngle = tick() * angle
			local offset = Vector3.new(math.cos(tickAngle), 0, math.sin(tickAngle)) * dis
			root.CFrame = CFrame.new(npcRoot.Position + offset, npcRoot.Position + Vector3.new(0, 2, 0))

			-- Auto Click
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

			-- Hiển thị máu
			healthLabel.Text = string.format("Máu BOSS: %.0f / %.0f", humanoid.Health, humanoid.MaxHealth)
		else
			healthLabel.Text = "Máu NPC2: Không tìm thấy"
		end

		task.wait(0.1)
	end
end)
