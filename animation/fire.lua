return function (rgbdata, speed)
  rgbdata = rgbdata or { 44, 239, 129 }
  speed = speed or 20
  buffer:fade(speed, ws2812.FADE_IN)
  buffer:fill(rgbdata[1], rgbdata[2], rgbdata[3])
  ws2812.write(buffer)

  local cooling = 50
  local sparking = 120


  animationData.heat = {}
  for i=1, buffer:size() do
    animationData.heat[i] = 0
  end

  tmr.alarm(0, speed, tmr.ALARM_AUTO, function()

    
    -- 1. Cooldown each led
    for led = 1, #animationData.heat do
      local cooldown = math.random(0, ((cooling * 10) /  #animationData.heat ) + 2) 
      if cooldown > animationData.heat[led]  then
        animationData.heat[led]=0;
      else 
        animationData.heat[led]=animationData.heat[led]-cooldown
      end
    end

    -- 2. move each led up and diffuse
    for led = #animationData.heat, 3, -1 do
      animationData.heat[led] = (animationData.heat[led - 1] + animationData.heat[led - 2] + animationData.heat[led - 2]) / 3;
    end

    -- 3. initiate sparks
    if math.random(255) < sparking then
      local y = math.random(1,8);
      animationData.heat[y] = animationData.heat[y] + math.random(160,255)
    end

    -- 4. calculate led colors from heat
    for led = 1, #animationData.heat do
      local t192 = (animationData.heat[led]*191)/255
      local heatramp = bit.band(t192, 63)
      heatramp = bit.lshift(heatramp, 2)

      if heatramp <= 0x40 then
        buffer:set(led, 0, heatramp, 0)
      elseif heatramp <= 0x80 then
        buffer:set(led, heatramp, 255, 0) 
      else
        buffer:set(led, 255, 255, heatramp)
      end

    end

    ws2812.write(buffer)
  end)

end

