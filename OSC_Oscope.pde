/* 
 OSC Oscilliscope display
 Original code taken from https://forum.processing.org/two/discussion/1129/simple-oscilloscope
 Original credit for code to user Oolong
 Modified by Michael King (hybridsix) 11/2016
 Modified by David Sikes (pockybum522) 09/2017
 */

import processing.io.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;

Mixer.Info[] mixerInfo;

Minim minim_out_spkrs;
Minim minim_out_loopback;

Minim minim_in_loopback;
Minim minim_in_mic;

AudioInput in_loop;
AudioInput in_mic;

AudioOutput out_loopback;
AudioOutput out_speakers;

Sampler [] tone_spk = new Sampler[4];
Sampler [] tone_loop = new Sampler[4];

int buttonOnePin = 19;
int buttonTwoPin = 5;
int buttonThreePin = 6;
int buttonFourPin = 13;
int buttonMicPin = 26;

boolean buttonOneFired = false;
boolean buttonTwoFired = false;
boolean buttonThreeFired = false;
boolean buttonFourFired = false;
boolean buttonMicFired = false;
boolean showingSomething = false;

int width = 1366;
int height = 768;

void setup() {
  fullScreen();
  
  // We need two outputs and two inputs because one is loopback.

  minim_out_spkrs = new Minim(this);
  minim_out_loopback = new Minim(this);
  
  minim_in_loopback = new Minim(this);
  minim_in_mic = new Minim(this);

  mixerInfo = AudioSystem.getMixerInfo();
  
  // This dumps the mixer names and numbers to the console for debugging
  for(int i = 0; i < mixerInfo.length; i++){
    print(i);
    print(" - ");
    println(mixerInfo[i].getName());
  } 
  
  tone_spk[0] = new Sampler("sounds/300hz_10s.mp3", 4, minim_out_spkrs);
  tone_spk[1] = new Sampler("sounds/600hz_10s.mp3", 4, minim_out_spkrs);
  tone_spk[2] = new Sampler("sounds/900hz_10s.mp3", 4, minim_out_spkrs);
  tone_spk[3] = new Sampler("sounds/1200hz_10s.mp3", 4, minim_out_spkrs);
  
  // Patched into the loopback for visualization
  tone_loop[0] = new Sampler("sounds/300hz_10s.mp3", 4, minim_out_loopback);
  tone_loop[1] = new Sampler("sounds/600hz_10s.mp3", 4, minim_out_loopback);
  tone_loop[2] = new Sampler("sounds/900hz_10s.mp3", 4, minim_out_loopback);
  tone_loop[3] = new Sampler("sounds/1200hz_10s.mp3", 4, minim_out_loopback);
  
  // Original: Mixer mixer2 = AudioSystem.getMixer(mixerInfo[3]); // This is all for using the usb sound card
  Mixer mixer_loopback = AudioSystem.getMixer(mixerInfo[4]); // Testing
  Mixer mixer_speakers = AudioSystem.getMixer(mixerInfo[3]);
  
  minim_out_spkrs.setOutputMixer(mixer_speakers);
  minim_out_loopback.setOutputMixer(mixer_loopback);

  out_speakers = minim_out_spkrs.getLineOut();
  out_loopback = minim_out_loopback.getLineOut();
  out_loopback.setGain(-10);  // Otherwise it's too big on the screen
  
  // More patching for loopback and actual speakers both
  tone_loop[0].patch(out_loopback);
  tone_loop[1].patch(out_loopback);
  tone_loop[2].patch(out_loopback);
  tone_loop[3].patch(out_loopback);
  
  tone_spk[0].patch(out_speakers);
  tone_spk[1].patch(out_speakers);
  tone_spk[2].patch(out_speakers);
  tone_spk[3].patch(out_speakers);

  Mixer mixer_in_loop = AudioSystem.getMixer(mixerInfo[5]);
  minim_in_loopback.setInputMixer(mixer_in_loop);
  
  Mixer mixer_in_mic = AudioSystem.getMixer(mixerInfo[0]);
  minim_in_mic.setInputMixer(mixer_in_mic);
  
  // use the getLinein_loopmethod of the Minim object to get an AudioInput
  in_loop = minim_in_loopback.getLineIn(Minim.MONO, 2048);
  in_mic = minim_in_mic.getLineIn(Minim.MONO, 2048);
  //println (in.bufferSize());

  background(0);

  GPIO.pinMode(buttonOnePin, GPIO.INPUT);
  GPIO.pinMode(buttonTwoPin, GPIO.INPUT);
  GPIO.pinMode(buttonThreePin, GPIO.INPUT);
  GPIO.pinMode(buttonFourPin, GPIO.INPUT);
  GPIO.pinMode(buttonMicPin, GPIO.INPUT);
}

void draw() {  
  // ---------------=================== Button handlers ===================----------------- 
  if (GPIO.digitalRead(buttonOnePin) == GPIO.HIGH) {
    if (!buttonOneFired) {
      println("ButtonOne firing!");
      buttonOneFired = true;
      tone_loop[0].trigger();
      tone_spk[0].trigger();
    }
  } else {
    if (buttonOneFired) {
      println("Button one released!");
      buttonOneFired = false;
      tone_loop[0].stop();
      tone_spk[0].stop();
    }
  } 

  if (GPIO.digitalRead(buttonTwoPin) == GPIO.HIGH) {
    if (!buttonTwoFired) {
      println("ButtonTwo firing!");
      buttonTwoFired = true;
      tone_spk[1].trigger();
      tone_loop[1].trigger();
    }
  } else {
    if (buttonTwoFired) {
      println("ButtonTwo released!");
      buttonTwoFired = false;
      tone_spk[1].stop();
      tone_loop[1].stop();
    }
  }

  if (GPIO.digitalRead(buttonThreePin) == GPIO.HIGH) {
    if (!buttonThreeFired) {
      println("ButtonThree firing!");
      buttonThreeFired = true;
      tone_spk[2].trigger();
      tone_loop[2].trigger();
    }
  } else {
    if (buttonThreeFired) {
      println("ButtonThree released!");
      buttonThreeFired = false;
      tone_spk[2].stop();
      tone_loop[2].stop();
    }
  } 

  if (GPIO.digitalRead(buttonFourPin) == GPIO.HIGH) {
    if (!buttonFourFired) {
      println("ButtonFour firing!");
      buttonFourFired = true;
      tone_spk[3].trigger();
      tone_loop[3].trigger();
    }
  } else {
    if (buttonFourFired) {
      println("ButtonFour released!");
      buttonFourFired = false;
      tone_spk[3].stop();
      tone_loop[3].stop();
    }
  } 

  if (GPIO.digitalRead(buttonMicPin) == GPIO.HIGH) {
    if (!buttonMicFired) {
      println("ButtonMic firing!");
      buttonMicFired = true;
    }
  } else {
    if (buttonMicFired) {
      println("ButtonMic released!");
      buttonMicFired = false;
    }
  } 
// ------------=================== END BUTTON HANDLERS ====================----------------

  fill (0, 0, 32, 255);
  rect (0, 0, width, height);
  stroke (32);

  // this draws the intermediary grid lines
  for (int i = 0; i < width / 70; i++) { 
    line (0, i * 75, width, i * 75);
    line (i * 75 + 25, 0, i * 75 + 25, height); //
  }

  stroke (0);
  line (width / 2, 0, width / 2, height);
  line (0, height / 2, width, height / 2);
  stroke (64, 255, 64);
  int crossing = 0;
  
  if (buttonMicFired){
    // draw the waveforms so we can see what we are monitoring
    for (int i = 0; i < in_mic.bufferSize() - 1 && i < width + crossing; i++) {
      if (crossing == 0 && in_mic.left.get(i) < 0 && in_mic.left.get(i + 1) > 0) crossing = i;
      if (crossing != 0) {
        line(i - crossing, height / 2 + in_mic.left.get(i) * 540, i + 1 - crossing, height / 2 + in_mic.left.get(i + 1) * 540 );
      }
    }
  }
  
  if (!buttonMicFired){
    if (buttonOneFired || buttonTwoFired || buttonThreeFired || buttonFourFired || buttonMicFired){ 
      // draw the waveforms so we can see what we are monitoring
      for (int i = 0; i < in_loop.bufferSize() - 1 && i < width + crossing; i++) {
        if (crossing == 0 && in_loop.left.get(i) < 0 && in_loop.left.get(i + 1) > 0) crossing = i;
        if (crossing != 0) {
          line(i - crossing, height / 2 + in_loop.left.get(i) * 540, i + 1 - crossing, height / 2 + in_loop.left.get(i + 1) * 540 );
        }
      }
    } else { // If no buttons are being pressed.
      for (int i = 0; i < width + crossing; i++) {
        if (crossing == 0) crossing = i;
        if (crossing != 0) {
          line(i - crossing, height / 2, i + 1 - crossing, height / 2);
        }
      }
    }
  }
}
