local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local boostAktif = false
local enforceConnection = nil
local boostGui, boostBtn, rainbowStroke

local function startEnforceSpeed()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	enforceConnection = RunService.Heartbeat:Connect(function()
		if humanoid.WalkSpeed ~= 50 then
			humanoid.WalkSpeed = 50
		end
	end)

	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if boostAktif and humanoid.WalkSpeed ~= 50 then
			humanoid.WalkSpeed = 50
		end
	end)
end

local function stopEnforceSpeed()
	if enforceConnection then
		enforceConnection:Disconnect()
		enforceConnection = nil
	end

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 20
		end
	end
end

local function updateRainbow()
	local t = 0
	RunService.RenderStepped:Connect(function()
		t = t + 0.01
		local r = math.sin(t) * 127 + 128
		local g = math.sin(t + 2) * 127 + 128
		local b = math.sin(t + 4) * 127 + 128
		if rainbowStroke then
			rainbowStroke.Color = Color3.fromRGB(r, g, b)
		end
	end)
end

local function buatBoostGUI()
	boostGui = Instance.new("ScreenGui")
	boostGui.Name = "BoostGUI"
	boostGui.ResetOnSpawn = false
	boostGui.Parent = player:WaitForChild("PlayerGui")

	boostBtn = Instance.new("TextButton")
	boostBtn.Size = UDim2.new(0, 100, 0, 35)
	boostBtn.Position = UDim2.new(0.5, 0, 1, -70)
	boostBtn.AnchorPoint = Vector2.new(0.5, 1)
	boostBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	boostBtn.TextColor3 = Color3.new(1, 1, 1)
	boostBtn.Font = Enum.Font.GothamBold
	boostBtn.TextSize = 15
	boostBtn.BorderSizePixel = 0
	boostBtn.AutoButtonColor = false
	boostBtn.Text = "Tuấn Anh IOS"
	boostBtn.Parent = boostGui

	-- Bo góc
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = boostBtn

	-- Viền 7 màu (UIStroke động)
	rainbowStroke = Instance.new("UIStroke")
	rainbowStroke.Thickness = 2
	rainbowStroke.Transparency = 0
	rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	rainbowStroke.Parent = boostBtn

	-- Bắt đầu đổi màu viền
	updateRainbow()

	-- Khi click vào nút
	boostBtn.MouseButton1Click:Connect(function()
		boostAktif = not boostAktif
		if boostAktif then
			boostBtn.Text = "Speed ON"
			startEnforceSpeed()
		else
			boostBtn.Text = "Speed OFF"
			stopEnforceSpeed()
		end
	end)
end

buatBoostGUI()