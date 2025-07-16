
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 📁 Tên thư mục chứa base
local baseFolder = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases")
if not baseFolder then
	warn("Không tìm thấy thư mục base")
	return
end

-- ✅ Tọa độ cần so sánh
local checkPositions = {
	Vector3.new(-469.1, -6.6, -99.3),
	Vector3.new(-348.4, -6.6, 7.1),
	Vector3.new(-469.1, -6.5, 8.2),
	Vector3.new(-348.0, -6.6, -100.0),
	Vector3.new(-469.2, -6.6, 114.7),
	Vector3.new(-348.5, -6.6, 111.3),
	Vector3.new(-470.4, -6.6, 221.0),
	Vector3.new(-348.4, -6.6, 219.3),
}

-- 🔍 Kiểm tra TextLabel/TextBox chứa tên player
local function isMyBase(model)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("TextLabel") or desc:IsA("TextBox") then
			local text = (desc.Text or ""):lower()
			if text:find(LocalPlayer.Name:lower()) or text:find(LocalPlayer.DisplayName:lower()) then
				return true
			end
		end
	end
	return false
end

-- 📦 Tìm base của người chơi
local function findMyBasePart()
	for _, plot in ipairs(baseFolder:GetChildren()) do
		if plot:IsA("Model") then
			if isMyBase(plot) then
				local part = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart")
				if part then return part end
			end
		end
	end
	return nil
end

-- 📏 Tìm tọa độ gần nhất so với base
local function getNearestPoint(basePos)
	local closest = nil
	local shortest = math.huge
	for _, pos in ipairs(checkPositions) do
		local dist = (basePos - pos).Magnitude
		if dist < shortest then
			shortest = dist
			closest = pos
		end
	end
	return closest
end

-- 🌈 Tạo ESP block hiện rõ ra (không trong suốt)
local function createBaseBlock(position, text)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(4, 2, 4)
	part.Position = position + Vector3.new(0, 2, 0) -- nâng lên cho dễ thấy
	part.BrickColor = BrickColor.new("Bright red")
	part.Material = Enum.Material.Neon
	part.Name = "ESPBlock"
	part.Parent = Workspace

	-- Gắn BillboardGui chữ lên block
	local gui = Instance.new("BillboardGui", part)
	gui.Adornee = part
	gui.Size = UDim2.new(0, 100, 0, 30)
	gui.AlwaysOnTop = true

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.TextStrokeTransparency = 0.3
	label.TextStrokeColor3 = Color3.new(0, 0, 0)

	-- Rainbow hiệu ứng
	local hue = 0
	RunService.RenderStepped:Connect(function()
		hue = (hue + 0.01) % 1
		label.TextColor3 = Color3.fromHSV(hue, 1, 1)
	end)

	return part
end

-- 🔁 Thực hiện
local myBase = findMyBasePart()
if myBase then
	local nearest = getNearestPoint(myBase.Position)
	if nearest then
		local block = createBaseBlock(nearest, "Your Base")
		warn("ESP Block đã đặt tại:", nearest)
	else
		warn("Không tìm được vị trí gần base.")
	end
else
	warn("Không tìm được base của bạn.")
end
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- 📦 UI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PHUCMAX_UI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0, 60, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.new(1, 1, 1)

local gradient = Instance.new("UIGradient", stroke)
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

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "PHUCMAX"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local textGradient = Instance.new("UIGradient", title)
textGradient.Color = gradient.Color
task.spawn(function()
	while title.Parent do
		textGradient.Rotation += 1
		task.wait(0.03)
	end
end)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0, 40)
button.Text = "TELEPORT"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

-- 🔍 Tìm base player
local baseFolder = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases")

local checkPositions = {
	Vector3.new(-469.1, -6.6, -99.3),
	Vector3.new(-348.4, -6.6, 7.1),
	Vector3.new(-469.1, -6.5, 8.2),
	Vector3.new(-348.0, -6.6, -100.0),
	Vector3.new(-469.2, -6.6, 114.7),
	Vector3.new(-348.5, -6.6, 111.3),
	Vector3.new(-470.4, -6.6, 221.0),
	Vector3.new(-348.4, -6.6, 219.3),
}

local function isMyBase(model)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextBox") then
			local text = (d.Text or ""):lower()
			if text:find(LocalPlayer.Name:lower()) or text:find(LocalPlayer.DisplayName:lower()) then
				return true
			end
		end
	end
	return false
end

local function findMyBasePart()
	if not baseFolder then return nil end
	for _, plot in ipairs(baseFolder:GetChildren()) do
		if plot:IsA("Model") and isMyBase(plot) then
			return plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart")
		end
	end
	return nil
end

local function getNearestPoint(basePos)
	local closest = nil
	local shortest = math.huge
	for _, pos in ipairs(checkPositions) do
		local dist = (basePos - pos).Magnitude
		if dist < shortest then
			shortest = dist
			closest = pos
		end
	end
	return closest
end

local function createESP(position)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(4, 2, 4)
	part.Position = position + Vector3.new(0, 2, 0)
	part.BrickColor = BrickColor.new("Bright red")
	part.Material = Enum.Material.Neon
	part.Name = "PhucBaseESPPart"
	part.Parent = Workspace

	local gui = Instance.new("BillboardGui", part)
	gui.Adornee = part
	gui.Size = UDim2.new(0, 100, 0, 30)
	gui.AlwaysOnTop = true

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = "Your Base"
	label.TextStrokeTransparency = 0.3
	label.TextStrokeColor3 = Color3.new(0, 0, 0)

	local hue = 0
	RunService.RenderStepped:Connect(function()
		hue = (hue + 0.01) % 1
		label.TextColor3 = Color3.fromHSV(hue, 1, 1)
	end)
end

local function getESPPart()
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj:IsA("Part") and obj.Name == "PhucBaseESPPart" then
			return obj
		end
	end
	return nil
end

-- 🔁 Khởi tạo ESP
local basePart = findMyBasePart()
if basePart then
	local nearest = getNearestPoint(basePart.Position)
	if nearest then
		createESP(nearest)
	end
end

-- 🧠 NÚT TELEPORT
button.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local espPart = getESPPart()
	if not espPart then
		warn("⚠️ Không tìm thấy ESP part!")
		return
	end

	local destination = espPart.Position + Vector3.new(0, 3, 0)
	local farPosition = Vector3.new(0.00, -340282346638528859811704183484516925440.00, 0.00)

	-- Tele ra xa
	hrp.CFrame = CFrame.new(farPosition)
	task.wait(0.3)

	-- Tele về base
	hrp.CFrame = CFrame.new(destination)
end)
