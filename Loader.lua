-- =============================================================================
-- 🚀 LOADER — Phát hiện player, click Play UI, rồi chạy main script
-- =============================================================================

-- ⚙️ CẤU HÌNH
local ALLOWED_USERNAMES = {
    "eaxkebvvbd",
    "jiaoztmawz",
    "cdsghsa223",
}
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/phuoculi1810-hub/strength_clone1/refs/heads/main/main.lua"

-- =============================================================================
-- 1. ĐỢI LOCAL PLAYER LOAD XONG
-- =============================================================================
local Players = game:GetService("Players")
local VIM     = game:GetService("VirtualInputManager")
local player  = Players.LocalPlayer

while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
    task.wait(0.5)
end
print("✅ LocalPlayer load xong:", player.Name)

-- =============================================================================
-- 2. KIỂM TRA USERNAME
-- =============================================================================
local allowed = false
for _, name in ipairs(ALLOWED_USERNAMES) do
    if string.lower(player.Name) == string.lower(name) then
        allowed = true
        break
    end
end
if not allowed then
    print("⛔ Username không khớp (" .. player.Name .. "), không chạy script.")
    return
end
print("✅ Username khớp: " .. player.Name)

-- =============================================================================
-- 3. CLICK PLAY NOW
-- =============================================================================
local playerGui = player:WaitForChild("PlayerGui")

local function isRenderedOnScreen(g)
    if not g.Visible then return false end
    if g.AbsoluteSize.X <= 0 or g.AbsoluteSize.Y <= 0 then return false end
    local screenSize = workspace.CurrentCamera.ViewportSize
    local ax = g.AbsolutePosition.X
    local ay = g.AbsolutePosition.Y
    if ax < 0 or ay < 0 then return false end
    if ax > screenSize.X or ay > screenSize.Y then return false end
    local p = g.Parent
    while p do
        if p:IsA("GuiObject") and not p.Visible then return false end
        if p:IsA("ScreenGui") and not p.Enabled then return false end
        p = p.Parent
    end
    return true
end

local function clickButton(g)
    local cx = g.AbsolutePosition.X + g.AbsoluteSize.X / 2
    local cy = g.AbsolutePosition.Y + g.AbsoluteSize.Y / 2
    print("   → Click tại tọa độ:", cx, cy)

    pcall(function()
        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait(0.08)
        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end)
    task.wait(0.1)

    pcall(function() firesignal(g.MouseButton1Down) end)
    task.wait(0.05)
    pcall(function() firesignal(g.MouseButton1Click) end)
    task.wait(0.05)
    pcall(function() firesignal(g.MouseButton1Up) end)
    task.wait(0.05)

    pcall(function() g:Activate() end)

    if getconnections then
        for _, conn in pairs(getconnections(g.MouseButton1Click)) do
            pcall(function() conn:Fire() end)
        end
        for _, conn in pairs(getconnections(g.Activated)) do
            pcall(function() conn:Fire() end)
        end
    end
end

local function clickPlayNow()
    print("🖱️ Đang chờ nút Play thực sự render trên màn hình...")
    local timeout = 60
    local elapsed = 0
    while elapsed < timeout do
        for _, g in ipairs(playerGui:GetDescendants()) do
            if (g:IsA("TextButton") or g:IsA("ImageButton"))
            and g.Name:lower() == "play"
            and isRenderedOnScreen(g) then
                print("🖱️ Nút Play đã render:", g:GetFullName())
                print("   ABS POS:", g.AbsolutePosition)
                print("   ABS SIZE:", g.AbsoluteSize)
                clickButton(g)
                print("✅ Đã click Play Now!")
                return true
            end
        end
        task.wait(0.3)
        elapsed = elapsed + 0.3
    end
    print("ℹ️ Hết timeout 60s — tiếp tục chạy main.")
    return false
end

local function waitForPlayButtonGone()
    print("⏳ Đợi UI Play biến mất...")
    local timeout = 60
    local elapsed = 0
    while elapsed < timeout do
        local found = false
        for _, g in ipairs(playerGui:GetDescendants()) do
            if (g:IsA("TextButton") or g:IsA("ImageButton"))
            and g.Name:lower() == "play"
            and isRenderedOnScreen(g) then
                found = true; break
            end
        end
        if not found then
            print("✅ Nút Play đã biến mất — map đang load!")
            break
        end
        task.wait(0.5)
        elapsed = elapsed + 0.5
    end
end

clickPlayNow()
waitForPlayButtonGone()
task.wait(1)

-- =============================================================================
-- 4. CHẠY MAIN SCRIPT QUA LOADSTRING
-- =============================================================================
print("🚀 Đang load main script...")
local ok, err = pcall(function()
    loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
end)

if not ok then
    warn("❌ Lỗi khi chạy main script: " .. tostring(err))
else
    print("✅ Main script đã chạy!")
end
