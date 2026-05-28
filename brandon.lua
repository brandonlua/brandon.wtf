local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
	bg      = Color3.fromRGB(20, 20, 20),
	panel   = Color3.fromRGB(30, 30, 30),
	topbar  = Color3.fromRGB(24, 24, 24),
	item    = Color3.fromRGB(38, 38, 38),
	border  = Color3.fromRGB(60, 60, 60),
	accent  = Color3.fromRGB(100, 170, 220),
	text    = Color3.fromRGB(255, 255, 255),
	muted   = Color3.fromRGB(200, 200, 200),
	dim     = Color3.fromRGB(130, 130, 130),
}

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Brandon.wtf"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 180)
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
HideBtn.Text = "—"
HideBtn.TextColor3 = C.muted
HideBtn.TextSize = 13
HideBtn.Font = Enum.Font.Code
HideBtn.AutoButtonColor = false
HideBtn.ZIndex = 2
HideBtn.Parent = TopBar
addOutlines(HideBtn)

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -16, 0, 0)
Container.Position = UDim2.new(0, 8, 0, 36)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ClipsDescendants = false
Container.Parent = MainFrame

local ContainerLayout = Instance.new("UIListLayout")
ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContainerLayout.Padding = UDim.new(0, 8)
ContainerLayout.Parent = Container

local Section = Instance.new("Frame")
Section.Name = "Section"
Section.Size = UDim2.new(1, 0, 0, 24)
Section.BackgroundColor3 = C.panel
Section.BorderSizePixel = 0
Section.ClipsDescendants = false
Section.Parent = Container
addOutlines(Section)

local SectionTitleFrame = Instance.new("Frame")
SectionTitleFrame.Size = UDim2.new(0, 70, 0, 8)
SectionTitleFrame.Position = UDim2.new(0, 10, 0, 0)
SectionTitleFrame.BackgroundColor3 = C.panel
SectionTitleFrame.BorderSizePixel = 0
SectionTitleFrame.ZIndex = 3
SectionTitleFrame.Parent = Section

local SectionTitle = Instance.new("TextLabel")
SectionTitle.Size = UDim2.new(1, 0, 0, 14)
SectionTitle.Position = UDim2.new(0, 0, 0, -3)
SectionTitle.BackgroundTransparency = 1
SectionTitle.Text = "Cosmetics"
SectionTitle.TextColor3 = C.text
SectionTitle.TextSize = 14
SectionTitle.Font = Enum.Font.Code
SectionTitle.ZIndex = 4
SectionTitle.Parent = SectionTitleFrame

local ItemHolder = Instance.new("Frame")
ItemHolder.Name = "ItemHolder"
ItemHolder.Size = UDim2.new(1, -16, 0, 0)
ItemHolder.Position = UDim2.new(0, 8, 0, 14)
ItemHolder.BackgroundTransparency = 1
ItemHolder.BorderSizePixel = 0
ItemHolder.ZIndex = 2
ItemHolder.Parent = Section

local ItemLayout = Instance.new("UIListLayout")
ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
ItemLayout.Padding = UDim.new(0, 5)
ItemLayout.Parent = ItemHolder

local SkinBtn = Instance.new("TextButton")
SkinBtn.Name = "SkinBtn"
SkinBtn.Size = UDim2.new(1, 0, 0, 20)
SkinBtn.BackgroundColor3 = C.item
SkinBtn.BorderSizePixel = 0
SkinBtn.AutoButtonColor = false
SkinBtn.Text = "Unlock All Skins"
SkinBtn.TextColor3 = C.text
SkinBtn.TextSize = 14
SkinBtn.Font = Enum.Font.Code
SkinBtn.ZIndex = 2
SkinBtn.Parent = ItemHolder
addOutlines(SkinBtn)

local function resizeAll()
	local ih = ItemLayout.AbsoluteContentSize.Y
	ItemHolder.Size = UDim2.new(1, -16, 0, ih)
	Section.Size = UDim2.new(1, 0, 0, ih + 24)
	local ch = ContainerLayout.AbsoluteContentSize.Y
	Container.Size = UDim2.new(1, -16, 0, ch)
	MainFrame.Size = UDim2.new(0, 300, 0, ch + 52)
end

ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeAll)
ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeAll)
resizeAll()

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 160, 0, 18)
Watermark.Position = UDim2.new(0, 8, 1, -20)
Watermark.BackgroundTransparency = 1
Watermark.Text = "i skidded ts lol "
Watermark.TextColor3 = C.dim
Watermark.TextSize = 15
Watermark.Font = Enum.Font.Code
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.Parent = MainFrame

coroutine.wrap(function()
	while task.wait() do
		AccentLine.BackgroundColor3 = C.accent
	end
end)()

local contentVisible = true

HideBtn.MouseButton1Click:Connect(function()
	contentVisible = not contentVisible
	Container.Visible = contentVisible
	Watermark.Visible = contentVisible
	HideBtn.Text = contentVisible and "—" or "+"
	if contentVisible then
		resizeAll()
		MainFrame.Size = UDim2.new(0, 300, 0, ContainerLayout.AbsoluteContentSize.Y + 52)
	else
		MainFrame.Size = UDim2.new(0, 300, 0, 34)
	end
end)

HideBtn.MouseEnter:Connect(function() HideBtn.BorderSizePixel = 1 end)
HideBtn.MouseLeave:Connect(function() HideBtn.BorderSizePixel = 0 end)
SkinBtn.MouseEnter:Connect(function() SkinBtn.BorderSizePixel = 1 end)
SkinBtn.MouseLeave:Connect(function() SkinBtn.BorderSizePixel = 0 end)

SkinBtn.MouseButton1Click:Connect(function()
	SkinBtn.Text = "Loading..."
	SkinBtn.TextColor3 = C.dim
	pcall(function()
		loadstring(game:HttpGet("https://pastebin.com/raw/4rVNKnw0"))()
		SkinBtn.Text = "Unlocked"
		SkinBtn.TextColor3 = C.accent
	end)
end)

UserInputService.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)
