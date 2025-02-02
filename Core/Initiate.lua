-- loadstring(game:HttpGet("https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Initiate.lua"))()

local getgenv: () -> ({[string]: any}) = getfenv().getgenv

local function Notify(Text)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Nanonite Notification",
		Text = Text,
		Duration = 10
	})
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Analytics.lua"))()

local PlaceName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

PlaceName = PlaceName:gsub("%b[]", "")
PlaceName = PlaceName:gsub("[^%a]", "")

local Code: string = game:HttpGet(`https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Games/{PlaceName}.lua`)

if Code ~= "404: Not Found" then
	Notify("Game found, the script is loading.")
	getgenv().PlaceFileName = PlaceName
else
	Notify("Game not found, loading universal.")
	getgenv().ScriptVersion = "Universal"
	Code = game:HttpGet("https://raw.githubusercontent.com/Nanonite-crypto/NanoniteHub/refs/heads/main/Core/Core.lua")
end

getgenv().FrostByteHandleFunction(loadstring(Code))
