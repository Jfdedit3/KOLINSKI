local success, result = pcall(function()
    return game:GetObjects("rbxassetid://01997056190")[1]
end)

if not success then
    warn("Erreur de chargement de l'interface:", result)
    return
end

local aa = result
aa.Parent = game.CoreGui
wait(0.2)

local GUI = aa.PopupFrame.PopupFrame
local pos = 0

local ignore = {
    "rbxasset://sounds/action_get_up.mp3",
    "rbxasset://sounds/uuhhh.mp3",
    "rbxasset://sounds/action_falling.mp3",
    "rbxasset://sounds/action_jump.mp3",
    "rbxasset://sounds/action_jump_land.mp3",
    "rbxasset://sounds/impact_water.mp3",
    "rbxasset://sounds/action_swim.mp3",
    "rbxasset://sounds/action_footsteps_plastic.mp3"
}

-- Fonction pour envoyer une notification
local function sendNotification(title, text, icon, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Notification",
            Text = text or "",
            Icon = icon or "http://www.roblox.com/asset/?id=176572847",
            Duration = duration or 5
        })
    end)
end

-- Fonction pour vérifier si writefile est disponible
local function writefileExploit()
    return writefile ~= nil
end

-- Fonction pour afficher un tableau dans le panneau Store
local function printTable(tbl, targetLabel)
    if type(tbl) ~= 'table' or not targetLabel then return nil end
    local output = ""
    local depthCount = 0

    local function run(val, indentLevel)
        indentLevel = indentLevel or 0
        local indent = string.rep('  ', indentLevel) -- Utiliser des espaces pour l'indentation
        for i, v in pairs(val) do
            if type(v) == 'table' then
                output = output .. indent .. "[" .. tostring(i) .. "] = {\n"
                run(v, indentLevel + 1)
                output = output .. indent .. "}\n"
            else
                output = output .. indent .. "[" .. tostring(i) .. "] = " .. tostring(v) .. "\n"
            end
        end
    end
    run(tbl)
    targetLabel.Text = output
end

-- Fonction pour rafraîchir la liste des sons
local function refreshlist()
    pos = 0
    for _, child in pairs(GUI.Logs:GetChildren()) do
        if child:IsA("Frame") then -- S'assurer qu'on traite que les éléments de la liste
            child.Position = UDim2.new(0, 0, 0, pos)
            pos = pos + child.Size.Y.Offset
        end
    end
    GUI.Logs.CanvasSize = UDim2.new(0, 0, 0, pos)
end

-- Fonction pour trouver un élément dans un tableau
local function FindTable(Table, Name)
    for i, v in pairs(Table) do
        if v == Name then
            return true
        end
    end
    return false
end

-- Fonction de Drag améliorée
function drag(gui)
    spawn(function()
        local UserInputService = game:GetService("UserInputService")
        local dragging
        local dragInput
        local dragStart
        local startPos

        local function update(input)
            local delta = input.Position - dragStart
            gui:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), "InOut", "Quart", 0.04, true, nil)
        end

        -- Événement InputBegan : Détecte le début du clic
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                -- Vérifie si le clic a eu lieu sur la barre de titre (ou sur une zone spécifique pour le drag)
                -- Ici, on suppose que la barre de titre s'appelle "TitleBar" ou "Header"
                -- Si votre GUI n'a pas de barre de titre, vous pouvez utiliser un Frame invisible au-dessus de la fenêtre.
                local titleBar = gui:FindFirstChild("TitleBar") or gui:FindFirstChild("Header")

                if titleBar then
                    -- Vérifie si le clic est dans la barre de titre
                    local mousePos = input.Position
                    local guiAbsolutePos = gui.AbsolutePosition
                    local titleBarPos = titleBar.AbsolutePosition
                    local titleBarSize = titleBar.AbsoluteSize

                    if mousePos.X >= titleBarPos.X and mousePos.X <= titleBarPos.X + titleBarSize.X and
                       mousePos.Y >= titleBarPos.Y and mousePos.Y <= titleBarPos.Y + titleBarSize.Y then
                        dragging = true
                        dragStart = input.Position
                        startPos = gui.Position
                    end
                else
                    -- Si aucune barre de titre n'est trouvée, on utilise toute la fenêtre (moins les boutons)
                    -- On va créer une exception pour les boutons
                    local clickedOnButton = false
                    for _, child in pairs(gui:GetChildren()) do
                        if child:IsA("TextButton") or child:IsA("ImageButton") then
                            -- Vérifie si le clic est sur ce bouton
                            local buttonPos = child.AbsolutePosition
                            local buttonSize = child.AbsoluteSize
                            if mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                               mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y then
                                clickedOnButton = true
                                break
                            end
                        end
                    end
                    if not clickedOnButton then
                        dragging = true
                        dragStart = input.Position
                        startPos = gui.Position
                    end
                end

                -- Connecte l'événement de fin du clic
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        -- Événement InputChanged : Détecte le mouvement de la souris/touche
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        -- Événement InputChanged global : Met à jour la position de la fenêtre
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end)
end

-- Appliquer le drag à la fenêtre
drag(aa.PopupFrame)

-- Fonction pour créer des effets visuels sur les boutons
local function createButtonEffect(button)
    if button:IsA("TextButton") or button:IsA("ImageButton") then
        button.MouseEnter:Connect(function()
            button.BackgroundTransparency = 0.8 -- Légèrement plus foncé au survol
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundTransparency = 0.5 -- Retour à la transparence normale
        end)
        button.MouseButton1Click:Connect(function()
            button.BackgroundTransparency = 0.9 -- Effet de pression
            wait(0.1)
            button.BackgroundTransparency = 0.8
        end)
    end
end

-- Appliquer les effets à tous les boutons enfants de la fenêtre principale
for _, child in pairs(GUI:GetChildren()) do
    createButtonEffect(child)
    if child:IsA("Frame") then -- Parcourir les enfants des frames aussi (ex: le panneau d'info)
        for _, subChild in pairs(child:GetChildren()) do
            createButtonEffect(subChild)
        end
    end
end

-- Fermeture de l'interface (le "X")
GUI.Close.MouseButton1Click:connect(function()
    GUI:TweenSize(UDim2.new(0, 360, 0, 0),"Out","Quad",0.5,true)
    wait(0.6)
    -- Assurez-vous que tous les events sont bien déconnectés avant la destruction
    if itemadded then
        itemadded:Disconnect()
    end
    aa:Destroy()
end)

-- Minimiser/maximiser l'interface
local min = false
GUI.Minimize.MouseButton1Click:connect(function()
    if not min then
        GUI:TweenSize(UDim2.new(0, 360, 0, 20),"Out","Quad",0.5,true)
        min = true
    else
        GUI:TweenSize(UDim2.new(0, 360, 0, 260),"Out","Quad",0.5,true)
        min = false
    end
end)

-- Autres variables
local writeaudio = {}
local running = false
local selectedaudio = nil

-- Sauvegarde des sons sélectionnés
GUI.SS.MouseButton1Click:connect(function()
    if not writefileExploit() then
        sendNotification("Audio Logger", "Exploit ne supporte pas writefile :(", nil, 5)
        return
    end
    if running then return end
    running = true
    GUI.Load.Visible = true
    GUI.Load:TweenSize(UDim2.new(0, 360, 0, 20), "Out", "Quad", 0.5, true)
    wait(0.3)

    writeaudio = {} -- Réinitialiser la table
    for _, child in pairs(GUI.Logs:GetChildren()) do
        if child:FindFirstChild('ImageButton') then
            local bttn = child.ImageButton
            if bttn.BackgroundTransparency == 0 then -- Sélectionné
                writeaudio[#writeaudio + 1] = { NAME = child.NAME.Value, ID = child.ID.Value }
            end
        end
    end

    if #writeaudio == 0 then
        sendNotification("Audio Logger", "Aucun son sélectionné à sauvegarder.", nil, 5)
        GUI.Load.Visible = false
        running = false
        return
    end

    printTable(writeaudio, GUI.Store) -- Affiche dans GUI.Store.TextLabel
    GUI.Store.Visible = true
    wait(0.2)

    local filename = 0
    local function write()
        local file
        pcall(function() file = readfile("Audios" .. filename .. ".txt") end)
        if file then
            filename = filename + 1
            write()
        else
            local text = GUI.Store.TextLabel.Text -- Utiliser le TextLabel dans Store
            text = text:gsub('\n', '\r\n')
            writefile("Audios" .. filename .. ".txt", text)
        end
    end
    write()

    -- Animation de chargement
    for rep = 1, 10 do
        GUI.Load.BackgroundTransparency = GUI.Load.BackgroundTransparency + 0.1
        wait(0.05)
    end

    GUI.Load.Visible = false
    GUI.Load.BackgroundTransparency = 0
    GUI.Load.Size = UDim2.new(0, 0, 0, 20)
    running = false
    GUI.Store.Visible = false
    GUI.Store.TextLabel.Text = '' -- Réinitialiser le texte

    sendNotification("Audio Logger", "Sons sélectionnés sauvegardés (Audios" .. filename .. ".txt)", nil, 5)
end)

-- Sauvegarde de TOUS les sons
GUI.SA.MouseButton1Click:connect(function()
    if not writefileExploit() then
        sendNotification("Audio Logger", "Exploit ne supporte pas writefile :(", nil, 5)
        return
    end
    if running then return end
    running = true
    GUI.Load.Visible = true
    GUI.Load:TweenSize(UDim2.new(0, 360, 0, 20), "Out", "Quad", 0.5, true)
    wait(0.3)

    writeaudio = {} -- Réinitialiser la table
    for _, child in pairs(GUI.Logs:GetChildren()) do
        writeaudio[#writeaudio + 1] = { NAME = child.NAME.Value, ID = child.ID.Value }
    end

    if #writeaudio == 0 then
        sendNotification("Audio Logger", "Aucun son trouvé à sauvegarder.", nil, 5)
        GUI.Load.Visible = false
        running = false
        return
    end

    printTable(writeaudio, GUI.Store)
    GUI.Store.Visible = true
    wait(0.2)

    local filename = 0
    local function write()
        local file
        pcall(function() file = readfile("Audios" .. filename .. ".txt") end)
        if file then
            filename = filename + 1
            write()
        else
            local text = GUI.Store.TextLabel.Text
            text = text:gsub('\n', '\r\n')
            writefile("Audios" .. filename .. ".txt", text)
        end
    end
    write()

    for rep = 1, 10 do
        GUI.Load.BackgroundTransparency = GUI.Load.BackgroundTransparency + 0.1
        wait(0.05)
    end

    GUI.Load.Visible = false
    GUI.Load.BackgroundTransparency = 0
    GUI.Load.Size = UDim2.new(0, 0, 0, 20)
    running = false
    GUI.Store.Visible = false
    GUI.Store.TextLabel.Text = ''

    sendNotification("Audio Logger", "Tous les sons sauvegardés (Audios" .. filename .. ".txt)", nil, 5)
end)

-- Fonction pour rechercher les sons dans un parent
local function getaudio(place)
    if running then return end
    running = true
    GUI.Load.Visible = true
    GUI.Load:TweenSize(UDim2.new(0, 360, 0, 20), "Out", "Quad", 0.5, true)
    wait(0.3)

    for _, child in pairs(place:GetDescendants()) do
        spawn(function()
            if child:IsA("Sound") and not GUI.Logs:FindFirstChild(child.SoundId) and not FindTable(ignore, child.SoundId) then
                local id = string.match(child.SoundId, "rbxasset://sounds.+") or string.match(child.SoundId, "&hash=.+") or string.match(child.SoundId, "%d+")
                if id ~= nil then
                    local newsound = GUI.Audio:Clone()
                    if string.sub(id, 1, 6) == "&hash=" or string.sub(id, 1, 7) == "&0hash=" then
                        id = string.sub(id, (string.sub(id, 1, 6) == "&hash=" and 7) or (string.sub(id, 1, 7) == "&0hash=" and 8), string.len(id))
                        newsound.ImageButton.Image = 'rbxassetid://1453863294'
                    end

                    newsound.Parent = GUI.Logs
                    newsound.Name = child.SoundId
                    newsound.Visible = true
                    newsound.Position = UDim2.new(0, 0, 0, pos)
                    pos = pos + 20
                    GUI.Logs.CanvasSize = UDim2.new(0, 0, 0, pos)

                    local audioname = 'error'
                    local success, message = pcall(function()
                        return game:GetService("MarketplaceService"):GetProductInfo(id)
                    end)
                    if success and message.Name then
                        audioname = message.Name
                    else
                        audioname = child.Name
                    end

                    newsound.TextLabel.Text = audioname

                    local dataId = Instance.new('StringValue')
                    dataId.Parent = newsound
                    dataId.Value = child.SoundId
                    dataId.Name = 'ID'

                    local dataName = Instance.new('StringValue')
                    dataName.Parent = newsound
                    dataName.Value = audioname
                    dataName.Name = 'NAME'

                    local soundselected = false
                    newsound.ImageButton.MouseButton1Click:Connect(function()
                        if not GUI.Info.Visible then
                            if not soundselected then
                                soundselected = true
                                newsound.ImageButton.BackgroundTransparency = 0
                            else
                                soundselected = false
                                newsound.ImageButton.BackgroundTransparency = 1
                            end
                        end
                    end)

                    newsound.Click.MouseButton1Click:Connect(function()
                        if not GUI.Info.Visible then
                            GUI.Info.TextLabel.Text = "Nom: " .. audioname .. "\n\nID: " .. child.SoundId .. "\n\nNom Workspace: " .. child.Name
                            selectedaudio = child.SoundId
                            GUI.Info.Visible = true
                        end
                    end)
                end
            end
        end)
    end

    for rep = 1, 10 do
        GUI.Load.BackgroundTransparency = GUI.Load.BackgroundTransparency + 0.1
        wait(0.05)
    end

    GUI.Load.Visible = false
    GUI.Load.BackgroundTransparency = 0
    GUI.Load.Size = UDim2.new(0, 0, 0, 20)
    running = false
    refreshlist() -- Rafraîchir la position après ajout
end

-- Boutons de scan
GUI.All.MouseButton1Click:connect(function() getaudio(game) end)
GUI.Workspace.MouseButton1Click:connect(function() getaudio(workspace) end)
GUI.Lighting.MouseButton1Click:connect(function() getaudio(game:GetService('Lighting')) end)
GUI.SoundS.MouseButton1Click:connect(function() getaudio(game:GetService('SoundService')) end)

-- Boutons de nettoyage
GUI.Clr.MouseButton1Click:connect(function()
    for _, child in pairs(GUI.Logs:GetChildren()) do
        if child:FindFirstChild('ImageButton') then
            local bttn = child.ImageButton
            if bttn.BackgroundTransparency == 1 then -- Non sélectionné
                child:Destroy()
            end
        end
    end
    refreshlist()
end)

GUI.ClrS.MouseButton1Click:connect(function()
    for _, child in pairs(GUI.Logs:GetChildren()) do
        if child:FindFirstChild('ImageButton') then
            local bttn = child.ImageButton
            if bttn.BackgroundTransparency == 0 then -- Sélectionné
                child:Destroy()
            end
        end
    end
    refreshlist()
end)

-- Bouton AutoScan
local autoscan = false
GUI.AutoScan.MouseButton1Click:connect(function()
    autoscan = not autoscan
    GUI.AutoScan.BackgroundTransparency = autoscan and 0.5 or 0
    sendNotification("Audio Logger", "Auto Scan " .. (autoscan and "ACTIVÉ" or "DÉSACTIVÉ"), nil, 5)
end)

-- Connexion à l'événement DescendantAdded pour l'AutoScan
local itemadded = game.DescendantAdded:connect(function(added)
    wait() -- Laisser le temps à l'objet d'être entièrement ajouté
    if autoscan and added:IsA('Sound') and not GUI.Logs:FindFirstChild(added.SoundId) and not FindTable(ignore, added.SoundId) then
        -- Réutiliser la logique de getaudio pour l'ajout
        local id = string.match(added.SoundId, "rbxasset://sounds.+") or string.match(added.SoundId, "&hash=.+") or string.match(added.SoundId, "%d+")
        if id ~= nil then
            local newsound = GUI.Audio:Clone()
            if string.sub(id, 1, 6) == "&hash=" or string.sub(id, 1, 7) == "&0hash=" then
                id = string.sub(id, (string.sub(id, 1, 6) == "&hash=" and 7) or (string.sub(id, 1, 7) == "&0hash=" and 8), string.len(id))
                newsound.ImageButton.Image = 'rbxassetid://1453863294'
            end

            newsound.Parent = GUI.Logs
            newsound.Name = added.SoundId
            newsound.Visible = true
            newsound.Position = UDim2.new(0, 0, 0, pos)
            pos = pos + 20
            GUI.Logs.CanvasSize = UDim2.new(0, 0, 0, pos)

            local audioname = 'error'
            local success, message = pcall(function()
                return game:GetService("MarketplaceService"):GetProductInfo(id)
            end)
            if success and message.Name then
                audioname = message.Name
            else
                audioname = added.Name
            end

            newsound.TextLabel.Text = audioname

            local dataId = Instance.new('StringValue')
            dataId.Parent = newsound
            dataId.Value = added.SoundId
            dataId.Name = 'ID'

            local dataName = Instance.new('StringValue')
            dataName.Parent = newsound
            dataName.Value = audioname
            dataName.Name = 'NAME'

            local soundselected = false
            newsound.ImageButton.MouseButton1Click:Connect(function()
                if not GUI.Info.Visible then
                    if not soundselected then
                        soundselected = true
                        newsound.ImageButton.BackgroundTransparency = 0
                    else
                        soundselected = false
                        newsound.ImageButton.BackgroundTransparency = 1
                    end
                end
            end)

            newsound.Click.MouseButton1Click:Connect(function()
                if not GUI.Info.Visible then
                    GUI.Info.TextLabel.Text = "Nom: " .. audioname .. "\n\nID: " .. added.SoundId .. "\n\nNom Workspace: " .. added.Name
                    selectedaudio = added.SoundId
                    GUI.Info.Visible = true
                end
            end)

            -- Scroller vers le bas automatiquement
            GUI.Logs.CanvasPosition = Vector2.new(0, GUI.Logs.CanvasSize.Y.Offset)
        end
    end
end)

-- Bouton Copier (dans le menu Info)
GUI.Info.Copy.MouseButton1Click:Connect(function()
    if not selectedaudio then return end
    local success = pcall(function()
        if Synapse then
            Synapse:Copy(selectedaudio)
        elseif setclipboard then
            setclipboard(selectedaudio)
        elseif Clipboard and Clipboard.set then
            Clipboard.set(selectedaudio)
        else
            error("Aucune fonction de copie trouvée")
        end
    end)
    if success then
        sendNotification("Audio Logger", "Copié dans le presse-papiers", nil, 5)
    else
        sendNotification("Audio Logger", "Échec de la copie", nil, 5)
    end
end)

-- Bouton Fermer (dans le menu Info) - CORRIGÉ
GUI.Info.Close.MouseButton1Click:Connect(function()
    GUI.Info.Visible = false
    -- Arrête le son d'écoute s'il existe
    for _, sound in pairs(game:GetService('Players').LocalPlayer.PlayerGui:GetChildren()) do
        if sound.Name == 'SampleSound' then
            sound:Destroy()
        end
    end
    GUI.Info.Listen.Text = 'Listen'
end)

-- Bouton Écouter/Arrêter (dans le menu Info)
GUI.Info.Listen.MouseButton1Click:Connect(function()
    if not selectedaudio then return end
    if GUI.Info.Listen.Text == 'Listen' then
        local existingSound = game:GetService('Players').LocalPlayer.PlayerGui:FindFirstChild('SampleSound')
        if existingSound then
            existingSound:Destroy()
        end
        local sampleSound = Instance.new('Sound')
        sampleSound.Parent = game:GetService('Players').LocalPlayer.PlayerGui
        sampleSound.Looped = true
        sampleSound.SoundId = selectedaudio
        sampleSound:Play()
        sampleSound.Name = 'SampleSound'
        sampleSound.Volume = 5
        GUI.Info.Listen.Text = 'Stop'
    else
        for _, sound in pairs(game:GetService('Players').LocalPlayer.PlayerGui:GetChildren()) do
            if sound.Name == 'SampleSound' then
                sound:Destroy()
            end
        end
        GUI.Info.Listen.Text = 'Listen'
    end
end)