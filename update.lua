local key = "phucmax91"

-- UI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local KeyBox = Instance.new("TextBox")
local SubmitBtn = Instance.new("TextButton")
local GetKeyBtn = Instance.new("TextButton")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "KeySystem"

Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Position = UDim2.new(0.5, -150, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "bypass link get key help me 😊"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Parent = Frame

KeyBox.Size = UDim2.new(0.8, 0, 0, 30)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.PlaceholderText = "Enter your key here..."
KeyBox.Font = Enum.Font.SourceSans
KeyBox.Text = ""
KeyBox.TextSize = 18
KeyBox.TextColor3 = Color3.new(1, 1, 1)
KeyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
KeyBox.BorderSizePixel = 0
KeyBox.Parent = Frame

SubmitBtn.Size = UDim2.new(0.35, 0, 0, 30)
SubmitBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
SubmitBtn.Text = "Submit Key"
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.TextSize = 18
SubmitBtn.TextColor3 = Color3.new(1, 1, 1)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
SubmitBtn.BorderSizePixel = 0
SubmitBtn.Parent = Frame

GetKeyBtn.Size = UDim2.new(0.35, 0, 0, 30)
GetKeyBtn.Position = UDim2.new(0.55, 0, 0.6, 0)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.Font = Enum.Font.SourceSansBold
GetKeyBtn.TextSize = 18
GetKeyBtn.TextColor3 = Color3.new(1, 1, 1)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Parent = Frame

SubmitBtn.MouseButton1Click:Connect(function()
	if KeyBox.Text == key then
		ScreenGui:Destroy()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/menu.lua"))()
	else
		Title.Text = "❌ Wrong Key!"
		Title.TextColor3 = Color3.fromRGB(255, 0, 0)
	end
end)

GetKeyBtn.MouseButton1Click:Connect(function()
	setclipboard("https://link4sub.com/ZpR8") -- thay link key thật nếu có
end)
