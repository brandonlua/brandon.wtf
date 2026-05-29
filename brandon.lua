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

local espEnabled  = false
local nameEnabled = false
local fillEnabled = false
local espObjects  = {}
local boxColor    = Color3.fromRGB(130, 80, 200)
local nameColor   = Color3.fromRGB(130, 80, 200)

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
				objs.outerBlack.Visible  = true
				objs.outerBlack.Position = UDim2.new(0, minX - 1, 0, minY - 1)
				objs.outerBlack.Size     = UDim2.new(0, w + 2, 0, h + 2)
				objs.box.Visible         = true
				objs.box.Position        = UDim2.new(0, minX, 0, minY)
				objs.box.Size            = UDim2.new(0, w, 0, h)
				objs.accentBorder.Visible  = true
				objs.accentBorder.Position = UDim2.new(0, minX, 0, minY)
				objs.accentBorder.Size     = UDim2.new(0, w, 0, h)
				objs.fill.Visible    = fillEnabled
				objs.fill.Position   = UDim2.new(0, minX + 1, 0, minY + 1)
				objs.fill.Size       = UDim2.new(0, w - 2, 0, h - 2)
				objs.nameLabel.Visible   = nameEnabled
				objs.nameLabel.Text      = target.DisplayName ~= "" and target.DisplayName or target.Name
				objs.nameLabel.Position  = UDim2.new(0, minX, 0, minY - 16)
				objs.nameLabel.Size      = UDim2.new(0, w, 0, 16)
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

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -4, 0, 0)
ScrollFrame.Position = UDim2.new(0, 2, 0, 32)
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

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -12, 0, 0)
Container.Position = UDim2.new(0, 6, 0, 6)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.AutomaticSize = Enum.AutomaticSize.Y
Container.Parent = ScrollFrame

local ContainerLayout = Instance.new("UIListLayout")
ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContainerLayout.Padding = UDim.new(0, 8)
ContainerLayout.Parent = Container

local function makeSection(name, labelWidth)
	local sec = Instance.new("Frame")
	sec.BackgroundColor3 = C.panel
	sec.BorderSizePixel = 0
	sec.ClipsDescendants = false
	sec.AutomaticSize = Enum.AutomaticSize.Y
	sec.Size = UDim2.new(1, 0, 0, 0)
	sec.Parent = Container
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
		lbl.TextColor3 = state and C.text or C.muted
	end

	box.MouseButton1Click:Connect(function() setState(not state) end)
	box.MouseEnter:Connect(function() box.BorderSizePixel = 1 end)
	box.MouseLeave:Connect(function() box.BorderSizePixel = 0 end)

	return row, function() return state end, setState
end

-- FIXED COLOR PICKER
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

	-- SV Box
	local svFrame = Instance.new("Frame")
	svFrame.Size = UDim2.new(1, 0, 0, 100)
	svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	svFrame.BorderSizePixel = 0
	svFrame.ClipsDescendants = true
	svFrame.Parent = wrapper
	addOutlines(svFrame)

	local satGradient = Instance.new("UIGradient")
	satGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}
	satGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
	satGradient.Parent = svFrame

	local valGradient = Instance.new("UIGradient")
	valGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))}
	valGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
	valGradient.Rotation = 90
	valGradient.Parent = svFrame

	local svCursor = Instance.new("Frame")
	svCursor.Size = UDim2.new(0, 8, 0, 8)
	svCursor.BackgroundTransparency = 1
	svCursor.BorderSizePixel = 2
	svCursor.BorderColor3 = Color3.new(1,1,1)
	svCursor.ZIndex = 5
	svCursor.Parent = svFrame

	-- Hue Slider
	local hueFrame = Instance.new("Frame")
	hueFrame.Size = UDim2.new(1, 0, 0, 12)
	hueFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
	hueFrame.BorderSizePixel = 0
	hueFrame.Parent = wrapper
	addOutlines(hueFrame)

	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1,1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1,1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))
	}
	hueGradient.Parent = hueFrame

	local hueCursor = Instance.new("Frame")
	hueCursor.Size = UDim2.new(0, 4, 1, 0)
	hueCursor.BackgroundColor3 = Color3.new(1,1,1)
	hueCursor.BorderSizePixel = 1
	hueCursor.BorderColor3 = Color3.new(0,0,0)
	hueCursor.ZIndex = 5
	hueCursor.Parent = hueFrame

	local function updateSV()
		svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		color = Color3.fromHSV(h, s, v)
		preview.BackgroundColor3 = color
		onChange(color)
	end

	local function updatePositions()
		svCursor.Position = UDim2.new(math.clamp(s, 0, 1) - 0.04, 0, 1 - math.clamp(v, 0, 1) - 0.04, 0)
		hueCursor.Position = UDim2.new(math.clamp(h, 0, 1) - 0.02, 0, 0, 0)
	end

	local svDragging, hueDragging = false, false

	svFrame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			svDragging = true
			local mouse = UserInputService:GetMouseLocation()
			local absPos = svFrame.AbsolutePosition
			local absSize = svFrame.AbsoluteSize
			s = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
			v = 1 - math.clamp((mouse.Y - absPos.Y) / absSize.Y, 0, 1)
			updateSV()
			updatePositions()
		end
	end)

	hueFrame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			hueDragging = true
			local mouse = UserInputService:GetMouseLocation()
			local absPos = hueFrame.AbsolutePosition
			local absSize = hueFrame.AbsoluteSize
			h = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
			updateSV()
			updatePositions()
		end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement then
			local mouse = UserInputService:GetMouseLocation()
			if svDragging then
				local absPos = svFrame.AbsolutePosition
				local absSize = svFrame.AbsoluteSize
				s = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
				v = 1 - math.clamp((mouse.Y - absPos.Y) / absSize.Y, 0, 1)
				updateSV()
				updatePositions()
			elseif hueDragging then
				local absPos = hueFrame.AbsolutePosition
				local absSize = hueFrame.AbsoluteSize
				h = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
				updateSV()
				updatePositions()
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			svDragging = false
			hueDragging = false
		end
	end)

	updateSV()
	updatePositions()
	return wrapper
end

local _, CosmeticHolder = makeSection("Cosmetics", 70)

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
SkinBtn.Parent = CosmeticHolder
addOutlines(SkinBtn)

local _, ESPHolder = makeSection("ESP", 36)

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

local MAX_HEIGHT = 340

local function resizeAll()
	local canvasH = Container.AbsoluteSize.Y + 14
	local frameH  = math.min(canvasH, MAX_HEIGHT) + 34
	ScrollFrame.Size = UDim2.new(1, -4, 0, frameH - 34)
	MainFrame.Size   = UDim2.new(0, 300, 0, frameH)
end

ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeAll)

coroutine.wrap(function()
	task.wait()
	resizeAll()
end)()

coroutine.wrap(function()
	while task.wait() do
		AccentLine.BackgroundColor3 = C.accent
	end
end)()

local contentVisible = false
HideBtn.MouseButton1Click:Connect(function()
	contentVisible = not contentVisible
	ScrollFrame.Visible = contentVisible
	HideBtn.Text = contentVisible and "—" or "+"
	if contentVisible then
		resizeAll()
	else
		MainFrame.Size = UDim2.new(0, 300, 0, 34)
	end
end)

HideBtn.MouseEnter:Connect(function() HideBtn.BorderSizePixel = 1 end)
HideBtn.MouseLeave:Connect(function() HideBtn.BorderSizePixel = 0 end)
SkinBtn.MouseEnter:Connect(function() SkinBtn.BorderSizePixel = 1 end)
SkinBtn.MouseLeave:Connect(function() SkinBtn.BorderSizePixel = 0 end)

RunService.Heartbeat:Connect(function()
	espEnabled  = getBoxESP()
	nameEnabled = getNameESP()
	fillEnabled = getFillESP()
	if espEnabled then initESP() else clearAllESP() end
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

UserInputService.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)
