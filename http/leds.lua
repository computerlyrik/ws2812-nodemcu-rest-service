return function (connection, req, args)
   if req.method == "POST" then
      local rd = req.getRequestData()
      for lednumber, value in pairs(rd) do
          buffer:set(lednumber, value[1], value[2], value[3])
      end
      ws2812.write(buffer)
      dofile("httpserver-header.lc")(connection, 200, 'json')
      connection:send('{"status": "OK"}')
   elseif req.method == "GET" then
      dofile("httpserver-header.lc")(connection, 500)
      connection:send("GET not implemented")
      buffer:fill(5, 5, 5)
      ws2812.write(buffer)
   else
      connection:send("ERROR WTF req.method is ", req.method)
   end
end
