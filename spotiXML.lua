local austream = shell.resolveProgram("austream")
local xmlURL = "https://crssnt.com/preview/https:/docs.google.com/spreadsheets/d/111D7sGb0GHoGnIbb_vY-1VW50OCekC7kIjLLzUvfvPM/edit#gid=0"

-- Vérification et téléchargement des fichiers AUKit et AUStream
if not fs.exists("aukit.lua") then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/aukit.lua", "aukit.lua")
end

if not fs.exists("austream.lua") then
  shell.run("wget", "https://github.com/MCJack123/AUKit/raw/master/austream.lua", "austream.lua")
end

-- Chargement des bibliothèques AUKit et AUStream
os.loadAPI("aukit.lua")
os.loadAPI("austream.lua")

-- Fonction pour récupérer le contenu du fichier XML depuis le lien
local function getXMLContent(url)
  local response = http.get(url)
  if response then
    local content = response.readAll()
    response.close()
    return content
  else
    return nil
  end
end

-- Récupération du contenu du fichier XML
local xmlContent = getXMLContent(xmlURL)

if xmlContent then
  -- Parsing du fichier XML
  local xmlData = aukit.parseXML(xmlContent)

  if xmlData and xmlData.channel and xmlData.channel.item then
    local musicList = {}

    -- Parcours des éléments du canal dans le fichier XML
    for _, item in ipairs(xmlData.channel.item) do
      local title = item.title and item.title[1]
      local link = item.link and item.link[1]

      if title and link then
        table.insert(musicList, { title = title, link = link })
      end
    end

    local function playMusic(title, musicURL)
      shell.run("austream.lua", musicURL)
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
    print("Erreur de parsing du fichier XML.")
  end
else
  print("Erreur lors du téléchargement du fichier XML.")
end
