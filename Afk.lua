--// PHUC FIX LAG MAX (Full Features)
-- by ChatGPT (FPS + Ping + Fix Lag + Tele + AntiAFK + AutoReset)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

--⚡ Config
local TeleportPos = Vector3.new(1658.0, 19.3, -224.0)

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "PhucFixLagMax"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 90)
Frame.Position = UDim2.new(0.7, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Frame)
Stroke.Thickness = 3

-- Rainbow loop
task.spawn(function()
	while task.wait(0.05) do
		local t = tick() % 5 / 5
		Stroke.Color = Color3.fromHSV(t,1,1)
		Frame.BackgroundColor3 = Color3.fromHSV((t+0.3)%1,0.8,0.8)
	end
end)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "🌈 PHUC FIX LAG MAX 🌈"
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local FPSLabel = Instance.new("TextLabel", Frame)
FPSLabel.Size = UDim2.new(1, 0, 0, 25)
FPSLabel.Position = UDim2.new(0,0,0.35,0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Font = Enum.Font.Code
FPSLabel.TextScaled = true

local PingLabel = Instance.new("TextLabel", Frame)
PingLabel.Size = UDim2.new(1, 0, 0, 25)
PingLabel.Position = UDim2.new(0,0,0.65,0)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = Enum.Font.Code
PingLabel.TextScaled = true

-- Rainbow text
task.spawn(function()
	while task.wait(0.1) do
		local t = tick() % 5 / 5
		Title.TextColor3 = Color3.fromHSV(t,1,1)
		FPSLabel.TextColor3 = Color3.fromHSV((t+0.2)%1,1,1)
		PingLabel.TextColor3 = Color3.fromHSV((t+0.4)%1,1,1)
	end
end)

-- FPS + Ping update
local lastUpdate = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
	frameCount += 1
	if tick() - lastUpdate >= 1 then
		FPSLabel.Text = "FPS: "..frameCount
		frameCount = 0
		lastUpdate = tick()
	end
	local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
	PingLabel.Text = "Ping: "..ping
end)

-- Fix lag function
local function FixLagMax()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			if obj.Anchored and (obj.Size.X > 10 or obj.Size.Z > 10) then
				obj.Color = Color3.fromRGB(150, 150, 150)
				obj.Material = Enum.Material.SmoothPlastic
			else
				obj.Transparency = 1
				obj.CanCollide = false
			end
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj:Destroy()
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
			obj.Enabled = false
		end
	end
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.Brightness = 1
	Lighting.Ambient = Color3.fromRGB(128,128,128)
end

-- Teleport
local function TeleToPos()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(TeleportPos)
	end
end

-- Anti AFK
LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

-- Auto Reset mỗi 10 phút
task.spawn(function()
	while task.wait(600) do -- 600s = 10 phút
		if LocalPlayer.Character then
			LocalPlayer.Character:BreakJoints() -- reset nhân vật
			task.wait(12) -- chờ respawn
			TeleToPos()
		end
	end
end)

-- Kích hoạt ngay khi bật script
FixLagMax()
task.delay(3, TeleToPos)
