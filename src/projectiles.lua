--[[
Projectile drawing and logic.
--]]

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
