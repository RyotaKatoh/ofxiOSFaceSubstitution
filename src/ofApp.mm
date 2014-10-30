#include "ofApp.h"

#include "FaceSubstitutionViewController.h"

// this is gui view controller
FaceSubstitutionViewController *guiViewController;


//--------------------------------------------------------------
void ofApp::setup(){	

    ofSetVerticalSync(true);
    
    
    // gui set up
    guiViewController = [[FaceSubstitutionViewController alloc]initWithNibName:@"FaceSubstitutionViewController" bundle:nil];
    [ofxiOSGetGLParentView() addSubview:guiViewController.view];
    
    
    
#ifndef USE_SIMULATOR
    
// TODO: write camera code
    camera.setDeviceID(1);
    camera.initGrabber(ofGetWidth(), ofGetHeight());
    
    
#else
    
    camera.loadImage("mask5.jpg");
    camera.rotate90(45);

    if(camera.getWidth() > camera.getHeight()){
    
        camera.resize(ofGetWidth(), camera.getHeight()*ofGetWidth() /camera.getWidth());
    }
    else{
    
        camera.resize(camera.getWidth()*ofGetHeight()/camera.getHeight(), ofGetHeight());
        
    }
    
#endif
    
//    ofFbo::Settings settings;
//    settings.width = camera.getWidth();
//    settings.height= camera.getHeight();
//    maskFbo.allocate(settings);
//    cameraFbo.allocate(settings);
//    
    cameraFaceTracker.setup();
    maskFaceTracker.setup();
    
//    clone.setup(camera.getWidth(), camera.getHeight());
    cloneReady = false;
    
    maskImage.loadImage("Laura.jpg");
    
    if(maskImage.getWidth() > 0){
    
        maskFaceTracker.update(ofxCv::toCv(maskImage));
        maskPoints = maskFaceTracker.getImagePoints();

        if(!maskFaceTracker.getFound()){
            
            cout<<"please select good mask image."<<endl;
            
        }
    }

    
    bTakenPhoto = false;
    
    
    myScene = ready;
    
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
	

    if(myScene == ready){
    
        // TODO: write some ready code.
        
        ofPushStyle();
        
        ofSetColor(0, 0, 0);
        ofDrawBitmapString("unknown camera", ofGetWidth()/2., ofGetHeight()/2.);
        
        ofPopStyle();
        
        
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

void ofApp::maskTakenPhoto(ofImage &input){

    // change image type. OF_IMAGE_COLOR_ALPHA => OF_IMAGE_COLOR
    
    if(input.type == OF_IMAGE_COLOR_ALPHA){
    
        input.setImageType(OF_IMAGE_COLOR);
        
    }
    
    // resize input image.
    if(input.getWidth() > input.getHeight()){
        
        input.resize(ofGetWidth(), input.getHeight()*ofGetWidth() /input.getWidth());
    }
    else{
        
        input.resize(input.getWidth()*ofGetHeight()/input.getHeight(), ofGetHeight());
        
    }
    
    
    // set mask Fbo
    ofFbo::Settings settings;
    settings.width = input.getWidth();
    settings.height= input.getHeight();
    maskFbo.allocate(settings);
    cameraFbo.allocate(settings);
    
    clone.setup(input.getWidth(), input.getHeight());

    
    cameraFaceTracker.update(ofxCv::toCv(input));
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
        input.getTextureReference().bind();
        maskImage.bind();
        cameraMesh.draw();
        maskImage.unbind();
        cameraFbo.end();
        
        clone.setStrength(16);
        clone.update(cameraFbo.getTextureReference(), input.getTextureReference(), maskFbo.getTextureReference());
        
        
        ofPixels pixels;
        clone.buffer.readToPixels(pixels);
        maskedImage.setFromPixels(pixels);
        maskedImage.update();
        
        
        myScene = preview;
        
    }
    else{
    
        maskedImage = input;
        
    }
        
}
