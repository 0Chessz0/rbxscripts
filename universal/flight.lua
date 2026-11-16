local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local global = getgenv and getgenv()

if global and global.UniversalFlightCleanup then
    pcall(global.UniversalFlightCleanup)
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Universal Flight",
    LoadingTitle = "Universal Flight",
    LoadingSubtitle = "By Chessz0",
    ShowText = "Universal Flight",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local Tab = Window:CreateTab("Flight", "plane")

local enabled = false
local speed = 60
local velocity, gyro, loop, humanoid
local oldPlatformStand, oldAutoRotate
local toggle

local function stop()
    enabled = false

    if loop then
        loop:Disconnect()
        loop = nil
    end

    if velocity then
        velocity:Destroy()
        velocity = nil
    end

    if gyro then
        gyro:Destroy()
        gyro = nil
    end

    if humanoid and humanoid.Parent then
        humanoid.PlatformStand = oldPlatformStand
        humanoid.AutoRotate = oldAutoRotate

        if humanoid.Health > 0 and not oldPlatformStand then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    humanoid = nil
end

local function fly()
    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not root or hum.Health <= 0 then
        return false
    end

    humanoid = hum
    oldPlatformStand = hum.PlatformStand
    oldAutoRotate = hum.AutoRotate

    velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    velocity.P = 20000
    velocity.Velocity = Vector3.zero
    velocity.Parent = root

    gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    gyro.P = 20000
    gyro.D = 1000
    gyro.CFrame = root.CFrame
    gyro.Parent = root

    hum.PlatformStand = true
    hum.AutoRotate = false
    enabled = true

    loop = RunService.RenderStepped:Connect(function()
        if hum.Health <= 0 or not root.Parent then
            stop()
            if toggle then toggle:Set(false) end
            return
        end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local cf = cam.CFrame
        local dir = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            dir += cf.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            dir -= cf.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            dir -= cf.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            dir += cf.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir -= Vector3.yAxis
        end

        velocity.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero

        local look = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
        if look.Magnitude > 0.001 then
            gyro.CFrame = CFrame.lookAt(root.Position, root.Position + look)
        end
    end)

    return true
end

toggle = Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "UniversalFlight",
    Callback = function(value)
        if value then
            if not enabled and not fly() then
                task.defer(function()
                    toggle:Set(false)
                end)
            end
        else
            stop()
        end
    end
})

Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 60,
    Flag = "UniversalFlightSpeed",
    Callback = function(value)
        speed = value
    end
})

local keybind = Tab:CreateKeybind({
    Name = "Toggle Key",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "UniversalFlightKey",
    Callback = function()
        toggle:Set(not enabled)
    end
})

Tab:CreateLabel("By Chessz0")

local respawn = player.CharacterRemoving:Connect(function()
    stop()
    if toggle then toggle:Set(false) end
end)

if global then
    global.UniversalFlightCleanup = function()
        stop()
        respawn:Disconnect()
        Rayfield:Destroy()
        global.UniversalFlightCleanup = nil
    end
end
