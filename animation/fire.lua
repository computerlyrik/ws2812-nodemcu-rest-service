return function (rgbdata, speed)
  rgbdata = rgbdata or { 44, 239, 129 }
  speed = speed or 20
  buffer:fade(speed, ws2812.FADE_IN)
  buffer:fill(rgbdata[1], rgbdata[2], rgbdata[3])
  ws2812.write(buffer)

  local cooling = 50
  local sparking = 120
  local numleds = buffer:size()

  animationData.heat = {}
  for i=1, numleds do
    animationData.heat[i] = 0
  end

  tmr.alarm(0, speed, tmr.ALARM_AUTO, function()
    print('mem '..node.heap())
    local cooldown = math.random(0, ((cooling * 10) /  #animationData.heat ) + 2);
    
    -- 1. Cooldown each led
    for led = 1, #animationData.heat do
      animationData.heat[led] = math.max(0, animationData.heat[led]-cooldown)
    end

    -- 2. move each led up and diffuse
    for led = 3, #animationData.heat do
      animationData.heat[led] = (animationData.heat[led - 1] + animationData.heat[led - 2] + animationData.heat[led - 2]) / 3;
    end

    -- 3. initiate sparks
    if math.random(255) < sparking then
      local y = math.random(1,8);
      animationData.heat[y] = animationData.heat[y] + math.random(160,255)
    end

    -- 4. calculate led colors from heat
    for led = 1, #animationData.heat do
      local t192 = (animationData.heat[led]/255)*191
      local heatramp = bit.band(t192, 63)
      heatramp = bit.lshift(heatramp, 2)

      -- print(led .. " > " .. heatramp)

      if heatramp <= 0x40 then
        buffer:set(led, heatramp, 0, 0)
      elseif heatramp <= 0x80 then
        buffer:set(led, 255, heatramp, 0) 
      else
        buffer:set(led, 255, 255, heatramp)
      end

    end

    ws2812.write(buffer)
  end)

end

