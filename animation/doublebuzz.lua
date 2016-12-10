return function (rgbdata, speed)
  rgbdata = rgbdata or { 44, 239, 129 }
  speed = speed or 20
  tmr.alarm(0, speed, tmr.ALARM_AUTO, function()
    i=i+1
    buffer:fade(2)
    buffer:set(i%buffer:size()+1, rgbdata[1], rgbdata[2], rgbdata[3])
    buffer:set((i+8)%buffer:size()+1, rgbdata[1], rgbdata[2], rgbdata[3])
    ws2812.write(buffer)
  end)
end
