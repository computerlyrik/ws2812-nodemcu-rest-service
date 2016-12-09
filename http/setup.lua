return function (connection, req, args)
   if req.method == "POST" then

      local rd = req.getRequestData()
      local wifi_config = {}
      wifi_config.ssid = rd['ssid'] 
      wifi_config.pwd =  rd['password']
      wifi_config.save = true
      print('setup wifi:' .. wifi_config.ssid .. ' : ' .. wifi_config.pwd)
      wifi.sta.config(wifi_config)
      dofile("httpserver-header.lc")(connection, 200, 'json')
      connection:send('{"status":"OK"}')
      connection:flush()

   else
      dofile("httpserver-header.lc")(connection, 500)
      connection:send("ERROR WTF req.method is ", req.method)
   end
end
