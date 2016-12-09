# [ws2812-nodemcu-rest-service](https://github.com/computerlyrik/ws2812-nodemcu-rest-service)
...facing exactly this setup.

Based on https://github.com/marcoskirsch/nodemcu-httpserver
Find out more about the HTTP-Server itself and File uploading processes


test http rest:

curl -H "Content-Type: application/json" -X POST -d '{"1":[23, 233, 112],"25":[223, 84, 122]}' http://192.168.0.60:80/led.lua


## Features
- Supports RGB Stripes with WS2812(b) LED chips




## Prerequisites 

### Firmware

Make sure modules are built in.
For convenience i added a working firmware file built by [the NodeMCU build service](https://nodemcu-build.com/index.php)
and includes the following modules
`cjson file gpio http mdns net node tmr uart wifi ws2812`

### Uploader-Software

Currently [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader) as mentioned on [nodemcu-httpserver project](https://github.com/marcoskirsch/nodemcu-httpserver)


## Test
```
curl -H "Content-Type: application/json" -X POST -d '{"1":[23, 233, 112],"25":[223, 84, 122]}' http://<yourip>:80/stripe.lua
```

Currently not working/in progress

- RGBW Stripes
- set all LEDs at once
- make Buffer configurable
- add Animations

Make following Chapter work:

Get to work:
Erase Flash & Flash Files - make
Connect to Wlan network
execute curl to configure wlan (does a persistence setup - if it breaks, you need to re-set firmware)

If there are any problems, try restarting, especially after flashing steps.
