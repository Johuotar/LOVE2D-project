-- socket provides low-level networking features.
socket = require "socket"

-- First up, we need a UDP socket, from which we'll do all our networking.
udp = socket.udp()

-- the address and port of the server
address, port = "188.226.149.151", 1337
entity = 0  -- entity is what we'll be controlling
updaterate=0.1 -- how long to wait, in seconds, before requesting an update
world = {} -- the empty world-state
udp_t = 0
initialConnectSuccess = false


-- Setup everything needed to do networking via UDP. Called in love.load()
function setupUDP()
  -- Normally socket reads block (cause your game to stop and wait) until they
  -- have data. That doesn't suit us, so we tell it not to do that by setting
  -- the timeout to zero.
  udp:settimeout(0)
  -- "Connect" this socket to the server's address and port using udp:setpeername.
  -- UDP is actually connectionless, this is purely a convenience provided by the
  -- socket library.
  udp_success, udp_err = udp:setpeername(address, port)

  if checkConnectionStatus() then
    initialConnectSuccess = true
    -- Seed the PRNG, so we don't just get the same numbers each time. entity will
    -- be what we'll be controlling, for the sake of this tutorial. It's just a
    -- number, but it'll do. We'll just use math.random to give us a reasonably
    -- unique identity for little effort.
    math.randomseed(os.time())
  	entity = tostring(math.random(99999))
    -- Here we do our first bit of actual networking: we set up a string containing
    -- the data we want to send (using string.format) and then send it using udp.send.
    -- Since we used udp:setpeername earlier we don't even have to specify where to send it.
    local dg = string.format("%s %s %d %d", entity, 'at', 320, 240)
  	udp:send(dg) -- the magic line in question.

    -- Sends client launch notification on game load
    greetTheServer()

  	-- t is just a variable we use to help us with the update rate in love.update.
  	udp_t = 0 -- (re)set t to 0
  end
end


-- Sends a message to the server informing that a client has launched
function greetTheServer()
  -- Send NEW message to server
  local newClientMsg = "NEW"
  udp:send(newClientMsg)
end


-- Checks for connection status returned by the socket. This can be checked at
-- any point in time.
function checkConnectionStatus()
  if udp_success and udp_err ~= 'timeout' and udp_err ~= 'connection refused' then
    return true
  else
    return false
  end
end

-- Check if initial connection succeeds. This controls if we even attempt any
-- network-related stuff during the session. initialConnectSuccess is set by
-- setupUDP() if connection succeeds.
function checkInitialConnection()
  return initialConnectSuccess
end

-- called in love.update().
-- dt = deltatime from love.update()
function handleNetworkUpdates(dt)
  if checkInitialConnection() then
    udp_t = udp_t + dt -- increase t by the deltatime

    -- only care about updates if player is moving
    if player['moving'] > 0 then
      if udp_t > updaterate then
        -- Again, we prepare a packet payload using string.format, then send it on
        -- its way with udp:send. This is the move update mentioned above.
        local dg = string.format("%s %f %f", 'move', player['x'], player['y'])
        udp:send(dg)
        local dg = string.format("SCORE %s", playerScore)
        udp:send(dg)

    		udp_t = udp_t-updaterate -- set udp_t for the next round
      end
    end -- endif player moving


    --[[
    There could well be more than one message waiting for us, so we'll loop until
    we run out!

    And here is something new, the much anticipated other end of udp:send!
    udp:receive will return a waiting packet (or nil, and an error message).
    data is a string, the payload of the far-end's udp:send. We can deal with it
    the same ways we could deal with any other string in Lua (needless to say,
    getting familiar with Lua's string handling functions is a must.)
    ]]--
    repeat
  		data, msg = udp:receive()
  		if data then -- you remember, right? that all values in lua evaluate as true, save nil and false?
        ent, cmd, parms = data:match("^(%S*) (%S*) (.*)")
  			if cmd == 'at' then
  				local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
          assert(x and y)
  				x, y = tonumber(x), tonumber(y)
  				world[ent] = {x=x, y=y}
        else
          print("unrecognised command:", cmd)
        end
      --elseif msg ~= 'timeout' then
      --  print("Network error: "..tostring(msg))
      --elseif msg ~= 'connection refused' then
      --  print("Network error: "..tostring(msg))
      end
    until not data
  end
end


-- Called in love.draw()
function drawNetworkUpdates()
  -- loop over the world table, and print the name (key) of everything in there
  if player['moving'] > 0 and checkInitialConnection() then
    for k, v in pairs(world) do
      love.graphics.print(k, v.x, v.y)
    end
  end
end
