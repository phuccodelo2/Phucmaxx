-- PHUCMAX ANTI AFK SCRIPT
-- Tự động tele, anti afk, auto reconnect, hiện FPS & Ping
-- UI Neon Pastel Gradient Style

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ⚡ Config
local TeleportPos = Vector3.new(1658.0, 19.3, -224.0)
local ScriptUrl = "https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/Afk.lua" 
-- (chỗ này mày thay bằng link chính của script này để auto load lại)

-- 🔹 UI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "PHUCMAX_UI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0.75, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1
Frame.ClipsDescendants = true
Frame.Active = true
Frame.Draggable = true
Frame.AnchorPoint = Vector2.new(0.5,0.5)
Frame.AutomaticSize = Enum.AutomaticSize.None
Frame.BorderMode = Enum.BorderMode.Outline
Frame.UICorner = Instance.new("UICorner", Frame)
Frame.UICorner.CornerRadius = UDim.new(0,15)

-- Hiệu ứng viền Neon Pastel Gradient
local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(255,105,180)

task.spawn(function()
	while task.wait(0.1) do
		UIStroke.Color = Color3.fromHSV(tick() % 5 / 5,1,1)
	end
end)

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "🌌 PHUCMAX ANTI AFK 🌌"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

task.spawn(function()
	while task.wait(0.1) do
		Title.TextColor3 = Color3.fromHSV(tick()%5/5,0.8,1)
	end
end)

-- FPS & Ping
local Info = Instance.new("TextLabel", Frame)
Info.Size = UDim2.new(1,0,0,25)
Info.Position = UDim2.new(0,0,0.2,0)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(200,200,200)
Info.Font = Enum.Font.Code
Info.TextScaled = true

RunService.RenderStepped:Connect(function()
	local fps = math.floor(1/RunService.RenderStepped:Wait())
	local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
	Info.Text = "FPS: "..fps.." | PING: "..ping
end)

-- Toggle Auto Re-execute
local ToggleBtn = Instance.new("TextButton", Frame)
ToggleBtn.Size = UDim2.new(0.9,0,0,30)
ToggleBtn.Position = UDim2.new(0.05,0,0.6,0)
ToggleBtn.Text = "🔄 Auto Re-Execute: ON"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextScaled = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,8)

local autoRe = true
ToggleBtn.MouseButton1Click:Connect(function()
	autoRe = not autoRe
	ToggleBtn.Text = "🔄 Auto Re-Execute: "..(autoRe and "ON" or "OFF")
end)

-- Tele khi bật script
task.delay(3,function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(TeleportPos)
	end
end)

-- Anti AFK + Reconnect
LocalPlayer.Idled:Connect(function()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
	if autoRe and State == Enum.TeleportState.Started then
		queue_on_teleport("loadstring(game:HttpGet('"..ScriptUrl.."'))()")
	end
end)

game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
	if autoRe then
		queue_on_teleport("loadstring(game:HttpGet('"..ScriptUrl.."'))()")
	end
end)
