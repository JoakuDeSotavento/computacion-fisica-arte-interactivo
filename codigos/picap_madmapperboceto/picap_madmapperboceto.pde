/***************************

 Bare Conductive projection mapping sletch for Pi Cap and MadMapper
 -------------------------------------------------------------------------------

picap_madmapper.pde - sketch to communicate between Pi Cap and MadMaper

 Requires Processing 3.0+

 Requires osc5 (version 0.9.8+) to be in your processing libraries folder:
 http://www.sojamo.de/libraries/oscP5/

 Bare Conductive code written by Pascal Loose.

 This work is licensed under a MIT license https://opensource.org/licenses/MIT

 Copyright (c) 2017, Bare Conductive

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

***************************/

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress madMapper;
NetAddress touchDesigner, touchDesigner2;
int value = 0;

//aqui cambiar el numero dependiendo cuantos videos tengas
int numElectrodes  = 9;
int[] status, lastStatus;
String[] mediasList = new String [numElectrodes];

void updateArrayOSC(int[] array, Object[] data) {
  if (array == null || data == null) {
    return;
  }

  for (int i = 0; i < min(array.length, data.length); i++) {
    array[i] = (int)data[i];
  }
}

void setup() {
  // setup OSC receiver on port 3000
  oscP5 = new OscP5(this, 3000);
  madMapper = new NetAddress("127.0.0.1", 8010);
  touchDesigner = new NetAddress("192.168.43.249", 7000);
  touchDesigner2 = new NetAddress("127.0.0.1", 6000);

  
  status            = new int[numElectrodes];
  lastStatus        = new int[numElectrodes];
  
  // aqui agregar las animaciones
  mediasList[0] = "R1_1.mp4";
  mediasList[1] = "R2.mp4";
  mediasList[2] = "R3.mp4";
  mediasList[3] = "R4.mp4";
  mediasList[4] = "R6.mp4";
  mediasList[5] = "R7.mp4";
  mediasList[6] = "R8.mp4";
  mediasList[7] = "R9.mp4";
  mediasList[8] = "R10.mp4";
 
}

void oscEvent(OscMessage oscMessage) {
    if (oscMessage.checkAddrPattern("/touch")) {
      updateArrayOSC(status, oscMessage.arguments());
    }
    
    for (int i = 0; i < numElectrodes; i++) {
      if (lastStatus[i] == 0 && status[i] == 1) {
        // touched
        println("Electrode " + i + " was touched");
        lastStatus[i] = 1;
        sendMMMessage(true, i);
      } 
      else if(lastStatus[i] == 1 && status[i] == 0) {
        // released
        println("Electrode " + i + " was released");
        lastStatus[i] = 0;
        sendMMMessage(false, i);
      }
    }
}

void sendMMMessage(boolean begin, int electrode) {
  OscMessage msg = new OscMessage("/medias/" + mediasList[electrode] + "/restart");
  msg.add(begin);
  
  // send it to MadMapper
  oscP5.send(msg, madMapper);
  oscP5.send(msg, touchDesigner);
  oscP5.send(msg, touchDesigner2);
  
  println(msg);
}
