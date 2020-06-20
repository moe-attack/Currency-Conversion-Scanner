//
//  ScannerViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 14/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//
//  Key idea of the imlementation is to separate the concerns of Video camera capturing set
//  up responsibilities with the concerns of Vision framework set up responsibilities.
//  This allows cleaner code, less bulky controllers (Because Implementing includes Core
//  Graphic library as well, which can be heavy), and makes maintaining code quality easier.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var previewView: PreviewView!

    var maskLayer = CAShapeLayer()
    
    private let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "JunHong.Currency-Conversion-Scanner.CaptureSessionQueue")
    
    var captureDevice: AVCaptureDevice?
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "JunHong.Currency-Conversion-Scanner.VideoDataOutputQueue")
    
    // region of video data output buffer that Vision runs on. Value gets recalculated once screen set up is done.
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    // orientation of text to search for in the region of interest.
    var textOrientation = CGImagePropertyOrientation.right
    
    var bufferAspectRatio: Double!
    // Transform from UI orientation to buffer orientation.
    var uiRotationTransform = CGAffineTransform.identity
    // Transform bottom-left coordinates to top-left.
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    // Transform coordinates in ROI to global coordinates (still normalized).
    var roiToGlobalTransform = CGAffineTransform.identity
    
    // Vision -> AVF coordinate transform.
    var visionToAVFTransform = CGAffineTransform.identity

    // get location
    var currentLocation = UserDefaults.standard.string(forKey: "CurrentLocation") ?? ""
    var currency: CurrencyData?
    var defaultCurrency = UserDefaults.standard.string(forKey: "DefaultCurrency") ?? "AUD"
    let wsm = WebServiceManager()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Scanner"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up preview view
        previewView.session = captureSession
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        switch AVCaptureDevice.authorizationStatus(for: .video) {  // ensure the camera device is accessible before set up.
        case .authorized:
            startSetUpCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.startSetUpCamera()
                }
            }
        case .denied:
            return
        case .restricted:
            return
        @unknown default:
            fatalError("Failure to determine capture device status")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        updateGrayout()
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func startSetUpCamera(){
        // starting the capture session is a blocking call. Perform setup using
        // a dedicated serial dispatch queue to prevent blocking the main thread.
        captureSessionQueue.async {
            self.setupCamera()
            
            DispatchQueue.main.async {
                // recalculate region of interest since camera is set up
                self.calculateRegionOfInterest()
            }
        }
    }
    
    /*
     This method utilize the Core Graphic library to calculate the region of interest by scaling and transforming the affine transformation mattrix from the existing preview
     */
    func calculateRegionOfInterest() {
        let desiredHeightRatio = 0.3  //0.15
        let desiredWidthRatio = 0.6  //0.6
        let maxPortraitWidth = 0.8  //0.8

        // figure out size of ROI. important to have a max portait width to keep region of interest within normalized domain
        let size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)

        // make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size
        
        // ROI changed, update transform.
        // compensate for region of interest.
        let roi = regionOfInterest
        // using CGAffineTransform to scale the object in graphic context
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        
        // compensate for orientation
        uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        
        // full Vision ROI to AVF transform, combining affine transforms.
        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform).concatenating(uiRotationTransform)
    }
    
    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            print("Could not create capture device.")
            return
        }
        self.captureDevice = captureDevice
        // limit the capture session to 1080p to reduce power consumptio
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        bufferAspectRatio = 1920.0 / 1080.0
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Could not create device input.")
            return
        }
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        // configure video data output.
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            // disable stabaliztion to allow drawing bounding box
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            print("Could not add VDO output")
            return
        }
        
        // set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not set zoom level due to error: \(error)")
            return
        }
        
        captureSession.startRunning()
    }
        
    /*
     This function shows the scanned result in a dedicated queue to avoid blocking main thread.
     */
    func showString(string: String) {
        // show the scanned result, to implement
        print("Got a value: \(string)\n")
        captureSessionQueue.sync {
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                self.displayAlert(title: "Scanned Result", value: string)
            }
        }
    }
    
    /*
     This function shows an alert message with an alert action handler
     */
    func displayAlert(title: String, value: String) {
        var currentAbbre = ""
        if currentLocation != "" {
            for each in Constants.allCurrencies.ALL_CURRENCIES {
                if each.country == currentLocation{
                    currentAbbre = each.abbre
                }
            }
        }
        
        let valueDouble: Double = Double(value.replacingOccurrences(of: "$", with: "")) ?? 1.0
        
        if currentAbbre != "" {
            fetchCurrency(abbre: currentAbbre)
            let rate = valueDouble / wsm.getRateFromCurrencyData(currency: self.currency, abbre: defaultCurrency)
            let msg = String(format: "%@ %@ = %@ %@", String(valueDouble) ,defaultCurrency, String(roundUpDouble(number: rate)), currentAbbre).uppercased()
            let messageBody = "If value 'INF' showed up, please try again! m(_ _;m)"
            let alertController = UIAlertController(title: msg, message: messageBody, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss",
                style: UIAlertAction.Style.default,handler: alertCompleteHandler))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func roundUpDouble(number: Double) -> Double{
        return Double(round(1000*number)/1000)
    }
    
    /*
     This function resumes the capture session if it is not already running
     */
    func alertCompleteHandler(action: UIAlertAction){
        captureSessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    func fetchCurrency(abbre: String){
        let url = String(format: Constants.allCurrencies.QUERY_URL, abbre)
        let jsonURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let currencyData = try decoder.decode(RawCurrencyData.self, from: data!)
                if let rates = currencyData.rates {
                    self.currency = rates
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }
}

extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // This is implemented in VisionViewController.
    }
}

