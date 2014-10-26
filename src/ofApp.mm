#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){	

    ofSetVerticalSync(true);
    
#ifndef USE_SIMULATOR
    
// TODO: write camera code
    camera.setDeviceID(1);
    camera.initGrabber(ofGetWidth(), ofGetHeight());
    
    
#else
    
    camera.loadImage("mask4.jpg");

    if(camera.getWidth() > camera.getHeight()){
    
        camera.resize(ofGetWidth(), camera.getHeight()*ofGetWidth() /camera.getWidth());
    }
    else{
    
        camera.resize(camera.getWidth()*ofGetHeight()/camera.getHeight(), ofGetHeight());
        
    }
    
#endif
    
    ofFbo::Settings settings;
    settings.width = camera.getWidth();
    settings.height= camera.getHeight();
    maskFbo.allocate(settings);
    cameraFbo.allocate(settings);
    
    cameraFaceTracker.setup();
    maskFaceTracker.setup();
    
    clone.setup(camera.getWidth(), camera.getHeight());
    cloneReady = false;
    
    maskImage.loadImage("mask4.jpg");
    
    if(maskImage.getWidth() > 0){
    
        maskFaceTracker.update(ofxCv::toCv(maskImage));
        maskPoints = maskFaceTracker.getImagePoints();
        
    }
    
    bTakenPhoto = false;
    
    
}

//--------------------------------------------------------------
void ofApp::update(){

#ifndef USE_SIMULATOR

    if(!bTakenPhoto){
    
        camera.update();
        
    }

#endif

}

//--------------------------------------------------------------
void ofApp::draw(){
	
    
    if(!bTakenPhoto){
        
        ofPushMatrix();
        
        ofTranslate(ofGetWidth()/2. - cameraFbo.getWidth()/2., ofGetHeight()/2. - cameraFbo.getHeight()/2.);

        
        camera.draw(0, 0);
        

        ofPopMatrix();
        
    }
    else if(bTakenPhoto && cameraFaceTracker.getFound() && maskFaceTracker.getFound()){

        ofPushMatrix();

        
        
        ofTranslate(ofGetWidth()/2. - cameraFbo.getWidth()/2., ofGetHeight()/2. - cameraFbo.getHeight()/2.);
        
        clone.draw(0, 0);
        //clone.srcBlur.draw(0, 0);
        
        ofPopMatrix();
        
    }
    else{
    
        ofPushMatrix();
        
        ofTranslate(ofGetWidth()/2. - cameraFbo.getWidth()/2., ofGetHeight()/2. - cameraFbo.getHeight()/2.);
        
        camera.draw(0, 0);
        
        ofPopMatrix();
        
        
        ofDrawBitmapString("can not find faces...", ofPoint(10, 10));
        
    }

    
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

    if(bTakenPhoto){
    
        bTakenPhoto = !bTakenPhoto;
        
    }
    else{
        bTakenPhoto = !bTakenPhoto;
        
        maskTakenPhoto();
    }
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}

void ofApp::maskTakenPhoto(){
    
#ifndef USE_SIMULATOR
    ofImage tmp;
    tmp.setFromPixels(camera.getPixels(), camera.getWidth(), camera.getHeight(), OF_IMAGE_COLOR);
    
    cameraFaceTracker.update(ofxCv::toCv(tmp));

#else
    
    cameraFaceTracker.update(ofxCv::toCv(camera));
    
#endif

    
    cloneReady = cameraFaceTracker.getFound();
    
    if(cloneReady){
    
        ofMesh cameraMesh = cameraFaceTracker.getImageMesh();
        cameraMesh.clearTexCoords();
        cameraMesh.addTexCoords(maskPoints);
        for(int i=0; i< cameraMesh.getTexCoords().size(); i++) {
            ofVec2f & texCoord = cameraMesh.getTexCoords()[i];
            texCoord.x /= ofNextPow2(maskImage.getWidth());
            texCoord.y /= ofNextPow2(maskImage.getHeight());
        }
        
        maskFbo.begin();
        ofClear(0, 255);
        cameraMesh.draw();
        maskFbo.end();
        
        cameraFbo.begin();
        ofClear(0, 255);
        camera.getTextureReference().bind();
        maskImage.bind();
        cameraMesh.draw();
        maskImage.unbind();
        cameraFbo.end();
        
        clone.setStrength(16);
        clone.update(cameraFbo.getTextureReference(), camera.getTextureReference(), maskFbo.getTextureReference());
        
        
        
        
    }

}


