local SLAXML = require('slaxml')

-- Fonction pour télécharger un fichier à partir d'une URL
local function downloadFile(url, path)
  local response = http.get(url)
  if response then
    local file = fs.open(path, "w")
    file.write(response.readAll())
    file.close()
    response.close()
    return true
  else
    return false
  end
end

-- Fonction pour vérifier si un fichier existe
local function fileExists(path)
  return fs.exists(path) and not fs.isDir(path)
end

local aukitPath = "aukit.lua"
local austreamPath = "austream.lua"
local upgradePath = "upgrade"

-- Vérification et téléchargement des fichiers AUKit et AUStream
if not fileExists(aukitPath) then
  local success = downloadFile("https://github.com/MCJack123/AUKit/raw/master/aukit.lua", aukitPath)
  if not success then
    print("Erreur lors du téléchargement du fichier AUKit.")
    return
  end
end

if not fileExists(austreamPath) then
  local success = downloadFile("https://github.com/MCJack123/AUKit/raw/master/austream.lua", austreamPath)
  if not success then
    print("Erreur lors du téléchargement du fichier AUStream.")
    return
  end
end

-- Vérification et téléchargement du fichier "upgrade"
if not fileExists(upgradePath) then
  shell.run("pastebin", "get", "PvwtVW1S", upgradePath)
end

-- Chargement des bibliothèques AUKit et AUStream
os.loadAPI(aukitPath)
os.loadAPI(austreamPath)

local function handleItemChild(childTag, childAttr, childNsURI, childNsPrefix)
  if childTag == "title" then
    title = childAttr[1]
  elseif childTag == "link" then
    musicURL = childAttr[1]
  end
end

local function handleXML(tag, attr, nsURI, nsPrefix)
  if tag == "item" then
    local title = ""
    local musicURL = ""

    SLAXML:parse(handleItemChild)
    
    if title ~= "" and musicURL ~= "" then
      print("Titre:", title)
      print("URL de la musique:", musicURL)
      print()
    end
  end
end

local playlistURL = "https://crssnt.com/preview/https:/docs.google.com/spreadsheets/d/111D7sGb0GHoGnIbb_vY-1VW50OCekC7kIjLLzUvfvPM/edit#gid=0"
local response = http.get(playlistURL)
if response then
  local playlistData = response.readAll()
  response.close()

  local musicList = {}

  SLAXML:parse(playlistData, {
    startElement = function(tag, attr, nsURI, nsPrefix)
      if tag == "item" then
        local title = ""
        local musicURL = ""

        handleItemChild = function(childTag, childAttr, childNsURI, childNsPrefix)
          if childTag == "title" then
            title = childAttr[1]
          elseif childTag == "link" then
            musicURL = childAttr[1]
          end
        end

        handleEndElement = function(tag, nsURI, nsPrefix)
          if tag == "item" and title ~= "" and musicURL ~= "" then
            table.insert(musicList, { title = title, link = musicURL })
          end
        end

        SLAXML:parse(playlistData, {
          startElement = handleItemChild,
          endElement = handleEndElement
        })
      end
    end
  })

  local function playMusic(title, musicURL)
    shell.run(austreamPath, musicURL)
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
        local option = musicList[i]

        if optionIndex == selectedIndex then
          term.setTextColor(colors.green)
          option = option.title .. " "
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
        local selectedMusic = musicList[selectedOption]
        playMusic(selectedMusic.title, selectedMusic.link)
      end
    end
  end

  displayMusicMenu()
else
  print("Erreur lors du téléchargement du fichier de la liste de lecture.")
end
