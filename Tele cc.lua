local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- UI Setup
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PHUCMAX_UI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 70)
frame.Position = UDim2.new(0, 50, 0.5, -35)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(0.8, 0, 0, 30)
button.Position = UDim2.new(0.1, 0, 0.5, -15)
button.Text = "FLY TO BASE"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
Instance.new("UICorner", button)

-- CONFIG
local speed = 60
local flyHeight = 70

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

-- FIND BASE PART
local baseFolder = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("Bases")

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

-- FLY SETUP
local flying = false
local AP = Instance.new("AlignPosition")
AP.MaxForce = 999999
AP.MaxVelocity = math.huge
AP.Responsiveness = 200
AP.Mode = Enum.PositionAlignmentMode.OneAttachment
AP.RigidityEnabled = true
AP.Parent = HRP

local att = Instance.new("Attachment", HRP)
AP.Attachment0 = att

-- BAY RA ĐIỂM
local function flyTo(targetPos)
	if flying then return end
	flying = true

	-- Bay lên cao
	HRP.CFrame = HRP.CFrame + Vector3.new(0, flyHeight, 0)

	-- Fly đến mục tiêu
	RunService:BindToRenderStep("PhucFlyToBase", Enum.RenderPriority.Character.Value, function()
		if not flying then return end
		local dir = (targetPos - HRP.Position).Unit
		AP.Position = HRP.Position + dir * speed * 0.1

		if (HRP.Position - targetPos).Magnitude <= 8 then
			flying = false
			RunService:UnbindFromRenderStep("PhucFlyToBase")
			AP:Destroy()
			att:Destroy()
		end
	end)
end

-- BẤM NÚT UI
button.MouseButton1Click:Connect(function()
	local basePart = findMyBasePart()
	if basePart then
		local target = getNearestPoint(basePart.Position)
		if target then
			flyTo(target)
		else
			warn("Không tìm được tọa độ gần base")
		end
	else
		warn("Không tìm thấy base của bạn")
	end
end)
