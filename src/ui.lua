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
		menu_base_pos = {}
		menu_base_pos['x'] = 450
		menu_base_pos['y'] = 150
		love.graphics.draw(menu_bg, 0, 0)
		for i=1, tablelength(menu_items) do
			coord_y = menu_base_pos['y'] + (i * 80)
			love.graphics.print(menu_items[i], menu_base_pos['x'], coord_y)
		end
    love.graphics.print(splashText, 15, 370, 18.1, splashSize)
    love.graphics.print('HELP SECTION:', 20, 475, 0, 0.6)
    love.graphics.print('Arrowkeys to move, space to shoot, hold left control to change look direction \n Dodge the monsters and move to new map regions. You cannot return the way you came \n Killing monsters gives scrore.', 20, 500, 0, 0.5)
		love.graphics.print('->', menu_base_pos['x'] - 50, menu_base_pos['y'] + (menuchoice * 80))
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
	love.graphics.rectangle("fill", 20, 700, player['hp'], 20)
  drawPlayerScore()
end

-- Draws the player score on the screen
function drawPlayerScore()
  love.graphics.printf( playerScore, 20, 650, 100, "left" )
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
		menuchoice = 1
	end
	-- main menu
	if menu == 1 then

		if love.keyboard.isDown('return') and menuCooldown == 0 then
			if menuchoice == 1 then
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
