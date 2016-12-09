return function (connection, req, args)
   if req.method == "POST" then
      dofile("httpserver-header.lc")(connection, 200, 'json')
      local rd = req.getRequestData()
      connection:send('<h2>Received the following values:</h2>')
      for name, value in pairs(rd) do
          connection:send(name .. '->' .. value[1] .. ', ' .. value[2] .. ', ' .. value[3] .. "\n")
          buffer:set(name, value[1], value[2], value[3])
      end
      ws2812.write(buffer)
   elseif req.method == "GET" then
      dofile("httpserver-header.lc")(connection, 500)
      connection:send("GET not implemented")
      buffer:fill(5, 5, 5)
      ws2812.write(buffer)
   else
      connection:send("ERROR WTF req.method is ", req.method)
   end
end
