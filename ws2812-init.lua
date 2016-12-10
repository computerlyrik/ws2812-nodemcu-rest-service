return function (numleds, channels)

  -- load from file if not set

  if (not numleds or not channels) and file.exists("settings") then
    file.open("settings","r")
    numleds = (file.readline())
    channels = (file.readline())
    file.close()
  end
  
  -- set default if not set
  numleds = numleds or 144
  channels = channels or 3

  print("Configuring Leds with " .. numleds .. " numleds and " .. channels .. " channels")

  ws2812.init()
  buffer = ws2812.newBuffer(numleds, channels)
  buffer:fill(0, 0, 0)

  -- store current into settings file
  file.open("settings","w")
  file.writeline(numleds)
  file.writeline(channels)
  file.close()
end
