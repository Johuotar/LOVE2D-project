--[[
Projectile drawing and logic.
--]]

function runProjectileLogic(projectile)
	-- do something each iteration depending on projectile.
	if projectiles[projectile]['type'] == 'puke' then
		-- puke flies for some time in a direction then disappears unless it hits an enemy.
		if projectiles[projectile]['direction'] == 'left' then
			projectile_move(projectile, projectiles[projectile]['x'] - 1, projectiles[projectile]['y'])
		elseif projectiles[projectile]['direction'] == 'right' then
			projectile_move(projectile, projectiles[projectile]['x'] + 1, projectiles[projectile]['y'])
		elseif projectiles[projectile]['direction'] == 'up' then
			projectile_move(projectile, projectiles[projectile]['x'], projectiles[projectile]['y'] - 1)
		elseif projectiles[projectile]['direction'] == 'down' then
			projectile_move(projectile, projectiles[projectile]['x'], projectiles[projectile]['y'] + 1)
		end
    projectiles[projectile]['moving'] = projectiles[projectile]['moving'] - 1
	end
end

function handleProjectiles()
	for i=1, tablelength(projectiles) do
		runProjectileLogic(i)
		checkProjectileCollision(i)
	end
	destroyProjectiles()
end

function setProjectileToBeRemoved(projectile)
	--set actor to be removed, as per table safety https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
	projectiles[projectile]['destroyed'] = true
end

function destroyProjectiles()
	-- iterate backwards, removing any projectiles set to be removed
	for i=tablelength(projectiles),1,-1 do
		if projectiles[i]['destroyed'] == true then
			table.remove(projectiles, i)
		end
	end
end

function createNewProjectile(of_type, coord_x, coord_y, direction)
	new_index = tablelength(projectiles) + 1
	projectiles[new_index] = {}
	projectiles[new_index]['type'] = of_type
	projectiles[new_index]['direction'] = direction
	projectiles[new_index]['x'] = coord_x
	projectiles[new_index]['y'] = coord_y
  projectiles[new_index]['weight'] = 3
  projectiles[new_index]['moving'] = 0
	projectiles[new_index]['visual_x'] = coord_x * tile_size
	projectiles[new_index]['visual_y'] = coord_y * tile_size
	projectiles[new_index]['destroyed'] = false
end

function projectile_move(projectile, coord_x, coord_y)
	-- movement for projectiles. Major difference is that projectiles are removed immediately when they are "stuck"
	-- are we inside bounds?
	if coord_x > 0 and coord_x <= tablelength(map) then

		for x=1, tablelength(map) do
			if coord_y > 0 and coord_y <= tablelength(map[x]) then
        -- not moving anymore?
        if projectiles[projectile]['moving'] < 1 then
          -- tile in question can be moved on?
          if tile_attrs[map[coord_x][coord_y]] == nil then
            -- move. set it on path
            projectiles[projectile]['moving'] = projectiles[projectile]['weight']
            projectiles[projectile]['x'] = coord_x
            projectiles[projectile]['y'] = coord_y
          else
            projectiles[projectile]['destroyed'] = true
          end
        end
			else
        projectiles[projectile]['destroyed'] = true
      end
    end
	else
		-- destroy projectile if it considered moving out of bounds.
		projectiles[projectile]['destroyed'] = true
	end
end


function checkProjectileCollision(projectile)
	-- if collision between projectile and anything, do something
	-- actors
	for i=1, tablelength(actors) do
		if projectiles[projectile]['x'] == actors[i]['x'] and projectiles[projectile]['y'] == actors[i]['y'] then
			if projectiles[projectile]['type'] == 'puke' then
        --puke does a lot of spiritual damage but only neglible physical damage
        -- todo: apply both once separate stats are made??
        spiritual_damage = actors[i]['spiritual_factor'] * 25
        physical_damage = actors[i]['physical_factor'] * 1
        if spiritual_damage > physical_damage then
          actors[i]['hp'] = actors[i]['hp'] - spiritual_damage
        else
          actors[i]['hp'] = actors[i]['hp'] - physical_damage
        end
        setProjectileToBeRemoved(projectile)
			end
		end
	end

	-- player

	-- other projectiles
end


function drawProjectiles()
	for i=1, tablelength(projectiles) do
		love.graphics.draw(dynamics_resource, projectile_images[projectiles[i]['type']], projectiles[i]['visual_x'], projectiles[i]['visual_y'])
    if projectiles[i]['visual_x'] < projectiles[i]['x'] * tile_size then
			projectiles[i]['visual_x'] = projectiles[i]['visual_x'] + 12
		end
		if projectiles[i]['visual_x'] > projectiles[i]['x'] * tile_size then
			projectiles[i]['visual_x'] = projectiles[i]['visual_x'] - 12
		end
		if projectiles[i]['visual_y'] < projectiles[i]['y'] * tile_size then
			projectiles[i]['visual_y'] = projectiles[i]['visual_y'] + 12
		end
		if projectiles[i]['visual_y'] > projectiles[i]['y'] * tile_size then
			projectiles[i]['visual_y'] = projectiles[i]['visual_y'] - 12
		end
	end
end
