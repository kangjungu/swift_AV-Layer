//
//  ImageLayerViewController.swift
//  TmapTest
//
//  Created by JHJG on 2016. 12. 4..
//  Copyright © 2016년 KangJungu. All rights reserved.
//

import UIKit
import AVFoundation


//자세히 다시 봐보기 카메라에 레이어 올리기 성공함
class ImageLayerViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var previewView:UIView!;
    var boxView:UIView!;
    
    
    //실시간으로 카메라 영상을 받아 오려면 먼저 AVCaptureSession 오브젝트를 만들고 이를 이용하면 카메라로부터 들어오는 이미지 데이터를 순차적으로 받을 수 있습니다.
    let session = AVCaptureSession();
    //이때 사용 되는것이 AVCaptureVideoDataOutput입니다. AVCaptureVideoDataOutput 오브젝트를 만들어서 캡쳐 세션에 추가를 합니다.
    var videoDataOutput: AVCaptureVideoDataOutput!;
    //디스패치 큐(Dispatch Queue)라는건 일종의 스레드 개념과 비슷하다. 클로져로 구성된 태스크(Task)를 이 큐(Queue)에다 등록하면 별도의 스레드에서 이 큐의 내용물을 뽑아서 해당 스레드에서 태스크를 구동시키게 해 주는 문 역할을 한다.
    var videoDataOutputQueue:DispatchQueue!;
    //AVCaptureVideoPreviewLayer는 입력 장치에서 캡처 한 비디오를 표시하는 데 사용하는 CALayer의 하위 클래스입니다
    var previewLayer:AVCaptureVideoPreviewLayer!;
    //AVCaptureDevice 객체는 물리적 캡처 장치와 해당 장치와 관련된 속성을 나타냅니다. 캡처 장치를 사용하여 기본 하드웨어의 속성을 구성합니다. 캡처 장치는 AVCaptureSession 객체에 입력 데이터 (예 : 오디오 또는 비디오)를 제공합니다.
    var captureDevice:AVCaptureDevice!;
    //코어 이미지 필터에 의해 처리되거나 생성 될 이미지의 표현.
    var currentFrame:CIImage!;
    var done = false;
    
    //ViewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height));
        self.previewView.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(previewView);
        
        //레이어로 올릴 뷰(화살표에 사용하면 될듯)
        self.boxView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2, width: 100, height: 200))
        self.boxView.backgroundColor = UIColor.green
        self.boxView.alpha = 0.3
        self.view.addSubview(self.boxView)
        
        self.setupAVCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //뷰 컨트롤러가 화면에 나타나기 직전에 실행됩니다
    override func viewWillAppear(_ animated: Bool) {
        print("♥️♥️♥️♥️♥️♥️♥️ viewWillAppear")
        if !done {
            session.startRunning();
        }
    }
    
    //회전 메서드가 자식 뷰 컨트롤러에 전달되는지 여부를 나타내는 부울 값을 반환합니다.
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
            UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
            UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            print("♥️♥️♥️♥️♥️♥️ shouldAutomaticallyForwardRotationMethods : false")
            return false;
        }
        else {
            print("♥️♥️♥️♥️♥️♥️ shouldAutomaticallyForwardRotationMethods : true")
            return true;
        }
        
    }
    
    
    // AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods start
    
    //AVCapture 초기화
    func setupAVCapture(){
        print("♥️♥️♥️♥️♥️ setupAVCapture")
        //sessionPreset 속성을 사용하여 출력의 품질 수준, 비트 전송률 또는 기타 설정을 사용자 정의합니다. 가장 일반적인 캡처 구성은 세션 사전 설정을 통해 사용할 수 있습니다. 그러나 일부 특수 옵션 (예 : 높은 프레임 속도)에서는 AVCaptureDevice 인스턴스에 캡처 형식을 직접 설정해야합니다.
        session.sessionPreset = AVCaptureSessionPreset640x480;
        
        //시스템에서 사용 가능한 캡처 장치의 배열을 반환합니다.( 후면카메라, 전면카메라, 아이폰 마이크 ...)
        //position을 front로 변경하면 전면 카메라 사용 가능
        let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        captureDevice = device
        if captureDevice != nil {
            beginSession();
            done = true;
        }
        
        //위의 것과 똑같음. deprecate되서 변경
        //        let devices = AVCaptureDevice.devices()
        
        //        // Loop through all the capture devices on this phone
        //        for device in devices! {
        //            // Make sure this particular device supports video
        //            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
        //                // Finally check the position and confirm we've got the front camera
        //                if((device as AnyObject).position == AVCaptureDevicePosition.front) {
        
        //                    print("captureDevice \(captureDevice)")
        //        if captureDevice != nil {
        //            beginSession();
        //            done = true;
        //            break
        //        }
        
        //                }
        //            }
    }
    
    
    func beginSession(){
        print("♥️♥️♥️♥️ beginSession")
        var err : NSError? = nil
        //AVCaptureDeviceInput은 AVCaptureDevice 개체에서 데이터를 캡처하는 데 사용하는 AVCaptureInput의 구체적인 하위 클래스입니다.
        var deviceInput:AVCaptureDeviceInput?
        do {
            //지정된 장치를 사용하도록 입력을 초기화합니다.
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        };
        if err != nil {
            print("error: \(err?.localizedDescription)");
        }
        //지정된 입력을 세션에 추가 할 수 있는지 여부를 나타내는 부울 값을 반환합니다.
        if self.session.canAddInput(deviceInput){
            //주어진 입력을 세션에 추가합니다.
            self.session.addInput(deviceInput);
        }
        
        //카메라로부터 들어오는 이미지 데이터를 순차적으로 받을 수 있습니다. AVCaptureVideoDataOutput 오브젝트를 만들어서 캡쳐 세션에 추가를 합니다.
        self.videoDataOutput = AVCaptureVideoDataOutput();
        //비디오 프레임이 늦게 도착하면 비디오 프레임을 삭제할지 여부를 나타냅니다.
        self.videoDataOutput.alwaysDiscardsLateVideoFrames=true;
        //스레드 사용하기 위한 큐 생성
        self.videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        //캡처 된 버퍼를 받아들이는 대리자와 대리자가 호출 될 디스패치 큐를 설정합니다.
        self.videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue);
        
        //지정된 출력을 세션에 추가 할 수 있는지 여부를 나타내는 부울 값을 반환합니다.
        if session.canAddOutput(self.videoDataOutput){
            //주어진 입력을 세션에 추가
            session.addOutput(self.videoDataOutput);
        }
        
        //connection : 지정된 배열 유형의 입력 포트로 connections 배열의 첫 번째 연결을 반환합니다.
        self.videoDataOutput.connection(withMediaType: AVMediaTypeVideo).isEnabled = true;
        //session : 미리보기중인 캡처 세션 인스턴스입니다.
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
        //videoGravity: 플레이어 레이어의 범위 내에서 비디오가 표시되는 방법을 나타냅니다.
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        let rootLayer :CALayer = self.previewView.layer;
        rootLayer.masksToBounds=true;
        self.previewLayer.frame = rootLayer.bounds;
        rootLayer.addSublayer(self.previewLayer);
        // startRunning: 입력에서 출력으로의 데이터 플로우를 시작
        session.startRunning();
        
    }
    
    
    
    // 대리자에게 새 비디오 프레임이 작성되었음을 알립니다.
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("♥️ captureOutput")
        currentFrame = self.convertImageFromCMSampleBufferRef(sampleBuffer: sampleBuffer);
    }
    
    // clean up AVCapture
    func stopCamera(){
        print("♥️♥️ stopCamera")
        session.stopRunning()
        done = false;
    }
    
    func convertImageFromCMSampleBufferRef(sampleBuffer:CMSampleBuffer) -> CIImage{
        print("♥️♥️♥️ convertImageFromCMSampleBufferRef")
        let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!;
        let ciImage:CIImage = CIImage(cvPixelBuffer: pixelBuffer)
        return ciImage;
    }
    
    // AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods ends
    
}
