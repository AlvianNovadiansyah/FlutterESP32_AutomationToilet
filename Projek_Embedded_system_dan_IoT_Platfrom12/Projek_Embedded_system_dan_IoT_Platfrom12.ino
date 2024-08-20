#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <DHT.h>
#include <addons/RTDBHelper.h>
#include <addons/TokenHelper.h>
#include <Servo.h>

Servo myservo;  // create servo object to control a servo

#define ssid ""  //WiFi SSID
#define password ""  //WiFi Password
#define FIREBASE_HOST ""       //Firebase Project URL Remove "https:" , "\" and "/"
#define FIREBASE_AUTH ""      //Firebase Auth Token

FirebaseData fbdo; //fbdo adalah variabel.
FirebaseConfig config; 

#define SOUND_VELOCITY 0.034
#define CM_TO_INCH 0.393701
#define DHTTYPE DHT11

// mendefinisikan pin yang digunakan adalah pin Digital
#define DHTPIN D7
#define PinDigital D2 

int NilaiDigital;
int Power;
bool PowerF;
bool PowerL;
float Temp;
float Hump;
const int trigPin = D6;
const int echoPin = D5;

//define sound velocity in cm/uS

long duration;
float distanceCm;
float distanceInch;
int pos = 0;

unsigned long sendDataPrevMillis = 0;
unsigned long sendDataUSMillis = 0;
unsigned long sendDataLOMillis = 0;

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  pinMode(PinDigital, OUTPUT);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  myservo.attach(D8);  // attaches the servo on pin 9 to the servo object

  WiFi.begin(ssid, password);
  Serial.print(F("Menghubungkan Wi-Fi"));
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("terhubung dengan WiFi IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  config.token_status_callback = tokenStatusCallback;
  
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  Firebase.setFloatDigits(5);
  Firebase.setDoubleDigits(5);

  
}

void loop() {
if (Firebase.ready() && (millis() - sendDataPrevMillis >= 5000 || sendDataPrevMillis == 0))
{
  sendDataPrevMillis = millis();

  NilaiDigital = 0; // membaca nilai digital
  Hump = dht.readHumidity();
  Temp = dht.readTemperature();

  if(Firebase.RTDB.getInt(&fbdo, "/Switch")){
    if(fbdo.dataType() =  "int"){
      Power = fbdo.intData();      
    }
  }
  
  if(Firebase.RTDB.getBool(&fbdo, "/ESP32_DEVICE/SwitchFan")){
    if(fbdo.dataType() =  "boolean"){
      PowerF = fbdo.boolData();      
    }
  }

  if(Firebase.RTDB.getBool(&fbdo, "/ESP32_DEVICE/SwitchLed")){
    if(fbdo.dataType() =  "boolean"){
      PowerL = fbdo.boolData();      
    }
  }
  Serial.println(Power);
  Serial.println(PowerF);
  Serial.println(PowerL);  

  Serial.print(F("Nilai Output Digital = "));
  Serial.println(NilaiDigital);

  //Proses Kirim Data
  if (Power == 1) {
      Firebase.setString(fbdo, "/System", "ON");
      trigger();
      logic();
      aircheck();   
      Firebase.setInt(fbdo, "/ESP32_DEVICE/Touch", NilaiDigital);
      Firebase.setFloat(fbdo, "/ESP32_DEVICE/Humidity", Hump);
      Firebase.setFloat(fbdo, "/ESP32_DEVICE/Temperature", Temp);
      Serial.print(F("Jarak: "));
      Serial.print(distanceCm);
      Serial.print (F(" cm"));
      Serial.print(F("\nHumidity: "));
      Serial.print(Hump);
      Serial.print (F(" %"));
      Serial.print(F("\nTemperature: "));
      Serial.print(Temp);
      Serial.print (F(" %"));
      Serial.println (" ");
      }
  else{
      NilaiDigital = 0;
      distanceCm = 0;
      Hump = 0;
      Temp = 0;
      Firebase.setString(fbdo, "/System", "OFF");
      Firebase.setInt(fbdo, "/ESP32_DEVICE/Touch", NilaiDigital);
      Firebase.setFloat(fbdo, "/ESP32_DEVICE/Distance", distanceCm);
      Firebase.setFloat(fbdo, "/ESP32_DEVICE/Humidity", Hump);
      Firebase.setFloat(fbdo, "/ESP32_DEVICE/Temperature", Temp);
      Serial.println(F("SYSTEM OFF"));
      fancek();
      lightcek();
      }
  }
}

void logic() {
  if (distanceCm <= 20) {
      digitalWrite(PinDigital, HIGH);
      Firebase.setBool(fbdo, "/ESP32_DEVICE/SwitchLed", true);
    Serial.println(F("Ada orang!!!"));
  }

  else if (( distanceCm > 20 ) && ( distanceCm < 90)) {

      digitalWrite(PinDigital, LOW);
      Firebase.setBool(fbdo, "/ESP32_DEVICE/SwitchLed", false);
    Serial.println (F("Hanya orang lewat"));

  }

  else if ( distanceCm >= 80) {

      digitalWrite(PinDigital, LOW);
      Firebase.setBool(fbdo, "/ESP32_DEVICE/SwitchLed", false);
    Serial.println (F("Tidak ada orang"));
  }
}

void aircheck(){
  if(Hump >=  65 || Temp >= 32){
    Firebase.setBool(fbdo, "/ESP32_DEVICE/SwitchFan", true);
    PowerF = true;
    for (pos = 0; pos <= 180; pos += 1) {
    myservo.write(pos);              
    delay(10);                       
    }
    for (pos = 180; pos >= 0; pos -= 1) { 
    myservo.write(pos);              
    delay(10);                       
    }
    Serial.println(F("Kipas Nyala"));
  }

  else if(Hump < 65 || Temp < 32){
      PowerF = false;
      Firebase.setBool(fbdo, "/ESP32_DEVICE/SwitchFan", false);
      Serial.println(F("Kipas Mati"));    
  }
}

void fancek(){
  if(PowerF == true){
    for (pos = 0; pos <= 180; pos += 1) { 
    myservo.write(pos);              
    delay(15);                       
    }
    for (pos = 180; pos >= 0; pos -= 1) { 
    myservo.write(pos);              
    delay(15);                       
    }
    Serial.println(F("Kipas Nyala"));
  }
  else{
    PowerF = false;
    Firebase.setBool(fbdo, "/ESP32_DEVICE/SwitchFan", false);
    Serial.println(F("Kipas Mati"));
  }
}

void lightcek(){
  if(PowerL == true){
  digitalWrite(PinDigital, HIGH);
  Serial.println(F("Lampu Nyala"));
  
  }else{
    Firebase.setBool(fbdo, "/ESP32_DEVICE/SwitchLed", false);
    PowerL = false;
    digitalWrite(PinDigital, LOW);
    Serial.println(F("Lampu Mati"));
  }
}


void trigger() {
  // Clears the trigPin
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);
  
  // Calculate the distance
  distanceCm = duration * SOUND_VELOCITY/2;
  
  // Convert to inches
  distanceInch = distanceCm * CM_TO_INCH;
  
  // Prints the distance on the Serial Monitor
  Serial.print(F("Distance (cm): "));
  Serial.println(distanceCm);
  Firebase.setFloat(fbdo, "/ESP32_DEVICE/Distance", distanceCm);
  Serial.print(F("Distance (inch): "));
  Serial.println(distanceInch);
}
