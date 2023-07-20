local aukitPath = "aukit.lua"
local austreamPath = "austream.lua"
local upgradePath = "upgrade"

-- Fonction pour vérifier si un fichier existe
local function fileExists(path)
  return fs.exists(path) and not fs.isDir(path)
end

-- Vérification et téléchargement des fichiers AUKit et AUStream
if not fileExists(aukitPath) then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/aukit.lua", aukitPath)
end

if not fileExists(austreamPath) then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/austream.lua", austreamPath)
end

-- Vérification et téléchargement du fichier "upgrade"
if not fileExists(upgradePath) then
  shell.run("pastebin", "get", "PvwtVW1S", upgradePath)
end

local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
local normalPlaylistURL = playlistURL
local darkPlaylistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlistdark.json"
local response = http.get(playlistURL)
if response then
  local playlistData = response.readAll()
  response.close()

  local success, playlist = pcall(textutils.unserializeJSON, playlistData)
  if success and type(playlist) == "table" then
    local musicList = {}
    for _, entry in ipairs(playlist) do
      table.insert(musicList, entry.title)
    end

    local function playMusic(title, musicURL)
      shell.run(austreamPath, musicURL)
    end

    -- Variables pour l'easter egg
    local easterEggActivated = false
    local rightArrowCount = 0

    local function resetEasterEgg()
      easterEggActivated = false
      rightArrowCount = 0
      -- Changer ici la couleur de fond en vert pour revenir à la version originale
      -- Charger la playlist originale depuis le fichier "playlist.json"
      term.setBackgroundColor(colors.black)  -- Remplacer ici par la couleur de fond originale
      playlistURL = normalPlaylistURL
    end

    local function displayMainMenu()
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      local menuOptions = {"Play", "Options", "Quitter"}
      local totalMenuOptions = #menuOptions

      while true do
        term.clear()
        term.setCursorPos(1, 3)

        term.setTextColor(colors.green)
        term.setCursorPos(1, 2)
        term.write(string.rep(string.char(143), term.getSize()))
        term.setCursorPos(1, 3)
        term.write(string.rep(" ", term.getSize()))

        term.setTextColor(colors.white)
        local headerText = "Spotify"
        local headerTextPos = (term.getSize() - #headerText) / 2 + 1
        term.setCursorPos(headerTextPos, 3)
        term.write(headerText)

        -- Afficher les options du menu principal
        for i = 1, totalMenuOptions do
          if i == selectedIndex then
            term.setTextColor(colors.green)
          else
            term.setTextColor(colors.white)
          end
          term.setCursorPos(1, i + 4)
          term.write("[" .. menuOptions[i] .. "]")
        end

        -- Afficher la liste de musique
        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, totalOptions)

        for i = startIndex, endIndex do
          local optionIndex = i - startIndex + 1
          option = musicList[i]

          if optionIndex == selectedIndex then
            term.setTextColor(colors.green)
            option = option .. " "
          else
            term.setTextColor(colors.gray)
          end

          term.setCursorPos(1, i + 8)
          term.write("[" .. option .. "]")
        end

        term.setTextColor(colors.white)
        local pageText = currentPage .. "/" .. totalPages
        local totalText = "Options :"
        local headerText = "Spotify"
        local headerTextPos = (term.getSize() - #headerText) / 2 + 1
        term.setCursorPos(headerTextPos, 3)
        term.write(headerText)
        term.setCursorPos(1, 7)
        term.write(totalText .. "  " .. pageText)

        local _, key = os.pullEvent("key")
        local keyName = keys.getName(key)

        if key == keys.up then
          if selectedIndex > 1 then
            selectedIndex = selectedIndex - 1
          else
            selectedIndex = totalMenuOptions
          end
        elseif key == keys.down then
          if selectedIndex < totalMenuOptions then
            selectedIndex = selectedIndex + 1
          else
            selectedIndex = 1
          end
        elseif key == keys.enter then
          if selectedIndex == 1 then
            displayMusicMenu()
          elseif selectedIndex == 2 then
            displayOptionsMenu()
          elseif selectedIndex == 3 then
            term.clear()
            term.setCursorPos(1, 1)
            return  -- Quitter le programme
          end
        end
      end
    end

    local function displayMusicMenu()
      -- Le code pour le menu de lecture reste inchangé
    end

    local function displayOptionsMenu()
      -- Le code pour le menu d'options reste inchangé
    end

    displayMainMenu()
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
