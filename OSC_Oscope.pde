/* OSC Oscilliscope display
Original code taken from https://forum.processing.org/two/discussion/1129/simple-oscilloscope
Original credit for code to user Oolong
Modified by Michael King (hybridsix) 11/2016

*/


import ddf.minim.*;
 
Minim minim;
AudioInput in;

int width = 1920;
int height = 1080;

void setup()
{
  //size(1280, 720, P3D);
 fullScreen();
  minim = new Minim(this);
 
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn(Minim.MONO, 2048);
  println (in.bufferSize());
  // uncomment this line to *hear* what is being monitored, in addition to seeing it
  //in.enableMonitoring();
  background(0);
}
 
void draw()
{
  //background(0);
  fill (0, 0, 32, 255);
  rect (0, 0, width, height);
  stroke (32);
  for (int i = 0; i < 26 ; i++){ /// this draws the intermediary grid lines
    line (0, i*75, width, i*75);
    line (i*75+25, 0, i*75+25, height); //
  }
  stroke (0);
  line (width/2, 0, width/2, height);
  line (0, height/2, width, height/2);
  stroke (64,255,64);
  int crossing=0;
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < in.bufferSize() - 1 && i<width+crossing; i++)
  {
    if (crossing==0&&in.left.get(i)<0&&in.left.get(i+1)>0) crossing=i;
    if (crossing!=0){
      line( i-crossing, height/2 + in.left.get(i)*540, i+1-crossing, height/2 + in.left.get(i+1)*540 );
    }
  }
}