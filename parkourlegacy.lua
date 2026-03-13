local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Window = Rayfield:CreateWindow({
    Name = "script by hello nigger Flux_axolotl nigger",
    LoadingTitle = "시발시발",
    LoadingSubtitle = "hello nigger",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ParkourHack",
        FileName = "ParkourSettings"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Movement Hacks", 4483362458)

local speedVal = 100  -- УВЕЛИЧЕНО С 65 ДО 100
local jumpVal = 50    -- УВЕЛИЧЕНО С 35 ДО 50
local infLoop = false
local infJump = false
local noFallDamage = false
local conn = nil
local bv = nil
local originalWalkSpeed = 16

-- Update func ФИКС: bv обновляется ВСЕГДА → stop когда Magnitude=0
local function update()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
   
    -- Jump
    hum.UseJumpPower = false
    hum.JumpHeight = jumpVal
   
    -- Speed ФИКС: всегда обновляем bv.Velocity (0 при остановке!)
    if not bv or not bv.Parent then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(100000, 0, 100000)  -- УВЕЛИЧЕНА СИЛА
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root
    end
    local moveVel = hum.MoveDirection * speedVal
    bv.Velocity = Vector3.new(moveVel.X, 0, moveVel.Z)
end

-- ФУНКЦИЯ NO FALL DAMAGE (ИСПРАВЛЕННАЯ)
local function setupNoFallDamage()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Сохраняем оригинальную скорость
    originalWalkSpeed = humanoid.WalkSpeed
    
    -- Метод 1: Отключаем урон от падения полностью
    if humanoid:FindFirstChild("TakeDamage") then
        humanoid.TakeDamage:Connect(function(damageInfo)
            if noFallDamage then
                damageInfo:SetProperty("Damage", 0)
            end
        end)
    end
    
    -- Метод 2: Защита через StateChanged (более надежный)
    local function onStateChanged(oldState, newState)
        if noFallDamage then
            -- Если персонаж начинает падать или получать урон от падения
            if newState == Enum.HumanoidStateType.FallingDown or 
               newState == Enum.HumanoidStateType.PlatformStanding then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
    
    humanoid.StateChanged:Connect(onStateChanged)
    
    -- Метод 3: Защита через Health изменение
    local function onHealthChanged(health)
        if noFallDamage and health < humanoid.MaxHealth then
            -- Если здоровье уменьшилось (возможно от падения), восстанавливаем
            humanoid.Health = humanoid.MaxHealth
        end
    end
    
    humanoid.HealthChanged:Connect(onHealthChanged)
    
    -- Метод 4: Через физику (самый надежный)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        -- Добавляем защиту от урона
        local bodyForce = Instance.new("BodyForce")
        bodyForce.Name = "AntiFallDamage"
        bodyForce.Force = Vector3.new(0, character:GetMass() * 196.2, 0)  -- Сила против гравитации
        
        RunService.Heartbeat:Connect(function()
            if noFallDamage and rootPart then
                -- Если скорость падения слишком высокая, уменьшаем ее
                local velocity = rootPart.Velocity
                if velocity.Y < -100 then  -- Если падаем слишком быстро
                    bodyForce.Force = Vector3.new(0, character:GetMass() * 250, 0)
                    bodyForce.Parent = rootPart
                else
                    bodyForce.Force = Vector3.new(0, character:GetMass() * 196.2, 0)
                end
            else
                bodyForce:Destroy()
            end
        end)
    end
end

Tab:CreateSlider({
    Name = "Speed (50-500)",  -- УВЕЛИЧЕН ДИАПАЗОН
    Range = {50, 500},        -- МАКСИМУМ 500!
    Increment = 10,
    CurrentValue = 100,       -- УВЕЛИЧЕНО С 65
    Flag = "SpeedSlider",
    Callback = function(Value)
        speedVal = Value
        Rayfield:Notify({
            Title = "⚡ ULTRA SPEED",
            Content = "Скорость: " .. Value .. " (СУПЕР БЫСТРО!)",
            Duration = 2.5,
            Image = 4483362458
        })
    end,
})

Tab:CreateSlider({
    Name = "Jump Height (20-200)",  -- УВЕЛИЧЕН ДИАПАЗОН
    Range = {20, 200},              -- МАКСИМУМ 200!
    Increment = 5,
    CurrentValue = 50,              -- УВЕЛИЧЕНО С 35
    Flag = "JumpSlider",
    Callback = function(Value)
        jumpVal = Value
        Rayfield:Notify({
            Title = "🦘 MEGA JUMP",
            Content = "Высота прыжка: " .. Value .. " (ОЧЕНЬ ВЫСОКО!)",
            Duration = 2.5,
            Image = 4483362458
        })
    end,
})

Tab:CreateToggle({
    Name = "Infinite (анти-ресет после смерти)",
    CurrentValue = false,
    Flag = "InfiniteToggle",
    Callback = function(state)
        infLoop = state
        if state then
            conn = RunService.Heartbeat:Connect(update)
            Rayfield:Notify({
                Title = "♾️ Infinite ON",
                Content = "СУПЕР-бег + прыжок навсегда! (Стопит при отпускании клавиш)",
                Duration = 3,
                Image = 4483362458
            })
        else
            if conn then conn:Disconnect() conn = nil end
            if bv then bv:Destroy() bv = nil end
            Rayfield:Notify({
                Title = "Infinite OFF",
                Content = "Выключено",
                Duration = 2
            })
        end
    end,
})

Tab:CreateToggle({
    Name = "Inf Jump (SPACE в воздухе)",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(state)
        infJump = state
        Rayfield:Notify({
            Title = "Inf Jump",
            Content = state and "ВКЛ (SPACE везде!)" or "ВЫКЛ",
            Duration = 2.5,
            Image = 4483362458
        })
    end,
})

Tab:CreateToggle({
    Name = "🛡️ No Fall Damage (100% защита)",
    CurrentValue = false,
    Flag = "NoFallDamageToggle",
    Callback = function(state)
        noFallDamage = state
        if state then
            -- Немедленно применяем защиту
            setupNoFallDamage()
            
            -- Также защищаем через изменение WalkSpeed
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = originalWalkSpeed
                end
            end
            
            Rayfield:Notify({
                Title = "🛡️ NO FALL DAMAGE ON",
                Content = "Теперь вы НЕПОБЕДИМЫ! Урон от падения отключен!",
                Duration = 4,
                Image = 4483362458
            })
        else
            -- Восстанавливаем нормальную скорость
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = originalWalkSpeed
                end
            end
            
            Rayfield:Notify({
                Title = "No Fall Damage OFF",
                Content = "Урон от падения снова активен",
                Duration = 2.5,
                Image = 4483362458
            })
        end
    end,
})

-- Inf Jump (твой код)
UIS.JumpRequest:Connect(function()
    if infJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Respawn fix (bv clean + restart)
player.CharacterAdded:Connect(function(character)
    task.wait(0.5)  -- Уменьшил ожидание для более быстрой инициализации
    
    -- Очистка старых соединений
    if bv then bv:Destroy() bv = nil end
    
    -- Перезапуск Infinite если активно
    if infLoop then
        if conn then conn:Disconnect() end
        conn = RunService.Heartbeat:Connect(update)
    end
    
    -- Перезапуск No Fall Damage если активно
    if noFallDamage then
        task.wait(0.2)
        setupNoFallDamage()
    end
    
    -- Установка скорости и прыжка
    task.wait(0.3)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        originalWalkSpeed = humanoid.WalkSpeed
        humanoid.UseJumpPower = false
        humanoid.JumpHeight = jumpVal
        
        if noFallDamage then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end)

-- Автоматическое включение No Fall Damage при старте
task.wait(1)
if noFallDamage then
    setupNoFallDamage()
end

Rayfield:Notify({
    Title = "✅ RAYFIELD ЗАГРУЖЕН!",
    Content = "⚡ СУПЕР СКОРОСТЬ + 🛡️ ЗАЩИТА ОТ ПАДЕНИЯ!\nСкорость: 100 | Прыжок: 50 | Infinite = идеальный стоп!",
    Duration = 8,
    Image = 4483362458
})

Rayfield:LoadConfiguration()
