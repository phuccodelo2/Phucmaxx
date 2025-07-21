local correctKey = "phucmax91"
local keySaved = getgenv().phucmaxKey or nil

if keySaved == correctKey then
    -- Nếu key đã lưu và đúng, load script luôn
    loadstring(game:HttpGet("https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/menu.lua"))()
else
    -- UI nhập key
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    local Frame = Instance.new("Frame", ScreenGui)
    local TextBox = Instance.new("TextBox", Frame)
    local GetKeyBtn = Instance.new("TextButton", Frame)
    local SubmitBtn = Instance.new("TextButton", Frame)
    local InfoLabel = Instance.new("TextLabel", Frame)

    -- UI config
    ScreenGui.Name = "PhucMaxKeyUI"
    Frame.Size = UDim2.new(0, 300, 0, 180)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -90)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0

    InfoLabel.Size = UDim2.new(1, 0, 0, 30)
    InfoLabel.Position = UDim2.new(0, 0, 0, 0)
    InfoLabel.Text = "Enter Key to use PHUCMAX"
    InfoLabel.TextColor3 = Color3.fromRGB(255,255,255)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Enum.Font.SourceSansBold
    InfoLabel.TextSize = 18

    TextBox.Size = UDim2.new(0.9, 0, 0, 30)
    TextBox.Position = UDim2.new(0.05, 0, 0, 40)
    TextBox.PlaceholderText = "Enter your key here"
    TextBox.Text = ""
    TextBox.Font = Enum.Font.SourceSans
    TextBox.TextSize = 16
    TextBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    TextBox.TextColor3 = Color3.fromRGB(255,255,255)

    GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 30)
    GetKeyBtn.Position = UDim2.new(0.05, 0, 0, 90)
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    GetKeyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    GetKeyBtn.Font = Enum.Font.SourceSansBold
    GetKeyBtn.TextSize = 16

    SubmitBtn.Size = UDim2.new(0.4, 0, 0, 30)
    SubmitBtn.Position = UDim2.new(0.55, 0, 0, 90)
    SubmitBtn.Text = "Submit"
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    SubmitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    SubmitBtn.Font = Enum.Font.SourceSansBold
    SubmitBtn.TextSize = 16

    -- Button function
    GetKeyBtn.MouseButton1Click:Connect(function()
        setclipboard("https://link4sub.com/ZpR8") -- thay link này nếu cần
        InfoLabel.Text = "Link copied to clipboard!"
    end)

    SubmitBtn.MouseButton1Click:Connect(function()
        if TextBox.Text == correctKey then
            InfoLabel.Text = "Correct key! Loading script..."
            getgenv().phucmaxKey = TextBox.Text
            wait(1)
            ScreenGui:Destroy()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/phuccodelo2/Phucmaxx/refs/heads/main/menu.lua"))()
        else
            InfoLabel.Text = "Wrong key! Try again."
        end
    end)
end
