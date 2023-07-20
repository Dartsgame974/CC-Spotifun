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

    while true do
      term.clear()
      term.setCursorPos(1, 1)

      -- Le reste du code du menu principal ici...

      local _, key = os.pullEvent("key")
      local keyName = keys.getName(key)

      if keyName == "b" or keyName == "a" or keyName == "t" or keyName == "m" or keyName == "n" then
        secretCode = secretCode .. keyName

        if secretCode == "batman" then
          easterEggMode = true
          term.setBackgroundColor(colors.purple) -- Changer la couleur de fond en violet
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
        if easterEggMode then
          -- Utiliser la playlist alternative pour le mode easter egg
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
        else
          -- Utiliser la playlist normale pour le mode normal
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
    end

    displayMusicMenu()
  else
    print("Erreur de parsing du fichier de la liste de lecture.")
  end
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
