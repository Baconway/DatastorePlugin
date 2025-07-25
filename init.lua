local DatastoreService = game:GetService('DataStoreService')
local HTTPService = game:GetService('HttpService')

local janitor = require(script.Parent.Janitor)

local UIBody = script.Parent.Body
local UISFrame = UIBody.ScrollingFrame

local UIReturn : TextButton
local UICommit : TextButton
local UISettings : TextButton
local UIInput : TextBox

local UISettingsMenu : Frame
local UIBoolTemplate = script.Parent.Bool
local UITextTemplate = script.Parent.Text

local loadedUI
local Datastore : DataStore
local key : string
local loadedData : {}

local booleanColors = {['true'] = Color3.fromRGB(85, 255, 127), ['false'] = Color3.fromRGB(255, 0, 0)}
local cleaner = janitor.new()

local function renderUI_Data(d)
	for k, v in d do
		if typeof(v) == 'boolean' then 
			local uiField = UIBoolTemplate:Clone()
			uiField.TextLabel.Text = k
			uiField.TextButton.BackgroundColor3 = booleanColors[tostring(v)]
			
			cleaner:Add(uiField.TextButton.MouseButton1Down:Connect(function()
				uiField.TextButton.BackgroundColor3 = booleanColors[tostring(not loadedData[k])]
				loadedData[k] = not loadedData[k]
				
				print(loadedData)
			end), 'Disconnect')
			
			uiField.Parent = loadedUI.ScrollingFrame
		else
			local uiField = UITextTemplate:Clone()
			uiField.TextLabel.Text = k
			uiField.TextBox.Text = v
			
			cleaner:Add(uiField.TextBox.FocusLost:Connect(function(enterPressed : boolean)
				if not enterPressed then return end
				loadedData[k] = uiField.TextBox.Text
				print(loadedData)
			end), 'Disconnect')
			
			uiField.Parent = loadedUI.ScrollingFrame
		end
	end
end

local function customClear()
	for k, v in loadedUI.ScrollingFrame:GetChildren() do
		if v:IsA('Frame') then
			v:Destroy()
		end
		
	end
	
	cleaner:Cleanup()
end

local function ProcessSettings(data)
	return data
end

function commitChanges()
	print(Datastore, key)
	if not Datastore or not key then return warn('theres absolutely nothing to commit!') end
	local processedData = ProcessSettings(loadedData)
	Datastore:SetAsync(key, processedData)
end

function clearData()
	UIInput.InsideDatastore.Value = false
	Datastore = nil
	key = nil
	
	UIInput.PlaceholderText = 'Datastore Name'
	UIInput.Text = ''
	customClear()
end

function renderData(enterPressed : boolean)
	if not enterPressed then return end
	print(Datastore, key)
	if not Datastore then 
		Datastore = DatastoreService:GetDataStore(UIInput.Text) 
		UIInput.Text = ''
		UIInput.PlaceholderText = 'Input your key here' return 
	elseif not key then 
		key = UIInput.Text 
		loadedData = Datastore:GetAsync(key)
		renderUI_Data(loadedData)
		
		return
	end
end

function Settings()
	UISettingsMenu.Visible = not UISettingsMenu.Visible
	print(UISettings.Visible)
end

return function(ui)
	loadedUI = ui
	
	UIReturn = ui.Top.Return
	UICommit = ui.Top.Commit
	UISettings = ui.Top.Options
	UIInput = ui.Top.Input

	UISettingsMenu = ui.SettingsBody

	UIReturn.MouseButton1Down:Connect(clearData)
	UICommit.MouseButton1Down:Connect(commitChanges)
	UISettings.MouseButton1Down:Connect(Settings)
	UIInput.FocusLost:Connect(renderData)
end
