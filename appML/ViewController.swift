//
//  ViewController.swift
//  appML
//
//  Created by Admin on 23/1/2562 BE.
//  Copyright © 2562 Admin. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {
     let captureSession = AVCaptureSession()
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var descLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Camera starting function
        self.startingTheCam()
    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
//
//
//        guard let captureDevice =
//            AVCaptureDevice.default(for: .video) else { return }
//        guard let input = try? AVCaptureDeviceInput(device:
//            captureDevice) else { return }
//        captureSession.addInput(input)
//
//        captureSession.startRunning()
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = view.frame
//
//        let dataOutput = AVCaptureVideoDataOutput()
//        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        captureSession.addOutput(dataOutput)
//
//        //            VNImageRequestHandler(cgImage: , options: [:]).perform(request:)
//    }
//
//    func captureOutput(_ output: AVCaptureOutput, didOutput
//        sampleBufer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        //        print("Camera was able to capture a frame: ", Date())
//
//        guard let pixekBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBufer) else { return }
//        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else { return }
//        let request = VNCoreMLRequest(model: model){
//            (finishedReq, err) in
//            //            print(finishedReq.results)
//            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
//            guard let firstObservation = results.first else { return }
//            print(firstObservation.identifier, firstObservation.confidence)
//        }
//        try? VNImageRequestHandler(cvPixelBuffer: pixekBuffer, options: [:]).perform([request])    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Starting the camera
    func startingTheCam(){
        
        //Set session preset
        captureSession.sessionPreset = .photo
        
        //Capturing Device
        guard let capturingDevice = AVCaptureDevice.default(for: .video) else { return }
        
        //Capture Input
        guard let capturingInput = try? AVCaptureDeviceInput(device: capturingDevice) else { return }
        
        //Adding input to capture session
        captureSession.addInput(capturingInput)
        
        //Data output
        let cameraDataOutput = AVCaptureVideoDataOutput()
        cameraDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "outputVideo"))
        captureSession.addOutput(cameraDataOutput)
        
        //Construct a camera preview layer
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //Set the frame
        cameraPreviewLayer.frame = cameraView.bounds
        
        //Add this preview layer to sublayer of view
        cameraView.layer.addSublayer(cameraPreviewLayer)
        
        //Start the session
        captureSession.startRunning()
        
        
    }
    
    
    
}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //Get pixel buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        //get model
        guard let resNetModel = try? VNCoreMLModel(for: ImageClassifier().model) else { return }
        //Create a coreml request
        let requestCoreML = VNCoreMLRequest(model: resNetModel) { (vnReq, err) in
            //handling error and request
            DispatchQueue.main.async {
                if err == nil{
                    guard let capturedRes = vnReq.results as? [VNClassificationObservation] else { return }
                    guard let firstObserved = capturedRes.first else { return }
                    print(firstObserved.identifier, firstObserved.confidence)
                    self.descLabel.text = String(format: "This may be %.2f%% %@", firstObserved.confidence, firstObserved.identifier)
                }
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestCoreML])
    }
}

