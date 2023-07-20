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

local aukit = require("aukit")
local austream = shell.resolveProgram("austream")

local playlistURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlist.json"
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

    local secretCode = ""
    local easterEggMode = false

    local function displayMusicMenu()
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      -- Boot Menu
      local monitor = peripheral.find("monitor")
      monitor.setTextScale(1)
      monitor.clear()

      local screenWidth, screenHeight = monitor.getSize()
      local logoHeight = 5
      local logoText = "Spotifo"
      local byText = "by Dartsgame"
      local logoY = math.floor((screenHeight - logoHeight) / 2)
      local logoX = math.floor((screenWidth - #logoText) / 2)

      while true do
        monitor.clear()
        monitor.setCursorPos(1, 3)

        monitor.setTextColor(colors.green)
        monitor.setCursorPos(1, 2)
        monitor.write(string.rep(string.char(143), screenWidth))
        monitor.setCursorPos(1, 3)
        monitor.write(string.rep(" ", screenWidth))
        monitor.setCursorPos((screenWidth - #logoText) / 2 + 1, 3)
        monitor.write(logoText)
        monitor.setCursorPos(1, 4)
        monitor.write(string.rep(string.char(143), screenWidth))

        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, totalOptions)

        for i = startIndex, endIndex do
          local optionIndex = i - startIndex + 1
          local option = musicList[i]

          if optionIndex == selectedIndex then
            monitor.setTextColor(colors.green)
            option = option .. " "
          else
            monitor.setTextColor(colors.gray)
          end

          monitor.setCursorPos(1, i - startIndex + 5)
          monitor.write(optionIndex .. " [" .. option .. "]")
        end

        monitor.setTextColor(colors.white)
        local pageText = currentPage .. "/" .. totalPages
        local totalText = "Titres " .. totalOptions
        local headerText = logoText .. "  " .. pageText .. "  " .. totalText
        local headerTextPos = (screenWidth - #headerText) / 2 + 1
        monitor.setCursorPos(headerTextPos, 3)
        monitor.write(headerText)

        -- Options "Précédent" et "Suivant"
        monitor.setTextColor(colors.blue)
        monitor.setCursorPos(1, screenHeight)
        monitor.write("Précédent")
        monitor.setCursorPos(screenWidth - 7, screenHeight)
        monitor.write("Suivant")

        -- Vérifier la combinaison de touches pour activer le mode easter egg
        local event, key = os.pullEvent("key")
        local keyName = keys.getName(key)

        if keyName == "b" or keyName == "a" or keyName == "t" or keyName == "m" or keyName == "n" then
          secretCode = secretCode .. keyName

          if secretCode == "batman" then
            easterEggMode = true
            -- Charger la playlist alternative depuis le fichier "playlistdark.json"
            local playlistDarkURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlistdark.json"
            local responseDark = http.get(playlistDarkURL)
            if responseDark then
              local playlistDarkData = responseDark.readAll()
              responseDark.close()
              local successDark, playlistDark = pcall(textutils.unserializeJSON, playlistDarkData)
              if successDark and type(playlistDark) == "table" then
                musicList = {}
                for _, entry in ipairs(playlistDark) do
                  table.insert(musicList, entry.title)
                end
              end
            end

            os.sleep(0.5) -- Attendre un court délai pour réinitialiser le code secret
            secretCode = ""
          end
        else
          secretCode = ""
        end

while true do
  monitor.clear()
  monitor.setCursorPos(1, 3)

  monitor.setTextColor(colors.green)
  monitor.setCursorPos(1, 2)
  monitor.write(string.rep(string.char(143), screenWidth))
  monitor.setCursorPos(1, 3)
  monitor.write(string.rep(" ", screenWidth))
  monitor.setCursorPos((screenWidth - #logoText) / 2 + 1, 3)
  monitor.write(logoText)
  monitor.setCursorPos(1, 4)
  monitor.write(string.rep(string.char(143), screenWidth))

  local startIndex = (currentPage - 1) * itemsPerPage + 1
  local endIndex = math.min(startIndex + itemsPerPage - 1, totalOptions)

  for i = startIndex, endIndex do
    local optionIndex = i - startIndex + 1
    local option = musicList[i]

    if optionIndex == selectedIndex then
      monitor.setTextColor(colors.green)
      option = option .. " "
    else
      monitor.setTextColor(colors.gray)
    end

    monitor.setCursorPos(1, i - startIndex + 5)
    monitor.write(optionIndex .. " [" .. option .. "]")
  end

  monitor.setTextColor(colors.white)
  local pageText = currentPage .. "/" .. totalPages
  local totalText = "Titres " .. totalOptions
  local headerText = logoText .. "  " .. pageText .. "  " .. totalText
  local headerTextPos = (screenWidth - #headerText) / 2 + 1
  monitor.setCursorPos(headerTextPos, 3)
  monitor.write(headerText)

  -- Options "Précédent" et "Suivant"
  monitor.setTextColor(colors.blue)
  monitor.setCursorPos(1, screenHeight)
  monitor.write("Précédent")
  monitor.setCursorPos(screenWidth - 7, screenHeight)
  monitor.write("Suivant")

  -- Vérifier la combinaison de touches pour activer le mode easter egg
  local event, key = os.pullEvent("key")
  local keyName = keys.getName(key)

  if keyName == "b" or keyName == "a" or keyName == "t" or keyName == "m" or keyName == "n" then
    secretCode = secretCode .. keyName

    if secretCode == "batman" then
      easterEggMode = true
      -- Charger la playlist alternative depuis le fichier "playlistdark.json"
      local playlistDarkURL = "https://raw.githubusercontent.com/Miniprimestaff/music-cc/main/program/playlistdark.json"
      local responseDark = http.get(playlistDarkURL)
      if responseDark then
        local playlistDarkData = responseDark.readAll()
        responseDark.close()
        local successDark, playlistDark = pcall(textutils.unserializeJSON, playlistDarkData)
        if successDark and type(playlistDark) == "table" then
          musicList = {}
          for _, entry in ipairs(playlistDark) do
            table.insert(musicList, entry.title)
          end
        end
      end

      os.sleep(0.5) -- Attendre un court délai pour réinitialiser le code secret
      secretCode = ""
    end
  else
    secretCode = ""
  end

  -- Le reste du code pour le menu principal ici...
  -- Vous pouvez ajouter des fonctionnalités spécifiques pour le mode normal
  -- N'oubliez pas d'ajouter les actions spécifiques au mode easter egg
end

      end
    end

    displayMusicMenu()
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
