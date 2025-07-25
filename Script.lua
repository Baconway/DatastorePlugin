local HTTPService = game:GetService('HttpService')
local Management = game:GetService('PluginManagementService')

local toolbar = plugin:CreateToolbar('Editor')
local toolbarButton = toolbar:CreateButton('1', 'Open up the editor', 'rbxassetid://19005561666', 'Datastore Editor')

Management.Capabilities = SecurityCapabilities.new(Enum.SecurityCapability.Input, Enum.SecurityCapability.UI)

local UI_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, true,  602, 424, 502, 424)

local pluginUI : PluginGui
local ui : Frame

local function onActivation()
	if not pluginUI then 
		pluginUI = plugin:CreateDockWidgetPluginGui('DatastoreUI', UI_info)
		pluginUI.Title = 'Datastore Editor'	
		print(pluginUI.AbsoluteSize)
		ui = script.UI.Body:Clone()
		ui.Parent = pluginUI
		ui.Position = UDim2.new()
		require(script.UI.init)(ui)
		
	else
		pluginUI.Enabled = not pluginUI.Enabled
	end
end

toolbarButton.Click:Connect(onActivation)
