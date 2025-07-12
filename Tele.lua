-- 📦 UI PHUCMAX: Viền rainbow + kéo được + chức năng chạy BASE

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- TẠO GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PHUCMAX_UI"
gui.ResetOnSpawn = false

-- MAIN FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 60, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- 🌈 VIỀN RAINBOW

-- 🌈 VIỀN RAINBOW ĐÚNG CÁCH
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255, 0, 0) -- Chỉ để khởi tạo, sẽ thay bằng Gradient sau

local gradient = Instance.new("UIGradient", frame) -- GẮN VÀO FRAME, KHÔNG GẮN VÀO UIStroke
gradient.Rotation = 0
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 255))
}
stroke.Color = Color3.new(1, 1, 1)
stroke.Transparency = 0
gradient.Transparency = NumberSequence.new(0)

-- 🌈 Animate viền bằng rotation UIGradient
task.spawn(function()
	while frame.Parent do
		gradient.Rotation += 1
		task.wait(0.03)
	end
end)

-- LABEL TIÊU ĐỀ
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "PHUCMAX"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

-- NÚT BẬT TẮT
local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0, 40)
button.Text = "RUN TO BASE OFF"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

-- ⚙️ CHỨC NĂNG CHẠY BASE
local running = false
local runner = nil

local function getESPBase()
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Part") and (obj.Name == "ESP_BASE" or obj.Name == "ESPBase") then
			return obj
		end
	end
end

local function runToXZ(targetXZ, hrp)
	while running and (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(targetXZ.X, 0, targetXZ.Z)).Magnitude > 3 do
		local dir = (targetXZ - hrp.Position)
		dir = Vector3.new(dir.X, 0, dir.Z).Unit
		hrp.CFrame = hrp.CFrame + dir * 5
		task.wait(0.03)
	end
end

local function isOverPart(part, hrp)
	local horiz = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(part.Position.X, 0, part.Position.Z)).Magnitude
	local vert = math.abs(hrp.Position.Y - part.Position.Y)
	return (horiz <= 5 and vert <= 5)
end

local function startRun()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- Tele lên 200
	hrp.CFrame = hrp.CFrame + Vector3.new(0, 200, 0)
	task.wait(0.05)

	local base = getESPBase()
	if base then
		local targetXZ = Vector3.new(base.Position.X, hrp.Position.Y, base.Position.Z)
		runToXZ(targetXZ, hrp)

		if isOverPart(base, hrp) then
			hrp.CFrame = hrp.CFrame - Vector3.new(0, 20, 0)
		end
	end
end

-- KHI BẤM NÚT
button.MouseButton1Click:Connect(function()
	running = not running
	if running then
		button.Text = "RUN TO BASE ON"
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		if runner then runner:Disconnect() end
		runner = RunService.Heartbeat:Connect(function()
			pcall(startRun)
			task.wait(1)
		end)
	else
		button.Text = "RUN TO BASE OFF"
		button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		if runner then runner:Disconnect() end
	end
end)
