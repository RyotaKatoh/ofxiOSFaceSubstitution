#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"

#include "ofxOpenCv.h"

#include "ofxCv.h"
#include "ofxFaceTracker.h"
#include "Clone.h"

//#define USE_SIMULATOR

class ofApp : public ofxiOSApp {
	
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void maskTakenPhoto();
    ofIndexType convertVertexIndexForMouthMesh(ofIndexType faceTrackerVertexIndes);
    
#ifndef USE_SIMULATOR
    ofVideoGrabber  camera;

#else
    ofImage         camera;
#endif
    ofImage         maskImage;
    
    ofFbo           cameraFbo;
    ofFbo           maskFbo;
    
    ofxFaceTracker  cameraFaceTracker;
    ofxFaceTracker  maskFaceTracker;
    
    vector<ofVec2f> maskPoints;
    
    bool            bTakenPhoto;
    bool            cloneReady;
    
    Clone           clone;

};


