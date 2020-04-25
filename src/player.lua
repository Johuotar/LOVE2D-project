--[[
Functions for player character generation and action handling.
--]]

function applyPlayerEffect(effect, context_variable)
	-- apply any kind of effect based on name on player.
	if effect == "takeDamage" then
		-- todo: apply sound effect, color splash and shit
		gore_ticker = 20 -- set splash effect in motion
		alterPlayerStat("hp", context_variable)
		playerGrunt()
	end
end

function alterPlayerStat(stat_name, amount)
	-- alter a player stat by an amount. Use minus value to subtract
	player[stat_name] = player[stat_name] + amount
	-- todo: need other operations to handle?
end

-- Increment playerScore by given amount.
function incrementPlayerScore(amount)
	playerScore = playerScore + amount
end
-- Resets playerScore to initial value
function resetPlayerScore()
	playerScore = 0
end

function player_move(coord_x, coord_y, map)
	-- check where player is about to move, allow or disallow move based on that and resolve effects
	-- apply speed / delay factor to movement
	-- can be used for teleport

	-- are we still moving?
	if player['moving'] < 1 then

		-- are we inside bounds?
		if coord_x > 0 and coord_x <= tablelength(map) then

			for x=1, tablelength(map) do
				if coord_y > 0 and coord_y <= tablelength(map[x]) then

					-- tile in question can be moved on?
					if tile_attrs[map[coord_x][coord_y]] == nil then
						-- move. set us on path
						player['moving'] = 10
						player['x'] = coord_x
						player['y'] = coord_y
					end
				elseif coord_y > tablelength(map[x]) and player['arrival'] ~= 'down' then
					player['arrival'] = 'up'
					intermission = 1
				elseif coord_y < 1 and player['arrival'] ~= 'up' then
					player['arrival'] = 'down'
					intermission = 1
				end

			end
		-- arrival direction determiningin, always trigger intermission
		elseif coord_x > tablelength(map) and player['arrival'] ~= 'right' then
			player['arrival'] = 'left'
			intermission = 1
		elseif coord_x < 1 and player['arrival'] ~= 'left' then
			player['arrival'] = 'right'
			intermission = 1
		end
	end
end

function playerCreate()
	player = {}
	player['x'] = 2
	player['y'] = 15
	player['visual_x'] = 2 * tile_size
	player['visual_y'] = 15 * tile_size
	player['moving'] = 0
	player['weight'] = 10
	player['image'] = love.graphics.newImage('gfx/CharacterSheet.png')
	player['arrival'] = 'left'
	player['cooldown'] = 0
	player['direction'] = 'right'

	--stats player
	player['hp'] = 100
	player['max_hp'] = 100
	player['fatigue'] = 0
	player['promilles'] = 0
	player['equipped'] = 'puke'
  player['passed_out_time'] = 0

	player['frames'] = {}
	--directional frames player
	player['frames']['down'] = {}
	player['frames']['down'][1] = love.graphics.newQuad(0,0,32,32, player['image']:getDimensions())
	player['frames']['down'][2] = love.graphics.newQuad(32,0,32,32, player['image']:getDimensions())
  player['frames']['down'][3] = love.graphics.newQuad(0,0,32,32, player['image']:getDimensions())
  player['frames']['down'][4] = love.graphics.newQuad(64,0,32,32, player['image']:getDimensions())
	player['frames']['up'] = {}
	player['frames']['up'][1] = love.graphics.newQuad(0,32,32,32, player['image']:getDimensions())
	player['frames']['up'][2] = love.graphics.newQuad(32,32,32,32, player['image']:getDimensions())
  player['frames']['up'][3] = love.graphics.newQuad(0,32,32,32, player['image']:getDimensions())
  player['frames']['up'][4] = love.graphics.newQuad(64,32,32,32, player['image']:getDimensions())
	player['frames']['left'] = {}
	player['frames']['left'][1] = love.graphics.newQuad(0,96,32,32, player['image']:getDimensions())
	player['frames']['left'][2] = love.graphics.newQuad(32,96,32,32, player['image']:getDimensions())
  player['frames']['left'][3] = love.graphics.newQuad(0,96,32,32, player['image']:getDimensions())
  player['frames']['left'][4] = love.graphics.newQuad(32,96,32,32, player['image']:getDimensions())
	player['frames']['right'] = {}
	player['frames']['right'][1] = love.graphics.newQuad(0,64,32,32, player['image']:getDimensions())
	player['frames']['right'][2] = love.graphics.newQuad(32,64,32,32, player['image']:getDimensions())
  player['frames']['right'][3] = love.graphics.newQuad(0,64,32,32, player['image']:getDimensions())
  player['frames']['right'][4] = love.graphics.newQuad(32,64,32,32, player['image']:getDimensions())
	player['direction'] = 'down'
	player['activeFrame'] = 1
  player['walk_delay'] = 10

	--generic sound effects
	player['grunts'] = {}
	player['grunts'][1] = love.audio.newSource('sfx/zombie-1.wav', 'static')
	player['grunts'][2] = love.audio.newSource('sfx/zombie-2.wav', 'static')
	player['grunts'][3] = love.audio.newSource('sfx/zombie-3.wav', 'static')
  
  --footsteps by tile type
  player['footsteps'] = {}
  
  player['footsteps']['floor_wood'] = {}
  player['footsteps']['floor_wood'][1] = love.audio.newSource('sfx/stepwood_1.wav', 'static')
  player['footsteps']['floor_wood'][2] = love.audio.newSource('sfx/stepwood_2.wav', 'static')
  
  -- todo: i think should be floor_cement
  player['footsteps']['cmt'] = {}
  player['footsteps']['cmt'][1] = love.audio.newSource('sfx/stepstone_1.wav', 'static')
  player['footsteps']['cmt'][2] = love.audio.newSource('sfx/stepstone_2.wav', 'static')
  player['footsteps']['cmt'][3] = love.audio.newSource('sfx/stepstone_3.wav', 'static')
  player['footsteps']['cmt'][4] = love.audio.newSource('sfx/stepstone_4.wav', 'static')
  player['footsteps']['cmt'][5] = love.audio.newSource('sfx/stepstone_5.wav', 'static')
  player['footsteps']['cmt'][6] = love.audio.newSource('sfx/stepstone_6.wav', 'static')
  player['footsteps']['cmt'][7] = love.audio.newSource('sfx/stepstone_7.wav', 'static')
  player['footsteps']['cmt'][8] = love.audio.newSource('sfx/stepstone_8.wav', 'static')
  
  --attacks TODO might be item based
  player['attacks'] = {}
  player['attacks']['puke'] = love.audio.newSource('sfx/zombie-8.wav', 'static')
  player['attacks']['puke']:setPitch(1.5)
  
  --status effect timers and other variables not directly related to player
  promilleDecay = 100
end

function playerArrive()
	if player['arrival'] == 'left' then
		player['x'] = 2 --Don't spawn on the border tiles
		player['visual_x'] = 2 * tile_size
	elseif player['arrival'] == 'right' then
		player['x'] = tablelength(start_map) - 1
		player['visual_x'] = 31 * tile_size
	elseif player['arrival'] == 'up' then
		player['y'] = 2
		player['visual_y'] = 2 * tile_size
	elseif player['arrival'] == 'down' then
		player['y'] = tablelength(start_map[1]) - 1 --todo: fix map variable name
		player['visual_y'] = tablelength(start_map[1]) * tile_size - 1
	end
end

function playerUseItem()
	-- launch a player item use depending on chosen item.
	if player['cooldown'] < 1 then
		if player['equipped'] == 'puke' then
			-- create a puke ball
			createNewProjectile('puke', player['x'], player['y'], player['direction'])
      playSoundEffect(player['attacks']['puke'])
      player['cooldown'] = 25
		end
	end
end

function checkPlayerStatus()
	-- check and apply whatever persistent statuses player has. Also check death.
  if player['promilles'] > 100 then
    --ps. i dont know why max promilles are 100 but they are, maybe 100% of 5.5???????
    player['promilles'] = 100  -- do this before applying any effects
  end
  if player['promilles'] > 0 then
    -- player is drunk. Does it have any other effect except for altering amount of otherworldly enemies?
    promilleDecay = promilleDecay - 1
    if promilleDecay < 1 then
      player['promilles'] = player['promilles'] - 1
      promilleDecay = 100
    end
    if player['promilles'] >= 100 then
      player['passed_out_time'] = 100
    end
  elseif player['promilles'] <= 0 then
    promilleDecay = 100  -- enforce promille decay default value when not counting it
  end
  --passed out: blur screen, remove ability to do anything.
  if player['passed_out_time'] > 0 then
    player['passed_out_time'] = player['passed_out_time'] - 1
  end
	if player['hp'] < 1 then
		gameOver()
	end
end

function playerControls()
	-- todo: Something so you can bind keys
  -- allow controlling either sober or drunk only player is not passed out
  if player['passed_out_time'] <= 0 then
    -- attack/use active item
    if love.keyboard.isDown('space') then
      -- todo: check what item is active
      playerUseItem()
    end
    
    --if player is drunk enough, a small chance per update cycle of stumbling to random tile in side
    if player['promilles'] > 50 then
      stumble_value = 10 + player['promilles'] / 2
      if love.math.random(stumble_value) > 35 then 
        -- code for stumbling into random direction
        dir = love.math.random(4)
        if dir == 1 then
          player_move(player['x'], player['y'] + 1, start_map)
          if player['direction'] ~= 'down' then
            player['activeFrame'] = 1
          end
          player['direction'] = 'down'
        elseif dir == 2 then
          player_move(player['x'], player['y'] - 1, start_map)
          if player['direction'] ~= 'up' then
            player['activeFrame'] = 1
          end
          player['direction'] = 'up'
        elseif dir == 3 then
          player_move(player['x'] - 1, player['y'], start_map)
          if player['direction'] ~= 'left' then
            player['activeFrame'] = 1
          end
          player['direction'] = 'left'
        elseif dir == 4 then
          player_move(player['x'] + 1, player['y'], start_map)
          if player['direction'] ~= 'right' then
            player['activeFrame'] = 1
          end
          player['direction'] = 'right'
        end
      end
    end
    
    -- code for turning without moving
    if love.keyboard.isDown('lctrl') and love.keyboard.isDown('down') then
      player['activeFrame'] = 1
      player['direction'] = 'down'
      return true
    elseif love.keyboard.isDown('lctrl') and love.keyboard.isDown('up') then
      player['activeFrame'] = 1
      player['direction'] = 'up'
      return true
    elseif love.keyboard.isDown('lctrl') and love.keyboard.isDown('left') then
      player['activeFrame'] = 1
      player['direction'] = 'left'
      return true
    elseif love.keyboard.isDown('lctrl') and love.keyboard.isDown('right') then
      player['activeFrame'] = 1
      player['direction'] = 'right'
      return true
    end
    -- code for moving
    if love.keyboard.isDown('down') then
      player_move(player['x'], player['y'] + 1, start_map)
      if player['direction'] ~= 'down' then
        player['activeFrame'] = 1
      end
      player['direction'] = 'down'
    elseif love.keyboard.isDown('up') then
      player_move(player['x'], player['y'] - 1, start_map)
      if player['direction'] ~= 'up' then
        player['activeFrame'] = 1
      end
      player['direction'] = 'up'
    elseif love.keyboard.isDown('left') then
      player_move(player['x'] - 1, player['y'], start_map)
      if player['direction'] ~= 'left' then
        player['activeFrame'] = 1
      end
      player['direction'] = 'left'
    elseif love.keyboard.isDown('right') then
      player_move(player['x'] + 1, player['y'], start_map)
      if player['direction'] ~= 'right' then
        player['activeFrame'] = 1
      end
      player['direction'] = 'right'
    end
	-- code for interacting with environment
	if love.keyboard.isDown('f') then
	  playerInteractWithMap()
	end
  end
end
