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
      shell.run(austream, musicURL)
      -- Jouer le son "ui.button.click"
      local speaker = peripheral.find("speaker")
      speaker.playSound("ui.button.click")
      -- Afficher le titre de la musique sur le deuxième écran
      local secondMonitor = peripheral.find("monitor", function(_, p) return p ~= monitor end)
      secondMonitor.setTextScale(1)
      secondMonitor.clear()
      secondMonitor.setCursorPos(1, 1)
      secondMonitor.write("Titre: " .. title)
    end

    local function searchMusic()
      term.clear()
      term.setCursorPos(1, 1)
      term.setTextColor(colors.white)
      write("Rechercher une musique : ")
      local searchTerm = read()
      -- Mettre à jour la liste des options en fonction de la recherche
      musicList = {}
      for _, entry in ipairs(playlist) do
        if string.find(entry.title:lower(), searchTerm:lower()) then
          table.insert(musicList, entry.title)
        end
      end
      totalOptions = #musicList
      currentPage = 1
      selectedIndex = 1
    end

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
        monitor.setCursorPos(screenWidth - 16, screenHeight)
        monitor.write("Rechercher")

        local event, side, x, y = os.pullEvent("monitor_touch")

        if y == screenHeight then
          if x == 1 and currentPage > 1 then
            currentPage = currentPage - 1
            -- Jouer le son "ui.button.click"
            local speaker = peripheral.find("speaker")
            speaker.playSound("ui.button.click")
          elseif x >= screenWidth - 6 and x <= screenWidth then
            currentPage = currentPage + 1
            if currentPage > totalPages then
              currentPage = totalPages
            end
            -- Jouer le son "ui.button.click"
            local speaker = peripheral.find("speaker")
            speaker.playSound("ui.button.click")
          elseif x >= screenWidth - 15 and x <= screenWidth then
            searchMusic()
          end
        elseif y >= 5 and y <= screenHeight - 1 then
          local selectedOption = startIndex + (y - 5)
          if selectedOption <= totalOptions then
            local selectedMusic = playlist[selectedOption]
            playMusic(selectedMusic.title, selectedMusic.link)
          end
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
