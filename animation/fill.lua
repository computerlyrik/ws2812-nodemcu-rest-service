return function (rgbdata, speed)
  rgbdata = rgbdata or { 44, 239, 129 }
  speed = speed or 2
  buffer:fade(speed, ws2812.FADE_IN)
  buffer:fill(rgbdata[1], rgbdata[2], rgbdata[3])
  ws2812.write(buffer)
end
