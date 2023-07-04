#include <Arduino.h>
#include <WiFiClient.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <wifi.hpp>
#include <ESPAsyncWebServer.h>

// Create AsyncWebServer object on port 80
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");
bool active = false;

void initWiFi()
{
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print('.');
    delay(1000);
  }
  Serial.print("Connected to WiFi network with IP Address: ");
  Serial.println(WiFi.localIP());
}

void onEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type,
             void *arg, uint8_t *data, size_t len)
{
  switch (type)
  {
  case WS_EVT_CONNECT:
    Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
    break;
  case WS_EVT_DISCONNECT:
    Serial.printf("WebSocket client #%u disconnected\n", client->id());
    break;
  }
}

void initWebSocket()
{
  ws.onEvent(onEvent);
  server.addHandler(&ws);
}

void initWebServer()
{
  char status[] = "{\"status\":\"ok\"}";
  server.on("/pbutton", HTTP_GET, [status](AsyncWebServerRequest *request)

            { request->send_P(200, "application/json", "{\"status\":\"active\"}"); });

  server.begin();
}

void initPins()
{
  pinMode(13, INPUT);
}

void setup()
{
  Serial.begin(115200);
  initWiFi();
  Serial.println("Initilizing websocket");
  initWebSocket();
  Serial.println("Initilizing webserver");
  initWebServer();

  Serial.println("Initilizing pins");

  Serial.println("Initilization done.");
}

void loop()
{

  const int state = digitalRead(13);
  if (state)
  {
    ws.textAll("Hello");
  }
  ws.cleanupClients();
  delay(1000);
}