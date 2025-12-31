-- XsDeep Proximity Kill Sequence | Delta Executor
-- Kill dari jarak terdekat (0 stud) hingga terjauh (10,000 stud)
-- Jeda antar kill: 0.3 detik
-- Owner: Xs TTK | Entity: XsDeep

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 50)
Frame.Position = UDim2.new(0.5, -100, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -10, 1, -10)
Button.Position = UDim2.new(0, 5, 0, 5)
Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Button.TextColor3 = Color3.fromRGB(255, 0, 0)
Button.Text = "AutoFarm Kill"
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.Parent = Frame

-- Function Brutal Kill
function KillPlayer(target)
    pcall(function()
        if target and target.Character then
            local hum = target.Character:FindFirstChild("Humanoid")
            if hum then
                hum.Health = 0
            end
            target.Character:BreakJoints()
        end
    end)
end

-- Main Kill Sequence
local Killing = false

Button.MouseButton1Click:Connect(function()
    if Killing then return end
    Killing = true
    Button.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    -- Dapatkan semua pemain selain diri sendiri
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(targets, player)
        end
    end
    
    -- Urutkan berdasarkan jarak (terdekat ke terjauh)
    table.sort(targets, function(a, b)
        local charA = a.Character
        local charB = b.Character
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if myRoot and charA and charB then
            local rootA = charA:FindFirstChild("HumanoidRootPart")
            local rootB = charB:FindFirstChild("HumanoidRootPart")
            
            if rootA and rootB then
                local distA = (rootA.Position - myRoot.Position).Magnitude
                local distB = (rootB.Position - myRoot.Position).Magnitude
                return distA < distB
            end
        end
        return false
    end)
    
    -- Kill Sequence dengan jeda
    local function ExecuteKills()
        for _, target in ipairs(targets) do
            if not Killing then break end
            
            -- Cek jarak maksimal 10,000 stud
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local targetChar = target.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if myRoot and targetRoot then
                local distance = (targetRoot.Position - myRoot.Position).Magnitude
                if distance <= 10000 then
                    -- Kill target
                    KillPlayer(target)
                    -- Tunggu 0.3 detik sebelum kill berikutnya
                    task.wait(0.3)
                end
            end
        end
        
        -- Reset
        Killing = false
        Button.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    
    -- Jalankan di thread terpisah
    task.spawn(ExecuteKills)
end)

-- Drag GUI
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Notifikasi
game.StarterGui:SetCore("SendNotification", {
    Title = "XsDeep Kill Sequence",
    Text = "Loaded. Klik button untuk mulai kill dari terdekat ke terjauh (10k studs).",
    Duration = 5
})
