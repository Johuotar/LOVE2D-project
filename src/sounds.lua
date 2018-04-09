--[[
Music and SFX.
--]]

function playSoundEffect(effect)
  -- set volume level for clip and play it.
  effect:stop()
  effect:setVolume(effects_volume * master_volume)
  effect:play()
end

function playTrack(track)
  --set volume level for track and play it.
  track:setVolume(music_volume * master_volume)
  track:play()
end

function playSpeech(clip)
  -- speech clips modified by speech sound volume
  clip:setVolume(speech_volume * master_volume)
  clip:play()
end

function playerGrunt()
    -- todo: generalize, AKA should be playerSoundFX(), not just for grunts
	-- play a grunt sound from player, randomized with random pitch.
	for i=1, tablelength(player['grunts']) do
		if player['grunts'][i]:isPlaying() then
			player['grunts'][i]:stop()
		end
	end
	grunt = love.math.random(tablelength(player['grunts']))
	pitch = love.math.random()
	if pitch < 0.5 then
		pitch = 0.5
	end

	player['grunts'][grunt]:setPitch(pitch)
	playSoundEffect(player['grunts'][grunt])
end

function menuJukebox()
	for i=1, tablelength(jukebox) do
		if jukebox[i]:isPlaying() == true then
			jukebox[i]:stop()
		end
	end
	playTrack(menu_music)
	menu_music:setLooping(true)
end

function gameJukebox()
  -- suspend jukebox operation when any scene is playing
  if scene == 'no_scene' then
    -- disable menu music if playing
    if menu_music:isPlaying() == true then
      menu_music:stop()
    end
    --disable special songs if playing
    --todo: universalize this
    for track=1, tablelength(scene_playlists['guitar_man']) do
      if scene_playlists['guitar_man'][track]:isPlaying() then
        scene_playlists['guitar_man'][track]:stop()
      end
    end

    ended = true

    -- dont do anything while previous jukebox song is playing
    for i=1, tablelength(jukebox) do
      if jukebox[i]:isPlaying() == true then
        ended = false
      end
    end
    if ended == true then
      shuffle = love.math.random(tablelength(jukebox))
      playTrack(jukebox[shuffle])
    end
  else
    for i=1, tablelength(jukebox) do
      if jukebox[i]:isPlaying() then
        jukebox[i]:stop()
      end
    end
  end
end
