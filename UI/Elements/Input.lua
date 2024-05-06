local Input = {}
Input.__index = Input

local function anim(instance,duration,propTable)
	local tweenService = game:GetService("TweenService")
	tweenService:Create(instance,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),propTable):Play()
end

function Input.New(args)
	local self = setmetatable({},Input)
	self.__Destroyed = false
	self.__Visible = args.Visible or true
	self.__VisibilityDebounce = false
	self.Text = args.Text or ""
	self.Placeholder = args.Placeholder or ""
	self.Callback = args.Callback or function() end
	local function createInputInstance()
		local newInput = script.Input:Clone()
		newInput.Text = self.Text
		newInput.PlaceholderText = self.Placeholder
		newInput.Parent = script.Parent.Parent
		newInput.Focused:Connect(function()
			anim(newInput.Border,0.3,{Transparency=0})
		end)
		newInput.FocusLost:Connect(function()
			anim(newInput.Border,0.3,{Transparency=1})
		end)
		newInput.FocusLost:Connect(function(enterPressed,inputThatCausedFocusLoss)
			if self.InputObject.Text ~= "" then
				self.Text = self.InputObject.Text
			end
			pcall(function() self.Callback(self,newInput.Text,enterPressed,inputThatCausedFocusLoss) end)
		end)
		return newInput
	end
	self.InputObject = createInputInstance()
	return self
end

function Input:Hide()
	if not self.__Destroyed and self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		anim(self.InputObject,0.3,{BackgroundTransparency=1,TextTransparency=1})
		anim(self.InputObject.Border,0.3,{Transparency=1})
		task.wait(0.3)
		self.InputObject.Visible = false
		self.__Visible = false
		self.__VisibilityDebounce = false
	end
end

function Input:Show()
	if not self.__Destroyed and not self.__Visible and not self.__VisibilityDebounce then
		self.__VisibilityDebounce = true
		self.InputObject.Visible = true
		anim(self.InputObject,0.3,{BackgroundTransparency=0,TextTransparency=0})
		task.wait(0.3)
		self.__Visible = true
		self.__VisibilityDebounce = false
	end
end

function Input:SetText(text)
	if not self.__Destroyed then
		self.InputObject.Text = text
	end
end

function Input:GetText()
	if not self.__Destroyed then
		return self.InputObject.Text
	end
end

function Input:SetProperty(prop,val)
	if not self.__Destroyed then
		self.InputObject[prop] = val
	end
end

function Input:Destroy()
	if not self.__Destroyed then
		self.InputObject:Destroy()
		self.__Destroyed = true
	end
end

return Input
