return function (connection, req, args)
  if req.method == "POST" then
    local rd = req.getRequestData()

    -- reset possible running animation
    tmr.stop(0)
    buffer:fill(0, 0, 0)
    animation_data = nil

    local filename = "animation/"..rd.name..".lc"
    if file.exists(filename) then
      print("Activating animation ".. filename .." with rgbdata ".. rd.rgbdata[1] .. " and speed " .. rd.speed)
      dofile(filename)(rd.rgbdata, rd.speed)

      dofile("httpserver-header.lc")(connection, 200, 'json')
      connection:send('{"status": "OK"}')
    else
      dofile("httpserver-header.lc")(connection, 500, 'json')
      connection:send('{"status":"ERROR", "message": "unknown animation: ' .. args.name..'"}')
    end

  else
    dofile("httpserver-header.lc")(connection, 500)
    connection:send("ERROR WTF req.method is ", req.method)
  end
end



