local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 📦 UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PHUCMAX_UI"
gui.ResetOnSpawn = false

-- 📦 Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 60, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- 🌈 Viền Rainbow
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.new(1, 1, 1) -- Bắt buộc là trắng để Gradient hiển thị

local gradient = Instance.new("UIGradient", stroke) -- GẮN VÀO UIStroke
gradient.Rotation = 0
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 255))
}

task.spawn(function()
	while frame.Parent do
		gradient.Rotation += 1
		task.wait(0.03)
	end
end)

-- 🏷️ Tiêu đề
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "PHUCMAX"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1) -- Bắt buộc là trắng để gradient hiện đúng
title.TextScaled = true

-- 🌈 Gradient màu cho chữ
local textGradient = Instance.new("UIGradient", title)
textGradient.Rotation = 0
textGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 255))
}

-- 🌈 Hiệu ứng chạy màu
task.spawn(function()
	while title.Parent do
		textGradient.Rotation += 1
		task.wait(0.03)
	end
end)

-- 🔘 Nút BẬT/TẮT
local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0, 40)
button.Text = "TELEPORT"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

-- ⚙️ Chức năng
local running = false

button.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	running = not running
	if running then
		button.Text = "FALL DOWN"
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		-- 🔼 Tele lên đúng Y = 200
		hrp.CFrame = CFrame.new(hrp.Position.X, 200, hrp.Position.Z)
	else
		button.Text = "FALL DOWN"
		button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		-- 🔽 Tele xuống đúng Y = 100 (không bay)
		hrp.CFrame = CFrame.new(hrp.Position.X, 180, hrp.Position.Z)
	end
end)
