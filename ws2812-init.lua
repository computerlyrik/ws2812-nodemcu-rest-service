if file.exists("settings") then
  file.open("settings","r")
  numleds = (file.readline())
  channels = (file.readline())
  file.close()
end
 
if numleds == nil then numleds = 144 end
if channels == nil then channels = 3 end

print("Configuring Leds with " .. numleds .. " numleds and " .. channels .. " channels")

ws2812.init()
buffer = ws2812.newBuffer(numleds, channels)
buffer:fill(0, 0, 0)
