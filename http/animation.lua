return function (connection, req, args)
   if req.method == "POST" then
      local rd = req.getRequestData()
      if rd.name == "buzz" then  
         print("Activating animation buzz")
         buffer:fill(0, 0, 0)
         tmr.alarm(0, 20, 1, function()
            i=i+1
            buffer:fade(2)
            buffer:set(i%buffer:size()+1, 44, 239, 129)
            ws2812.write(buffer)
          end)
      elseif rd.name == "doublebuzz" then  
         print("Activating animation doublebuzz")
         buffer:fill(0, 0, 0)
         tmr.alarm(0, 20, 1, function()
            i=i+1
            buffer:fade(2)
            buffer:set(i%buffer:size()+1, 44, 239, 129)
            buffer:set((i+8)%buffer:size()+1, 44, 239, 129)
            ws2812.write(buffer)
          end)
      elseif rd.name == "fill" then  
         print("Activating animation fill")
         buffer:fill(rd.data[1], rd.data[2], rd.data[3])
         ws2812.write(buffer)
      else
         dofile("httpserver-header.lc")(connection, 500, 'json')
         connection:send('unknown animation: ' .. args.name)
      end
      dofile("httpserver-header.lc")(connection, 200, 'json')
      connection:send('{"status": "OK"}')
   else
      dofile("httpserver-header.lc")(connection, 500)
      connection:send("ERROR WTF req.method is ", req.method)
   end
end
