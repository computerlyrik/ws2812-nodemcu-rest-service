return function (rgbdata, speed)
  rgbdata = rgbdata or { 44, 239, 129 }
  speed = speed or 20
  buffer:fade(speed, ws2812.FADE_IN)
  buffer:fill(rgbdata[1], rgbdata[2], rgbdata[3])
  ws2812.write(buffer)

  animationData.heat = {}
  for i=1, buffer:size() do
    animationData.heat[i] = 0
  end

  local cooling = ( 700 / #animationData.heat ) + 2
  local sparking = 120
  local firecore = #animationData.heat/7

  tmr.alarm(0, speed, tmr.ALARM_AUTO, function()
    local cooldown = math.random(0, cooling) 

    for led = 1, #animationData.heat do
      if cooldown >= animationData.heat[led]  then
        animationData.heat[led]=0;
      else 
        animationData.heat[led]=animationData.heat[led]-cooldown
      end
    end

    for led = #animationData.heat, 3, -1 do
      animationData.heat[led] = (animationData.heat[led - 1] + animationData.heat[led - 2] + animationData.heat[led - 2]) / 3
    end


    local y = math.random(1,firecore*2)
    if y < firecore then
      animationData.heat[y] = animationData.heat[y] + math.random(160,255)
    end

    for led = 1, #animationData.heat do
      local t192 = (animationData.heat[led]/255)*191
      local heatramp = bit.band(t192, 63)
      heatramp = bit.lshift(heatramp, 2)

      if bit.band(heatramp, 0x80) > 0 then
        buffer:set(led, 128, 128, heatramp)
      elseif bit.band(heatramp, 0x40) > 0 then
        buffer:set(led, heatramp, 128, 0) 
      else
        buffer:set(led, 0, heatramp, 0)
      end

    end

    ws2812.write(buffer)
  end)

end

