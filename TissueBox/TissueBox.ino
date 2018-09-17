//Include & setting Wifi
#include <ESP8266WiFi.h>
#define wifissid "Ernest Home" //wifi名稱
#define wifipass "0910383858" //wifi密碼

//Include & Setting Firebase
#include <FirebaseArduino.h>
#define firebaseURL "objethnographic.firebaseio.com" //
#define authCode "gLixyhZ0JcJmuaNzs2N7VjPAT9ORMMxxhag4q94C" //資料庫密鑰
String chipID = "CO2_Sensor" ; //(資料庫第一層)控制的物件名稱
String child_1 = "situation" ; //子變數名稱
String child_2 = "switch" ;
String data = "data" ; //上傳的資料

bool DEBUG = false;

bool play_state = false;
bool record_state = false;
int recordTime;

//Wifi 連接 function
void setupWifi(){
  // Serial.print("Trying to connect to ");
  // Serial.println(wifissid);
    // attempt to connect to Wifi network:
  WiFi.begin(wifissid, wifipass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    // Serial.print(".");  
    }
  // Serial.println("");
  // Serial.println("WiFi connected");
  // Serial.println(WiFi.macAddress());
  // Serial.print("IP:");
  // Serial.println(WiFi.localIP());
  // Serial.print("Subnet:");
  // Serial.println(WiFi.subnetMask());
  // Serial.print("Gateway:");
  // Serial.println(WiFi.gatewayIP());
  // Serial.print("Channel:");
  // Serial.println(WiFi.channel());
  // Serial.print("Status:");
  // Serial.println(WiFi.status());
  } // wifisetup

void setupFirebase(){
  Firebase.begin(firebaseURL, authCode);
  }

//firebase Pull function
void PullData(){
  String path = chipID ;
  FirebaseObject object = Firebase.get(path);
  play_state = object.getBool(child_1);
  record_state = object.getBool(child_2);
  recordTime = 1000 * object.getInt("recordTime");
  if(DEBUG){
    Serial.print(child_1+" = ");
    Serial.println(play_state);
    Serial.print(child_2+" = ");
    Serial.println(record_state);
    Serial.print("recordTime = ");
    Serial.println(recordTime);
  }
  delay(500);
}

//firenase Push funciton
void PushData (String ID, String subID, bool value){
  // Firebase.setBool ( chipID + "/switch",  record_state);
  Firebase.setBool ( ID + subID, value);
  if(DEBUG)
    Serial.println("record_state == false");
  // String name = Firebase.push("001", on);
  //   Firebase.push("temperature", temperatureObject);
  // handle error
  if (Firebase.failed()) {
      if(DEBUG){
        Serial.print("pushing true failed:");
        Serial.println(Firebase.error());  
      }
      return;
   }
  delay(500);
}

void setup() {
  Serial.begin(115200);
  setupWifi();
  setupFirebase();

}


int flip_play;
int flip_record;
int flip_save;
bool flip_timer = false;
bool flip_timer_p = false;
int timer;
int timer_p;
void loop() {
  PullData();
  // Serial.println("get!");
  
  int playTrigger = 1;
  int recordTrigger = 3;
  int saveTrigger = 4;

  if(play_state == false)
    flip_play = 0;
  else if(play_state == true){
    if(flip_play == 0){
      Serial.write(playTrigger);
      flip_play = 1;
    }
  }
  if(DEBUG){
    Serial.print("flip_play =");
    Serial.println(flip_play);
  }
  delay(10);

  if(record_state == false){
    flip_record = 0;
    
    if(flip_save == 0){
      Serial.write(saveTrigger);
      flip_save = 1;
    }
  }
  else if(record_state == true){
    if(flip_record == 0){
      Serial.write(recordTrigger);
      flip_record = 1;
    }
    //timer
    unsigned long temp = millis();
    if(flip_timer == false){
        timer = temp;
        if(DEBUG)
          Serial.println("timer reseted");
        flip_timer = true;
    }
    if(temp - timer > recordTime){
      timer = temp;
      flip_timer = false;
      record_state = false;
      PushData(chipID, "/switch", record_state);
    }

    flip_save = 0;
  }
  if(DEBUG){
    Serial.print("flip_record =");
    Serial.println(flip_record);
  }
  delay(10);

}
















