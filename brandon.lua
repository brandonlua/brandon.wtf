local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
   bg      = Color3.fromRGB(20, 20, 20),
   panel   = Color3.fromRGB(30, 30, 30),
   topbar  = Color3.fromRGB(24, 24, 24),
   item    = Color3.fromRGB(38, 38, 38),
   border  = Color3.fromRGB(60, 60, 60),
   accent  = Color3.fromRGB(130, 80, 200),
   text    = Color3.fromRGB(255, 255, 255),
   muted   = Color3.fromRGB(200, 200, 200),
   dim     = Color3.fromRGB(130, 130, 130),
}

local config = {
   autoExecute  = false,
   autoSave     = false,
   autoLoad     = false,
   accentColor  = Color3.fromRGB(130, 80, 200),
}

local espEnabled          = false
local nameEnabled         = false
local fillEnabled         = false
local espObjects          = {}
local boxColor            = Color3.fromRGB(255, 255, 255)
local nameColor           = Color3.fromRGB(255, 255, 255)
local triggerbotEnabled   = false
local triggerReactionTime = 0.08
local triggerReleaseTime  = 0.05
local triggerFiring       = false

local accentColorSetters  = {}
local sliderFillRefs      = {}
local sliderValRefs       = {}
local checkboxFillRefs    = {}

local function applyAccent(color)
   C.accent = color
end

local function addOutlines(parent, borderClr)
   local o1 = Instance.new("ImageLabel")
   o1.BackgroundTransparency = 1
   o1.Size = UDim2.new(1, 0, 1, 0)
   o1.Image = "rbxassetid://2592362371"
   o1.ImageColor3 = borderClr or C.border
   o1.ScaleType = Enum.ScaleType.Slice
   o1.SliceCenter = Rect.new(2, 2, 62, 62)
   o1.ZIndex = parent.ZIndex + 1
   o1.Parent = parent

   local o2 = Instance.new("ImageLabel")
   o2.BackgroundTransparency = 1
   o2.Position = UDim2.new(0, 1, 0, 1)
   o2.Size = UDim2.new(1, -2, 1, -2)
   o2.Image = "rbxassetid://2592362371"
   o2.ImageColor3 = Color3.fromRGB(0, 0, 0)
   o2.ScaleType = Enum.ScaleType.Slice
   o2.SliceCenter = Rect.new(2, 2, 62, 62)
   o2.ZIndex = parent.ZIndex + 1
   o2.Parent = parent
end

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "ESPGui"
ESPGui.ResetOnSpawn = false
ESPGui.DisplayOrder = 999998
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = playerGui

local function createESPForPlayer(target)
   if target == player then return end
   if espObjects[target] then return end

   local outerBlack = Instance.new("Frame")
   outerBlack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
   outerBlack.BackgroundTransparency = 0.7
   outerBlack.BorderSizePixel = 0
   outerBlack.ZIndex = 8
   outerBlack.Parent = ESPGui

   local box = Instance.new("Frame")
   box.BackgroundTransparency = 1
   box.BorderSizePixel = 0
   box.ZIndex = 9
   box.Parent = ESPGui

   local uiStroke = Instance.new("UIStroke")
   uiStroke.Color = Color3.fromRGB(0, 0, 0)
   uiStroke.Thickness = 1
   uiStroke.Transparency = 0.7
   uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
   uiStroke.Parent = box

   local accentBorder = Instance.new("Frame")
   accentBorder.BackgroundTransparency = 1
   accentBorder.BorderSizePixel = 0
   accentBorder.ZIndex = 10
   accentBorder.Parent = ESPGui
   addOutlines(accentBorder, boxColor)
   local ch = accentBorder:GetChildren()
   if ch[2] then ch[2].ImageTransparency = 1 end

   local fill = Instance.new("Frame")
   fill.BackgroundColor3 = boxColor
   fill.BackgroundTransparency = 0.75
   fill.BorderSizePixel = 0
   fill.ZIndex = 7
   fill.Parent = ESPGui

   local nameLabel = Instance.new("TextLabel")
   nameLabel.BackgroundTransparency = 1
   nameLabel.TextColor3 = nameColor
   nameLabel.TextStrokeTransparency = 0.3
   nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
   nameLabel.TextSize = 13
   nameLabel.Font = Enum.Font.Code
   nameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
   nameLabel.ZIndex = 11
   nameLabel.Parent = ESPGui

   espObjects[target] = {
   	outerBlack   = outerBlack,
   	box          = box,
   	accentBorder = accentBorder,
   	fill         = fill,
   	nameLabel    = nameLabel,
   }
end

local function removeESPForPlayer(target)
   if espObjects[target] then
   	for _, v in pairs(espObjects[target]) do v:Destroy() end
   	espObjects[target] = nil
   end
end

local function clearAllESP()
   for target in pairs(espObjects) do removeESPForPlayer(target) end
end

local function initESP()
   for _, p in ipairs(Players:GetPlayers()) do createESPForPlayer(p) end
end

local function updateESPColors()
   for _, objs in pairs(espObjects) do
   	local borderImg = objs.accentBorder:GetChildren()
   	if borderImg[1] then borderImg[1].ImageColor3 = boxColor end
   	objs.fill.BackgroundColor3 = boxColor
   	objs.nameLabel.TextColor3  = nameColor
   end
end

Players.PlayerAdded:Connect(function(p)
   if espEnabled then createESPForPlayer(p) end
end)
Players.PlayerRemoving:Connect(removeESPForPlayer)

local function getCharacterScreenBox(character)
   local rootPart = character:FindFirstChild("HumanoidRootPart")
   local humanoid = character:FindFirstChildOfClass("Humanoid")
   if not rootPart or not humanoid then return nil end
   local rootCF = rootPart.CFrame
   local size = Vector3.new(4, humanoid.HipHeight * 2 + 2, 4)
   local corners = {
   	rootCF * CFrame.new( size.X/2,  size.Y/2,  size.Z/2),
   	rootCF * CFrame.new(-size.X/2,  size.Y/2,  size.Z/2),
   	rootCF * CFrame.new( size.X/2, -size.Y/2,  size.Z/2),
   	rootCF * CFrame.new(-size.X/2, -size.Y/2,  size.Z/2),
   	rootCF * CFrame.new( size.X/2,  size.Y/2, -size.Z/2),
   	rootCF * CFrame.new(-size.X/2,  size.Y/2, -size.Z/2),
   	rootCF * CFrame.new( size.X/2, -size.Y/2, -size.Z/2),
   	rootCF * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
   }
   local minX, minY = math.huge, math.huge
   local maxX, maxY = -math.huge, -math.huge
   for _, cf in ipairs(corners) do
   	local screenPos, onScreen = Camera:WorldToViewportPoint(cf.Position)
   	if not onScreen then return nil end
   	if screenPos.X < minX then minX = screenPos.X end
   	if screenPos.X > maxX then maxX = screenPos.X end
   	if screenPos.Y < minY then minY = screenPos.Y end
   	if screenPos.Y > maxY then maxY = screenPos.Y end
   end
   return minX, minY, maxX, maxY
end

RunService.RenderStepped:Connect(function()
   for target, objs in pairs(espObjects) do
   	local character = target.Character
   	local visible = false
   	if character and espEnabled then
   		local minX, minY, maxX, maxY = getCharacterScreenBox(character)
   		if minX then
   			visible = true
   			local w = maxX - minX
   			local h = maxY - minY
   			objs.outerBlack.Visible    = true
   			objs.outerBlack.Position   = UDim2.new(0, minX - 1, 0, minY - 1)
   			objs.outerBlack.Size       = UDim2.new(0, w + 2, 0, h + 2)
   			objs.box.Visible           = true
   			objs.box.Position          = UDim2.new(0, minX, 0, minY)
   			objs.box.Size              = UDim2.new(0, w, 0, h)
   			objs.accentBorder.Visible  = true
   			objs.accentBorder.Position = UDim2.new(0, minX, 0, minY)
   			objs.accentBorder.Size     = UDim2.new(0, w, 0, h)
   			objs.fill.Visible          = fillEnabled
   			objs.fill.Position         = UDim2.new(0, minX + 1, 0, minY + 1)
   			objs.fill.Size             = UDim2.new(0, w - 2, 0, h - 2)
   			objs.nameLabel.Visible     = nameEnabled
   			objs.nameLabel.Text        = target.DisplayName ~= "" and target.DisplayName or target.Name
   			objs.nameLabel.Position    = UDim2.new(0, minX, 0, minY - 16)
   			objs.nameLabel.Size        = UDim2.new(0, w, 0, 16)
   		end
   	end
   	if not visible then
   		objs.outerBlack.Visible   = false
   		objs.box.Visible          = false
   		objs.accentBorder.Visible = false
   		objs.fill.Visible         = false
   		objs.nameLabel.Visible    = false
   	end
   end
end)

local function isLookingAtPlayer()
   local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
   for _, target in ipairs(Players:GetPlayers()) do
   	if target == player then continue end
   	local character = target.Character
   	if not character then continue end
   	local hrp = character:FindFirstChild("HumanoidRootPart")
   	local hum = character:FindFirstChildOfClass("Humanoid")
   	if not hrp or not hum or hum.Health <= 0 then continue end
   	local minX, minY, maxX, maxY = getCharacterScreenBox(character)
   	if minX then
   		if viewportCenter.X >= minX and viewportCenter.X <= maxX and
   			viewportCenter.Y >= minY and viewportCenter.Y <= maxY then
   			return true
   		end
   	end
   end
   return false
end

coroutine.wrap(function()
   while true do
   	task.wait(0.05)
   	if triggerbotEnabled and not triggerFiring then
   		if isLookingAtPlayer() then
   			triggerFiring = true
   			task.wait(triggerReactionTime)
   			if triggerbotEnabled and isLookingAtPlayer() then
   				pcall(function() mouse1press() end)
   				task.wait(triggerReleaseTime)
   				pcall(function() mouse1release() end)
   			end
   			triggerFiring = false
   		end
   	end
   end
end)()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Brandon.wtf"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 34)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
addOutlines(MainFrame)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -4, 0, 28)
TopBar.Position = UDim2.new(0, 2, 0, 2)
TopBar.BackgroundColor3 = C.topbar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 7, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "brandon.wtf"
TitleLabel.TextColor3 = C.text
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
TitleLabel.Parent = TopBar

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 1)
AccentLine.Position = UDim2.new(0, 0, 1, -1)
AccentLine.BackgroundColor3 = C.accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TopBar

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 26, 0, 18)
HideBtn.Position = UDim2.new(1, -30, 0.5, -9)
HideBtn.BackgroundColor3 = C.item
HideBtn.BorderSizePixel = 0
HideBtn.Text = "+"
HideBtn.TextColor3 = C.muted
HideBtn.TextSize = 13
HideBtn.Font = Enum.Font.Code
HideBtn.AutoButtonColor = false
HideBtn.ZIndex = 2
HideBtn.Parent = TopBar
addOutlines(HideBtn)

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -4, 0, 26)
TabBar.Position = UDim2.new(0, 2, 0, 32)
TabBar.BackgroundColor3 = C.topbar
TabBar.BorderSizePixel = 0
TabBar.Visible = false
TabBar.Parent = MainFrame

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Padding = UDim.new(0, 2)
TabBarLayout.Parent = TabBar

local TabBarPad = Instance.new("UIPadding")
TabBarPad.PaddingLeft = UDim.new(0, 4)
TabBarPad.PaddingTop = UDim.new(0, 4)
TabBarPad.Parent = TabBar

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -4, 0, 0)
ScrollFrame.Position = UDim2.new(0, 2, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = C.accent
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.ClipsDescendants = true
ScrollFrame.Visible = false
ScrollFrame.Parent = MainFrame

local tabs = {}
local activeTab = nil

local function refreshAccentUI()
   AccentLine.BackgroundColor3 = C.accent
   ScrollFrame.ScrollBarImageColor3 = C.accent
   for _, fill in ipairs(sliderFillRefs) do
   	fill.BackgroundColor3 = C.accent
   end
   for _, lbl in ipairs(sliderValRefs) do
   	lbl.TextColor3 = C.accent
   end
   for _, fill in ipairs(checkboxFillRefs) do
   	fill.BackgroundColor3 = C.accent
   end
end

local function makeTabPage()
   local page = Instance.new("Frame")
   page.Name = "TabPage"
   page.Size = UDim2.new(1, -12, 0, 0)
   page.Position = UDim2.new(0, 6, 0, 6)
   page.BackgroundTransparency = 1
   page.BorderSizePixel = 0
   page.AutomaticSize = Enum.AutomaticSize.Y
   page.Visible = false
   page.Parent = ScrollFrame

   local layout = Instance.new("UIListLayout")
   layout.SortOrder = Enum.SortOrder.LayoutOrder
   layout.Padding = UDim.new(0, 8)
   layout.Parent = page

   return page
end

local function makeTabButton(name, page, order)
   local btn = Instance.new("TextButton")
   btn.Size = UDim2.new(0, 56, 0, 18)
   btn.BackgroundColor3 = C.item
   btn.BorderSizePixel = 0
   btn.Text = name
   btn.TextColor3 = C.dim
   btn.TextSize = 11
   btn.Font = Enum.Font.Code
   btn.AutoButtonColor = false
   btn.LayoutOrder = order
   btn.ZIndex = 2
   btn.Parent = TabBar
   addOutlines(btn)

   tabs[name] = { btn = btn, page = page }

   btn.MouseButton1Click:Connect(function()
   	for tname, tdata in pairs(tabs) do
   		tdata.page.Visible = false
   		tdata.btn.TextColor3 = C.dim
   		tdata.btn.BackgroundColor3 = C.item
   	end
   	page.Visible = true
   	btn.TextColor3 = C.text
   	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
   	activeTab = name
   end)

   btn.MouseEnter:Connect(function()
   	if activeTab ~= name then btn.TextColor3 = C.muted end
   end)
   btn.MouseLeave:Connect(function()
   	if activeTab ~= name then btn.TextColor3 = C.dim end
   end)

   return btn
end

local CombatPage = makeTabPage()
local VisualPage = makeTabPage()
local MiscPage   = makeTabPage()
local ClientPage = makeTabPage()

makeTabButton("Combat",  CombatPage, 1)
makeTabButton("Visuals", VisualPage, 2)
makeTabButton("Misc",    MiscPage,   3)
makeTabButton("Client",  ClientPage, 4)

local function makeSection(parentPage, name, labelWidth)
   local sec = Instance.new("Frame")
   sec.BackgroundColor3 = C.panel
   sec.BorderSizePixel = 0
   sec.ClipsDescendants = false
   sec.AutomaticSize = Enum.AutomaticSize.Y
   sec.Size = UDim2.new(1, 0, 0, 0)
   sec.Parent = parentPage
   addOutlines(sec)

   local stf = Instance.new("Frame")
   stf.Size = UDim2.new(0, labelWidth or 50, 0, 8)
   stf.Position = UDim2.new(0, 10, 0, 0)
   stf.BackgroundColor3 = C.panel
   stf.BorderSizePixel = 0
   stf.ZIndex = 3
   stf.Parent = sec

   local st = Instance.new("TextLabel")
   st.Size = UDim2.new(1, 0, 0, 14)
   st.Position = UDim2.new(0, 0, 0, -3)
   st.BackgroundTransparency = 1
   st.Text = name
   st.TextColor3 = C.text
   st.TextSize = 14
   st.Font = Enum.Font.Code
   st.ZIndex = 4
   st.Parent = stf

   local ih = Instance.new("Frame")
   ih.Name = "ItemHolder"
   ih.Size = UDim2.new(1, -16, 0, 0)
   ih.Position = UDim2.new(0, 8, 0, 14)
   ih.BackgroundTransparency = 1
   ih.BorderSizePixel = 0
   ih.AutomaticSize = Enum.AutomaticSize.Y
   ih.ZIndex = 2
   ih.Parent = sec

   local il = Instance.new("UIListLayout")
   il.SortOrder = Enum.SortOrder.LayoutOrder
   il.Padding = UDim.new(0, 5)
   il.Parent = ih

   local pad = Instance.new("UIPadding")
   pad.PaddingBottom = UDim.new(0, 10)
   pad.Parent = ih

   return sec, ih
end

local function makeCheckbox(parent, labelText)
   local row = Instance.new("Frame")
   row.Size = UDim2.new(1, 0, 0, 20)
   row.BackgroundTransparency = 1
   row.BorderSizePixel = 0
   row.ZIndex = 2
   row.Parent = parent

   local box = Instance.new("TextButton")
   box.Size = UDim2.new(0, 14, 0, 14)
   box.Position = UDim2.new(0, 0, 0.5, -7)
   box.BackgroundColor3 = C.item
   box.BorderSizePixel = 0
   box.AutoButtonColor = false
   box.Text = ""
   box.ZIndex = 3
   box.Parent = row
   addOutlines(box)

   local boxFill = Instance.new("Frame")
   boxFill.Size = UDim2.new(1, -4, 1, -4)
   boxFill.Position = UDim2.new(0, 2, 0, 2)
   boxFill.BackgroundColor3 = C.accent
   boxFill.BorderSizePixel = 0
   boxFill.Visible = false
   boxFill.ZIndex = 4
   boxFill.Parent = box
   table.insert(checkboxFillRefs, boxFill)

   local lbl = Instance.new("TextLabel")
   lbl.Size = UDim2.new(1, -22, 1, 0)
   lbl.Position = UDim2.new(0, 22, 0, 0)
   lbl.BackgroundTransparency = 1
   lbl.Text = labelText
   lbl.TextColor3 = C.muted
   lbl.TextSize = 14
   lbl.Font = Enum.Font.Code
   lbl.TextXAlignment = Enum.TextXAlignment.Left
   lbl.TextYAlignment = Enum.TextYAlignment.Center
   lbl.ZIndex = 3
   lbl.Parent = row

   local state = false
   local function setState(val)
   	state = val
   	boxFill.Visible = state
   	boxFill.BackgroundColor3 = C.accent
   	lbl.TextColor3 = state and C.text or C.muted
   end

   box.MouseButton1Click:Connect(function() setState(not state) end)
   box.MouseEnter:Connect(function() box.BorderSizePixel = 1 end)
   box.MouseLeave:Connect(function() box.BorderSizePixel = 0 end)

   return row, function() return state end, setState
end

local function makeSlider(parent, labelText, minVal, maxVal, defaultVal, decimals, onChanged)
   local row = Instance.new("Frame")
   row.Size = UDim2.new(1, 0, 0, 36)
   row.BackgroundTransparency = 1
   row.BorderSizePixel = 0
   row.ZIndex = 2
   row.Parent = parent

   local lbl = Instance.new("TextLabel")
   lbl.Size = UDim2.new(1, 0, 0, 14)
   lbl.BackgroundTransparency = 1
   lbl.Text = labelText
   lbl.TextColor3 = C.text
   lbl.TextSize = 13
   lbl.Font = Enum.Font.Code
   lbl.TextXAlignment = Enum.TextXAlignment.Left
   lbl.ZIndex = 3
   lbl.Parent = row

   local valLabel = Instance.new("TextLabel")
   valLabel.Size = UDim2.new(1, 0, 0, 14)
   valLabel.BackgroundTransparency = 1
   valLabel.TextColor3 = C.text
   valLabel.TextSize = 13
   valLabel.Font = Enum.Font.Code
   valLabel.TextXAlignment = Enum.TextXAlignment.Right
   valLabel.ZIndex = 3
   valLabel.Parent = row
   table.insert(sliderValRefs, valLabel)

   local track = Instance.new("Frame")
   track.Size = UDim2.new(1, 0, 0, 6)
   track.Position = UDim2.new(0, 0, 0, 20)
   track.BackgroundColor3 = C.item
   track.BorderSizePixel = 0
   track.ZIndex = 3
   track.Parent = row
   addOutlines(track)

   local fill = Instance.new("Frame")
   fill.Size = UDim2.new(0, 0, 1, 0)
   fill.BackgroundColor3 = C.accent
   fill.BorderSizePixel = 0
   fill.ZIndex = 4
   fill.Parent = track
   table.insert(sliderFillRefs, fill)

   local currentVal = defaultVal
   local dragging = false
   local fmt = "%." .. (decimals or 2) .. "f"

   local function setValue(val)
   	currentVal = math.clamp(val, minVal, maxVal)
   	local t = (currentVal - minVal) / (maxVal - minVal)
   	fill.Size = UDim2.new(t, 0, 1, 0)
   	fill.BackgroundColor3 = C.accent
   	valLabel.Text = string.format(fmt .. "s", currentVal)
   	onChanged(currentVal)
   end

   setValue(defaultVal)

   track.InputBegan:Connect(function(inp)
   	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
   		dragging = true
   		local absPos = track.AbsolutePosition
   		local absSize = track.AbsoluteSize
   		local mouse = UserInputService:GetMouseLocation()
   		local t = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
   		setValue(minVal + t * (maxVal - minVal))
   	end
   end)

   UserInputService.InputChanged:Connect(function(inp)
   	if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
   		local absPos = track.AbsolutePosition
   		local absSize = track.AbsoluteSize
   		local mouse = UserInputService:GetMouseLocation()
   		local t = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
   		setValue(minVal + t * (maxVal - minVal))
   	end
   end)

   UserInputService.InputEnded:Connect(function(inp)
   	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
   		dragging = false
   	end
   end)

   return row
end

local function makeColorPicker(parent, labelText, defaultColor, onChange)
   local h, s, v = defaultColor:ToHSV()
   local color = defaultColor

   local wrapper = Instance.new("Frame")
   wrapper.Size = UDim2.new(1, 0, 0, 0)
   wrapper.BackgroundTransparency = 1
   wrapper.AutomaticSize = Enum.AutomaticSize.Y
   wrapper.ZIndex = 2
   wrapper.Parent = parent

   local wLayout = Instance.new("UIListLayout")
   wLayout.SortOrder = Enum.SortOrder.LayoutOrder
   wLayout.Padding = UDim.new(0, 4)
   wLayout.Parent = wrapper

   local header = Instance.new("Frame")
   header.Size = UDim2.new(1, 0, 0, 18)
   header.BackgroundTransparency = 1
   header.Parent = wrapper

   local title = Instance.new("TextLabel")
   title.Size = UDim2.new(0.6, 0, 1, 0)
   title.BackgroundTransparency = 1
   title.Text = labelText
   title.TextColor3 = C.muted
   title.TextSize = 13
   title.Font = Enum.Font.Code
   title.TextXAlignment = Enum.TextXAlignment.Left
   title.Parent = header

   local preview = Instance.new("Frame")
   preview.Size = UDim2.new(0, 50, 0, 16)
   preview.Position = UDim2.new(1, -50, 0.5, -8)
   preview.BackgroundColor3 = color
   preview.BorderSizePixel = 0
   preview.Parent = header
   addOutlines(preview)

   local svFrame = Instance.new("Frame")
   svFrame.Size = UDim2.new(1, 0, 0, 100)
   svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
   svFrame.BorderSizePixel = 0
   svFrame.ClipsDescendants = false
   svFrame.ZIndex = 2
   svFrame.Parent = wrapper
   addOutlines(svFrame)

   local satGradient = Instance.new("UIGradient")
   satGradient.Color = ColorSequence.new{
   	ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
   	ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
   }
   satGradient.Transparency = NumberSequence.new{
   	NumberSequenceKeypoint.new(0, 0),
   	NumberSequenceKeypoint.new(1, 1)
   }
   satGradient.Parent = svFrame

   local valGradient = Instance.new("UIGradient")
   valGradient.Color = ColorSequence.new{
   	ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
   	ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
   }
   valGradient.Transparency = NumberSequence.new{
   	NumberSequenceKeypoint.new(0, 1),
   	NumberSequenceKeypoint.new(1, 0)
   }
   valGradient.Rotation = 90
   valGradient.Parent = svFrame

   local svCursor = Instance.new("Frame")
   svCursor.Size = UDim2.new(0, 7, 0, 7)
   svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
   svCursor.ZIndex = 10
   svCursor.Parent = svFrame

   local svStroke = Instance.new("UIStroke")
   svStroke.Color = Color3.new(0, 0, 0)
   svStroke.Thickness = 1.5
   svStroke.Parent = svCursor

   local svCorner = Instance.new("UICorner")
   svCorner.CornerRadius = UDim.new(1, 0)
   svCorner.Parent = svCursor

   local hueFrame = Instance.new("Frame")
   hueFrame.Size = UDim2.new(1, 0, 0, 12)
   hueFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
   hueFrame.BorderSizePixel = 0
   hueFrame.ZIndex = 2
   hueFrame.Parent = wrapper
   addOutlines(hueFrame)

   local hueGradient = Instance.new("UIGradient")
   hueGradient.Color = ColorSequence.new{
   	ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,    1, 1)),
   	ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
   	ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
   	ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,  1, 1)),
   	ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
   	ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
   	ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,    1, 1))
   }
   hueGradient.Parent = hueFrame

   local hueCursor = Instance.new("Frame")
   hueCursor.Size = UDim2.new(0, 5, 1, 4)
   hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
   hueCursor.ZIndex = 10
   hueCursor.Parent = hueFrame

   local hueStroke = Instance.new("UIStroke")
   hueStroke.Color = Color3.new(0, 0, 0)
   hueStroke.Thickness = 1.5
   hueStroke.Parent = hueCursor

   local function updateColor()
   	color = Color3.fromHSV(h, s, v)
   	svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
   	preview.BackgroundColor3 = color
   	onChange(color)
   end

   local function updateCursorPositions()
   	local svSize = svFrame.AbsoluteSize
   	if svSize.X == 0 then return end
   	local half = 3
   	local px = math.clamp(s * svSize.X - half, 0, svSize.X - (half * 2))
   	local py = math.clamp((1 - v) * svSize.Y - half, 0, svSize.Y - (half * 2))
   	svCursor.Position = UDim2.new(0, px, 0, py)
   	local hueSize = hueFrame.AbsoluteSize
   	if hueSize.X == 0 then return end
   	local hx = math.clamp(h * hueSize.X - 2, 0, hueSize.X - 5)
   	hueCursor.Position = UDim2.new(0, hx, 0, -2)
   end

   local svDragging = false
   local hueDragging = false

   svFrame.InputBegan:Connect(function(inp)
   	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
   		svDragging = true
   		local absPos = svFrame.AbsolutePosition
   		local absSize = svFrame.AbsoluteSize
   		local mouse = UserInputService:GetMouseLocation()
   		s = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
   		v = 1 - math.clamp((mouse.Y - absPos.Y) / absSize.Y, 0, 1)
   		updateColor()
   		updateCursorPositions()
   	end
   end)

   hueFrame.InputBegan:Connect(function(inp)
   	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
   		hueDragging = true
   		local absPos = hueFrame.AbsolutePosition
   		local absSize = hueFrame.AbsoluteSize
   		local mouse = UserInputService:GetMouseLocation()
   		h = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
   		updateColor()
   		updateCursorPositions()
   	end
   end)

   UserInputService.InputChanged:Connect(function(inp)
   	if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
   		local mouse = UserInputService:GetMouseLocation()
   		if svDragging then
   			local absPos = svFrame.AbsolutePosition
   			local absSize = svFrame.AbsoluteSize
   			s = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
   			v = 1 - math.clamp((mouse.Y - absPos.Y) / absSize.Y, 0, 1)
   			updateColor()
   			updateCursorPositions()
   		elseif hueDragging then
   			local absPos = hueFrame.AbsolutePosition
   			local absSize = hueFrame.AbsoluteSize
   			h = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
   			updateColor()
   			updateCursorPositions()
   		end
   	end
   end)

   UserInputService.InputEnded:Connect(function(inp)
   	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
   		svDragging = false
   		hueDragging = false
   	end
   end)

   task.defer(function()
   	updateColor()
   	updateCursorPositions()
   end)

   return wrapper
end

local function serializeConfig(data)
   local parts = {}
   parts[#parts+1] = "boxColor="    .. data.boxColor[1]    .. "," .. data.boxColor[2]    .. "," .. data.boxColor[3]
   parts[#parts+1] = "nameColor="   .. data.nameColor[1]   .. "," .. data.nameColor[2]   .. "," .. data.nameColor[3]
   parts[#parts+1] = "accentColor=" .. data.accentColor[1] .. "," .. data.accentColor[2] .. "," .. data.accentColor[3]
   parts[#parts+1] = "triggerReaction=" .. data.triggerReaction
   parts[#parts+1] = "triggerRelease="  .. data.triggerRelease
   parts[#parts+1] = "autoExecute=" .. tostring(data.autoExecute)
   parts[#parts+1] = "autoSave="    .. tostring(data.autoSave)
   parts[#parts+1] = "autoLoad="    .. tostring(data.autoLoad)
   return table.concat(parts, ";")
end

local function deserializeConfig(str)
   local data = {}
   for pair in str:gmatch("[^;]+") do
   	local key, val = pair:match("^(.-)=(.+)$")
   	if key and val then
   		if key == "boxColor" or key == "nameColor" or key == "accentColor" then
   			local r, g, b = val:match("([^,]+),([^,]+),([^,]+)")
   			if r then data[key] = { tonumber(r), tonumber(g), tonumber(b) } end
   		elseif key == "triggerReaction" or key == "triggerRelease" then
   			data[key] = tonumber(val)
   		elseif key == "autoExecute" or key == "autoSave" or key == "autoLoad" then
   			data[key] = val == "true"
   		end
   	end
   end
   return data
end

local function saveConfig(name)
   local ok = pcall(function()
   	if not writefile then error("no writefile") end
   	local data = {
   		boxColor        = { boxColor.R,   boxColor.G,   boxColor.B   },
   		nameColor       = { nameColor.R,  nameColor.G,  nameColor.B  },
   		accentColor     = { C.accent.R,   C.accent.G,   C.accent.B   },
   		triggerReaction = triggerReactionTime,
   		triggerRelease  = triggerReleaseTime,
   		autoExecute     = config.autoExecute,
   		autoSave        = config.autoSave,
   		autoLoad        = config.autoLoad,
   	}
   	writefile("brandon_" .. name .. ".cfg", serializeConfig(data))
   end)
   return ok
end

local function loadConfig(name)
   local ok, result = pcall(function()
   	if not readfile then error("no readfile") end
   	return deserializeConfig(readfile("brandon_" .. name .. ".cfg"))
   end)
   if ok and result then
   	if result.boxColor   then boxColor   = Color3.new(result.boxColor[1],   result.boxColor[2],   result.boxColor[3])   end
   	if result.nameColor  then nameColor  = Color3.new(result.nameColor[1],  result.nameColor[2],  result.nameColor[3])  end
   	if result.accentColor then
   		applyAccent(Color3.new(result.accentColor[1], result.accentColor[2], result.accentColor[3]))
   		refreshAccentUI()
   	end
   	if result.triggerReaction then triggerReactionTime = result.triggerReaction end
   	if result.triggerRelease  then triggerReleaseTime  = result.triggerRelease  end
   	if result.autoExecute ~= nil then config.autoExecute = result.autoExecute end
   	if result.autoSave    ~= nil then config.autoSave    = result.autoSave    end
   	if result.autoLoad    ~= nil then config.autoLoad    = result.autoLoad    end
   	updateESPColors()
   	return true
   end
   return false
end

local function deleteConfig(name)
   local ok = pcall(function()
   	if not delfile then error("no delfile") end
   	delfile("brandon_" .. name .. ".cfg")
   end)
   return ok
end

local function listConfigs()
   local ok, result = pcall(function()
   	if not listfiles then error("no listfiles") end
   	local cfgs = {}
   	for _, f in ipairs(listfiles("")) do
   		local name = f:match("brandon_(.+)%.cfg$")
   		if name then table.insert(cfgs, name) end
   	end
   	return cfgs
   end)
   if ok and result then return result end
   return {}
end

local _, CombatHolder = makeSection(CombatPage, "Triggerbot", 72)

local _, getTrigger = makeCheckbox(CombatHolder, "Triggerbot")

makeSlider(CombatHolder, "Reaction Time", 0.01, 0.5, triggerReactionTime, 2, function(val)
   triggerReactionTime = val
end)

makeSlider(CombatHolder, "Release Time", 0.01, 0.3, triggerReleaseTime, 2, function(val)
   triggerReleaseTime = val
end)

local _, ESPHolder = makeSection(VisualPage, "ESP", 36)

local _, getBoxESP  = makeCheckbox(ESPHolder, "Box ESP")
local _, getNameESP = makeCheckbox(ESPHolder, "Name ESP")
local _, getFillESP = makeCheckbox(ESPHolder, "Fill Box")

makeColorPicker(ESPHolder, "Box Color", boxColor, function(col)
   boxColor = col
   updateESPColors()
end)

makeColorPicker(ESPHolder, "Name Color", nameColor, function(col)
   nameColor = col
   updateESPColors()
end)

local _, MiscHolder = makeSection(MiscPage, "Cosmetics", 70)

local SkinBtn = Instance.new("TextButton")
SkinBtn.Size = UDim2.new(1, 0, 0, 20)
SkinBtn.BackgroundColor3 = C.item
SkinBtn.BorderSizePixel = 0
SkinBtn.AutoButtonColor = false
SkinBtn.Text = "Unlock All Skins"
SkinBtn.TextColor3 = C.text
SkinBtn.TextSize = 14
SkinBtn.Font = Enum.Font.Code
SkinBtn.ZIndex = 2
SkinBtn.Parent = MiscHolder
addOutlines(SkinBtn)

local _, ThemeHolder   = makeSection(ClientPage, "Theme", 50)
local _, SettingHolder = makeSection(ClientPage, "Settings", 60)
local _, ConfigHolder  = makeSection(ClientPage, "Config Manager", 110)

makeColorPicker(ThemeHolder, "Accent Color", C.accent, function(col)
   applyAccent(col)
   config.accentColor = col
   refreshAccentUI()
end)

local _, getAutoExecute, setAutoExecute = makeCheckbox(SettingHolder, "Auto Execute")
local _, getAutoSave,    setAutoSave    = makeCheckbox(SettingHolder, "Auto Save")
local _, getAutoLoad,    setAutoLoad    = makeCheckbox(SettingHolder, "Auto Load")

local configNameBox = Instance.new("TextBox")
configNameBox.Size = UDim2.new(1, 0, 0, 22)
configNameBox.BackgroundColor3 = C.item
configNameBox.BorderSizePixel = 0
configNameBox.Text = ""
configNameBox.PlaceholderText = "Config name..."
configNameBox.PlaceholderColor3 = C.dim
configNameBox.TextColor3 = C.text
configNameBox.TextSize = 13
configNameBox.Font = Enum.Font.Code
configNameBox.ClearTextOnFocus = false
configNameBox.ZIndex = 3
configNameBox.Parent = ConfigHolder
addOutlines(configNameBox)

local configBtnRow = Instance.new("Frame")
configBtnRow.Size = UDim2.new(1, 0, 0, 20)
configBtnRow.BackgroundTransparency = 1
configBtnRow.BorderSizePixel = 0
configBtnRow.ZIndex = 2
configBtnRow.Parent = ConfigHolder

local configBtnLayout = Instance.new("UIListLayout")
configBtnLayout.FillDirection = Enum.FillDirection.Horizontal
configBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
configBtnLayout.Padding = UDim.new(0, 4)
configBtnLayout.Parent = configBtnRow

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 86, 0, 20)
SaveBtn.BackgroundColor3 = C.item
SaveBtn.BorderSizePixel = 0
SaveBtn.AutoButtonColor = false
SaveBtn.Text = "Save"
SaveBtn.TextColor3 = C.text
SaveBtn.TextSize = 13
SaveBtn.Font = Enum.Font.Code
SaveBtn.ZIndex = 3
SaveBtn.Parent = configBtnRow
addOutlines(SaveBtn)

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(0, 86, 0, 20)
LoadBtn.BackgroundColor3 = C.item
LoadBtn.BorderSizePixel = 0
LoadBtn.AutoButtonColor = false
LoadBtn.Text = "Load"
LoadBtn.TextColor3 = C.text
LoadBtn.TextSize = 13
LoadBtn.Font = Enum.Font.Code
LoadBtn.ZIndex = 3
LoadBtn.Parent = configBtnRow
addOutlines(LoadBtn)

local DeleteBtn = Instance.new("TextButton")
DeleteBtn.Size = UDim2.new(0, 86, 0, 20)
DeleteBtn.BackgroundColor3 = C.item
DeleteBtn.BorderSizePixel = 0
DeleteBtn.AutoButtonColor = false
DeleteBtn.Text = "Delete"
DeleteBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
DeleteBtn.TextSize = 13
DeleteBtn.Font = Enum.Font.Code
DeleteBtn.ZIndex = 3
DeleteBtn.Parent = configBtnRow
addOutlines(DeleteBtn)

local ConfigStatus = Instance.new("TextLabel")
ConfigStatus.Size = UDim2.new(1, 0, 0, 14)
ConfigStatus.BackgroundTransparency = 1
ConfigStatus.Text = ""
ConfigStatus.TextColor3 = C.text
ConfigStatus.TextSize = 12
ConfigStatus.Font = Enum.Font.Code
ConfigStatus.TextXAlignment = Enum.TextXAlignment.Center
ConfigStatus.ZIndex = 3
ConfigStatus.Parent = ConfigHolder

local configListLabel = Instance.new("TextLabel")
configListLabel.Size = UDim2.new(1, 0, 0, 12)
configListLabel.BackgroundTransparency = 1
configListLabel.Text = "Saved configs:"
configListLabel.TextColor3 = C.dim
configListLabel.TextSize = 11
configListLabel.Font = Enum.Font.Code
configListLabel.TextXAlignment = Enum.TextXAlignment.Left
configListLabel.ZIndex = 3
configListLabel.Parent = ConfigHolder

local configListHolder = Instance.new("Frame")
configListHolder.Size = UDim2.new(1, 0, 0, 0)
configListHolder.BackgroundTransparency = 1
configListHolder.AutomaticSize = Enum.AutomaticSize.Y
configListHolder.BorderSizePixel = 0
configListHolder.ZIndex = 2
configListHolder.Parent = ConfigHolder

local configListLayout = Instance.new("UIListLayout")
configListLayout.SortOrder = Enum.SortOrder.LayoutOrder
configListLayout.Padding = UDim.new(0, 3)
configListLayout.Parent = configListHolder

local function showStatus(msg, success)
   ConfigStatus.Text = msg
   ConfigStatus.TextColor3 = success and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(220, 100, 100)
   task.delay(2.5, function() ConfigStatus.Text = "" end)
end

local function refreshConfigList()
   for _, c in ipairs(configListHolder:GetChildren()) do
   	if c:IsA("Frame") then c:Destroy() end
   end
   local cfgs = listConfigs()
   for _, name in ipairs(cfgs) do
   	local row = Instance.new("Frame")
   	row.Size = UDim2.new(1, 0, 0, 18)
   	row.BackgroundColor3 = C.item
   	row.BorderSizePixel = 0
   	row.ZIndex = 3
   	row.Parent = configListHolder
   	addOutlines(row)

   	local nameLbl = Instance.new("TextLabel")
   	nameLbl.Size = UDim2.new(1, -40, 1, 0)
   	nameLbl.Position = UDim2.new(0, 4, 0, 0)
   	nameLbl.BackgroundTransparency = 1
   	nameLbl.Text = name
   	nameLbl.TextColor3 = C.muted
   	nameLbl.TextSize = 12
   	nameLbl.Font = Enum.Font.Code
   	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
   	nameLbl.ZIndex = 4
   	nameLbl.Parent = row

   	local selectBtn = Instance.new("TextButton")
   	selectBtn.Size = UDim2.new(0, 36, 1, -2)
   	selectBtn.Position = UDim2.new(1, -38, 0, 1)
   	selectBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
   	selectBtn.BorderSizePixel = 0
   	selectBtn.AutoButtonColor = false
   	selectBtn.Text = "Select"
   	selectBtn.TextColor3 = C.text
   	selectBtn.TextSize = 10
   	selectBtn.Font = Enum.Font.Code
   	selectBtn.ZIndex = 5
   	selectBtn.Parent = row
   	addOutlines(selectBtn)

   	selectBtn.MouseButton1Click:Connect(function()
   		configNameBox.Text = name
   	end)
   	selectBtn.MouseEnter:Connect(function() selectBtn.BorderSizePixel = 1 end)
   	selectBtn.MouseLeave:Connect(function() selectBtn.BorderSizePixel = 0 end)
   end
end

SaveBtn.MouseButton1Click:Connect(function()
   local name = configNameBox.Text
   if name == "" then showStatus("Enter a config name", false) return end
   local ok = saveConfig(name)
   showStatus(ok and "Saved: " .. name or "Save failed", ok)
   refreshConfigList()
end)

LoadBtn.MouseButton1Click:Connect(function()
   local name = configNameBox.Text
   if name == "" then showStatus("Enter a config name", false) return end
   local ok = loadConfig(name)
   showStatus(ok and "Loaded: " .. name or "Config not found", ok)
end)

DeleteBtn.MouseButton1Click:Connect(function()
   local name = configNameBox.Text
   if name == "" then showStatus("Enter a config name", false) return end
   local ok = deleteConfig(name)
   showStatus(ok and "Deleted: " .. name or "Delete failed", ok)
   refreshConfigList()
   configNameBox.Text = ""
end)

SaveBtn.MouseEnter:Connect(function() SaveBtn.BorderSizePixel = 1 end)
SaveBtn.MouseLeave:Connect(function() SaveBtn.BorderSizePixel = 0 end)
LoadBtn.MouseEnter:Connect(function() LoadBtn.BorderSizePixel = 1 end)
LoadBtn.MouseLeave:Connect(function() LoadBtn.BorderSizePixel = 0 end)
DeleteBtn.MouseEnter:Connect(function() DeleteBtn.BorderSizePixel = 1 end)
DeleteBtn.MouseLeave:Connect(function() DeleteBtn.BorderSizePixel = 0 end)

local MAX_HEIGHT = 340

local function resizeAll()
   local totalH = 0
   for _, tdata in pairs(tabs) do
   	if tdata.page.Visible then
   		totalH = tdata.page.AbsoluteSize.Y + 14
   		break
   	end
   end
   local frameH = math.min(totalH, MAX_HEIGHT) + 60
   ScrollFrame.Size = UDim2.new(1, -4, 0, frameH - 60)
   MainFrame.Size   = UDim2.new(0, 300, 0, frameH)
end

RunService.Heartbeat:Connect(function()
   if ScrollFrame.Visible then
   	resizeAll()
   end
end)

local contentVisible = false
HideBtn.MouseButton1Click:Connect(function()
   contentVisible = not contentVisible
   ScrollFrame.Visible = contentVisible
   TabBar.Visible = contentVisible
   HideBtn.Text = contentVisible and "—" or "+"

   if contentVisible then
   	if activeTab == nil then
   		for tname, tdata in pairs(tabs) do
   			tdata.page.Visible = (tname == "Combat")
   			tdata.btn.TextColor3 = (tname == "Combat") and C.text or C.dim
   			tdata.btn.BackgroundColor3 = (tname == "Combat") and Color3.fromRGB(50,50,50) or C.item
   		end
   		activeTab = "Combat"
   	end
   	task.wait()
   	resizeAll()
   else
   	MainFrame.Size = UDim2.new(0, 300, 0, 34)
   end
end)

HideBtn.MouseEnter:Connect(function() HideBtn.BorderSizePixel = 1 end)
HideBtn.MouseLeave:Connect(function() HideBtn.BorderSizePixel = 0 end)
SkinBtn.MouseEnter:Connect(function() SkinBtn.BorderSizePixel = 1 end)
SkinBtn.MouseLeave:Connect(function() SkinBtn.BorderSizePixel = 0 end)

local autoSaveTimer = 0
RunService.Heartbeat:Connect(function(dt)
   espEnabled         = getBoxESP()
   nameEnabled        = getNameESP()
   fillEnabled        = getFillESP()
   triggerbotEnabled  = getTrigger()
   config.autoExecute = getAutoExecute()
   config.autoSave    = getAutoSave()
   config.autoLoad    = getAutoLoad()
   if espEnabled then initESP() else clearAllESP() end
   if config.autoSave then
   	autoSaveTimer = autoSaveTimer + dt
   	if autoSaveTimer >= 10 then
   		autoSaveTimer = 0
   		saveConfig("autosave")
   	end
   end
end)

SkinBtn.MouseButton1Click:Connect(function()
   SkinBtn.Text = "Loading..."
   SkinBtn.TextColor3 = C.dim
   pcall(function()
   	loadstring(game:HttpGet("https://pastebin.com/raw/4rVNKnw0"))()
   	SkinBtn.Text = "Unlocked"
   	SkinBtn.TextColor3 = C.text
   end)
end)

task.defer(function()
   refreshConfigList()
   if config.autoLoad then
   	loadConfig("autosave")
   end
   if config.autoExecute then
   	pcall(function()
   		loadstring(game:HttpGet("https://pastebin.com/raw/4rVNKnw0"))()
   	end)
   end
end)

UserInputService.InputBegan:Connect(function(i)
   if i.KeyCode == Enum.KeyCode.RightShift then
   	ScreenGui.Enabled = not ScreenGui.Enabled
   end
end)
