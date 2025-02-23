local NanoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/MainModule/NanoUI.lua"))()
local Map = game.Players.LocalPlayer.PlayerGui.GameUI.Top.Main.StageInfo.Inner.WorldTitle.Text
local towers = game.Workspace:WaitForChild("Friendlies")
local player = game.Players.LocalPlayer
local singleTowerSet = 1  -- Initialize with a default value


MAPS = {
    ["Conch Street - 1"] = 1,
    ["Conch Street - 2"] = 1,
    ["Conch Street - 3"] = 1,
    ["Conch Street - 4"] = 1,
    ["Conch Street - 5"] = 1,
    ["Conch Street - 6"] = 2,
    ["Conch Street - 7"] = 2,
    ["Conch Street - 8"] = 2,
    ["Conch Street - 9"] = 2,
    ["Conch Street - 10"] = 2,
}

print("ye ".. Map)

local ui = NanoUI.new({
    Name = "Nanonite UI",
    ReopenKey = "N",  -- Press "N" to reopen the window after closing
    AnimationConfig = {
        close = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        maximize = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),  -- used for reopening
        minimize = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
    },
    HeaderButtons = {
        close = {
            Type = "Text",
            Text = "X",
            Color = Color3.new(1, 0, 0),
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -35, 0, 5),
            Font = Enum.Font.SourceSansBold,
            TextScaled = true,
        },
        minimize = {
            Type = "Text",
            Text = "-",
            Color = Color3.new(1, 1, 1),
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -70, 0, 5),
            Font = Enum.Font.SourceSansBold,
            TextScaled = true,
        }
    }
})

local clientTab = ui:CreateTab("Client")

ui:CreateSection(clientTab, {Title = "Discord"})
ui:CreateButton(clientTab, {
    Name = "Join the Nanonite Discord!",
    Callback = function()
         print("Discord button clicked!")
    end
})

ui:CreateSection(clientTab, {Title = "AFK"})
ui:CreateToggle(clientTab, {
    Name = "Anti AFK Disconnection",
    CurrentValue = true,
    Callback = function(val)
         print("AFK toggle is", val)
    end
})

ui:CreateSection(clientTab, {Title = "Performance"})
ui:CreateSlider(clientTab, {
    Name = "Max FPS (0 for Unlimited)",
    Range = {0, 120},
    CurrentValue = 0,
    Callback = function(val)
         print("Max FPS set to", val)
    end
})

ui:CreateSection(clientTab, {Title = "Properties"})
ui:CreateSlider(clientTab, {
    Name = "Set Walkspeed (Studs/s)",
    Range = {16, 120},
    CurrentValue = 16,
    Callback = function(val)
         print("Walkspeed set to", val)
         local player = game.Players.LocalPlayer
         local character = player.Character or player.CharacterAdded:Wait()
         local humanoid = character:WaitForChild("Humanoid")
         humanoid.WalkSpeed = tonumber(val)
    end
})


ui:CreateSection(clientTab, {Title = "Auto"})

ui:CreateSlider(clientTab, {
    Name = "Single Tower (Hotbar Slot)",
    Range = {1, 6},
    CurrentValue = 1,
    Callback = function(val)
        singleTowerSet = math.floor(val)  -- Ensure the value is an integer
        print("TowerIndex set to", singleTowerSet)
    end
})

function getTowerSet()
    return singleTowerSet
end

function replayRound()
    local args = {
        [1] = "Replay"
    }

    print("Replaying...")

    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RF"):WaitForChild("EndGameVote"):InvokeServer(unpack(args))
    wait(1)
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RF"):WaitForChild("VoteStartRound"):InvokeServer()
end

function playNextRound()
    local args = {
        [1] = "Next"
    }

    print("Playing Next Round...")

    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RF"):WaitForChild("EndGameVote"):InvokeServer(unpack(args))
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RF"):WaitForChild("VoteStartRound"):InvokeServer()
end

local autoPlaceRunning = false
local autoUpgradeRunning = false
local autoReplayRunning = false
local autoNextRunning = false
local autoCheckChests = false
local autoPrestige = false


ui:CreateToggle(clientTab, {
    Name = "Auto Place",
    CurrentValue = false,
    Callback = function(val)
        autoPlaceRunning = val
        print("AUTO PLACE:", val)

        local function notOverFive(name)
            local count = 0
            print("DEBUG TOWERS:", game.Workspace.Friendlies:GetChildren())
            for _, child in ipairs(towers:GetChildren()) do
                if child.Name == name then
                    count = count + 1
                    if count > 5 then
                        print("CHILD: ", child.Name)
                        return true
                    else
                        print("its not over 5")
                        return false
                    end
                end
            end
            return true
        end

        function startsWith(str, start)
            return string.sub(str, 1, string.len(start)) == start
        end

        function getTowers()
            local player = game.Players.LocalPlayer
            local hotbar = player.PlayerGui.HUD.Bottom.Hotbar

            -- Create a list to store the information
            local resultList = {}

            for _, child in ipairs(hotbar:GetChildren()) do
                if child:IsA("TextButton") then
                    -- Get the name of the TextButton
                    local buttonName = child.Name

                    -- Check if the structure exists
                    local towerInfo = child:FindFirstChild("Content")
                    if towerInfo then
                        local viewportFrame = towerInfo:FindFirstChild("TowerInfo")
                        if viewportFrame then
                            local worldModel = viewportFrame:FindFirstChild("ViewportFrame")
                            if worldModel then
                                local model = worldModel:FindFirstChild("WorldModel")
                                if model then
                                    local towerModel = model:GetChildren()[1]
                                    if towerModel then
                                        local modelName = towerModel.Name
                                        -- Append to the result list
                                        table.insert(resultList, {buttonName = buttonName, modelName = modelName})
                                    else
                                        print("No Model found for", buttonName)
                                    end
                                else
                                    print("No WorldModel found for", buttonName)
                                end
                            else
                                print("No ViewportFrame found for", buttonName)
                            end
                        else
                            print("No TowerInfo found for", buttonName)
                        end
                    else
                        print("No Content found for", buttonName)
                    end
                end
            end

            -- Return the list
            return resultList
        end

        local function findTowerByName(models, namePart)
            for _, modelInfo in ipairs(models) do
                if string.find(string.lower(modelInfo.modelName), string.lower(namePart)) then
                    return tonumber(modelInfo.buttonName)
                end
            end
            return nil  -- If no matching model is found
        end

        function placeTower(TOWERNUM, x, y, z)
            local args = {
                [1] = CFrame.new(x,y,z, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                [2] = TOWERNUM
            }

            print("Placing Tower At ", tostring(x), tostring(y), tostring(z))
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("TowerService"):WaitForChild("RF"):WaitForChild("PlaceTower"):InvokeServer(unpack(args))
        end

        -- Function to print table contents in a specific format
        local function printTable(t)
            local parts = {}
            for i, v in ipairs(t) do
                table.insert(parts, string.format("%d = %s", i, v.modelName))
            end
            print("{" .. table.concat(parts, ", ") .. "}")
        end

        if val then
            coroutine.wrap(function()
                while autoPlaceRunning do
                    Map = game.Players.LocalPlayer.PlayerGui.GameUI.Top.Main.StageInfo.Inner.WorldTitle.Text

                    local models = getTowers()
                    -- Print all models for debugging
                    print("All Models:")
                    printTable(models)

                    print("GOT SINGLETOWER SET ", singleTowerSet)
                    local guiTowerName = player.PlayerGui.HUD.Bottom.Hotbar[tostring(singleTowerSet)].Content.TowerInfo.ViewportFrame.WorldModel:GetChildren()[1]
                    -- [[ STARTERS ]]
                    local spongebobIndex = findTowerByName(models, "Spongebob")
                    local squidwardIndex = findTowerByName(models, "Squidward")
                    local patrickIndex = findTowerByName(models, "Patrick")

                    -- [[ RARE ]]
                    local pearlIndex = findTowerByName(models, "Pearl")
                    local krustykrabIndex = findTowerByName(models, "KrustyKrab")
                    
                    -- [[ EPIC ]]
                    local atomicflounderIndex = findTowerByName(models, "AtomicFlounder")
                    local mermaidmanspongebobIndex = findTowerByName(models, "MermaidManSpongebob")

                    -- [[ LEGENDARY ]]
                    local handsomesquidwardIndex = findTowerByName(models, "HandsomeSquidward")
                    local mrkrabsIndex = findTowerByName(models, "MrKrabs")
                    local doodlebobIndex = findTowerByName(models, "DoodleBob")
                    local missappearIndex = findTowerByName(models, "MissAppear")
                    
                    -- [[ MYTHIC ]]
                    local realisticfishheadIndex = findTowerByName(models, "RealisticFishHead")
                    local kingneptuneIndex = findTowerByName(models, "KingNeptune")
                    local manrayIndex = findTowerByName(models, "ManRay")
                    local mermaidmanIndex = findTowerByName(models, "MermaidMan")

                    -- [[ SECRET ]]
                    local cyborgplanktonIndex = findTowerByName(models, "CyborgPlankton")
                    

                    if MAPS[Map] == 1 then

                        -- Conch Street ACT 1 --


                        --[[if spongebobIndex then
                            placeTower(spongebobIndex, -50.469696044921875, 81.89447021484375, 12.080700874328613)
                            placeTower(spongebobIndex, -60.469696044921875, 81.89447021484375, 12.080700874328613)
                            placeTower(spongebobIndex, -50.469696044921875, 81.89447021484375, 2.080700874328613)
                            placeTower(spongebobIndex, -60.469696044921875, 81.89447021484375, 2.080700874328613)
                            placeTower(spongebobIndex, -65.05299377441406, 81.82585906982422, 12.080700874328613)
                            placeTower(spongebobIndex, -65.05299377441406, 81.82585906982422, 2.080700874328613)
                        else

                        ]]


                        --[[if realisticfisheadIndex then
                            if mrkrabsIndex then
                                placeTower(mrkrabsIndex, -49.688201904296875, 81.90093231201172, 9.673673629760742)
                                placeTower(realisticfisheadIndex, -89.7808837890625, 82.40098571777344, 9.808916091918945)
                                placeTower(realisticfisheadIndex, -90.16045379638672, 82.46959686279297, 0.3008732795715332)
                            else
                                placeTower(realisticfisheadIndex, -49.135677337646484, 82.46959686279297, 9.44611644744873)
                                placeTower(realisticfisheadIndex, -59.172969818115234, 82.46959686279297, 9.549297332763672)
                            end]]

                        if krustykrabIndex then
                            placeTower(krustykrabIndex, -112.79808044433594, 81.79622650146484, -60.20471954345703)
                            if cyborgplanktonIndex then
                                placeTower(cyborgplanktonIndex, -48.345218658447266, 81.94279479980469, 11.969005584716797)
                            elseif pearlIndex then
                                placeTower(pearlIndex, -60.760711669921875, 81.83309173583984, 11.541154861450195)
                                placeTower(pearlIndex, -80.94099426269531, 81.83309173583984, -7.914839267730713)
                                placeTower(pearlIndex, -74.86628723144531, 81.83309173583984, 13.549261093139648)
                                placeTower(pearlIndex, -80.82010650634766, 81.83309173583984, 20.213565826416016)
                            elseif handsomesquidwardIndex then
                                placeTower(handsomesquidwardIndex, -58.03690719604492, 81.93077850341797, 1.950894832611084)
                                placeTower(handsomesquidwardIndex, -45.21202087402344, 81.86216735839844, 15.895241737365723)
                                placeTower(handsomesquidwardIndex, -58.31394958496094, 81.93077850341797, 9.955920219421387)
                            end
                            if kingneptuneIndex then
                                placeTower(kingneptuneIndex, 13.516682624816895, 82.812255859375, 11.427483558654785)
                                placeTower(kingneptuneIndex, -63.347862243652344, 82.812255859375, -4.120278835296631)
                            elseif mrkrabsIndex then
                                placeTower(mrkrabsIndex, 13.516682624816895, 82.812255859375, 11.427483558654785)
                                placeTower(mrkrabsIndex, -63.347862243652344, 82.812255859375, -4.120278835296631)
                            end
                            if realisticfishheadIndex then
                                placeTower(realisticfishheadIndex, -91.16117858886719, 82.46959686279297, 0.766697883605957)
                                placeTower(realisticfishheadIndex, -91.11587524414062, 82.46959686279297, 9.722922325134277)
                            elseif mermaidmanIndex then
                                placeTower(mermaidmanIndex, -91.5176010131836, 81.83255767822266, 11.288106918334961)
                                placeTower(mermaidmanIndex, -90.53898620605469, 81.90116882324219, -0.14499282836914062)
                            elseif mermaidmanspongebobIndex then
                                placeTower(mermaidmanspongebobIndex, -91.5176010131836, 81.83255767822266, 11.288106918334961)
                                placeTower(mermaidmanspongebobIndex, -90.53898620605469, 81.90116882324219, -0.14499282836914062)
                            elseif missappearIndex then
                                --placeTower(missappearIndex, -91.5176010131836, 81.83255767822266, 11.288106918334961)
                                --placeTower(missappearIndex, -90.53898620605469, 81.90116882324219, -0.14499282836914062)
                            end
                            if manrayIndex then
                                placeTower(manrayIndex, -83.92899322509766, 81.9013900756836, 0.12329253554344177)
                                placeTower(manrayIndex, -85.20375061035156, 81.83277893066406, 11.1602201461792)
                            elseif doodlebobIndex then
                                placeTower(doodlebobIndex, -83.92899322509766, 81.9013900756836, 0.12329253554344177)
                                placeTower(doodlebobIndex, -85.20375061035156, 81.83277893066406, 11.1602201461792)
                            end
                        elseif squidwardIndex then
                            placeTower(squidwardIndex, -57.883052825927734, 81.90117645263672, 1.8509368896484375)
                            placeTower(squidwardIndex, -51.058502197265625, 81.90117645263672, 2.053215980529785)
                            placeTower(squidwardIndex,-51.140953063964844, 81.90117645263672, 8.564817428588867)
                            placeTower(squidwardIndex, -58.120094299316406, 81.90117645263672, 8.651710510253906)
                            placeTower(squidwardIndex, -39.035728454589844, 81.83256530761719, 10.476228713989258)
                            placeTower(squidwardIndex, -49.28620529174805, 81.83256530761719, 21.52135467529297)
                        else
                            print("Doesn't have any available strats.")
                        end


                    elseif MAPS[Map] == 2 then

                        -- Conch Street ACT 2 --

                        if squidwardIndex then
                            placeTower(squidwardIndex, 11.906923294067383, 81.83256530761719, -2.9144554138183594)                            
                            placeTower(squidwardIndex, -68.583251953125, 81.83256530761719, -21.146440505981445)
                            placeTower(squidwardIndex, -59.88611602783203, 81.83256530761719, -20.709671020507812)
                            placeTower(squidwardIndex, -50.56944274902344, 81.90117645263672, 0.1910991668701172)
                            placeTower(squidwardIndex, -41.67198181152344, 81.90117645263672, 0.10247039794921875)
                            placeTower(squidwardIndex, -69.177001953125, 81.83256530761719, -18.19882583618164)
                        elseif pearlIndex then
                            placeTower(pearlIndex, -77.85921478271484, 81.90149688720703, 1.0943154096603394)
                            placeTower(pearlIndex, -64.0494384765625, 81.8328857421875, -18.854434967041016)
                            placeTower(pearlIndex, -46.32029724121094, 81.93286895751953, -3.7638697624206543)
                            placeTower(pearlIndex, -64.00389862060547, 81.8328857421875, -2.6312856674194336)
                        else
                            print("No tower found with 'Pearl' in its model name.")
                        end

                        local jimIndex = findTowerByName(models, "Jim")

                        if jimIndex then
                            placeTower(jimIndex, -28.967960357666016, 81.83258056640625, -11.0302095413208)
                        else
                            print("No tower found with 'Jim' in its model name.")
                        end

                    else
                        print("Map not recognized.")
                    end
                    wait(5)
                end
            end)()
        end
    end
})

ui:CreateToggle(clientTab, {
    Name = "Auto Upgrade",
    CurrentValue = false,
    Callback = function(val)
        autoUpgradeRunning = val

        print("AUTO UPGRADE:", val)

        function upgradeTower(id)
            local args = {
                [1] = id
            }

            print("Upgrading: ", id)
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RF"):WaitForChild("UpgradeTower"):InvokeServer(unpack(args))
        end

        if val then
            coroutine.wrap(function()
                while autoUpgradeRunning do
                    -- First, upgrade all Krusty Krab towers
                    local krustyKrabTowers = {}
                    for _, tower in ipairs(towers:GetChildren()) do
                        if tower:IsA("Model") then
                            local id = tower:GetAttribute("Id")
                            if id and tower.Name == "Krusty Krab" then
                                table.insert(krustyKrabTowers, id)
                            end
                        end
                    end
                    
                    -- Upgrade all Krusty Krab towers first
                    for _, id in ipairs(krustyKrabTowers) do
                        upgradeTower(id)
                    end

                    -- Then, upgrade all other towers
                    for _, tower in ipairs(towers:GetChildren()) do
                        if tower:IsA("Model") then
                            local id = tower:GetAttribute("Id")
                            if id and tower.Name ~= "Krusty Krab" then
                                upgradeTower(id)
                            end
                        end
                    end

                    wait(5)
                end
            end)()
        end
    end
})

ui:CreateToggle(clientTab, {
    Name = "Auto Replay",
    CurrentValue = false,
    Callback = function(val)
        autoReplayRunning = val
        print("AUTO REPLAY:", val)

        if val then
            coroutine.wrap(function()
                while autoReplayRunning do
                    print("Trying to replay...")
                    if game.Players.LocalPlayer.PlayerGui.RoundSummary.Enabled then
                        replayRound()
                        wait(2.4)
                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("GameService"):WaitForChild("RF"):WaitForChild("VoteStartRound"):InvokeServer()
                    else
                        print("Still not ready to replay...")
                    end
                    wait(1)
                end
            end)()
        end
    end
})

ui:CreateToggle(clientTab, {
    Name = "Show Gems & Coins",
    CurrentValue = false,
    Callback = function(val)
        print("Show Gems & Coins:", val)
        game.Players.LocalPlayer.PlayerGui.HUD.Bottom.Currency.Visible = val
    end
})

-- Function to create and manage the popup GUI
function showChestPopup(text)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")  -- Changed to CoreGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 50)
    Frame.Position = UDim2.new(0.5, -100, 0.5, -25) -- Center the frame
    Frame.BackgroundColor3 = Color3.new(0, 0.5, 1)  -- Blue vibrant background
    Frame.Parent = ScreenGui
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextSize = 20
    TextLabel.TextColor3 = Color3.new(0, 1, 0)  -- Bold green text
    TextLabel.Parent = Frame

    -- Destroy the GUI after 5 seconds
    wait(5)
    ScreenGui:Destroy()
end

ui:CreateToggle(clientTab, {
    Name = "Auto Check Chests",
    CurrentValue = false,
    Callback = function(val)
        autoCheckChests = val
        print("Auto Check Chest:", val)


        local chest
        local epicChest
        local legendaryChest
        local mythicChest
        local pickedChest

        if val then
            coroutine.wrap(function()
                while autoCheckChests do
                    print("CHECKING FOR CHESTS...")
                    if game.Players.LocalPlayer.PlayerGui.RoundSummary.Enabled then
                        print("Round Summary found...")
                        local rewardsFrame = game.Players.LocalPlayer.PlayerGui.RoundSummary.Main.Content.RoundData.Rewards.Bin
                        chest = rewardsFrame:FindFirstChild("TreasureChest", true)
                        epicChest = rewardsFrame:FindFirstChild("EpicTreasureChest", true)
                        legendaryChest = rewardsFrame:FindFirstChild("LegendaryTreasureChest", true)
                        mythicChest = rewardsFrame:FindFirstChild("MythicTreasureChest", true)
                        
                        if chest then pickedChest="NORMAL CHEST" elseif epicChest then pickedChest="EPIC CHEST" elseif legendaryChest then pickedChest="LEGENDARY CHEST" elseif mythicChest then pickedChest="MYTHIC CHEST" else pickedChest=false end
                        
                        if pickedChest then
                            -- Here you would typically interact with the chest, but for this example, we'll just show the popup
                            showChestPopup(pickedChest)
                            if chest then
                                print("NORMAL CHEST: ", chest.Name)
                            elseif epicChest then
                                print("EPIC CHEST: ", epicChest.Name)
                            elseif legendaryChest then
                                print("LEGENDARY CHEST: ", legendaryChest.Name)
                            elseif mythicChest then
                                print("MYTHIC CHEST: ", mythicChest.Name)
                            end
                            local args = {
                                [1] = chest.Name or epicChest.Name or legendaryChest.Name or mythicChest.Name
                            }

                            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("TreasureService"):WaitForChild("RF"):WaitForChild("Open"):InvokeServer(unpack(args))
                            print("OPENED...")
                        end
                    end
                    wait(0.1) -- Wait for a second before next check to not overload the game
                end
            end)()
        end
    end
})

ui:CreateToggle(clientTab, {
    Name = "Auto Prestige",
    CurrentValue = false,
    Callback = function(val)
        autoPrestige = val
        print("Auto Prestige:", val)
        if val then
            coroutine.wrap(function()
                while autoPrestige do
                    print("CHECKING FOR CHESTS...")
                    if game.Players.LocalPlayer.PlayerGui.HUD.Bottom.Leveling.Progression.Text == "Level 100 (MAX)" then
                        print("Attempting to Prestige...")
                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("StatsService"):WaitForChild("RF"):WaitForChild("Prestige"):InvokeServer()
                    else
                        print("Still not Level 100.")
                    end
                    wait(1) -- Wait for a second before next check to not overload the game
                end
            end)()
        end
    end
})


ui:CreateToggle(clientTab, {
    Name = "Auto Next",
    CurrentValue = false,
    Callback = function(val)
        autoNextRunning = val
        print("AUTO NEXT:", val)

        if val then
            coroutine.wrap(function()
                while autoNextRunning do
                    print("Trying to play next round...")
                    if game.Players.LocalPlayer.PlayerGui.RoundSummary.Enabled then
                        playNextRound()
                    else
                        print("Still not ready to play next round...")
                    end
                    wait(5)
                end
            end)()
        end
    end
})


ui:CreateSection(clientTab, {Title = "Development"})
ui:CreateButton(clientTab, {
    Name = "Rejoin",
    Callback = function()
         print("Rejoin pressed!")
    end
})

print("The UI is active.")
print("Click the red X button to close (animate out) the window, then press 'N' to reopen it.")
