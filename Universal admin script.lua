local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- State Variables
local isFlying = false
local isNoclipping = false
local isSpeedOn = false
local isJumpOn = false
local isMinimized = false

local speedVal = 16
local jumpVal = 50
local flySpeed = 50

local noclipConnection, flyConnection = nil, nil
local bv, bg = nil, nil

-- Main ScreenGui
local UtilityGui = Instance.new("ScreenGui")
UtilityGui.Name = "Neon_Movement_Hub"
UtilityGui.Parent = CoreGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 310)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 128)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = UtilityGui

-- Header
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " Movement Engine [Neon]"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.TextSize = 11

-- Floating Minimize Icon
local OpenBtn = Instance.new("TextButton", UtilityGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
OpenBtn.Text = "🏃"
OpenBtn.TextSize = 20
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
OpenBtn.BorderColor3 = Color3.fromRGB(0, 255, 128)
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true

-- Minimize Button (-)
local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -50, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.TextSize = 18
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 128)

-- Close Button (X)
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextSize = 14
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local function toggleMinimize()
    isMinimized = not isMinimized
    MainFrame.Visible = not isMinimized
    OpenBtn.Visible = isMinimized
end

MinimizeBtn.MouseButton1Click:Connect(toggleMinimize)
OpenBtn.MouseButton1Click:Connect(toggleMinimize)

-- Cleanup function for Close Button
CloseBtn.MouseButton1Click:Connect(function()
    if flyConnection then flyConnection:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    UtilityGui:Destroy()
end)

-- Main Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -10, 1, -35)
Container.Position = UDim2.new(0, 5, 0, 30)
Container.BackgroundTransparency = 1

---------------------------------------------------------
-- TOUCH SLIDER BUILDER
---------------------------------------------------------
local function createSlider(yPos, text, minVal, maxVal, defaultVal, callback)
    local Label = Instance.new("TextLabel", Container)
    Label.Text = text .. ": " .. defaultVal
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.Position = UDim2.new(0, 0, 0, yPos)
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 10

    local SliderBg = Instance.new("Frame", Container)
    SliderBg.Size = UDim2.new(1, 0, 0, 12)
    SliderBg.Position = UDim2.new(0, 0, 0, yPos + 18)
    SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local SliderFill = Instance.new("Frame", SliderBg)
    SliderFill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 128)

    local UserInputService = game:GetService("UserInputService")
    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(minVal + (maxVal - minVal) * pos)
        Label.Text = text .. ": " .. val
        callback(val)
    end

    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

---------------------------------------------------------
-- 1. WALKSPEED (TOGGLE + SLIDER)
---------------------------------------------------------
local SpeedBtn = Instance.new("TextButton", Container)
SpeedBtn.Size = UDim2.new(1, 0, 0, 22)
SpeedBtn.Position = UDim2.new(0, 0, 0, 0)
SpeedBtn.Text = "WalkSpeed: OFF"
SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

createSlider(25, "Speed Value", 16, 300, 16, function(val)
    speedVal = val
    if isSpeedOn and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speedVal end
    end
end)

SpeedBtn.MouseButton1Click:Connect(function()
    isSpeedOn = not isSpeedOn
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if isSpeedOn then
        SpeedBtn.Text = "WalkSpeed: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
        SpeedBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
        if hum then hum.WalkSpeed = speedVal end
    else
        SpeedBtn.Text = "WalkSpeed: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        if hum then hum.WalkSpeed = 16 end
    end
end)

---------------------------------------------------------
-- 2. JUMPPOWER (TOGGLE + SLIDER)
---------------------------------------------------------
local JumpBtn = Instance.new("TextButton", Container)
JumpBtn.Size = UDim2.new(1, 0, 0, 22)
JumpBtn.Position = UDim2.new(0, 0, 0, 65)
JumpBtn.Text = "JumpPower: OFF"
JumpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

createSlider(90, "Jump Value", 50, 500, 50, function(val)
    jumpVal = val
    if isJumpOn and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then 
            hum.UseJumpPower = true
            hum.JumpPower = jumpVal 
        end
    end
end)

JumpBtn.MouseButton1Click:Connect(function()
    isJumpOn = not isJumpOn
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if isJumpOn then
        JumpBtn.Text = "JumpPower: ON"
        JumpBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
        JumpBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
        if hum then 
            hum.UseJumpPower = true
            hum.JumpPower = jumpVal 
        end
    else
        JumpBtn.Text = "JumpPower: OFF"
        JumpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        if hum then hum.JumpPower = 50 end
    end
end)

---------------------------------------------------------
-- 3. FLY (TOGGLE + SLIDER)
---------------------------------------------------------
local FlyBtn = Instance.new("TextButton", Container)
FlyBtn.Size = UDim2.new(1, 0, 0, 22)
FlyBtn.Position = UDim2.new(0, 0, 0, 130)
FlyBtn.Text = "Fly Mode: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

createSlider(155, "Fly Speed", 10, 300, 50, function(val)
    flySpeed = val
end)

FlyBtn.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum then return end

    if isFlying then
        FlyBtn.Text = "Fly Mode: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
        FlyBtn.TextColor3 = Color3.fromRGB(15, 15, 15)

        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        flyConnection = RunService.RenderStepped:Connect(function()
            if isFlying and hrp and Workspace.CurrentCamera then
                local cam = Workspace.CurrentCamera
                bg.CFrame = cam.CFrame
                
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    bv.Velocity = cam.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z).Unit * flySpeed)
                else
                    bv.Velocity = Vector3.zero
                end
            end
        end)
    else
        FlyBtn.Text = "Fly Mode: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        if flyConnection then flyConnection:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

---------------------------------------------------------
-- 4. NOCLIP TOGGLE
---------------------------------------------------------
local NoclipBtn = Instance.new("TextButton", Container)
NoclipBtn.Size = UDim2.new(1, 0, 0, 25)
NoclipBtn.Position = UDim2.new(0, 0, 0, 200)
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

NoclipBtn.MouseButton1Click:Connect(function()
    isNoclipping = not isNoclipping
    if isNoclipping then
        NoclipBtn.Text = "Noclip: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
        NoclipBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        NoclipBtn.Text = "Noclip: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end)
