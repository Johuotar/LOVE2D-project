--scenes.lua: combined generation functions for setting up a scene.

function guitarManSceneSetup()
  --generate a guitar man in the middle of the scene.
  --todo: generate other dudes if needed
  actors = {}
  
  createNewActor('guitar_man', 16, 8, 0)
  
  --play teh guitar
  playTrack(scene_playlists['guitar_man'][1])
end