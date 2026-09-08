_G.ESPEnabled = true
_G.UseTeamColor = true

_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Toggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 80, 0, 28)
Button.Position = UDim2.new(0, 20, 0, 100)
Button.Text = "ESP: ON"
Button.TextSize = 13
Button.Active = true
Button.BackgroundTransparency = 0.2
Button.Parent = ScreenGui

-- =========================
-- ESP
-- =========================

local function CreateESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local character = player.Character
    local highlight = character:FindFirstChild("ESP_Highlight")

    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
    end

    local color

    if _G.UseTeamColor then
        color = player.TeamColor.Color
    elseif LocalPlayer.TeamColor == player.TeamColor then
        color = _G.FriendColor
    else
        color = _G.EnemyColor
    end

    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Enabled = _G.ESPEnabled
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if _G.ESPEnabled then
                CreateESP(player)
            else
                local esp = player.Character:FindFirstChild("ESP_Highlight")
                if esp then
                    esp.Enabled = false
                end
            end
        end
    end
end

-- =========================
-- ปุ่มเปิด / ปิด + ลาก
-- =========================

local dragging = false
local dragStart
local startPos
local moved = false

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        moved = false
        dragStart = input.Position
        startPos = Button.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            moved = true
        end

        Button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        if dragging and not moved then
            _G.ESPEnabled = not _G.ESPEnabled

            Button.Text = _G.ESPEnabled
                and "ESP: ON"
                or "ESP: OFF"

            UpdateESP()
        end

        dragging = false
    end
end)

-- =========================
-- ผู้เล่น / ตัวละคร
-- =========================

local function SetupPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        CreateESP(player)
    end)

    if player.Character then
        CreateESP(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

Players.PlayerAdded:Connect(SetupPlayer)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        local esp = player.Character:FindFirstChild("ESP_Highlight")
        if esp then
            esp:Destroy()
        end
    end
end)

-- อัปเดตสีทีม
while task.wait(1) do
    UpdateESP()
end
