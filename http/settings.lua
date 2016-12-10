return function (connection, req, args)
   if req.method == "POST" then
      local rd = req.getRequestData()
      dofile("ws2812-init.lc")(rd.numleds, rd.channels)
      dofile("httpserver-header.lc")(connection, 200, 'json')
      connection:send('{"status": "OK"}')
   else
      dofile("httpserver-header.lc")(connection, 500)
      connection:send("ERROR WTF req.method is ", req.method)
   end
end
