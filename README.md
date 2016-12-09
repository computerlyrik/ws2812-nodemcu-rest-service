# [ws2812-nodemcu-rest-service](https://github.com/computerlyrik/ws2812-nodemcu-rest-service)
...facing exactly this setup.

Based on https://github.com/marcoskirsch/nodemcu-httpserver

Find out more about the HTTP-Server itself and File uploading processes

## Features
- [POST] Supports RGB Stripes with WS2812(b) LED chip (up to 144 led hard set)
- [GET] Reset leds to low brightness (current testing purpose only)


## Prerequisites 

### Firmware

Make sure modules are built in.
For convenience i added a working firmware file built by [the NodeMCU build service](https://nodemcu-build.com/index.php)
and includes the following modules
`cjson file gpio http mdns net node tmr uart wifi ws2812`

### Uploader-Software

Currently [nodemcu-uploader](https://github.com/kmpm/nodemcu-uploader) as mentioned on [nodemcu-httpserver project](https://github.com/marcoskirsch/nodemcu-httpserver)

This repository is prepared to use this as a submodule. To install just type `git submodule update --init`

## Getting Started

1. Upload all files 
  * erase your flash with `esptool`
  * upload flash using `make upload_all`
  * *restart node*
2. Setup Wifi
  * Connect to ESP* Wifi. Password is same as AP.
  * Setup your wifi settings ```curl -H "Content-Type: application/json" -X POST -d '{"ssid":"yourssid", "password":"yourpassword"}' http://192.168.111.1:80/setup.lua```
  * *restart node*
  * get <yourip> by asking your wifi system (or using console)
3. LED Settings
  * numleds = Number of leds in your row (may be multiple stripes)
  * channels = Number of channels, e.g. 3 for RGB, 4 for RGBW
  * Configure the led settings ```curl -H "Content-Type: application/json" -X POST -d '{"numleds":144, "channels":3}' http://<yourip>:80/settings.lua```


**If anything gets wrong or does not work: Restart & Re-Flash Firmware and start over**

## Test
This testing should work always - even on ESP* - Access Point connection. <yourip> would be 192.168.111.1 then.

```
curl -H "Content-Type: application/json" -X POST -d '{"1":[23, 233, 112],"25":[223, 84, 122]}' http://<yourip>:80/leds.lua
```

## Currently not working/in progress/ideas

- RGBW Stripes
- set all LEDs at once
- make Buffer configurable
- add Animations

### Make following Chapter work:

Get to work:
Erase Flash & Flash Files - make
Connect to Wlan network
execute curl to configure wlan (does a persistence setup - if it breaks, you need to re-set firmware)

If there are any problems, try restarting, especially after flashing steps.
