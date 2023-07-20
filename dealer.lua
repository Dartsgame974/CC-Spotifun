local logoText = "Spotifo"
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

    -- Déclaration de la variable option en dehors de la boucle while
    local option

    local function displayMainMenu()
      term.clear()
      term.setCursorPos(1, 3)

      term.setTextColor(colors.green)
      term.setCursorPos(1, 2)
      term.write(string.rep(string.char(143), term.getSize()))
      term.setCursorPos(1, 3)
      term.write(string.rep(" ", term.getSize()))
      term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 3)
      term.write(logoText)
      term.setCursorPos(1, 4)
      term.write(string.rep(string.char(143), term.getSize()))

      term.setTextColor(colors.white)
      local headerText = "Spotify"
      local headerTextPos = (term.getSize() - #headerText) / 2 + 1
      term.setCursorPos(headerTextPos, 3)
      term.write(headerText)

      print("1. Play")
      print("2. Options")
      print("3. Quitter")

      local _, key = os.pullEvent("key")
      local keyName = keys.getName(key)

      if key == keys.one then
        displayMusicMenu()
      elseif key == keys.two then
        displayOptionsMenu()
      elseif key == keys.three then
        term.clear()
        term.setCursorPos(1, 1)
        return  -- Quitter le programme
      end
    end

    local function displayMusicMenu()
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      -- Boot Menu
      term.clear()
      local screenWidth, screenHeight = term.getSize()
      local logoHeight = 5
      local logoText = "Spotifo"
      local byText = "by Dartsgame"
      local logoY = math.floor((screenHeight - logoHeight) / 2)
      local logoX = math.floor((screenWidth - #logoText) / 2)
      term.setTextColor(colors.green)
      term.setCursorPos(1, logoY)
      term.write(string.rep(string.char(143), screenWidth))
      term.setCursorPos(1, logoY + 1)
      term.write(string.rep(" ", screenWidth))
      term.setCursorPos(logoX, logoY + 2)
      term.write(logoText)
      term.setCursorPos((screenWidth - #byText) / 2 + 1, logoY + 3)
      term.write(byText)
      term.setCursorPos(1, logoY + 4)
      term.write(string.rep(string.char(143), screenWidth))
      sleep(2) -- Attente de 2 secondes

      while true do
        term.clear()
        term.setCursorPos(1, 3)

        term.setTextColor(colors.green)
        term.setCursorPos(1, 2)
        term.write(string.rep(string.char(143), term.getSize()))
        term.setCursorPos(1, 3)
        term.write(string.rep(" ", term.getSize()))
        term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 3)
        term.write(logoText)
        term.setCursorPos(1, 4)
        term.write(string.rep(string.char(143), term.getSize()))

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

          print(optionIndex, " [" .. option .. "]")
        end

        term.setTextColor(colors.white)
        local pageText = currentPage .. "/" .. totalPages
        local totalText = "Titres " .. totalOptions
        local headerText = logoText .. "  " .. pageText .. "  " .. totalText
        local headerTextPos = (term.getSize() - #headerText) / 2 + 1
        term.setCursorPos(headerTextPos, 3)
        term.write(headerText)

        term.setCursorPos(1, itemsPerPage + 7)
        term.write(string.char(17))
        term.setCursorPos(term.getSize(), itemsPerPage + 7)
        term.write(string.char(16))

        local _, key = os.pullEvent("key")
        local keyName = keys.getName(key)

        if key == keys.up then
          selectedIndex = selectedIndex - 1
          if selectedIndex < 1 then
            selectedIndex = endIndex - startIndex + 1
          end
        elseif key == keys.down then
          selectedIndex = selectedIndex + 1
          if selectedIndex > endIndex - startIndex + 1 then
            selectedIndex = 1
          end
        elseif key == keys.left and currentPage > 1 then
          currentPage = currentPage - 1
          selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
        elseif key == keys.right and currentPage < totalPages then
          currentPage = currentPage + 1
          selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
        elseif key == keys.enter then
          local selectedOption = startIndex + selectedIndex - 1
          local selectedMusic = playlist[selectedOption]
          playMusic(selectedMusic.title, selectedMusic.link)
        end

        -- Si l'easter egg est activé et l'utilisateur appuie sur une autre touche, réinitialiser l'easter egg
        if easterEggActivated and keyName ~= "right" then
          resetEasterEgg()
        end
      end
    end

    local function displayOptionsMenu()
      term.clear()
      term.setCursorPos(1, 3)

      term.setTextColor(colors.green)
      term.setCursorPos(1, 2)
      term.write(string.rep(string.char(143), term.getSize()))
      term.setCursorPos(1, 3)
      term.write(string.rep(" ", term.getSize()))
      term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 3)
      term.write(logoText)
      term.setCursorPos(1, 4)
      term.write(string.rep(string.char(143), term.getSize()))

      term.setTextColor(colors.white)
      print("Options :")
      print("1. Couleurs")
      print("2. Options avancées")
      print("3. Retour")

      local _, key = os.pullEvent("key")
      local keyName = keys.getName(key)

      if key == keys.one then
        displayColorsMenu()
      elseif key == keys.two then
        displayAdvancedOptionsMenu()
      elseif key == keys.three then
        displayMainMenu()
      end
    end

    local function displayColorsMenu()
      term.clear()
      term.setCursorPos(1, 3)

      term.setTextColor(colors.green)
      term.setCursorPos(1, 2)
      term.write(string.rep(string.char(143), term.getSize()))
      term.setCursorPos(1, 3)
      term.write(string.rep(" ", term.getSize()))
      term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 3)
      term.write(logoText)
      term.setCursorPos(1, 4)
      term.write(string.rep(string.char(143), term.getSize()))

      term.setTextColor(colors.white)
      print("Choisissez une couleur pour le fond :")
      print("1. Vert")
      print("2. Violet")
      print("3. Retour")

      local _, key = os.pullEvent("key")
      local keyName = keys.getName(key)

      if key == keys.one then
        term.setBackgroundColor(colors.green)
        playlistURL = normalPlaylistURL
        displayOptionsMenu()
      elseif key == keys.two then
        term.setBackgroundColor(colors.purple)
        playlistURL = darkPlaylistURL
        displayOptionsMenu()
      elseif key == keys.three then
        displayOptionsMenu()
      end
    end

    local function displayAdvancedOptionsMenu()
      term.clear()
      term.setCursorPos(1, 3)

      term.setTextColor(colors.green)
      term.setCursorPos(1, 2)
      term.write(string.rep(string.char(143), term.getSize()))
      term.setCursorPos(1, 3)
      term.write(string.rep(" ", term.getSize()))
      term.setCursorPos((term.getSize() - #logoText) / 2 + 1, 3)
      term.write(logoText)
      term.setCursorPos(1, 4)
      term.write(string.rep(string.char(143), term.getSize()))

      term.setTextColor(colors.white)
      print("Options avancées :")
      print("1. Changer la provenance des musiques")
      print("2. Retour")

      local _, key = os.pullEvent("key")
      local keyName = keys.getName(key)

      if key == keys.one then
        term.clear()
        term.setCursorPos(1, 3)
        term.setTextColor(colors.white)
        term.write("Veuillez saisir le mot de passe : ")
        local password = "votremotdepasse" -- Remplacer "votremotdepasse" par votre mot de passe
        local inputPassword = read("*")
        if inputPassword == password then
          term.clear()
          term.setCursorPos(1, 3)
          term.setTextColor(colors.green)
          term.write("Mot de passe correct. La provenance des musiques a été changée.")
          sleep(2)  -- Attente de 2 secondes pour afficher le message
          playlistURL = darkPlaylistURL
        else
          term.clear()
          term.setCursorPos(1, 3)
          term.setTextColor(colors.red)
          term.write("Mot de passe incorrect. Les options avancées ont été annulées.")
          sleep(2)  -- Attente de 2 secondes pour afficher le message
        end
        displayOptionsMenu()
      elseif key == keys.two then
        displayOptionsMenu()
      end
    end

    displayMainMenu()
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
