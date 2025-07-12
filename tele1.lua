local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PhucmaxAutoTeleUI"
gui.ResetOnSpawn = false

-- 🧱 Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 200, 0, 100)
main.Position = UDim2.new(0, 50, 0.5, -50)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- 🌈 Viền Rainbow
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = main

-- 💫 Gradient áp vào stroke
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 127, 0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
gradient.Rotation = 0
gradient.Parent = stroke -- 🟢 Gán gradient cho UIStroke

-- 🌀 Rainbow Animation
task.spawn(function()
	while gradient and gradient.Parent do
		gradient.Rotation += 1
		task.wait(0.03)
	end
end)

-- 🏷️ TIÊU ĐỀ RAINBOW
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "TELEPORT1st floor"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255) -- Màu khởi đầu
title.TextStrokeTransparency = 0
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- 🌈 Hiệu ứng đổi màu rainbow động
task.spawn(function()
	local hue = 0
	while title and title.Parent do
		hue = (hue + 1) % 360
		local color = Color3.fromHSV(hue / 360, 1, 1)
		title.TextColor3 = color
		title.TextStrokeColor3 = color
		task.wait(0.03)
	end
end)

-- 🔘 Nút bật tắt
local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0.8, 0, 0, 40)
toggle.Position = UDim2.new(0.1, 0, 0, 50)
toggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
toggle.Text = " OFF"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- ⚙️ Chức năng auto tele
local doorPositions = {
	Vector3.new(-469.1, -6.6, -99.3), Vector3.new(-348.4, -6.6, 7.1),
	Vector3.new(-469.1, -6.5, 8.2), Vector3.new(-348.0, -6.6, -100.0),
	Vector3.new(-469.2, -6.6, 114.7), Vector3.new(-348.5, -6.6, 111.3),
	Vector3.new(-470.4, -6.6, 221.0), Vector3.new(-348.4, -6.6, 219.3),
}

local function getClosestDoor()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local closest, minDist = nil, math.huge
	for _, pos in ipairs(doorPositions) do
		local dist = (hrp.Position - pos).Magnitude
		if dist < minDist then
			minDist = dist
			closest = pos
		end
	end
	return closest
end

local function smoothMove(toPos)
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	while (hrp.Position - toPos).Magnitude > 3 do
		local dir = (toPos - hrp.Position).Unit
		hrp.CFrame = hrp.CFrame + dir * (75/ 60)
		task.wait(1 / 60)
	end
end

local function getESPBase()
	local base = workspace:FindFirstChild("ESPBase")
	return base and base.Position
end

local function getESPLockList()
	local result = {}
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Part") and v.Name == "ESP_LOCK_POINT" then
			table.insert(result, v)
		end
	end
	return result
end

-- 📌 Logic chính
local active = false
local running = false

toggle.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if active then
		-- TẮT
		active = false
		toggle.Text = "OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
		running = false
		hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
	else
		-- BẬT
		active = true
		toggle.Text = "ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

		if running then return end
		running = true

		local target = getClosestDoor()
		if not target then return end
		smoothMove(target)
		task.wait(0.2)

		hrp.CFrame = hrp.CFrame + Vector3.new(0, 200, 0)
		task.wait(0.4)

		local basePos = getESPBase()
		if basePos then
			smoothMove(Vector3.new(basePos.X, hrp.Position.Y, basePos.Z))

			for y = 1, 200 do
				local check = hrp.Position - Vector3.new(0, y, 0)
				if (check - basePos).Magnitude < 5 then
					hrp.CFrame = CFrame.new(basePos.X, basePos.Y + 3, basePos.Z)
					break
				end
			end

			local locks = getESPLockList()
			for _, part in pairs(locks) do
				if not active then break end
				hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
				task.wait(0.1)
			end
		end

		running = false
	end
end)