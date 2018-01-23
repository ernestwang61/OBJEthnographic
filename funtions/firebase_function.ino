//Include & setting Wifi
#include <ESP8266WiFi.h>
#define wifissid "Ernest Home" //wifi名稱
#define wifipass "0910383858" //wifi密碼

//Include & Setting Firebase
#include <FirebaseArduino.h>
#define firebaseURL "objethnographic.firebaseio.com" //
#define authCode "gLixyhZ0JcJmuaNzs2N7VjPAT9ORMMxxhag4q94C" //資料庫密鑰
String chipID = "printer" ; //(資料庫第一層)控制的物件名稱
String child = "situation" ; //子變數名稱
String data = "data" ; //上傳的資料

//Wifi 連接 function
void setupWifi(){
  Serial.print("Trying to connect to ");
  Serial.println(wifissid);
    // attempt to connect to Wifi network:
  WiFi.begin(wifissid, wifipass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");  
    }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println(WiFi.macAddress());
  Serial.print("IP:");
  Serial.println(WiFi.localIP());
  Serial.print("Subnet:");
  Serial.println(WiFi.subnetMask());
  Serial.print("Gateway:");
  Serial.println(WiFi.gatewayIP());
  Serial.print("Channel:");
  Serial.println(WiFi.channel());
  Serial.print("Status:");
  Serial.println(WiFi.status());
  } // wifisetup

void setupFirebase(){
  Firebase.begin(firebaseURL, authCode);
  }

//firebase Pull function
void PullData(){
  String path = chipID ;
  FirebaseObject object = Firebase.get(path);
  String value = object.getString(child);
  Serial.println(child+" = ");
  Serial.println(value);
  delay(1000);
}

//firenase Push funciton
void PushData (){
  Firebase.setString ( chipID + "/time", data );
  // String name = Firebase.push("001", on);
  //   Firebase.push("temperature", temperatureObject);
  // handle error
  if (Firebase.failed()) {
      Serial.print("pushing true failed:");
      Serial.println(Firebase.error());  
      return;
   }
  delay(3000);
}

void setup() {
  Serial.begin(115200);
  setupWifi();
  setupFirebase();
  }

void loop() {
  PullData();
  Serial.println("get!");
  PushData();
  Serial.println("push!");
  }
