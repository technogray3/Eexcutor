local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ⚠️ YOUR RENDER BASE ENDPOINT
local BASE_URL = "https://my-krnl-hub-api.onrender.com"

-- Main ScreenGui
local KrnlGui = Instance.new("ScreenGui")
KrnlGui.Name = "Mobile_KRNL_Hub_AI"
KrnlGui.Parent = CoreGui

-- Mobile Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 250)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = KrnlGui

-- Top Header Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " KRNL Mobile Engine + Gemini AI"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.TextSize = 11

-- Sidebar Navigation
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 85, 1, -25)
Sidebar.Position = UDim2.new(0, 0, 0, 25)
Sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)

-- Content Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -90, 1, -28)
Container.Position = UDim2.new(0, 88, 0, 26)
Container.BackgroundTransparency = 1

-- Page Frames
local EditorPage = Instance.new("Frame", Container)
EditorPage.Size = UDim2.new(1, 0, 1, 0)
EditorPage.BackgroundTransparency = 1

local SearchPage = Instance.new("Frame", Container)
SearchPage.Size = UDim2.new(1, 0, 1, 0)
SearchPage.BackgroundTransparency = 1
SearchPage.Visible = false

local AIPage = Instance.new("Frame", Container)
AIPage.Size = UDim2.new(1, 0, 1, 0)
AIPage.BackgroundTransparency = 1
AIPage.Visible = false

local function showPage(target)
    EditorPage.Visible = (target == EditorPage)
    SearchPage.Visible = (target == SearchPage)
    AIPage.Visible = (target == AIPage)
end

local function createNavBtn(text, yPos, targetPage)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 10
    btn.MouseButton1Click:Connect(function() showPage(targetPage) end)
end

createNavBtn("Editor", 0, EditorPage)
createNavBtn("Search", 30, SearchPage)
createNavBtn("AI Gen", 60, AIPage)

---------------------------------------------------------
-- 1. EDITOR PAGE
---------------------------------------------------------
local ScriptBox = Instance.new("TextBox", EditorPage)
ScriptBox.Size = UDim2.new(1, -5, 0.75, 0)
ScriptBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScriptBox.TextColor3 = Color3.fromRGB(0, 255, 128)
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.ClearTextOnFocus = false
ScriptBox.MultiLine = true
ScriptBox.Text = "-- Mobile KRNL Engine Active"

local ExecBtn = Instance.new("TextButton", EditorPage)
ExecBtn.Size = UDim2.new(0.48, 0, 0.2, 0)
ExecBtn.Position = UDim2.new(0, 0, 0.8, 0)
ExecBtn.Text = "Execute"
ExecBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecBtn.MouseButton1Click:Connect(function()
    local func = loadstring(ScriptBox.Text)
    if func then func() end
end)

---------------------------------------------------------
-- 2. SEARCH PAGE
---------------------------------------------------------
local SearchBar = Instance.new("TextBox", SearchPage)
SearchBar.Size = UDim2.new(0, 190, 0, 25)
SearchBar.PlaceholderText = "Search scripts..."
SearchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)

local SearchSubmit = Instance.new("TextButton", SearchPage)
SearchSubmit.Size = UDim2.new(0, 80, 0, 25)
SearchSubmit.Position = UDim2.new(0, 195, 0, 0)
SearchSubmit.Text = "Fetch"
SearchSubmit.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SearchSubmit.TextColor3 = Color3.fromRGB(255, 255, 255)

local ScrollResults = Instance.new("ScrollingFrame", SearchPage)
ScrollResults.Size = UDim2.new(1, -5, 1, -30)
ScrollResults.Position = UDim2.new(0, 0, 0, 30)
ScrollResults.BackgroundTransparency = 1
ScrollResults.CanvasSize = UDim2.new(0, 0, 5, 0)

local UIList = Instance.new("UIListLayout", ScrollResults)
UIList.Padding = UDim.new(0, 4)

SearchSubmit.MouseButton1Click:Connect(function()
    for _, child in pairs(ScrollResults:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local url = BASE_URL .. "/api/search?q=" .. HttpService:UrlEncode(SearchBar.Text)
    local success, response = pcall(function() return game:HttpGet(url) end)

    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.results then
            for _, item in ipairs(data.results) do
                local Card = Instance.new("Frame", ScrollResults)
                Card.Size = UDim2.new(1, -8, 0, 45)
                Card.BackgroundColor3 = Color3.fromRGB(28, 28, 28)

                local CardTitle = Instance.new("TextLabel", Card)
                CardTitle.Text = item.title
                CardTitle.Size = UDim2.new(0.6, 0, 1, 0)
                CardTitle.Position = UDim2.new(0, 5, 0, 0)
                CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                CardTitle.TextXAlignment = Enum.TextXAlignment.Left
                CardTitle.TextSize = 10

                local RunBtn = Instance.new("TextButton", Card)
                RunBtn.Size = UDim2.new(0.3, 0, 0.6, 0)
                RunBtn.Position = UDim2.new(0.68, 0, 0.2, 0)
                RunBtn.Text = "Run"
                RunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                RunBtn.MouseButton1Click:Connect(function()
                    local func = loadstring(item.code)
                    if func then func() end
                end)
            end
        end
    end
end)

---------------------------------------------------------
-- 3. AI GENERATOR PAGE
---------------------------------------------------------
local AIPrompt = Instance.new("TextBox", AIPage)
AIPrompt.Size = UDim2.new(1, -5, 0, 35)
AIPrompt.PlaceholderText = "Describe script (e.g. WalkSpeed 100)..."
AIPrompt.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AIPrompt.TextColor3 = Color3.fromRGB(255, 255, 255)
AIPrompt.TextSize = 10

local AIBtn = Instance.new("TextButton", AIPage)
AIBtn.Size = UDim2.new(1, -5, 0, 25)
AIBtn.Position = UDim2.new(0, 0, 0, 40)
AIBtn.Text = "Generate Script with AI"
AIBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 200)
AIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local AIOutput = Instance.new("TextBox", AIPage)
AIOutput.Size = UDim2.new(1, -5, 1, -100)
AIOutput.Position = UDim2.new(0, 0, 0, 70)
AIOutput.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
AIOutput.TextColor3 = Color3.fromRGB(0, 220, 255)
AIOutput.TextXAlignment = Enum.TextXAlignment.Left
AIOutput.TextYAlignment = Enum.TextYAlignment.Top
AIOutput.ClearTextOnFocus = false
AIOutput.MultiLine = true
AIOutput.Text = "-- AI generated code will appear here..."

local AIRunBtn = Instance.new("TextButton", AIPage)
AIRunBtn.Size = UDim2.new(1, -5, 0, 25)
AIRunBtn.Position = UDim2.new(0, 0, 1, -25)
AIRunBtn.Text = "Run Generated AI Script"
AIRunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
AIRunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

AIBtn.MouseButton1Click:Connect(function()
    AIBtn.Text = "Generating..."
    local reqData = HttpService:JSONEncode({ prompt = AIPrompt.Text })
    
    local http_request = (syn and syn.request) or (http and http.request) or request or http_request
    if http_request then
        local success, response = pcall(function()
            return http_request({
                Url = BASE_URL .. "/api/ai-generate",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = reqData
            })
        end)

        if success and response and response.Body then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.script then
                AIOutput.Text = data.script
            else
                AIOutput.Text = "-- Error: " .. (data.error or "Unknown error")
            end
        else
            AIOutput.Text = "-- Failed to contact backend server"
        end
    else
        AIOutput.Text = "-- Your executor does not support custom HTTP requests"
    end
    AIBtn.Text = "Generate Script with AI"
end)

AIRunBtn.MouseButton1Click:Connect(function()
    local func = loadstring(AIOutput.Text)
    if func then func() end
end)
