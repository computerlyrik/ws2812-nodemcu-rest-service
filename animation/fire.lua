return function (rgbdata, speed)
  rgbdata = rgbdata or { 44, 239, 129 }
  speed = speed or 20
  buffer:fade(speed, ws2812.FADE_IN)
  buffer:fill(rgbdata[1], rgbdata[2], rgbdata[3])
  ws2812.write(buffer)

  local cooling = 50
  local sparking = 120


  animationData = {}
  animationData.heat = {} --[NUM_LEDS];

  tmr.alarm(0, speed, tmr.ALARM_AUTO, function()

    local cooldown = math.random(0, ((cooling * 10) / buffer:size() ) + 2);

    -- 1. Cooldown each led
    for led = 1, buffer.size() do
      animationData.heat[led] = math.max(0, animationData.heat[led]-cooldown)
    end

    -- 2. move each led up and diffuse
    for led = 1, buffer.size() do
      heat[led] = (heat[led - 1] + heat[led - 2] + heat[led - 2]) / 3;
    end

    -- 3. initiate sparks
    if math.random(255) < sparking then
      local y = math.random(7);
      animationData.heat[y] = animationData.heat[y] + math.random(160,255)
    end

    -- 4. calculate led colors from heat
    for led = 1, buffer.size() do
      local t192 = (animationData.heat[led]/255)*191 -- 0-191
      local heatramp = bit.band(t192, 63) -- 0..63
      heatramp = bit.lshift(heatramp, 2) -- scale up to 0..252
      setled(led,heatramp) 
    end

    ws2812.write(buffer)
  end)

  local function setled(index, heatramp) 
    if heatramp <= 0x40 then
      buffer:set(index, heatramp, 0, 0)
    elseif heatramp <= 0x80 then
      buffer:set(index, 255, heatramp, 0) 
    else
      buffer:set(index, 255, 255, heatramp)
    end
  end

end

