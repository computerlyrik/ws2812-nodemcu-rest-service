local numleds, channels

-- load from file if not set
if file.exists("settings") then
  file.open("settings","r")
  numleds = (file.readline())
  channels = (file.readline())
  file.close()
end

-- set default if not set
numleds = numleds or 144
channels = channels or 3

print("Configuring Leds with "..numleds.." numleds and "..channels.." channels")

ws2812.init()
buffer = ws2812.newBuffer(numleds, channels)
buffer:fill(0, 0, 0)

