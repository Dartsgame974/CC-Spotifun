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
    end

    local function displayMusicMenu()
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      local secretCode = ""
      local easterEggMode = false

      -- Boot Menu
      term.setBackgroundColor(colors.black)
      term.clear()
      term.setTextColor(colors.red)

      -- Afficher le texte "JAILBREAK débloqué" au milieu clignotant
      local screenWidth, screenHeight = term.getSize()
      local text = "JAILBREAK débloqué"
      local textX = math.floor((screenWidth - #text) / 2)
      local textY = math.floor(screenHeight / 2)
      while not easterEggMode do
        term.setCursorPos(textX, textY)
        term.write(text)
        sleep(0.5)
        term.setCursorPos(textX, textY)
        term.write(string.rep(" ", #text))
        sleep(0.5)
        -- Vérifier si la combinaison de touches "b-a-t-m-a-n" est entrée pour activer le mode easter egg
        local _, key = os.pullEvent("key")
        local keyName = keys.getName(key)
        if keyName == "b" then
          secretCode = "b"
          while keyName == "b" do
            _, key = os.pullEvent("key")
            keyName = keys.getName(key)
          end
        elseif keyName == "a" and secretCode == "b" then
          secretCode = "ba"
          while keyName == "a" do
            _, key = os.pullEvent("key")
            keyName = keys.getName(key)
          end
        elseif keyName == "t" and secretCode == "ba" then
          secretCode = "bat"
          while keyName == "t" do
            _, key = os.pullEvent("key")
            keyName = keys.getName(key)
          end
        elseif keyName == "m" and secretCode == "bat" then
          secretCode = "batm"
          while keyName == "m" do
            _, key = os.pullEvent("key")
            keyName = keys.getName(key)
          end
        elseif keyName == "a" and secretCode == "batm" then
          secretCode = "batma"
          while keyName == "a" do
            _, key = os.pullEvent("key")
            keyName = keys.getName(key)
          end
        elseif keyName == "n" and secretCode == "batma" then
          secretCode = "batman"
          easterEggMode = true
        else
          secretCode = ""
        end
      end

      -- Changer ici la couleur de fond en rouge pour l'easter egg
      term.setBackgroundColor(colors.red)
      term.clear()

      -- Afficher le logo "Torrent" au milieu en rouge sur fond noir
      local logo = [[
 _______  _______  __   __  _______    _______  _______  ______    _______ 
|       ||   _   ||  |_|  ||       |  |       ||       ||    _ |  |       |
|    ___||  |_|  ||       ||    _  |  |_     _||   _   ||   | ||  |  _____|
|   |___ |       ||       ||   |_| |    |   |  |  | |  ||   |_||_ | |_____ 
|    ___||       ||       ||    ___|    |   |  |  |_|  ||    __  ||_____  |
|   |___ |   _   | |     | |   |        |   |  |       ||   |  | | _____| |
|_______||__| |__|  |___|  |___|        |___|  |_______||___|  |_||_______|
]]
      local logoX = math.floor((screenWidth - 53) / 2)
      local logoY = math.floor((screenHeight - 7) / 2)
      term.setTextColor(colors.red)
      term.setCursorPos(logoX, logoY)
      term.write(logo)

      sleep(2) -- Attente de 2 secondes

      while true do
        term.clear()
        term.setCursorPos(1, 3)

        term.setTextColor(colors.red)
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
          local option = musicList[i]

          if optionIndex == selectedIndex then
            term.setTextColor(colors.red)
            option = option .. " "
          else
            term.setTextColor(colors.white)
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

        if key == keys.up then
          selectedIndex = selectedIndex - 1
          if selectedIndex < 1 then
            selectedIndex = totalOptions
          end
        elseif key == keys.down then
          selectedIndex = selectedIndex + 1
          if selectedIndex > totalOptions then
            selectedIndex = 1
          end
        elseif key == keys.left then
          currentPage = currentPage - 1
          if currentPage < 1 then
            currentPage = totalPages
          end
          selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
        elseif key == keys.right then
          currentPage = currentPage + 1
          if currentPage > totalPages then
            currentPage = 1
          end
          selectedIndex = math.min(selectedIndex, endIndex - startIndex + 1)
        elseif key == keys.enter then
          local selectedOption = startIndex + selectedIndex - 1
          local selectedMusic = playlist[selectedOption]
          playMusic(selectedMusic.title, selectedMusic.link)
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
