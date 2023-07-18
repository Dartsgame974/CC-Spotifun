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

local monitor = peripheral.find("monitor")
local secondMonitor = peripheral.find("monitor", function(_, p) return p ~= monitor end)

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
      -- Afficher le titre de la musique sur le deuxième écran
      secondMonitor.setTextScale(1)
      secondMonitor.clear()
      secondMonitor.setCursorPos(1, 1)
      secondMonitor.write("Titre: " .. title)
    end

    local function displayMusicMenu()
      local itemsPerPage = 6
      local currentPage = 1
      local totalOptions = #musicList
      local totalPages = math.ceil(totalOptions / itemsPerPage)
      local selectedIndex = 1

      -- Boot Menu
      monitor.clear()
      local screenWidth, screenHeight = monitor.getSize()
      local logoHeight = 5
      local logoText = "Spotifo"
      local byText = "by Dartsgame"
      local logoY = math.floor((screenHeight - logoHeight) / 2)
      local logoX = math.floor((screenWidth - #logoText) / 2)
      monitor.setTextColor(colors.green)
      monitor.setCursorPos(1, logoY)
      monitor.write(string.rep(string.char(143), screenWidth))
      monitor.setCursorPos(1, logoY + 1)
      monitor.write(string.rep(" ", screenWidth))
      monitor.setCursorPos(logoX, logoY + 2)
      monitor.write(logoText)
      monitor.setCursorPos((screenWidth - #byText) / 2 + 1, logoY + 3)
      monitor.write(byText)
      monitor.setCursorPos(1, logoY + 4)
      monitor.write(string.rep(string.char(143), screenWidth))
      sleep(2) -- Attente de 2 secondes

      while true do
        monitor.clear()
        monitor.setCursorPos(1, 3)

        monitor.setTextColor(colors.green)
        monitor.setCursorPos(1, 2)
        monitor.write(string.rep(string.char(143), monitor.getSize()))
        monitor.setCursorPos(1, 3)
        monitor.write(string.rep(" ", monitor.getSize()))
        monitor.setCursorPos((monitor.getSize() - #logoText) / 2 + 1, 3)
        monitor.write(logoText)
        monitor.setCursorPos(1, 4)
        monitor.write(string.rep(string.char(143), monitor.getSize()))

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

          monitor.setCursorPos(1, 6 + optionIndex)
          monitor.write(optionIndex .. " [" .. option .. "]")
        end

        monitor.setTextColor(colors.white)
        local pageText = currentPage .. "/" .. totalPages
        local totalText = "Titres " .. totalOptions
        local headerText = logoText .. "  " .. pageText .. "  " .. totalText
        local headerTextPos = (monitor.getSize() - #headerText) / 2 + 1
        monitor.setCursorPos(headerTextPos, 3)
        monitor.write(headerText)

        monitor.setCursorPos(1, itemsPerPage + 7)
        monitor.write(string.char(17))
        monitor.setCursorPos(monitor.getSize(), itemsPerPage + 7)
        monitor.write(string.char(16))

        local _, key = os.pullEvent("key")

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
      end
    end

    displayMusicMenu()
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
