#include "FastLED.h"
FASTLED_USING_NAMESPACE

#define DATA_PIN      4 
#define LED_TYPE      WS2812
#define COLOR_ORDER   GRB
#define NUM_LEDS      144
#define WEB_PORT 80


CRGB leds[NUM_LEDS];

//#define BRIGHTNESS         255
int BRIGHTNESS =           255;   // this is half brightness 
int new_BRIGHTNESS =       128;   // shall be initially the same as brightness

#define FRAMES_PER_SECOND  40    // here you can control the speed. With the Access Point / Web Server the 
                                  // animations run a bit slower. 

int ledMode = 8;                 
#define DEMO_MODE 0


#include <ESP8266WiFi.h>


const char* ssid = "computerlyrik";
const char* password = "Litpmwae=24";  

unsigned long ulReqcount;
unsigned long ulReconncount;

WiFiServer server(WEB_PORT);

void setup() 
{
  ulReqcount=0; 
  ulReconncount=0;
  
  // start serial
  Serial.begin(9600);
  delay(1);
  
  // inital connect
  WiFi.mode(WIFI_STA);
  WiFiStart();


  delay(2000);          // sanity delay for LEDs
  FastLED.addLeds<LED_TYPE,DATA_PIN,COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip); 
  FastLED.setBrightness(BRIGHTNESS);
}

uint8_t gHue = 0; // rotating "base color" used by many of the patterns

void WiFiStart()
{
  
  // Connect to WiFi network
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  
  // Start the server
  server.begin();
  Serial.println("Server started");

  // Print the IP address
  Serial.println(WiFi.localIP());
}

void loop() {
  webserver();

  if (DEMO_MODE) {
    EVERY_N_MILLISECONDS( 10000 ) {
      ledMode = ledMode % 10;  
    }
  }

  if (ledMode != 999) {

     switch (ledMode) {
      case  0: all_off(); break;
      case  1: fill(); break;
      case  2: rainbow(); break;
      case  3: rainbowWithGlitter(); break;
      case  4: confetti(); break;
      case  5: sinelon(); break;
      case  6: juggle(); break;
      case  7: bpm(); break;
      case  8: fire2012(); break;
      case  9: buzz(); break;
      case  10: doublebuzz(); break;
      }
      }
  FastLED.show();  
  FastLED.delay(1000/FRAMES_PER_SECOND); 

} 

//##### WEBSERVER

#include <ArduinoJson.h>

#define WEB_BUFFER 512
#define WEB_REQSIZE  32
#define WEB_ARGSIZE  64
#define WEB_BODYSIZE  255

struct danweb_webstate {
  char  request[WEB_REQSIZE+1];
  char  argv[WEB_ARGSIZE+1];
  char  body[WEB_BODYSIZE+1];
};

struct danweb_webstate webstate;


static int web_is_get_request (char *buf)
{
  if (strstr(buf, "GET ") != 0)
    return 1;
  return 0;
}
static void web_parse_get_request (char *buffer)
{
  // cut off the protocol version
  (strchr(&(buffer[5]), ' '))[0] = 0x0;
  // copy and truncate request
  strncpy(webstate.request, &(buffer[5]), WEB_REQSIZE);
  (strchr(webstate.request, '?'))[0] = 0x0;
  // arguments string
  strncpy(webstate.argv, strchr(&(buffer[5]), '?') +1, WEB_ARGSIZE);
}
static int web_is_post_request (char *buf)
{
  if (strstr(buf, "POST ") != 0)
    return 1;
  return 0;
}
static void web_parse_post_request (char *buffer, WiFiClient client)
{
  // cut off the protocol version
  (strchr(&(buffer[6]), ' '))[0] = 0x0;
  strncpy(webstate.request, &(buffer[5]), WEB_REQSIZE);
  char * pch = strchr(webstate.request, '?');
  if (pch != NULL) {
    pch[0] = 0x0;
  }

  String chunk;
  do {
    chunk = client.readStringUntil('\r');
    //Serial.println(chunk);
  } while (chunk.length() > 1);

  client.readBytes(webstate.body, WEB_BODYSIZE);
  //Serial.println(webstate.body);

}


static void web_send_404 (WiFiClient client)
{
    client.println("HTTP/1.1 404 Not Found");
    client.println("Content-Type: text/html");
    client.println();
    client.println("404 Gone for good");
}

static void web_send_500 (WiFiClient client, char *message)
{
    client.println("HTTP/1.1 500 Internal Server Error");
    client.println("Content-Type: text/html");
    client.println();
    client.println(message);
}

static void web_send_200 (WiFiClient client, char *contenttype, char *message)
{
    client.println("HTTP/1.1 200 OK");
    client.print("Content-Type: ");
    client.println(contenttype);
    client.println();
}


void webserver() { 
  // Check if a client has connected
  WiFiClient client = server.available();
  if (!client) 
  {
    return;
  }

  
  // Wait until the client sends some data
  Serial.println("new client");
  unsigned long ultimeout = millis()+250;
  while(!client.available() && (millis()<ultimeout) )
  {
    delay(1);
  }
  if(millis()>ultimeout) 
  { 
    Serial.println("client connection time-out!");
    return; 
  }

  char buffer[WEB_BUFFER];
  client.readBytesUntil( '\r', buffer, sizeof(buffer));
  Serial.println(buffer);

  // stop client, if request is empty
  if(buffer=="")
  {
    Serial.println("empty request! - stopping client");
    client.stop();
    return;
  }


  if (web_is_get_request(buffer)) {
    web_parse_get_request(buffer);
  }
  else if (web_is_post_request(buffer)) {
    web_parse_post_request(buffer, client);
  }
  Serial.print("request=");
  Serial.println(webstate.request);
  Serial.print("argv=");
  Serial.println(webstate.argv);
  Serial.print("body=");
  Serial.println(webstate.body);

  client.flush();

  if      (!strcmp(webstate.request, "/animation")) { process_animation(client); }
  else if (!strcmp(webstate.request, "/leds"))      { process_leds(client); }
  else { web_send_404(client); }
  
  // and stop the client
  client.stop();
  Serial.println("Client disonnected");  

}

void process_animation(WiFiClient client) {
  StaticJsonBuffer<200> jsonBuffer;
  JsonObject& root = jsonBuffer.parseObject(webstate.body);

  if (!root.success())
  {
    web_send_500(client, "invalid json request");
  }
  else {
    const char* animation    = root["name"];
    Serial.print("Staring animation: ");
    Serial.println(animation);
    
    if      (!strcmp(animation,"off"))             {ledMode = 0;}
    else if (!strcmp(animation,"fill"))            {ledMode = 1;}
    else if (!strcmp(animation,"rainbow"))         {ledMode = 2;}
    else if (!strcmp(animation,"rainbowGlitter"))  {ledMode = 3;}
    else if (!strcmp(animation,"confetti"))        {ledMode = 4;}
    else if (!strcmp(animation,"sinelon"))         {ledMode = 5;}
    else if (!strcmp(animation,"juggle"))          {ledMode = 6;}
    else if (!strcmp(animation,"bpm"))             {ledMode = 7;}
    else if (!strcmp(animation,"fire"))            {ledMode = 8;}
    else if (!strcmp(animation,"buzz"))            {ledMode = 9;}
    else if (!strcmp(animation,"doublebuzz"))      {ledMode = 10;}
    else { 
      web_send_500(client, "UNKNOWN ANIMATION");
      return;
    }
    web_send_200(client, "text/html", "OK");
  }
}

void process_leds(WiFiClient client) {
  StaticJsonBuffer<200> jsonBuffer;
  JsonObject& root = jsonBuffer.parseObject(webstate.body);

  if (!root.success())
  {
    web_send_500(client, "invalid json request");
  }
  else {
    for (JsonObject::iterator it=root.begin(); it!=root.end(); ++it)
    {
      leds[atoi(it->key)].setRGB( it->value[0], it->value[1], it->value[2]);
    }
    all_off();
    ledMode = 999;
    web_send_200(client, "text/html", "OK");
  }
}

/// END of complete web server //////////////////////////////////////////////////////////////////

// LED animations ###############################################################################
void all_off() {
  fill_solid(leds, NUM_LEDS, CRGB::Black); 
//  show_at_max_brightness_for_power();
//  delay_at_max_brightness_for_power(1000/FRAMES_PER_SECOND);   
  FastLED.show();
  FastLED.delay(1000/FRAMES_PER_SECOND); 
}

void fill() {
  fill_solid(leds, NUM_LEDS, CRGB::White); 
  FastLED.show();
  FastLED.delay(1000/FRAMES_PER_SECOND); 
}

void rainbow() 
{
  // FastLED's built-in rainbow generator
  EVERY_N_MILLISECONDS( 20 ) { gHue++; } // slowly cycle the "base color" through the rainbow
  fill_rainbow( leds, NUM_LEDS, gHue, 7);
  show_at_max_brightness_for_power();
  delay_at_max_brightness_for_power(1000/FRAMES_PER_SECOND); 
//  FastLED.show();  
//  FastLED.delay(1000/FRAMES_PER_SECOND); 
}

void rainbowWithGlitter() 
{
  // built-in FastLED rainbow, plus some random sparkly glitter
  rainbow();
  addGlitter(80);
}

void addGlitter( fract8 chanceOfGlitter) 
{
  if( random8() < chanceOfGlitter) {
    leds[ random16(NUM_LEDS) ] += CRGB::White;
  }
}

void confetti() 
{
  EVERY_N_MILLISECONDS( 200 ) { gHue++; }
  // random colored speckles that blink in and fade smoothly
  fadeToBlackBy( leds, NUM_LEDS, 10);
  int pos = random16(NUM_LEDS);
  leds[pos] += CHSV( gHue + random8(64), 200, 255);
  show_at_max_brightness_for_power();
  delay_at_max_brightness_for_power(1000/FRAMES_PER_SECOND); 
//  FastLED.show();  
//  FastLED.delay(1000/FRAMES_PER_SECOND); 
}

void sinelon()
{
  EVERY_N_MILLISECONDS( 200 ) { gHue++; }
  // a colored dot sweeping back and forth, with fading trails
  fadeToBlackBy( leds, NUM_LEDS, 20);
  int pos = beatsin16(13,0,NUM_LEDS);
  leds[pos] += CHSV( gHue, 255, 192);
  show_at_max_brightness_for_power();
  delay_at_max_brightness_for_power(1000/FRAMES_PER_SECOND); 
//  FastLED.show();  
//  FastLED.delay(1000/FRAMES_PER_SECOND); 
}

void bpm()
{
  // colored stripes pulsing at a defined Beats-Per-Minute (BPM)
  uint8_t BeatsPerMinute = 62;
  CRGBPalette16 palette = PartyColors_p;
  uint8_t beat = beatsin8( BeatsPerMinute, 64, 255);
  for( int i = 0; i < NUM_LEDS; i++) { //9948
    leds[i] = ColorFromPalette(palette, gHue+(i*2), beat-gHue+(i*10));
  }
  show_at_max_brightness_for_power();
  delay_at_max_brightness_for_power(1000/FRAMES_PER_SECOND); 
//  FastLED.show();  
//  FastLED.delay(1000/FRAMES_PER_SECOND); 
}

void juggle() {
  EVERY_N_MILLISECONDS( 200 ) { gHue++; }
  // eight colored dots, weaving in and out of sync with each other
  fadeToBlackBy( leds, NUM_LEDS, 20);
  byte dothue = 0;
  for( int i = 0; i < 8; i++) {
    leds[beatsin16(i+7,0,NUM_LEDS)] |= CHSV(dothue, 200, 255);
    dothue += 32;
  }
  show_at_max_brightness_for_power();
  delay_at_max_brightness_for_power(1000/FRAMES_PER_SECOND); 
//  FastLED.show();  
//  FastLED.delay(1000/FRAMES_PER_SECOND); 
}

#define COOLING  1
#define SPARKING 50
bool gReverseDirection = false;

void fire2012()
{
// Array of temperature readings at each simulation cell
  static byte heat[NUM_LEDS];

  // Step 1.  Cool down every cell a little
    for( int i = 0; i < NUM_LEDS; i++) {
      heat[i] = qsub8( heat[i],  random8(0, ((COOLING * 10) * i / NUM_LEDS) + 2));
    }
  
    // Step 2.  Heat from each cell drifts 'up' and diffuses a little
    for( int k= NUM_LEDS - 1; k >= 2; k--) {
      heat[k] = (heat[k - 1] + heat[k - 2] + heat[k - 2] ) / 3;
    }
    
    // Step 3.  Randomly ignite new 'sparks' of heat near the bottom
    if( random8() < SPARKING ) {
      int y = random8(7);
      heat[y] = qadd8( heat[y], random8(160,255) );

    }

    // Step 4.  Map from heat cells to LED colors
    for( int j = 0; j < NUM_LEDS; j++) {
      CRGB color = HeatColor( heat[j]);
      int pixelnumber;
      if( gReverseDirection ) {
        pixelnumber = (NUM_LEDS-1) - j;
      } else {
        pixelnumber = j;
      }
      leds[pixelnumber] = color;
    }
}

void buzz() {
  for( int i = 1; i < NUM_LEDS; i++) {
    leds[i] = leds[i-1];
  }
}

void doublebuzz() {
  for( int i = 1; i < NUM_LEDS; i++) {
    leds[i] = leds[i-1];
  }
}


