local Tab = {}
Tab.__index = Tab

local Debris = game:GetService("Debris")

local function anim(instance,duration,propTable)
	local tweenService = game:GetService("TweenService")
	tweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),propTable):Play()
end

function Tab.New(args,parent,eventCallback)
	local self = setmetatable({},Tab)
	self.Name = args.Name
	self.Active = args.Active or false
	self.Enabled = true
	self.EventCallback = eventCallback or function() end
	self.ElementsObjects = {}
	
	local function createTabInstance()
		local TabButton = script.TabButton:Clone()
		TabButton.Name = args.Name
		TabButton.Button.TabName.Text = args.Name
		TabButton.Parent = parent
		if args.Logo ~= nil then
			pcall(function()
				TabButton.Button.Logo.Image = string(args.Logo)
			end)
			TabButton.Button.Logo.Visible = true
			TabButton.Button.TabName.Size = UDim2.fromScale(TabButton.Button.TabName.Size.X.Scale - 0.21,1)
		end
		if args.CanClose then
			TabButton.Button.Close.Visible = true
			TabButton.Button.TabName.Size = UDim2.fromScale(TabButton.Button.TabName.Size.X.Scale - 0.21,1)
		end
		local TabFrame = script.TabFrame:Clone()
		TabFrame.Name = args.Name
		TabFrame.Parent = parent.Parent.Parent.TabFrameHolder
		if self.Active then
			local anim = require(script.Parent.Utils).anim
			anim(TabButton,0.1,{BackgroundTransparency=0})
			task.wait(0.1)
			TabButton.BackgroundTransparency = 0
			TabFrame.Visible = true
		end
		return TabButton,TabFrame
	end
	self.TabButton, self.TabFrame = createTabInstance()
	self.__IsDetroyed = false
	return self
end

function Tab:__index(key)
	local elementModule = script.Parent.Elements:FindFirstChild(key)
	if elementModule and elementModule:IsA("ModuleScript") then
		return function(args)
			local clonedModule = elementModule:Clone()
			clonedModule.Parent = self.TabFrame.Scroll.Elements
			local element = require(clonedModule).New(args)
			self.ElementsObjects[#self.ElementsObjects + 1] = element
			if not self.Active then
				element.__Visible = false
			end
			return element
		end
	else
		return rawget(Tab, key)
	end
end

function Tab:HideAll()
	for i,Element in pairs(self.ElementsObjects) do
		task.spawn(function()
			Element:Hide()
		end)
	end
	task.wait(0.15)
end

function Tab:ShowAll()
	for i,Element in pairs(self.ElementsObjects) do
		task.spawn(function()
			Element:Show()
		end)
	end
end

function Tab:Hide()
	anim(self.TabFrame,0.3,{BackgroundTransparency=1})
	anim(self.TabButton,0.3,{BackgroundTransparency=1})
	anim(self.TabButton.Button.Close.CloseBtn,0.3,{BackgroundTransparency=1})
	anim(self.TabButton.Button.TabName,0.3,{TextTransparency=1})
	self.TabFrame.Visible = false
	self.Enabled = false
end

function Tab:Show(setVisible)
	if setVisible then
		self.TabFrame.Visible = true
	end
	anim(self.TabFrame,0.3,{BackgroundTransparency=0})
	self.Enabled = true
end

function Tab:ShowButton(Active)
	anim(self.TabButton.Button.Close.CloseBtn,0.3,{BackgroundTransparency=0})
	anim(self.TabButton.Button.TabName,0.3,{TextTransparency=0})
	if Active then
		anim(self.TabButton,0.3,{BackgroundTransparency=0})
	end
end

function Tab:_Active()
	if not self.__IsDestroyed then
		local anim = require(script.Parent.Utils).anim
		anim(self.TabButton,0.1,{BackgroundTransparency=0})
		task.wait(0.1)
		self:Show(true)
		self:ShowAll()
		self.TabButton.BackgroundTransparency = 0
		self.TabFrame.Visible = true
		self.Active = true
	end
end

function Tab:_Deactive()
	if not self.__IsDestroyed then
		local anim = require(script.Parent.Utils).anim
		anim(self.TabButton,0.1,{BackgroundTransparency=1})
		task.wait(0.1)
		self.TabButton.BackgroundTransparency = 1
		self.TabFrame.Visible = false
		self.Active = false
	end
end

function Tab:Destroy()
	if not self.__IsDestroyed then
		self.EventCallback("Destroyed",self)
		self.__IsDestroyed = true
		Debris:AddItem(self.TabButton,0)
		Debris:AddItem(self.TabFrame,0)
	end
end

return Tab