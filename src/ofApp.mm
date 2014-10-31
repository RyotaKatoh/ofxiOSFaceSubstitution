#include "ofApp.h"

#include "ofxJSONElement.h"

#include "FaceSubstitutionViewController.h"

// this is gui view controller
FaceSubstitutionViewController *guiViewController;


//--------------------------------------------------------------
void ofApp::setup(){	

    ofSetVerticalSync(true);
    ofBackground(0, 0, 0);
    
    // gui set up
    guiViewController = [[FaceSubstitutionViewController alloc]initWithNibName:@"FaceSubstitutionViewController" bundle:nil];
    [ofxiOSGetGLParentView() addSubview:guiViewController.view];
    
    
    // json setting
    ofxJSONElement response;
    string url = "http://ryotakatoh.com/unknowncamera/getNumImages.cgi";
    if(!response.open(url)){
        
        cout<<"can not connect to the web server"<<endl;
        
    }
    else{
    
        numMaskImages = response["numImages"].asInt();
    
    }
    
    

    
    camera.loadImage("mask3.jpg");
//    camera.rotate90(45);

    if(camera.getWidth() > camera.getHeight()){
    
        camera.resize(ofGetWidth(), camera.getHeight()*ofGetWidth() /camera.getWidth());
    }
    else{
    
        camera.resize(camera.getWidth()*ofGetHeight()/camera.getHeight(), ofGetHeight());
        
    }
    
    
  
    cameraFaceTracker.setup();
    maskFaceTracker.setup();
    
    

    cloneReady = false;
    
    
    
    bTakenPhoto = false;
    
    myScene = ready;
    
    
    // this is for ready screen.
    ofxTextParticle unknownTitle;
    unknownTitle.setup("Unknown", ofPoint(ofGetWidth()/2., ofGetHeight()/7.));
    titles.push_back(unknownTitle);
    
    ofxTextParticle cameraTitle;
    cameraTitle.setup("Camera", ofPoint(ofGetWidth()/2., ofGetHeight()*2/7.));
    titles.push_back(cameraTitle);
    
    font.loadFont("font/Arial Black.ttf", 18);
    
    // for titleMesh
    maskFaceTracker.update(ofxCv::toCv(camera));
    originalTitleMesh = maskFaceTracker.getImageMesh();
    
    for(int i=0;i<originalTitleMesh.getVertices().size();i++){
    
        titleMesh.addVertex(originalTitleMesh.getVertices()[i]);
        
        
    }
    for(int i=0;i<originalTitleMesh.getIndices().size()/3;i++){
    
        if(ofRandom(1.0) < 0.3){
        
            titleMesh.addIndex(originalTitleMesh.getIndices()[i*3]);
            titleMesh.addIndex(originalTitleMesh.getIndices()[i*3+1]);
            titleMesh.addIndex(originalTitleMesh.getIndices()[i*3+2]);
            
        }
        
    }

    
}

//--------------------------------------------------------------
void ofApp::update(){

    if(myScene == ready){
    
        changeMesh();
        
    }

}

//--------------------------------------------------------------
void ofApp::draw(){
	

    if(myScene == ready){
    
        // TODO: write some ready code.
        
        // title
        for(int i=0;i<titles.size();i++)
            titles[i].noiseDraw();
        
        
        // titileMesh
        ofPushMatrix();
        
        ofTranslate(ofGetWidth()/2. - camera.getWidth()+10, ofGetHeight()/2. - camera.getHeight()+ 50);
        
        ofScale(2.0, 2.0);
                
        titleMesh.draw();
        
        ofPopMatrix();
        
        
        // start string
        ofPushStyle();
        
        ofSetColor(255, 255, 255, 255*abs(sin(ofGetFrameNum()*0.05)));
        string tapToStart = "tap to start";
        font.drawString(tapToStart, ofGetWidth()/2. - font.stringWidth(tapToStart)/2., ofGetHeight()*5/7 - font.stringHeight(tapToStart)/2. +100);
        
        ofPopStyle();
        
        

    }

    

    
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){

    changeMesh();
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

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


void ofApp::maskTakenPhoto(ofImage &input){

    setMaskFaceTraker();
    
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
        
        clone.setStrength(12);
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

void ofApp::setMaskFaceTraker(){
    
    if(maskImage.isAllocated())
        maskImage.clear();
    if(maskPoints.size() > 0)
        maskPoints.clear();
    maskFaceTracker.setup();
    
    // set mask Image
    int maskNo = ofRandom(numMaskImages);
    string url = "http://ryotakatoh.com/unknowncamera/MaskImages/"+ofToString(maskNo)+".jpg";
    maskImage.loadImage(url);
    
    if(!maskImage.isAllocated()){
        
        maskNo = ofRandom(STORED_IMAGES);
        url = "mask" + ofToString(maskNo) + ".jpg";
        maskImage.loadImage(url);
        
    }
    
    // setup maskFaceTracker
    if(maskImage.getWidth() > 0){
        
        maskFaceTracker.update(ofxCv::toCv(maskImage));
        maskPoints = maskFaceTracker.getImagePoints();
        
        if(!maskFaceTracker.getFound()){
            
            //cout<<"please select good mask image."<<endl;
            setMaskFaceTraker();
            
        }
    }
    
    
}

void ofApp::maskTakenPhotoforDebug(ofImage &input){

    setMaskTrackerforDebug();
    
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

void ofApp::setMaskTrackerforDebug(){

    if(maskImage.isAllocated())
        maskImage.clear();
    if(maskPoints.size() > 0)
        maskPoints.clear();
    maskFaceTracker.setup();
    
    // set mask Image
    static int debugMuskNo = 0;
    
    string url = "http://ryotakatoh.com/unknowncamera/MaskImages/"+ofToString(debugMuskNo)+".jpg";
    maskImage.loadImage(url);
    
    cout<<debugMuskNo<<endl;
    debugMuskNo ++;
    if(debugMuskNo > numMaskImages)
        debugMuskNo = 0;
    
    // setup maskFaceTracker
    if(maskImage.getWidth() > 0){
        
        maskFaceTracker.update(ofxCv::toCv(maskImage));
        maskPoints = maskFaceTracker.getImagePoints();
        
        if(!maskFaceTracker.getFound()){
            
            //cout<<"please select good mask image."<<endl;
            
        }
    }
    
}

#pragma mark - titleMesh

void ofApp::changeMesh(){

    titleMesh.clear();

    
    for (int i=0; i<originalTitleMesh.getVertices().size(); i++) {
        
        titleMesh.addVertex(originalTitleMesh.getVertices()[i]);
        
    }
    for(int i=0;i<originalTitleMesh.getIndices().size()/3;i++){
        
        if(ofRandom(1.0) < 0.3){

            
            titleMesh.addIndex(originalTitleMesh.getIndices()[i*3]);
            titleMesh.addIndex(originalTitleMesh.getIndices()[i*3+1]);
            titleMesh.addIndex(originalTitleMesh.getIndices()[i*3+2]);
        }
    }
    

    
}