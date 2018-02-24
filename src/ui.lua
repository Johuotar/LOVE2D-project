--[[
Functions for UI & menu.
--]]

function splashTextIncrease()
  if splashIncreasing then
    splashSize = splashSize + 0.003
  else
    splashSize = splashSize - 0.003
  end
  if splashSize >= splashMaxSize then
    splashIncreasing = false
  end
  if splashSize <= splashMinSize then
    splashIncreasing = true
  end
end

function drawMenu()
	if menu == 1 then
    menu_size = 50
		menu_base_pos = {}
		menu_base_pos['x'] = 450
		menu_base_pos['y'] = 270
		love.graphics.draw(menu_bg, 0, 0)
    if playerName == '' then
      love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(125, 125, 255)
    end
    love.graphics.print("Nimi: ", menu_base_pos['x'], menu_base_pos['y'] - menu_size)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(playerName, menu_base_pos['x'], menu_base_pos['y'])
		for i=1, tablelength(menu_items) do
			coord_y = menu_base_pos['y'] + (i * menu_size)
      if playerName == '' and i == 1 then
        love.graphics.setColor(170, 170, 170)
      else
        love.graphics.setColor(255, 255, 255)
      end
			love.graphics.print(menu_items[i], menu_base_pos['x'], coord_y)
		end
    love.graphics.print(splashText, 15, 370, 18.1, splashSize)
    love.graphics.print('HELP SECTION:', 20, 475, 0, 0.6)
    love.graphics.print('Arrowkeys to move, space to shoot, hold left control to change look direction \n Dodge the monsters and move to new map regions. You cannot return the way you came \n Killing monsters gives scrore.', 20, 500, 0, 0.5)
		love.graphics.print('->', menu_base_pos['x'] - 50, menu_base_pos['y'] + (menuchoice * menu_size))
    drawScoreBoard(30, 550)
	elseif menu == 2 then
		menu_base_pos = {}
		menu_base_pos['x'] = 250
		menu_base_pos['y'] = 150
    drawPlayerScore()
		for i=1, tablelength(menu_items) do
			coord_y = menu_base_pos['y'] + (i * 80)
			love.graphics.print(menu_items[i], menu_base_pos['x'], coord_y)
		end
		love.graphics.print('->', menu_base_pos['x'] - 50, menu_base_pos['y'] + (menuchoice * 80))
    drawScoreBoard(350, 500)
	elseif menu == 99 then
    menu_base_pos = {}
		menu_base_pos['x'] = 100
		menu_base_pos['y'] = 20
		for i=1, tablelength(menu_items) do
			coord_y = menu_base_pos['y'] + (i * 50)
      bar_start_x = 350
      bar_start_y = coord_y + 15
      if i==1 then
        love.graphics.rectangle("fill", bar_start_x, bar_start_y, master_volume * 100, 20)
      elseif i==2 then
        love.graphics.rectangle("fill", bar_start_x, bar_start_y, effects_volume * 100, 20)
      elseif i==3 then
        love.graphics.rectangle("fill", bar_start_x, bar_start_y, music_volume * 100, 20)
      elseif i==4 then
        love.graphics.rectangle("fill", bar_start_x, bar_start_y, speech_volume * 100, 20)
      end
			love.graphics.print(menu_items[i], menu_base_pos['x'], coord_y)
		end
		love.graphics.print('->', menu_base_pos['x'] - 50, menu_base_pos['y'] + (menuchoice * 50))
  end
end

function drawUI()
	-- draw ingame ui, hitpoints etc indicator
	-- set global color vars depending on damage etc.
	drawEffects()
  love.graphics.setColor(255,0,0)
	love.graphics.rectangle("fill", 20, 700, player['hp'], 20)
  love.graphics.setColor(255,0,255)
  love.graphics.rectangle("fill", 20, 710, player['promilles'], 20)
  love.graphics.setColor(255,255,255)
  if player['passed_out_time'] > 0 then
    love.graphics.print("Sammunut!", 400, 240)
    love.graphics.rectangle("fill", 400, 320, player['passed_out_time'], 20)
    love.graphics.setColor(10, 10, 10)
  end
  drawPlayerScore()
end

-- Draws the player score on the screen
function drawPlayerScore()
  love.graphics.printf( playerScore, 20, 650, 100, "left" )
end

function getScoreBoardEntries(display_rows)
  highscores = {}
  for line in love.filesystem.lines("highscores.dat") do
    table.insert(highscores, line)
  end
  table.sort(highscores, function(a,b)
      -- todo: this looks like crap, thanks lua
      for as in string.gmatch(a, "%S+") do
        for bs in string.gmatch(b, "%S+") do
          return tonumber(as) > tonumber(bs)
        end
       end
      return a<b
    end
  )
  -- get the first X entries for menu display
  for i=1, tablelength(highscores) do
    if i > display_rows then
      highscores[i] = nil
    end
  end
end

function writeEntryIntoScoreBoard(name, points)
  entry = points .. " - " .. name .. "\n"
  scores = love.filesystem.append("highscores.dat", entry)
end

function drawScoreBoard(x, y)
  iterator = 1
  for index,entry in ipairs(highscores) do
    love.graphics.print(entry, x, y + (iterator * 40))
    iterator = iterator + 1
  end
end

function handleMenu()
	menuJukebox()
  splashTextIncrease()
	genericControls()
	if love.keyboard.isDown('down') and menuCooldown == 0 then
    menuchoice = menuchoice + 1
    menuCooldown = menuWait
	elseif love.keyboard.isDown('up') and menuCooldown == 0 then
		menuchoice = menuchoice - 1
    menuCooldown = menuWait
	end
	if menuchoice > table.getn(menu_items) then
		menuchoice = table.getn(menu_items)
	elseif menuchoice < 1 then
    if menu == 1 then
      if menuchoice < 0 then
        menuchoice = 0
      end
    else
      menuchoice = 1
    end
	end
	-- main menu
	if menu == 1 then

		if love.keyboard.isDown('return') and menuCooldown == 0 then
      if menuchoice == 1 and playerName ~= '' then
				game = 1
				menu = 0
      elseif menuchoice == 2 then
        menuchoices = {}
        menu_items[1] = 'Master'
        menu_items[2] = 'Effekts'
        menu_items[3] = 'Karaoke'
        menu_items[4] = 'Sammallus'
        menu_items[5] = 'POIS! >:o'
        menu = 99
			elseif menuchoice == 3 then
				love.event.quit()
			end
		end
	end
	-- game over menu
	if menu == 2 then
		if love.keyboard.isDown('return') then
			if menuchoice == 1 then
				gamePreload()
				playerCreate()
				game = 1
				menu = 0
			elseif menuchoice == 2 then
				love.graphics.setColor(255,255,255)
				game = 0
				menu = 1
        menu_items[1] = 'Rymyämään ->'
        menu_items[2] = 'Vääntämään :F'
        menu_items[3] = 'Nukkumaan -.-'
        menuCooldown = menuWait
			elseif menuchoice == 3 then
				love.event.quit()
			end
		end
  end
  -- options menu
	if menu == 99 then
    if menuCooldown < 0.1 then
      if love.keyboard.isDown('left') then
        if menuchoice == 1 then
          -- master volume lower
          if master_volume > 0 then
            master_volume = master_volume - 0.1
            if master_volume == 0 then
              love.audio.setVolume(0)
            else
              love.audio.setVolume(master_volume)
            end
          end
        elseif menuchoice == 2 then
          -- effects volume lower
          if effects_volume > 0.1 then
            effects_volume = effects_volume - 0.1
          end
        elseif menuchoice == 3 then
          -- music volume lower
          if music_volume > 0.1 then
            music_volume = music_volume - 0.1
          end
        elseif menuchoice == 4 then
          -- speech volume lower
          if speech_volume > 0.1 then
            speech_volume = speech_volume - 0.1
          end
        end
        menuCooldown = 0.3
      elseif love.keyboard.isDown('right') then
        if menuchoice == 1 then
          -- master volume higher
          if master_volume < 1 then
            master_volume = master_volume + 0.1
            love.audio.setVolume(master_volume)
          end
        elseif menuchoice == 2 then
          -- effects volume higher
          if effects_volume < 1 then
            effects_volume = effects_volume + 0.1
          end
        elseif menuchoice == 3 then
          -- music volume higher
          if music_volume < 1 then
            music_volume = music_volume + 0.1
          end
        elseif menuchoice == 4 then
          -- speech volume higher
          if speech_volume < 1 then
            speech_volume = speech_volume + 0.1
          end
        end
        menuCooldown = 0.3
      elseif love.keyboard.isDown('return') then
        if menuchoice == 5 then
          menu_items = {}
          menu_items[1] = 'Rymyämään ->'
          menu_items[2] = 'Vääntämään :F'
          menu_items[3] = 'Nukkumaan -.-'
          menuchoice = 1
          menuCooldown = menuWait
          menu = 1
        end
      end
    end
  end

end
