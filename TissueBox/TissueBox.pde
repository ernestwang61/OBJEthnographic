//  serial connection ref:
//  http://coopermaa2nd.blogspot.tw/2011/03/processing-arduino.html

import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;

Serial myPort;

int state;

Minim minim;

FilePlayer player;


// for recording
AudioInput in;
AudioRecorder recorder;
boolean recorded;

// for playing back
AudioOutput out;

Mixer.Info[] mixerInfo;

// for timer
Timer downTimer = new Timer(150*1000);

String AudioLayer1;
String initialSound = "Tweeter.wav";
String newAudio = "Tweeter.wav";

String[] recordName = new String[100]; 
//[TODO] try StringList: https://processing.org/reference/StringList.html
// or expand(): https://processing.org/reference/expand_.html

int recordCount;
String[] preRecordList = {"HEBE_my_love.mp3", "Sodagreen.mp3", "The_Fray.mp3"};
JSONArray RecordList;




void setup(){
  size(512, 200, P3D);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn(Minim.STEREO); // use the getLineIn method of the Minim object to get an AudioInput
  

  mixerInfo = AudioSystem.getMixerInfo();
  printArray(mixerInfo);
  Mixer mixer = AudioSystem.getMixer(mixerInfo[3]);// choose correspond sound output
  //minim.setOutputMixer(mixer);

  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  out = minim.getLineOut( Minim.STEREO );
  out.setGain(50);

  player = new FilePlayer( minim.loadFileStream( initialSound ));
  player.patch(out);
  player.play();

  recorder = minim.createRecorder(in, "test-recording.wav");

  textFont(createFont("Arial", 12));
  printArray(Serial.list());
  String portName = Serial.list()[2];// choose correspond port number
  myPort = new Serial(this, portName, 115200);

  RecordList = loadJSONArray("recordList.json");
  recordCount = RecordList.size();
  print("recordCount = ");
  println(recordCount);



}

void draw(){
  background(0);
  stroke(255);
  
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line( i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50 );
    line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
  }
  
  // in.enableMonitoring();

  String monitoringState = in.isMonitoring() ? "enabled" : "disabled";
  text( "Input monitoring is currently " + monitoringState + ".", 5, 15 );



  //show text if it's recording
  if ( recorder.isRecording() )
  {
    text("Now recording, press the r key to stop recording.", 5, 40);
  }
  // else if ( !recorded )
  // {
  //   text("Press the r key to start recording.", 5, 40);
  // }
  else
  {
    text("Press the s key to save the recording to disk.", 5, 40);
  }  

  getSerial();
  // setSTATE();
  if(downTimer.end()){
    key = 's';
    keyReleased();
  }

}




////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////




int serialIncome = -1;
void getSerial(){

  if( myPort.available() > 0) {
    serialIncome = myPort.read();
    if(millis() < 15000)
      return;
    print("serialIncome = ");
    println(serialIncome);


    setSTATE();

  
  }
}

int preIncome = 0;
long t = 0;
int recordLengh = 10000;
void setSTATE(){
  // if(preIncome == 3){
  //   long temp = millis();
  //   if(temp - t < recordLengh)
  //     return;
  //   t = temp;
  //   key = 's';
  //   keyReleased();
  //   preIncome = 4;
  // }
  //if(serialIncome == preIncome)
  if(false)  
    return;
  else{
    switch(serialIncome){
      case 3:

        println("receive record command");

        key = 'r';
        keyReleased();

        preIncome = 3;


        break;


      case 4:

        println("receive save command");

        key = 's';
        keyReleased();

        preIncome = 4;

        break;

      case 1:
        println("receive play command");

        key = 'p';
        keyReleased();

        preIncome = 1;

        break;
    }
  }

  print("preIncome = ");
  println(preIncome);
}

// void keyPressed(){
//   switch(key){
//     case 'm':
//       if ( in.isMonitoring() ){
//         in.disableMonitoring();
//       }
//       else{
//         in.enableMonitoring();
//       }
//       break;
      
//     case 'M':
//       if ( in.isMonitoring() ){
//         in.disableMonitoring();
//       }
//       else{
//         in.enableMonitoring();
//       }
//       break;
//     case '1':
//       println("userAudioLayer1 = " + userAudioLayer1);

//       if ( player.isPlaying() )
//       {
//         player.pause();
//       }
//   // if the player is at the end of the file,
//   // we have to rewind it before telling it to play again
//       else if ( player.position() == player.length() )
//       {
//         player.rewind();
//         player.play();
//       }
//       else
//       {
//         player.play();
//       }
//       break;
      
//     case '2':
//       println("userAudioLayer2 = " + userAudioLayer2);

//       if ( player2.isPlaying() )
//       {
//         player2.pause();
//       }
//       // if the player is at the end of the file,
//       // we have to rewind it before telling it to play again
//       else if ( player2.position() == player.length() )
//       {
//         player2.rewind();
//         player2.play();
//       }
//       else
//       {
//         player2.play();
//       }
//       break;
//   }
// }
  
int rY = 0;
int rM = 0;
int rD = 0;
int rh = 0;
int rm = 0;
String recordTitle;
JSONObject newRecording;
void keyReleased(){
  switch(key){
    case 'r':
      println("start recording");
      int Y = year();
      int M = month();
      int D = day();
      int h = hour();
      int m = minute();

      rY = Y;
      rM = M;
      rD = D;
      rh = h;
      rm = m;
      
      recordTitle= "recording" + rY + rM + rD + "_" + rh + "_" + rm + ".wav";

      newRecording = new JSONObject();
      
      int i = RecordList.size();
      newRecording.setInt("id", i);
      newRecording.setString("type", "in-field");
      newRecording.setString("file title", recordTitle);
      RecordList.setJSONObject(i, newRecording);
      saveJSONArray(RecordList, "data/recordList.json");

      recorder = minim.createRecorder(in, recordTitle);
      recorder.beginRecord();

      downTimer.start();

      break;

    case 's':
      // we've filled the file out buffer, 
      // now write it to a file of the type we specified in setup
      // in the case of buffered recording, 
      // this will appear to freeze the sketch for sometime, if the buffer is large
      // in the case of streamed recording, 
      // it will not freeze as the data is already in the file and all that is being done
      // is closing the file.
      // save returns the recorded audio in an AudioRecordingStream, 
      // which we can then play with a FilePlayer
      if ( recorder.isRecording() ){
        println("recording has been saved");
        recorder.endRecord();
        recorder.save();
        recordCount++;
      }
      break;

    case 'p':
      int preRecordNum = 5;
      int random_i;
      int random_choice = int(random(3)); //first randomly choose between preRecortding/inField-recording
      print("random_choice =");
      println(random_choice);
      //then randomly choose files within the category to play
      if(random_choice == 0 || RecordList.size() == preRecordNum)
        random_i = int(random(0, preRecordNum));
      else
        random_i = int(random(preRecordNum, RecordList.size()));
      
      JSONObject recording = RecordList.getJSONObject(random_i);
      int id = recording.getInt("id");
      String type = recording.getString("type");
      String file_title = recording.getString("file title"); 
      
      AudioLayer1 = file_title;

      println("start playing id:" + id + ", type:" + type + ", file_title:" + file_title);

      loadSoundFile();
      player.play();
      break;
  }
}  


void loadSoundFile(){
  
  player.unpatch(out);
  player.close();
  player = new FilePlayer(minim.loadFileStream(AudioLayer1));
  player.patch(out); 
}

void timer(){
  long temp = millis();
  if(temp - t < recordLengh)
    return;
  t = temp;
  key = 's';
  keyReleased();
  preIncome = 4;

}

class Timer {
  int startTime, countDown;
 
  Timer(int countDown) {
    this.countDown = countDown;
  }
 
  void start() {
    startTime = millis();
  }
 
  boolean end() {
    return (millis()-startTime>countDown);
  }
}







