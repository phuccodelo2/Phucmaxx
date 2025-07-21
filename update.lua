local key = "phucmax91"
local keyFile = "phucmaxkey.txt"
local mainScriptURL = "https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/menu.lua"
local getKeyLink = "https://link4sub.com/ZpR8" -- Thay bằng link get key thật

-- Kiểm tra nếu key đã lưu từ trước
if pcall(function() return readfile(keyFile) end) and readfile(keyFile) == key then
    loadstring(game:HttpGet(mainScriptURL))()
    return
end

-- Tạo UI nhập key
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KeySystem"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Position = UDim2.new(0.5, -150, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local TextLabel = Instance.new("TextLabel", Frame)
TextLabel.Size = UDim2.new(1, 0, 0, 40)
TextLabel.Text = "Enter your key"
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
TextLabel.BackgroundTransparency = 1
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.TextSize = 24

local TextBox = Instance.new("TextBox", Frame)
TextBox.Position = UDim2.new(0, 20, 0, 50)
TextBox.Size = UDim2.new(1, -40, 0, 30)
TextBox.PlaceholderText = "Enter key here..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(0,0,0)
TextBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
TextBox.ClearTextOnFocus = false

local GetKeyBtn = Instance.new("TextButton", Frame)
GetKeyBtn.Position = UDim2.new(0, 20, 0, 90)
GetKeyBtn.Size = UDim2.new(1, -40, 0, 30)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
GetKeyBtn.TextColor3 = Color3.fromRGB(255,255,255)
GetKeyBtn.Font = Enum.Font.SourceSansBold
GetKeyBtn.TextSize = 18
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(getKeyLink)
    GetKeyBtn.Text = "Copied link!"
end)

local SubmitBtn = Instance.new("TextButton", Frame)
SubmitBtn.Position = UDim2.new(0, 20, 0, 130)
SubmitBtn.Size = UDim2.new(1, -40, 0, 30)
SubmitBtn.Text = "Submit Key"
SubmitBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 100)
SubmitBtn.TextColor3 = Color3.fromRGB(255,255,255)
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.TextSize = 18

SubmitBtn.MouseButton1Click:Connect(function()
    if TextBox.Text == key then
        writefile(keyFile, key)
        ScreenGui:Destroy()
        loadstring(game:HttpGet(mainScriptURL))()
    else
        SubmitBtn.Text = "Wrong key!"
        wait(1)
        SubmitBtn.Text = "Submit Key"
    end
end)
