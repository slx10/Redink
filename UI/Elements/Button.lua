local Button = {}
Button.__index = Button

local function anim(instance,duration,propTable)
	local tweenService = game:GetService("TweenService")
	tweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),propTable):Play()
end

function Button.New(args)
	local self = setmetatable({},Button)
	self.__Destroyed = false
	self.__Enabled = args.Enabled or true
	self.__Visible = args.Visible or true
	self.__VisibilityDebounce = false
	self.Text = args.Text or ""
	self.Description = args.Description or ""
	self.Callback = args.Callback or function() end
	local function createButtonInstance()
		local newButton = script.Button:Clone()
		newButton.Texts.Title.Text = self.Text
		newButton.Texts.Description.Text = self.Description
		newButton.Parent = script.Parent.Parent
		newButton.MouseButton1Click:Connect(function()
			pcall(function() 
				if self.__Enabled then
					self.Callback(self)
				end
			end)
		end)
		newButton.MouseEnter:Connect(function()
			anim(newButton.Border,0.3,{Transparency=0})
		end)
		newButton.MouseLeave:Connect(function()
			anim(newButton.Border,0.3,{Transparency=1})
		end)
		return newButton
	end
	self.ButtonObject = createButtonInstance()
	if self.Description == "" then
		self.ButtonObject.Texts.Title.Size = UDim2.fromScale(1,0.6)
		self.ButtonObject.Texts.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		self.ButtonObject.Texts.Title.TextYAlignment = Enum.TextYAlignment.Center
		self.ButtonObject.Texts.Description.Visible = false
	end
	return self
end

function Button:Hide()
	if not self.__Destroyed and self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		anim(self.ButtonObject,0.3,{BackgroundTransparency=1})
		anim(self.ButtonObject.Texts.Title,0.3,{TextTransparency=1})
		anim(self.ButtonObject.Texts.Description,0.3,{TextTransparency=1})
		anim(self.ButtonObject.Icon.Fingerprint,0.3,{ImageTransparency=1})
		task.wait(0.3)
		self.ButtonObject.Visible = false
		self.__Visible = false
		self.__VisibilityDebounce = false
	end
end

function Button:Show()
	if not self.__Destroyed and not self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		self.ButtonObject.Visible = true
		anim(self.ButtonObject,0.3,{BackgroundTransparency=0})
		anim(self.ButtonObject.Texts.Title,0.3,{TextTransparency=0})
		anim(self.ButtonObject.Texts.Description,0.3,{TextTransparency=0})
		anim(self.ButtonObject.Icon.Fingerprint,0.3,{ImageTransparency=0})
		task.wait(0.3)
		self.__Visible = true
		self.__VisibilityDebounce = false
	end
end

function Button:SetTitle(text)
	if not self.__Destroyed and typeof(text) == "string" then
		self.ButtonObject.Texts.Title.Text = text
	end
end

function Button:SetDescription(text)
	if not self.__Destroyed and typeof(text) == "string" then
		self.ButtonObject.Texts.Description.Text = text
	end
end

function Button:SetProperty(prop,val)
	if not self.__Destroyed then
		self.ButtonObject[prop] = val
	end
end

function Button:Destroy()
	if not self.__Destroyed then
		self.ButtonObject:Destroy()
		self.__Destroyed = true
	end
end

return Button