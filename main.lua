debug = true
require 'src/utility'
require 'src/assets'
require 'src/maps'
require 'src/player'
require 'src/ui'
require 'src/sounds'
require 'src/projectiles'
require 'src/networking'


function love.load()
  -- Setup UDP networking. Has no effect if connection cannot be established.
  setupUDP()

  love.window.setMode(1024, 768)
	menu_bg = love.graphics.newImage('gfx/bg/menu.jpg')
	menu_music = love.audio.newSource('music/menu.ogg')
	font = love.graphics.newFont('Avara.ttf', 40)
	love.graphics.setFont(font)
  preloadGraphicsResources()

    -- global ingame vars
	menu = 1
	menu_items = {}
	menu_items[1] = 'Rymyämään ->'
  menu_items[2] = 'Vääntämään :F'
	menu_items[3] = 'Nukkumaan -.-'
	menuchoice = 1
  menuCooldown = 0--time until menu option can be changed
  menuWait = 0.3 --How often menu options can be changed
	loading = 0
	game = 0
	intermission = 0
	generateTileProperties()
	tile_size = 32  -- finally!! power of two
  splashSize = 0.45
  splashIncreasing = true
  splashMaxSize = 0.55
  splashMinSize = 0.35
  splashText = "Default splashtext"--Default value
  splashTable = {}
  playerScore = 0

  --option variables
  --todo: save into an options file
  master_volume = 0.3
  love.audio.setVolume( master_volume ) -- all other volume levels are up to maximum of master_volume
  music_volume = 1
  effects_volume = 1
  speech_volume = 1

  --filesystem
  for line in love.filesystem.lines("splashtexts.txt") do
    table.insert(splashTable, line)
  end
  math.randomseed( os.time() )--seed for randomization from time
  splashText = splashTable[math.random(1, #splashTable )]--number between 1 and last integer in table

	--global trigger etc. vars
	gore_ticker = 0

	--tiles
	loadTileResource()

	--other image resources
	loadActorImages()
	loadProjectileImages()

	--audio
	loadJukeboxSongs()

	--player
	playerCreate()

	--actorbase
	actors = {}

	--projectilebase
	projectiles = {}

	--do init stuff
	gamePreload()
end

function handleActors()
	for i=1, tablelength(actors) do
		runActorLogic(i)
		checkCollisionWithPlayer(i)
	end
	destroyActors()
end

function createNewActor(of_type, coord_x, coord_y, weight)
	new_index = tablelength(actors) + 1
	actors[new_index] = {}
	actors[new_index]['type'] = of_type
	actors[new_index]['x'] = coord_x
	actors[new_index]['y'] = coord_y
	actors[new_index]['visual_x'] = coord_x * tile_size
	actors[new_index]['visual_y'] = coord_y * tile_size
	actors[new_index]['moving'] = 0
	actors[new_index]['weight'] = weight
	actors[new_index]['destroyed'] = false
  actors[new_index]['status'] = 'normal'
  actors[new_index]['frame'] = 1
  actors[new_index]['animation_delay'] = 15

	-- variables that depend on actor type
	-- lisko or demon: spiritual enemies. No damage gained from physical attacks
	if of_type == 'lisko' or of_type == 'demon' then
		actors[new_index]['physical_factor'] = 0
		actors[new_index]['spiritual_factor'] = 1
		actors[new_index]['hp'] = 1
	end

  -- load asset
end


function setActorToBeRemoved(actor)
	--set actor to be removed, as per table safety https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
	actors[actor]['destroyed'] = true
end

function destroyActors()
	-- iterate backwards, removing any actors set to be removed
	for i=tablelength(actors),1,-1 do
		if actors[i]['destroyed'] == true then
			table.remove(actors, i)
		end
	end
end

function runActorLogic(actor)
	--provide with index

	--lisko: sprawl around randomly!
	if actors[actor]['type'] == 'lisko' then
    if actors[actor]['status'] == 'alert' then
      -- chase player
      if player['x'] < actors[actor]['x'] then
        actor_move(actor, actors[actor]['x']-1, actors[actor]['y'])
      end
      if player['x'] > actors[actor]['x'] then
        actor_move(actor, actors[actor]['x']+1, actors[actor]['y'])
      end
      if player['y'] < actors[actor]['y'] then
        actor_move(actor, actors[actor]['x'], actors[actor]['y']-1)
      end
      if player['y'] > actors[actor]['y'] then
        actor_move(actor, actors[actor]['x'], actors[actor]['y']+1)
      end
    else
      dir = love.math.random(5)
      if dir == 1 then
        actor_move(actor, actors[actor]['x']-1, actors[actor]['y'])
      elseif dir == 2 then
        actor_move(actor, actors[actor]['x']+1, actors[actor]['y'])
      elseif dir == 3 then
        actor_move(actor, actors[actor]['x'], actors[actor]['y']-1)
      elseif dir == 4 then
        actor_move(actor, actors[actor]['x'], actors[actor]['y']+1)
      elseif dir == 5 then
        -- no move
      end
    end
		actors[actor]['moving'] = actors[actor]['moving'] - 1

    -- set chasing status if player is too near
    if player['x'] - actors[actor]['x'] < 5 and player['x'] - actors[actor]['x'] > -5 then
      if player['y'] - actors[actor]['y'] < 5 and player['y'] - actors[actor]['y'] > -5 then
        actors[actor]['status'] = 'alert'
      end
    else
      actors[actor]['status'] = 'normal'
    end
    if actors[actor]['hp'] < 1 then
      actors[actor]['destroyed'] = true
      incrementPlayerScore(1)
    end
	end
	if actors[actor]['type'] == 'demon' then
		-- demon glides around
		dir_x = love.math.random(-5, 5)
		dir_y = love.math.random(-5, 5)

		actor_move(actor, actors[actor]['x'] + dir_x, actors[actor]['y'] + dir_y)

		actors[actor]['moving'] = actors[actor]['moving'] - 1
    if actors[actor]['hp'] < 1 then
      actors[actor]['destroyed'] = true
      incrementPlayerScore(5)
    end
	end

end

function actorGeneration()
	-- call this after player is about to enter new map!
	-- empty actors list and generate it again
	actors = {}
	-- a certain amount of liskos from 1 to promille_factor...
	liskos = love.math.random(100)
	demonis = love.math.random(10)
	for i=1, liskos do
		createNewActor('lisko', love.math.random(24),love.math.random(12), 25)
	end
	for i=1, demonis do
		createNewActor('demon', love.math.random(24),love.math.random(12), 50)
	end
end

function drawSector(matrix)
	-- draw a sector upon which körsy walketh. 20x20 tiles.
	for x=1, table.getn(matrix) do
		for y=1, table.getn(matrix[x]) do
			tile_type = map[x][y] -- get tile type
      love.graphics.draw(resource, tiles[tile_type], x * tile_size, y * tile_size)
		end
	end
end

function genericControls()
	--these controls apply everywhere
	--quit
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
end

function gamePreload()
	start_map = generateMap()
	actorGeneration()
  resetPlayerScore()
end

function damageActor(actor, projectile)
  -- todo: compare projectile and actor to see what effect was on actor
end

function goreVisuals()
	-- gore: splash screen red quickly when taking damage
	-- todo: use an alpha layered blood splash image as effect?
	for i=1, gore_ticker do
		love.graphics.setColor(255, 255-(gore_ticker*20), 255-(gore_ticker*20))
	end
end

function actor_move(actor, coord_x, coord_y)
	-- mostly same as player, except for targeted actor (target with index)

	-- are we still moving?
	if actors[actor]['moving'] < 1 then

		-- are we inside bounds?
		if coord_x > 0 and coord_x <= tablelength(map) then

			for x=1, tablelength(map) do
				if coord_y > 0 and coord_y <= tablelength(map[x]) then

					-- tile in question can be moved on?
					if tile_attrs[map[coord_x][coord_y]] == nil then
						overlap = false
						-- no actor would be overlapping with move?
						for i=1, tablelength(actors) do
							if coord_x == actors[i]['x'] and coord_y == actors[i]['y'] then
								overlap = true
							end
						end
						if overlap == false then
							-- move. set it on path
							actors[actor]['moving'] = actors[actor]['weight']
							actors[actor]['x'] = coord_x
							actors[actor]['y'] = coord_y
						end
					end
				end

			end

		end
	end
end

function checkCollisionWithPlayer(actor)
	-- if collision between id'd actor and player happens, do something
	if actors[actor]['x'] == player['x'] and actors[actor]['y'] == player['y'] then
		if actors[actor]['type'] == 'lisko' or actors[actor]['type'] == 'demon' then
			applyPlayerEffect('takeDamage', -15)
			setActorToBeRemoved(actor)
		end
	end
end


function gameOver()
	--game over, my dude, game over! You lose. Transition to end screen and tell player to f off
	menu_items[1] = 'Takasin baanalle :p'
	menu_items[2] = 'Mee valikkoo'
	menu_items[3] = 'PAINU VITHUU :o'
	menu = 2
	game = 0
end

--main game loop
function handleGame()
	--not loading a new area
	if intermission == 0 then
		checkPlayerStatus() -- no point executing stuff if ur dead
		genericControls()
		gameJukebox()
		handleActors()
		handleProjectiles()
		playerControls()
    if player['moving'] > 0 then
      player['moving'] = player['moving'] - 1
    end
    if player['cooldown'] > 0 then
      player['cooldown'] = player['cooldown'] - 1
    end
	--loading a new area
	else
		start_map = generateMap() --todo: change map variable name
		actorGeneration()
		playerArrive()
		intermission = 0
	end
end

function drawActors()
	for i=1, tablelength(actors) do
    -- todo: active frames/animations system for actors
    tybe = actors[i]['type']
    frame = actors[i]['frame']
		love.graphics.draw(dynamics_resource, actors_images[tybe][frame], actors[i]['visual_x'], actors[i]['visual_y'])
    actors[i]['animation_delay'] = actors[i]['animation_delay'] - 1
    if actors[i]['animation_delay'] < 1 then
      actors[i]['frame'] = actors[i]['frame'] + 1
      if actors[i]['frame'] > tablelength(actors_images[tybe]) then
        actors[i]['frame'] = 1
      end
      actors[i]['animation_delay'] = 15
    end

		if actors[i]['visual_x'] < actors[i]['x'] * tile_size then
			actors[i]['visual_x'] = actors[i]['visual_x'] + 4
		end
		if actors[i]['visual_x'] > actors[i]['x'] * tile_size then
			actors[i]['visual_x'] = actors[i]['visual_x'] - 4
		end
		if actors[i]['visual_y'] < actors[i]['y'] * tile_size then
			actors[i]['visual_y'] = actors[i]['visual_y'] + 4
		end
		if actors[i]['visual_y'] > actors[i]['y'] * tile_size then
			actors[i]['visual_y'] = actors[i]['visual_y'] - 4
		end
	end
end

function drawGame()
	if intermission == 0 then
		drawSector(start_map)
		if player['visual_x'] < player['x'] * tile_size then
			player['visual_x'] = player['visual_x'] + 4
		end
		if player['visual_x'] > player['x'] * tile_size then
			player['visual_x'] = player['visual_x'] - 4
		end
		if player['visual_y'] < player['y'] * tile_size then
			player['visual_y'] = player['visual_y'] + 4
		end
		if player['visual_y'] > player['y'] * tile_size then
			player['visual_y'] = player['visual_y'] - 4
		end
		if player['moving'] > 1 then
      player['walk_delay'] = player['walk_delay'] - 1
    end

		drawActors()
		drawProjectiles()
		direction = player['direction']

    if player['walk_delay'] < 1 then
      player['activeFrame'] = player['activeFrame'] + 1
      if player['activeFrame'] > tablelength(player['frames'][direction]) then
        player['activeFrame'] = 1
      end
      player['walk_delay'] = 10

      -- play footstep sound if tile type has sound effect loaded
      tile_type = start_map[player['x']][player['y']]
      if setContains(player['footsteps'], tile_type) then
        -- Only on every second frame change
        if player['activeFrame'] % 2 == 0 then
          random_pick = love.math.random(1, tablelength(player['footsteps'][tile_type]))
          player['footsteps'][tile_type][random_pick]:stop()
          player['footsteps'][tile_type][random_pick]:play()
        end
      end
    end
    activeFrame = player['activeFrame']
		love.graphics.draw(player['image'], player['frames'][direction][activeFrame], player['visual_x'], player['visual_y'])
	end
end

function drawEffects()
	-- visual effects, hallucinations etc. miscellanous stuff

	-- damage color "tint" - screen goes gray in accordance with damage amount
	damage_factor = 155 + player['hp']
	if player['hp'] < 25 then
		damage_factor = damage_factor - 100
	end
	love.graphics.setColor(damage_factor,damage_factor,damage_factor)

	-- hit splash
	if gore_ticker > 0 then
		goreVisuals()
		gore_ticker = gore_ticker - 1
	end
end


function love.draw()
	if menu > 0 and game == 0 then
		drawMenu()
	elseif game == 1 and menu == 0 then
		drawGame()
		drawUI()
    -- Handle drawing network updates, WIP
    -- if checkInitialConnection() then
    --   drawNetworkUpdates()
    -- end
	end
end


function love.update(dt)
  if checkInitialConnection() then
    -- Send and receive updates to the network
    handleNetworkUpdates(dt)
  end

  menuCooldown = math.max ( 0, menuCooldown - dt )
	if menu > 0 and game == 0 then
		handleMenu()
	else
		handleGame()
	end
end
