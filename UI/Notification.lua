local Notification = {}
Notification.__index = Notification

function Notification.New(args)
	local self = setmetatable({}, Notification)
	self.__IsDestroyed = false
	self.Title = args.Title or ""
	self.Text = args.Text or ""
	self.Duration = args.Duration or 3

	if type(args.Buttons) == "table" then
		local buttons = script.Buttons:Clone()
		buttons.Title.Text = self.Title
		buttons.Message.Text = self.Text
		buttons.Visible = true

		for i, buttonData in ipairs(args.Buttons) do
			local button = buttons.Buttons[tostring(i)]
			button.Text = buttonData.Text
			button.MouseButton1Click:Connect(function()
				if buttonData.Callback then
					buttonData.Callback()
				end
			end)
		end

		buttons.Parent = script.Parent
		task.wait(self.Duration)
		buttons:Destroy()
	else
		local simple = script.Simple:Clone()
		simple.Title.Text = self.Title
		simple.Message.Text = self.Text
		simple.Visible = true
		simple.Parent = script.Parent
		task.wait(self.Duration)
		simple:Destroy()
	end

	return self
end

return Notification
