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
local SettingsTable = {['JsonEncoding'] = false}
local cleaner = janitor.new()

local function ProcessSettings(data, jsonSetting)
	local result, Value 
	
	if jsonSetting == 'decode' then 
		if typeof(data) ~= 'string' then 
			result = true Value = data
			return 
		else
			result, Value = pcall(function()
				return HTTPService:JSONDecode(data)
			end)
		end
	else
		result, Value = pcall(function()
			return HTTPService:JSONEncode(data)
		end)
	end

	return result, Value
end

local function renderUI_Data(d, parentKey : string?)	
	for k, v in d do
		if typeof(v) == 'boolean' then 
			local uiField = UIBoolTemplate:Clone()
			uiField.TextLabel.Text = parentKey..' -> '..k
			uiField.TextButton.BackgroundColor3 = booleanColors[tostring(v)]

			cleaner:Add(uiField.TextButton.MouseButton1Down:Connect(function()
				uiField.TextButton.BackgroundColor3 = booleanColors[tostring(not d[k])]
				d[k] = not d[k]

			end), 'Disconnect')

			uiField.Parent = loadedUI.ScrollingFrame
		elseif typeof(v) == 'table' then 
			renderUI_Data(v, k)
		else 
			local uiField = UITextTemplate:Clone()
			uiField.TextLabel.Text = parentKey..' -> '..k
			uiField.TextBox.Text = v

			cleaner:Add(uiField.TextBox.FocusLost:Connect(function(enterPressed : boolean)
				if not enterPressed then return end
				d[k] = uiField.TextBox.Text
				loadedData[parentKey] = d

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

function commitChanges()
	if not Datastore or not key then return warn('theres absolutely nothing to commit!') end
	local result, processedData
	
	if SettingsTable.JsonEncoding then 
		result, processedData = ProcessSettings(loadedData, 'encode')
	else
		processedData = loadedData
	end
	
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
	local processResult

	if not Datastore then 
		Datastore = DatastoreService:GetDataStore(UIInput.Text) 
		UIInput.Text = ''
		UIInput.PlaceholderText = 'Input your key here' 
		return 
	elseif not key then 
		key = UIInput.Text 
		loadedData = Datastore:GetAsync(key)
		if SettingsTable.JsonEncoding then processResult, loadedData = ProcessSettings(loadedData, 'decode') end
		renderUI_Data(loadedData, '')
		return
	end
end

function Settings()
	UISettingsMenu.Visible = not UISettingsMenu.Visible
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

	UISettingsMenu.JsonEncoding.TextButton.MouseButton1Down:Connect(function()
		SettingsTable.JsonEncoding = not SettingsTable.JsonEncoding
		UISettingsMenu.JsonEncoding.TextButton.BackgroundColor3 = booleanColors[tostring(SettingsTable.JsonEncoding)]
		print(SettingsTable.JsonEncoding)
	end)

end
