//
//  ViewController.swift
//  ISBN Barcode Scanner
//
//  Created by Alberto Oshiro on 3/1/19.
//  Copyright © 2019 Alberto Oshiro. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var textLabel: UILabel!
    
    var captureSession:AVCaptureSession?
    var inputLayer:AVCaptureVideoPreviewLayer?
    var barCodeFrameView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //try to find back camera
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Camera device was not found")
            return
        }
        
        setUpVideoCapture(captureDevice: captureDevice)
            
        captureSession!.startRunning()
        
        view.bringSubviewToFront(textLabel)
        
        //setting frame view on barcode
        barCodeFrameView = UIView()
        if let barcodeFrameView = barCodeFrameView {
            barcodeFrameView.layer.borderColor = UIColor.blue.cgColor
            barcodeFrameView.layer.borderWidth = 1
            view.addSubview(barcodeFrameView)
            view.bringSubviewToFront(barcodeFrameView)
        }
        
    }
    
    func setUpVideoCapture(captureDevice: AVCaptureDevice) {
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(cameraInput)
            
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //setting the type of metadata we are trying to read
            //ISBN barcodes are of type ean13
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
            
            inputLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            inputLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            inputLayer?.frame = view.layer.bounds
            view.layer.addSublayer(inputLayer!)
            
        } catch {
            print(error)
        }
        
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            textLabel.text = "No barcode is found"
            
        } else {
            
            //found some code
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObject.ObjectType.ean13 {
                
                //found ISBN barcode
                
                let barCodeObject = inputLayer?.transformedMetadataObject(for: metadataObj)
                barCodeFrameView?.frame = barCodeObject!.bounds
                
                if metadataObj.stringValue != nil {
                    textLabel.text = metadataObj.stringValue
                    print(metadataObj.stringValue!)
                }
            }
        }
    }
}

